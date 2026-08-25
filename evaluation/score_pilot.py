#!/usr/bin/env python3
"""Conservative exact-match scorer for TurkCuisineBench pilot responses."""

from __future__ import annotations

import argparse
import csv
import json
import re
import unicodedata
from pathlib import Path


SCORER_VERSION = "scorer_tr_v0.1"
FINAL_PUNCTUATION = re.compile(r"[.!?…]+$")
LEADING_LABEL = re.compile(r"^cevap\s*:\s*", re.IGNORECASE)


def turkish_lower(text: str) -> str:
    return text.replace("İ", "i").replace("I", "ı").lower()


def normalize_tr(text: str) -> str:
    value = unicodedata.normalize("NFC", text or "")
    value = value.replace("“", '"').replace("”", '"').replace("’", "'")
    value = value.replace("–", "-").replace("—", "-")
    value = turkish_lower(value.strip())
    value = LEADING_LABEL.sub("", value, count=1)
    value = FINAL_PUNCTUATION.sub("", value.strip())
    return re.sub(r"\s+", " ", value).strip()


def load_items(path: Path) -> dict[str, dict]:
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        return {row["item_id"]: row for row in csv.DictReader(handle)}


def load_jsonl(path: Path) -> list[dict]:
    rows = []
    with path.open("r", encoding="utf-8") as handle:
        for line in handle:
            if line.strip():
                rows.append(json.loads(line))
    return rows


def score(raw_response: str, accepted_answers: str) -> dict:
    normalized = normalize_tr(raw_response)
    accepted = [normalize_tr(x) for x in accepted_answers.split("|") if x.strip()]
    if normalized in accepted:
        return {"auto_label": "CO", "manual_review": "no", "scoring_reason": "exact_accepted_match"}
    if normalized == "bilmiyorum":
        return {"auto_label": "NA", "manual_review": "no", "scoring_reason": "explicit_abstention"}
    return {"auto_label": "REVIEW", "manual_review": "yes", "scoring_reason": "no_exact_registered_match"}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--items", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()

    items = load_items(args.items)
    results = load_jsonl(args.input)
    fields = [
        "run_id", "model_slot", "requested_model_id", "returned_model_id", "item_id",
        "raw_response", "normalized_response", "gold_answer", "accepted_answers",
        "auto_label", "manual_review", "scoring_reason", "final_label", "reviewer_note",
        "scorer_version", "request_id", "started_at_utc", "finished_at_utc", "latency_ms", "status",
    ]
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        for result in results:
            item = items[result["item_id"]]
            raw = result.get("raw_response", "")
            scored = score(raw, item["accepted_answers"]) if result.get("status") == "ok" else {
                "auto_label": "REVIEW", "manual_review": "yes", "scoring_reason": "request_error"
            }
            writer.writerow({
                "run_id": result["run_id"],
                "model_slot": result["model_slot"],
                "requested_model_id": result.get("requested_model_id", ""),
                "returned_model_id": result.get("returned_model_id", ""),
                "item_id": result["item_id"],
                "raw_response": raw,
                "normalized_response": normalize_tr(raw),
                "gold_answer": item["gold_answer"],
                "accepted_answers": item["accepted_answers"],
                **scored,
                "final_label": "",
                "reviewer_note": "",
                "scorer_version": SCORER_VERSION,
                "request_id": result.get("request_id", ""),
                "started_at_utc": result.get("started_at_utc", ""),
                "finished_at_utc": result.get("finished_at_utc", ""),
                "latency_ms": result.get("latency_ms", ""),
                "status": result.get("status", ""),
            })


if __name__ == "__main__":
    main()
