#!/usr/bin/env python3
"""Provider-neutral, resumable runner for the private TurkCuisineBench Test.

The runner refuses network execution unless the private configuration explicitly
sets execution_authorized=true. A dry run validates the panel, question-only
schema, prompt construction, ordering, and private-output boundary without
calling any model endpoint.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import random
import time
import urllib.error
import urllib.request
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


FORBIDDEN_QUESTION_FIELDS = {
    "gold_answer",
    "accepted_answers",
    "source_url",
    "source_fact_id",
    "error_label",
    "item_status",
}


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def canonical_json(value: Any) -> bytes:
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8")


def sha256_json(value: Any) -> str:
    return hashlib.sha256(canonical_json(value)).hexdigest()


def load_jsonl(path: Path) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    with path.open("r", encoding="utf-8") as handle:
        for line_number, line in enumerate(handle, 1):
            if not line.strip():
                continue
            value = json.loads(line)
            if not isinstance(value, dict):
                raise ValueError(f"{path}:{line_number} is not a JSON object")
            records.append(value)
    return records


def validate_inputs(config: dict[str, Any], questions: list[dict[str, Any]], dry_run: bool) -> None:
    models = config.get("models")
    if not isinstance(models, list) or len(models) != 8:
        raise ValueError("The main-study panel must contain exactly eight model slots")
    slots = [str(m.get("slot", "")) for m in models]
    if len(set(slots)) != 8 or any(not slot for slot in slots):
        raise ValueError("Model slots must be eight non-empty unique values")
    providers = {m.get("provider") for m in models}
    if len(providers) < 3:
        raise ValueError("The model panel must contain at least three inference providers")
    if sum(bool(m.get("open_weight")) for m in models) < 2:
        raise ValueError("The model panel must contain at least two open-weight slots")
    if not dry_run and not config.get("execution_authorized", False):
        raise RuntimeError("Gate M4 is closed: execution_authorized is not true")
    if not questions:
        raise ValueError("Question-only input is empty")
    if not dry_run and len(questions) != 72:
        raise ValueError(f"Expected 72 frozen Test questions, found {len(questions)}")
    item_ids: list[str] = []
    for index, row in enumerate(questions, 1):
        forbidden = FORBIDDEN_QUESTION_FIELDS.intersection(row)
        if forbidden:
            raise ValueError(f"Question row {index} exposes forbidden fields: {sorted(forbidden)}")
        if set(row) - {"item_id", "question_tr"}:
            raise ValueError(f"Question row {index} contains non-execution fields: {sorted(set(row) - {'item_id', 'question_tr'})}")
        if not str(row.get("item_id", "")).strip() or not str(row.get("question_tr", "")).strip():
            raise ValueError(f"Question row {index} lacks item_id or question_tr")
        item_ids.append(str(row["item_id"]))
    if len(set(item_ids)) != len(item_ids):
        raise ValueError("Question-only input contains duplicate item_id values")


def deterministic_schedule(config: dict[str, Any], questions: list[dict[str, Any]]) -> list[tuple[dict[str, Any], dict[str, Any]]]:
    seed = int(config["random_seed"])
    models = sorted(config["models"], key=lambda x: x["slot"])
    per_slot: dict[str, list[dict[str, Any]]] = {}
    for model in models:
        digest = hashlib.sha256(f"{seed}:{model['slot']}".encode("utf-8")).digest()
        rng = random.Random(int.from_bytes(digest[:8], "big"))
        ordered = list(questions)
        rng.shuffle(ordered)
        per_slot[model["slot"]] = ordered
    schedule: list[tuple[dict[str, Any], dict[str, Any]]] = []
    for position in range(len(questions)):
        rotation = position % len(models)
        for offset in range(len(models)):
            model = models[(rotation + offset) % len(models)]
            schedule.append((model, per_slot[model["slot"]][position]))
    return schedule


def prompt_messages(config: dict[str, Any], question: dict[str, Any]) -> tuple[str, str]:
    system = str(config["system_prompt"])
    user = str(config["user_template"]).replace("{{question_tr}}", str(question["question_tr"]))
    return system, user


def make_request(config: dict[str, Any], model: dict[str, Any], question: dict[str, Any]) -> tuple[str, dict[str, str], dict[str, Any]]:
    provider = model["provider"]
    system, user = prompt_messages(config, question)
    maximum = int(config["max_completion_tokens"])
    key_name = model["api_key_env"]
    api_key = os.environ.get(key_name)
    if not api_key:
        raise RuntimeError(f"Required environment variable is not set: {key_name}")

    if provider == "openai":
        url = "https://api.openai.com/v1/responses"
        headers = {"Authorization": f"Bearer {api_key}"}
        body: dict[str, Any] = {
            "model": model["model"],
            "instructions": system,
            "input": user,
            "max_output_tokens": maximum,
            "store": False,
        }
        if model.get("reasoning_effort") is not None:
            body["reasoning"] = {"effort": model["reasoning_effort"]}
    elif provider == "groq":
        url = "https://api.groq.com/openai/v1/chat/completions"
        headers = {"Authorization": f"Bearer {api_key}"}
        body = {
            "model": model["model"],
            "messages": [{"role": "system", "content": system}, {"role": "user", "content": user}],
            "max_completion_tokens": maximum,
        }
        if model.get("temperature") is not None:
            body["temperature"] = model["temperature"]
        if model.get("reasoning_effort") is not None:
            body["reasoning_effort"] = model["reasoning_effort"]
    elif provider == "anthropic":
        url = "https://api.anthropic.com/v1/messages"
        headers = {"x-api-key": api_key, "anthropic-version": "2023-06-01"}
        body = {
            "model": model["model"],
            "system": system,
            "messages": [{"role": "user", "content": user}],
            "max_tokens": maximum,
        }
        if model.get("temperature") is not None:
            body["temperature"] = model["temperature"]
    elif provider == "google":
        url = f"https://generativelanguage.googleapis.com/v1beta/models/{model['model']}:generateContent"
        headers = {"x-goog-api-key": api_key}
        generation: dict[str, Any] = {"maxOutputTokens": maximum}
        if model.get("temperature") is not None:
            generation["temperature"] = model["temperature"]
        if model.get("thinking_level") is not None:
            generation["thinkingConfig"] = {"thinkingLevel": str(model["thinking_level"]).upper()}
        body = {
            "systemInstruction": {"parts": [{"text": system}]},
            "contents": [{"role": "user", "parts": [{"text": user}]}],
            "generationConfig": generation,
        }
    else:
        raise ValueError(f"Unsupported provider: {provider}")
    headers["Content-Type"] = "application/json"
    headers["User-Agent"] = "TurkCuisineBench-main-study/0.1"
    return url, headers, body


def post_json(url: str, headers: dict[str, str], body: dict[str, Any], timeout: int = 180) -> tuple[dict[str, Any], dict[str, str]]:
    request = urllib.request.Request(url, data=canonical_json(body), headers=headers, method="POST")
    with urllib.request.urlopen(request, timeout=timeout) as response:
        return json.loads(response.read().decode("utf-8")), dict(response.headers.items())


def extract_result(provider: str, payload: dict[str, Any], headers: dict[str, str]) -> dict[str, Any]:
    if provider == "openai":
        parts = [
            content.get("text", "")
            for item in payload.get("output", [])
            for content in item.get("content", [])
            if content.get("type") in {"output_text", "text"}
        ]
        usage = payload.get("usage") or {}
        text = "".join(parts)
        finish = payload.get("status")
        incomplete = payload.get("incomplete_details")
        request_id = payload.get("id") or headers.get("x-request-id")
    elif provider == "groq":
        choice = payload.get("choices", [{}])[0]
        text = (choice.get("message") or {}).get("content") or ""
        finish = choice.get("finish_reason")
        incomplete = None
        usage = payload.get("usage") or {}
        request_id = payload.get("id") or headers.get("x-request-id")
    elif provider == "anthropic":
        text = "".join(x.get("text", "") for x in payload.get("content", []) if x.get("type") == "text")
        finish = payload.get("stop_reason")
        incomplete = None
        usage = payload.get("usage") or {}
        request_id = payload.get("id") or headers.get("request-id")
    else:
        candidate = payload.get("candidates", [{}])[0]
        text = "".join(x.get("text", "") for x in ((candidate.get("content") or {}).get("parts") or []))
        finish = candidate.get("finishReason")
        incomplete = None
        usage = payload.get("usageMetadata") or {}
        request_id = headers.get("x-request-id") or headers.get("x-goog-request-id")
    technically_valid = bool(text.strip()) and incomplete is None and str(finish).lower() not in {"length", "max_tokens", "incomplete"}
    return {
        "raw_response": text,
        "finish_reason": finish,
        "incomplete_details": incomplete,
        "usage": usage,
        "request_id": request_id,
        "technical_valid": technically_valid,
    }


def completed_run_ids(path: Path) -> set[str]:
    if not path.exists():
        return set()
    return {x["run_id"] for x in load_jsonl(path) if x.get("status") == "ok"}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", required=True, type=Path)
    parser.add_argument("--questions", required=True, type=Path)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    config = json.loads(args.config.read_text(encoding="utf-8"))
    questions = load_jsonl(args.questions)
    validate_inputs(config, questions, args.dry_run)
    schedule = deterministic_schedule(config, questions)
    schedule_hash = hashlib.sha256(canonical_json([(m["slot"], q["item_id"]) for m, q in schedule])).hexdigest()

    if args.dry_run:
        preview = []
        for model, question in schedule[: min(8, len(schedule))]:
            system, user = prompt_messages(config, question)
            preview.append({"slot": model["slot"], "item_id": question["item_id"], "prompt_sha256": sha256_json({"system": system, "user": user})})
        print(json.dumps({"status": "dry_run_pass", "questions": len(questions), "requests": len(schedule), "providers": sorted({m["provider"] for m in config["models"]}), "schedule_sha256": schedule_hash, "preview": preview}, ensure_ascii=False, indent=2))
        return

    if args.output is None:
        raise ValueError("--output is required for authorized execution")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    completed = completed_run_ids(args.output)
    retry_max = int(config.get("retry_policy", {}).get("maximum_technical_retries", 2))

    with args.output.open("a", encoding="utf-8", newline="\n") as handle:
        for model, question in schedule:
            run_id = f"{model['slot']}:{question['item_id']}"
            if run_id in completed:
                continue
            url, headers, body = make_request(config, model, question)
            started_at = utc_now()
            result: dict[str, Any] = {}
            payload: dict[str, Any] | None = None
            response_headers: dict[str, str] = {}
            for attempt in range(retry_max + 1):
                started = time.perf_counter()
                try:
                    payload, response_headers = post_json(url, headers, body)
                    result = {"status": "ok", "attempt": attempt + 1, "latency_ms": round((time.perf_counter() - started) * 1000)}
                    break
                except urllib.error.HTTPError as error:
                    retryable = error.code in {408, 409, 429} or error.code >= 500
                    result = {"status": "error", "attempt": attempt + 1, "http_status": error.code, "retryable": retryable, "error_type": type(error).__name__}
                    if not retryable or attempt >= retry_max:
                        break
                    time.sleep(min(20, 2 ** attempt))
                except (urllib.error.URLError, TimeoutError) as error:
                    result = {"status": "error", "attempt": attempt + 1, "retryable": True, "error_type": type(error).__name__, "error_message": str(error)}
                    if attempt >= retry_max:
                        break
                    time.sleep(min(20, 2 ** attempt))

            record: dict[str, Any] = {
                "run_id": run_id,
                "item_id": question["item_id"],
                "model_slot": model["slot"],
                "provider": model["provider"],
                "requested_model_id": model["model"],
                "started_at_utc": started_at,
                "finished_at_utc": utc_now(),
                "schedule_sha256": schedule_hash,
                "request_payload_sha256": sha256_json(body),
                **result,
            }
            if payload is not None:
                extracted = extract_result(model["provider"], payload, response_headers)
                returned = payload.get("model") or payload.get("modelVersion")
                record.update(extracted)
                record["returned_model_id"] = returned
                record["raw_payload_sha256"] = sha256_json(payload)
                if returned and returned != model["model"]:
                    record["model_id_drift"] = True
            handle.write(json.dumps(record, ensure_ascii=False) + "\n")
            handle.flush()
            os.fsync(handle.fileno())
            if record.get("model_id_drift"):
                raise RuntimeError(f"Returned model ID drift at {run_id}; execution stopped")


if __name__ == "__main__":
    main()
