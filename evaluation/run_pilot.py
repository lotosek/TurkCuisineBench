#!/usr/bin/env python3
"""Resumable, dependency-free runner for the TurkCuisineBench methods pilot."""

from __future__ import annotations

import argparse
import json
import os
import random
import time
import urllib.error
import urllib.request
from datetime import datetime, timezone
from pathlib import Path


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def load_jsonl(path: Path) -> list[dict]:
    records = []
    with path.open("r", encoding="utf-8") as handle:
        for line in handle:
            if line.strip():
                records.append(json.loads(line))
    return records


def completed_run_ids(path: Path) -> set[str]:
    if not path.exists():
        return set()
    completed = set()
    for record in load_jsonl(path):
        if record.get("status") == "ok":
            completed.add(record["run_id"])
    return completed


def extract_responses_text(payload: dict) -> str:
    parts = []
    for item in payload.get("output", []):
        for content in item.get("content", []):
            if content.get("type") in {"output_text", "text"} and isinstance(content.get("text"), str):
                parts.append(content["text"])
    return "".join(parts)


def request_json(url: str, api_key: str, body: dict, timeout: int = 120) -> tuple[dict, dict]:
    data = json.dumps(body, ensure_ascii=False).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=data,
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
            "User-Agent": "TurkCuisineBench/0.1",
        },
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=timeout) as response:
        headers = dict(response.headers.items())
        return json.loads(response.read().decode("utf-8")), headers


def run_one(model_cfg: dict, request_record: dict, common_cfg: dict) -> dict:
    key_name = model_cfg["api_key_env"]
    api_key = os.environ.get(key_name)
    if not api_key:
        raise RuntimeError(f"Required environment variable is not set: {key_name}")

    base_url = model_cfg["base_url"].rstrip("/")
    provider_type = model_cfg["provider_type"]
    model = model_cfg["model"]
    prompt = request_record["prompt"]
    max_tokens = int(common_cfg.get("max_output_tokens", 256))
    temperature = model_cfg.get("temperature")
    reasoning_effort = model_cfg.get("reasoning_effort")
    reasoning_format = model_cfg.get("reasoning_format")

    if provider_type == "openai_responses":
        url = f"{base_url}/responses"
        body = {
            "model": model,
            "input": prompt,
            "max_output_tokens": max_tokens,
            "store": bool(common_cfg.get("store", False)),
        }
        if temperature is not None:
            body["temperature"] = temperature
        if reasoning_effort is not None:
            body["reasoning"] = {"effort": reasoning_effort}
    elif provider_type == "openai_compatible_chat":
        url = f"{base_url}/chat/completions"
        body = {
            "model": model,
            "messages": [{"role": "user", "content": prompt}],
            "max_completion_tokens": max_tokens,
        }
        if temperature is not None:
            body["temperature"] = temperature
        if reasoning_effort is not None:
            body["reasoning_effort"] = reasoning_effort
        if reasoning_format is not None:
            body["reasoning_format"] = reasoning_format
    else:
        raise ValueError(f"Unsupported provider_type: {provider_type}")

    started = time.perf_counter()
    payload, headers = request_json(url, api_key, body)
    latency_ms = round((time.perf_counter() - started) * 1000)

    if provider_type == "openai_responses":
        raw_text = extract_responses_text(payload)
        response_status = payload.get("status")
        incomplete_details = payload.get("incomplete_details")
        finish_reason = None
    else:
        raw_text = payload["choices"][0]["message"]["content"]
        response_status = "completed"
        incomplete_details = None
        finish_reason = payload["choices"][0].get("finish_reason")

    usage = payload.get("usage") or {}
    output_details = usage.get("output_tokens_details") or {}
    completion_details = usage.get("completion_tokens_details") or {}

    return {
        "status": "ok",
        "requested_model_id": model,
        "returned_model_id": payload.get("model"),
        "provider_type": provider_type,
        "request_id": payload.get("id") or headers.get("x-request-id"),
        "latency_ms": latency_ms,
        "raw_response": raw_text,
        "response_status": response_status,
        "finish_reason": finish_reason,
        "incomplete_details": incomplete_details,
        "usage": {
            "input_tokens": usage.get("input_tokens", usage.get("prompt_tokens")),
            "output_tokens": usage.get("output_tokens", usage.get("completion_tokens")),
            "total_tokens": usage.get("total_tokens"),
            "reasoning_tokens": output_details.get(
                "reasoning_tokens", completion_details.get("reasoning_tokens")
            ),
        },
        "request_settings": {
            "max_output_tokens": max_tokens,
            "temperature": temperature,
            "reasoning_effort": reasoning_effort,
            "reasoning_format": reasoning_format,
            "store": bool(common_cfg.get("store", False)),
            "tools": "off",
            "stateless": True,
        },
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", required=True, type=Path)
    parser.add_argument("--requests", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--retries", type=int, default=3)
    args = parser.parse_args()

    config = json.loads(args.config.read_text(encoding="utf-8"))
    requests = load_jsonl(args.requests)
    completed = completed_run_ids(args.output)
    args.output.parent.mkdir(parents=True, exist_ok=True)

    with args.output.open("a", encoding="utf-8", newline="\n") as handle:
        for req in requests:
            if req["run_id"] in completed:
                continue
            model_cfg = config["models"][req["model_slot"]]
            if not model_cfg.get("enabled", False):
                continue

            started_at = utc_now()
            result = None
            for attempt in range(1, args.retries + 1):
                try:
                    result = run_one(model_cfg, req, config)
                    break
                except (urllib.error.URLError, urllib.error.HTTPError, TimeoutError, RuntimeError, ValueError) as exc:
                    result = {
                        "status": "error",
                        "error_type": type(exc).__name__,
                        "error_message": str(exc),
                        "attempt": attempt,
                    }
                    if attempt < args.retries:
                        time.sleep(min(20, (2 ** (attempt - 1)) + random.random()))

            record = {
                **req,
                "run_protocol_version": config.get("run_protocol_version"),
                "prompt_version": config.get("prompt_version"),
                "scorer_version": config.get("scorer_version"),
                "started_at_utc": started_at,
                "finished_at_utc": utc_now(),
                **result,
            }
            handle.write(json.dumps(record, ensure_ascii=False) + "\n")
            handle.flush()
            os.fsync(handle.fileno())


if __name__ == "__main__":
    main()
