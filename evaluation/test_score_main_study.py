#!/usr/bin/env python3
from score_main_study import route


metadata = {
    "question_tr": "İki artı iki kaçtır?",
    "knowledge_domain": "KX",
    "knowledge_specificity": "General",
    "lexical_leakage": "L0",
    "answer_form": "single_word",
    "numeric_answer": True,
    "source_url": "https://example.invalid/source",
    "source_type": "synthetic",
}
key = {"gold_answer": "Dört", "accepted_answers": ["dört", "4"], "source_fact_id": "FX001"}
base = {
    "run_id": "S01:FX001",
    "item_id": "FX001",
    "model_slot": "S01",
    "provider": "synthetic",
    "requested_model_id": "synthetic-model",
    "returned_model_id": "synthetic-model",
    "status": "ok",
    "incomplete_details": None,
}

exact = route({**base, "raw_response": "DÖRT.", "finish_reason": "stop", "technical_valid": True}, key, metadata)
assert exact["automatic_label"] == "CO" and exact["manual_review"] is False

abstain = route({**base, "raw_response": "BİLMİYORUM", "finish_reason": "stop", "technical_valid": True}, key, metadata)
assert abstain["automatic_label"] == "NA" and abstain["manual_review"] is False

review = route({**base, "raw_response": "4 sayısı", "finish_reason": "stop", "technical_valid": True}, key, metadata)
assert review["automatic_label"] == "REVIEW" and review["manual_review"] is True

invalid = route({**base, "raw_response": "", "finish_reason": "PROHIBITED_CONTENT", "technical_valid": False}, key, metadata)
assert invalid["automatic_label"] == "TECHNICAL_INVALID" and invalid["manual_review"] is False

print("PASS: main-study adapter preserves frozen CO/NA/REVIEW rules and isolates technical invalids")
