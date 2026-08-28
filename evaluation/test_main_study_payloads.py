#!/usr/bin/env python3
import json
import os
from pathlib import Path

from run_main_study import make_request


root = Path(__file__).resolve().parents[1]
config = json.loads((root / "configs" / "main_study_config.example.json").read_text(encoding="utf-8"))
question = {"item_id": "FX001", "question_tr": "İki artı iki kaçtır?"}
for env_name in {x["api_key_env"] for x in config["models"]}:
    os.environ[env_name] = "TEST-ONLY-NOT-A-REAL-KEY"

payloads = {}
for model in config["models"]:
    _, headers, body = make_request(config, model, question)
    payloads[model["slot"]] = body
    assert all("TEST-ONLY" not in str(value) for value in body.values())
    assert not any(key.lower() in {"tools", "web_search", "grounding"} for key in body)
    assert "Authorization" in headers or "x-api-key" in headers or "x-goog-api-key" in headers

assert payloads["S01"]["reasoning"] == {"effort": "none"}
assert payloads["S02"]["reasoning"] == {"effort": "none"}
assert payloads["S03"]["thinking"] == {"type": "disabled"}
assert "temperature" not in payloads["S03"]
assert payloads["S04"]["thinking"] == {"type": "disabled"}
assert payloads["S04"]["temperature"] == 0
assert payloads["S05"]["generationConfig"]["thinkingConfig"] == {"thinkingLevel": "MINIMAL"}
assert payloads["S06"]["generationConfig"]["thinkingConfig"] == {"thinkingLevel": "MINIMAL"}
assert payloads["S07"]["reasoning_effort"] == "low" and payloads["S07"]["reasoning_format"] == "hidden"
assert payloads["S08"]["reasoning_effort"] == "none" and payloads["S08"]["reasoning_format"] == "hidden"
assert all(body.get("max_tokens", body.get("max_output_tokens", body.get("max_completion_tokens", body.get("generationConfig", {}).get("maxOutputTokens")))) == 128 for body in payloads.values())
print("PASS: provider payloads enforce lowest supported reasoning, hidden reasoning, no tools, and 128-token ceilings")
