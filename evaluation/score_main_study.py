#!/usr/bin/env python3
"""Apply the frozen Turkish scorer to private main-study responses.

This is an I/O adapter around score_pilot.normalize_tr and score_pilot.score;
it does not alter the prospectively frozen normalization or label rules.
"""

from __future__ import annotations

import argparse
import json
from collections import Counter
from pathlib import Path
from typing import Any

from score_pilot import SCORER_VERSION, normalize_tr, score


def load_jsonl(path: Path) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    with path.open("r", encoding="utf-8") as handle:
        for line_number, line in enumerate(handle, 1):
            if not line.strip():
                continue
            row = json.loads(line)
            if not isinstance(row, dict):
                raise ValueError(f"{path}:{line_number} is not an object")
            rows.append(row)
    return rows


def keyed(rows: list[dict[str, Any]], label: str) -> dict[str, dict[str, Any]]:
    mapping: dict[str, dict[str, Any]] = {}
    for row in rows:
        item_id = str(row.get("item_id", ""))
        if not item_id or item_id in mapping:
            raise ValueError(f"{label} contains a missing or duplicate item_id: {item_id!r}")
        mapping[item_id] = row
    return mapping


def technical_valid(result: dict[str, Any]) -> bool:
    raw = str(result.get("raw_response") or "")
    finish = str(result.get("finish_reason") or "").lower()
    recomputed = (
        result.get("status") == "ok"
        and bool(raw.strip())
        and result.get("incomplete_details") is None
        and finish not in {"length", "max_tokens", "incomplete", "content_filter", "prohibited_content"}
    )
    recorded = result.get("technical_valid") is True
    if recomputed != recorded:
        raise ValueError(f"technical-validity mismatch for {result.get('run_id')}")
    return recorded


def route(result: dict[str, Any], key: dict[str, Any], metadata: dict[str, Any]) -> dict[str, Any]:
    raw = str(result.get("raw_response") or "")
    valid = technical_valid(result)
    accepted = key.get("accepted_answers")
    if not isinstance(accepted, list) or not accepted:
        raise ValueError(f"accepted_answers must be a non-empty list for {result['item_id']}")
    if valid:
        automatic = score(raw, " | ".join(str(x) for x in accepted))
        automatic_label = automatic["auto_label"]
        manual_review = automatic["manual_review"] == "yes"
        scoring_reason = automatic["scoring_reason"]
    else:
        automatic_label = "TECHNICAL_INVALID"
        manual_review = False
        scoring_reason = "technical_invalid_response"
    return {
        "response_id": result["run_id"],
        "run_id": result["run_id"],
        "item_id": result["item_id"],
        "model_slot": result["model_slot"],
        "provider": result["provider"],
        "requested_model_id": result.get("requested_model_id"),
        "returned_model_id": result.get("returned_model_id"),
        "raw_response": raw,
        "normalized_response": normalize_tr(raw),
        "technical_valid": valid,
        "automatic_label": automatic_label,
        "manual_review": manual_review,
        "scoring_reason": scoring_reason,
        "gold_answer": key["gold_answer"],
        "accepted_answers": accepted,
        "source_fact_id": key.get("source_fact_id"),
        "question_tr": metadata["question_tr"],
        "knowledge_domain": metadata["knowledge_domain"],
        "knowledge_specificity": metadata["knowledge_specificity"],
        "lexical_leakage": metadata["lexical_leakage"],
        "answer_form": metadata["answer_form"],
        "numeric_answer": bool(metadata["numeric_answer"]),
        "source_url": metadata["source_url"],
        "source_type": metadata["source_type"],
        "scorer_version": SCORER_VERSION,
        "finish_reason": result.get("finish_reason"),
    }


def write_jsonl(path: Path, rows: list[dict[str, Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="\n") as handle:
        for row in rows:
            handle.write(json.dumps(row, ensure_ascii=False, sort_keys=True) + "\n")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--key", required=True, type=Path)
    parser.add_argument("--metadata", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--review-candidates", required=True, type=Path)
    args = parser.parse_args()

    results = load_jsonl(args.input)
    keys = keyed(load_jsonl(args.key), "private key")
    metadata = keyed(load_jsonl(args.metadata), "metadata")
    if set(keys) != set(metadata):
        raise ValueError("private key and metadata item_id sets differ")
    run_ids = [str(row.get("run_id", "")) for row in results]
    if len(run_ids) != len(set(run_ids)) or any(not value for value in run_ids):
        raise ValueError("response run_id values must be non-empty and unique")
    if any(str(row.get("item_id")) not in keys for row in results):
        raise ValueError("response contains an item_id absent from the frozen key")

    scored = [route(row, keys[str(row["item_id"])], metadata[str(row["item_id"])]) for row in results]
    candidates = [row for row in scored if row["technical_valid"] and row["automatic_label"] == "REVIEW"]
    write_jsonl(args.output, scored)
    write_jsonl(args.review_candidates, candidates)
    labels = Counter(str(row["automatic_label"]) for row in scored)
    print(json.dumps({
        "scorer_version": SCORER_VERSION,
        "records": len(scored),
        "automatic_labels": dict(sorted(labels.items())),
        "manual_review_candidates": len(candidates),
    }, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
