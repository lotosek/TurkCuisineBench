#!/usr/bin/env python3
from pathlib import Path
from tempfile import TemporaryDirectory

from select_review_overlap import FORBIDDEN_OUTPUT, select, sha256_file, write_jsonl


def fixtures():
    rows = []
    for model in range(1, 9):
        for domain in range(1, 7):
            for item in range(1, 5):
                rows.append({
                    "response_id": f"R-{model}-{domain}-{item}",
                    "item_id": f"FX{domain:02d}{item:02d}",
                    "model_slot": f"S{model:02d}",
                    "knowledge_domain": f"K{domain}",
                    "knowledge_specificity": "local" if item % 2 else "regional",
                    "lexical_leakage": "L1" if item == 4 else "L0",
                    "answer_form": "numeric" if item == 3 else "short_text",
                    "numeric_answer": item == 3,
                    "automatic_label": "REVIEW",
                    "technical_valid": True,
                })
    return rows


rows = fixtures()
a, map_a, audit_a = select(rows, 20260828, "TEST-ONLY-BLINDING-SALT")
b, map_b, audit_b = select(rows, 20260828, "TEST-ONLY-BLINDING-SALT")
assert a == b and map_a == map_b and audit_a == audit_b
assert len(a) == 48 == audit_a["target"]
assert all(cell["eligible"] == 4 and cell["selected"] == 1 for cell in audit_a["primary_strata"].values())
assert len({x["response_id"] for x in a}) == len(a)
assert all(not FORBIDDEN_OUTPUT.intersection(x) for x in a)
assert len(set(map_a.values())) == 8
assert all(v.startswith("M") for v in map_a.values())
assert map_a != select(rows, 20260828, "DIFFERENT-PRIVATE-SALT")[1]
assert all(x["selection_seed"] == 20260828 for x in a)
with TemporaryDirectory() as temp_dir:
    test_output = Path(temp_dir) / "overlap.jsonl"
    write_jsonl(test_output, a)
    assert len(sha256_file(test_output)) == 64
print("PASS: deterministic 25% overlap selection, balanced primary strata, and blinded output")
