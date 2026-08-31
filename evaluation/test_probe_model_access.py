#!/usr/bin/env python3
from probe_model_access import PROBE_QUESTION, sanitized_record, select_models


config = {
    "models": [
        {"slot": "S02", "provider": "google", "model": "g-model", "api_key_env": "GEMINI_API_KEY"},
        {"slot": "S01", "provider": "anthropic", "model": "a-model", "api_key_env": "ANTHROPIC_API_KEY"},
    ]
}

assert PROBE_QUESTION == {"item_id": "ACCESS_PROBE", "question_tr": "Return exactly OK."}
selected = select_models(config, {"google", "anthropic"})
assert [model["slot"] for model in selected] == ["S01", "S02"]
assert [model["slot"] for model in select_models(config, {"google"}, {"S02"})] == ["S02"]

anthropic_payload = {
    "id": "msg_test",
    "model": "a-model",
    "stop_reason": "end_turn",
    "content": [{"type": "text", "text": "OK"}],
    "usage": {"input_tokens": 1, "output_tokens": 1},
}
record = sanitized_record(selected[0], anthropic_payload, {})
assert record["response_text"] == "OK"
assert record["technical_valid"] is True
assert record["model_id_drift"] is False
assert "api_key" not in str(record).lower()
print("PASS: access probe selection and sanitized output")
