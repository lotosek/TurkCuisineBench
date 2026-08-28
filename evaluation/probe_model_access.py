#!/usr/bin/env python3
"""Run explicit, neutral access probes without exposing benchmark content.

Network access is opt-in. The probe sends only ``Return exactly OK.`` and writes
sanitized results that contain no credentials or request payload bodies.
"""

from __future__ import annotations

import argparse
import json
import os
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from run_main_study import extract_result, make_request, post_json


PROBE_QUESTION = {"item_id": "ACCESS_PROBE", "question_tr": "Return exactly OK."}


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def select_models(config: dict[str, Any], providers: set[str]) -> list[dict[str, Any]]:
    models = [model for model in config["models"] if model["provider"] in providers]
    if not models:
        raise ValueError(f"No configured models match providers: {sorted(providers)}")
    return sorted(models, key=lambda model: model["slot"])


def sanitized_record(model: dict[str, Any], payload: dict[str, Any], headers: dict[str, str]) -> dict[str, Any]:
    extracted = extract_result(model["provider"], payload, headers)
    returned = payload.get("model") or payload.get("modelVersion")
    return {
        "timestamp_utc": utc_now(),
        "slot": model["slot"],
        "provider": model["provider"],
        "requested_model_id": model["model"],
        "returned_model_id": returned,
        "response_text": extracted["raw_response"].strip(),
        "finish_reason": extracted["finish_reason"],
        "technical_valid": extracted["technical_valid"],
        "model_id_drift": bool(returned and returned != model["model"]),
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", required=True, type=Path)
    parser.add_argument("--providers", nargs="+", required=True, choices=["openai", "anthropic", "google", "groq"])
    parser.add_argument("--output", type=Path)
    parser.add_argument("--authorize-network-probe", action="store_true")
    args = parser.parse_args()

    if not args.authorize_network_probe:
        raise RuntimeError("Neutral network probe not authorized; pass --authorize-network-probe explicitly")

    config = json.loads(args.config.read_text(encoding="utf-8"))
    models = select_models(config, set(args.providers))
    missing = sorted({model["api_key_env"] for model in models if not os.environ.get(model["api_key_env"])})
    if missing:
        raise RuntimeError(f"Missing required environment variables: {', '.join(missing)}")

    records = []
    for model in models:
        url, headers, body = make_request(config, model, PROBE_QUESTION)
        payload, response_headers = post_json(url, headers, body)
        records.append(sanitized_record(model, payload, response_headers))

    result = {"probe_text": PROBE_QUESTION["question_tr"], "records": records}
    rendered = json.dumps(result, ensure_ascii=False, indent=2)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(rendered + "\n", encoding="utf-8")
    print(rendered)


if __name__ == "__main__":
    main()
