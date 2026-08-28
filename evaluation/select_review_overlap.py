#!/usr/bin/env python3
"""Select the frozen 25% blinded manual-review overlap deterministically.

The selector operates only after automatic routing and before reviewers inspect
non-exact responses. It balances the primary model-slot x domain strata using
Hamilton allocation, then greedily balances registered secondary margins.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import os
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any


REQUIRED = {
    "response_id", "item_id", "model_slot", "knowledge_domain",
    "knowledge_specificity", "lexical_leakage", "answer_form",
    "numeric_answer", "automatic_label", "technical_valid",
}
FORBIDDEN_OUTPUT = {"provider", "model", "model_id", "requested_model", "returned_model"}
SECONDARY = ("knowledge_specificity", "lexical_leakage", "answer_form", "numeric_answer")


def load_jsonl(file: Path) -> list[dict[str, Any]]:
    rows = []
    with file.open("r", encoding="utf-8") as handle:
        for line_no, line in enumerate(handle, 1):
            if not line.strip():
                continue
            row = json.loads(line)
            if not isinstance(row, dict):
                raise ValueError(f"{file}:{line_no} is not an object")
            missing = REQUIRED - row.keys()
            if missing:
                raise ValueError(f"{file}:{line_no} missing fields: {sorted(missing)}")
            rows.append(row)
    return rows


def truthy(value: Any) -> bool:
    return value is True or value == 1 or str(value).strip().lower() == "true"


def digest(seed: int, *parts: Any) -> str:
    payload = ":".join([str(seed), *(str(x) for x in parts)])
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()


def blind_codes(slots: list[str], blind_salt: str) -> dict[str, str]:
    if len(blind_salt) < 16:
        raise ValueError("blinding salt must contain at least 16 characters")
    ordered = sorted(slots, key=lambda x: hashlib.sha256(f"{blind_salt}:{x}".encode("utf-8")).hexdigest())
    return {slot: f"M{index:02d}" for index, slot in enumerate(ordered, 1)}


def allocate(groups: dict[tuple[str, str], list[dict[str, Any]]], target: int, fraction: float, seed: int) -> dict[tuple[str, str], int]:
    allocation = {key: math.floor(len(rows) * fraction) for key, rows in groups.items()}
    remaining = target - sum(allocation.values())
    ranking = sorted(
        groups,
        key=lambda key: (-(len(groups[key]) * fraction - allocation[key]), digest(seed, "allocation", *key)),
    )
    for key in ranking[:remaining]:
        allocation[key] += 1
    return allocation


def balanced_pick(rows: list[dict[str, Any]], count: int, seed: int, stratum: tuple[str, str]) -> list[dict[str, Any]]:
    if count <= 0:
        return []
    totals = {field: Counter(str(row[field]) for row in rows) for field in SECONDARY}
    desired = {field: {level: count * n / len(rows) for level, n in counts.items()} for field, counts in totals.items()}
    selected: list[dict[str, Any]] = []
    selected_counts = {field: Counter() for field in SECONDARY}
    remaining = list(rows)
    while len(selected) < count:
        scored = []
        for row in remaining:
            score = 0.0
            for field in SECONDARY:
                for level, want in desired[field].items():
                    observed = selected_counts[field][level] + (1 if str(row[field]) == level else 0)
                    score += ((observed - want) ** 2) / max(want, 0.5)
            scored.append((score, digest(seed, "within", *stratum, row["response_id"]), row))
        _, _, chosen = min(scored, key=lambda x: (x[0], x[1]))
        selected.append(chosen)
        remaining.remove(chosen)
        for field in SECONDARY:
            selected_counts[field][str(chosen[field])] += 1
    return selected


def select(rows: list[dict[str, Any]], seed: int, blind_salt: str, fraction: float = 0.25) -> tuple[list[dict[str, Any]], dict[str, str], dict[str, Any]]:
    if not 0 < fraction <= 1:
        raise ValueError("fraction must be in (0, 1]")
    ids = [str(row["response_id"]) for row in rows]
    if len(ids) != len(set(ids)):
        raise ValueError("response_id values must be unique")
    candidates = [row for row in rows if truthy(row["technical_valid"]) and str(row["automatic_label"]).upper() == "REVIEW"]
    if not candidates:
        raise ValueError("no technically valid REVIEW candidates")
    groups: dict[tuple[str, str], list[dict[str, Any]]] = defaultdict(list)
    for row in candidates:
        groups[(str(row["model_slot"]), str(row["knowledge_domain"]))].append(row)
    target = math.ceil(len(candidates) * fraction)
    allocations = allocate(groups, target, fraction, seed)
    chosen = []
    for key in sorted(groups):
        chosen.extend(balanced_pick(groups[key], allocations[key], seed, key))
    chosen.sort(key=lambda row: digest(seed, "output", row["response_id"]))
    mapping = blind_codes(sorted({str(row["model_slot"]) for row in rows}), blind_salt)
    output = []
    for index, row in enumerate(chosen, 1):
        record = {
            "overlap_id": f"OV{index:04d}",
            "response_id": str(row["response_id"]),
            "item_id": str(row["item_id"]),
            "blind_model_code": mapping[str(row["model_slot"])],
            "knowledge_domain": row["knowledge_domain"],
            "knowledge_specificity": row["knowledge_specificity"],
            "lexical_leakage": row["lexical_leakage"],
            "answer_form": row["answer_form"],
            "numeric_answer": row["numeric_answer"],
            "selection_seed": seed,
        }
        if FORBIDDEN_OUTPUT.intersection(record):
            raise AssertionError("identity field leaked into reviewer overlap output")
        output.append(record)
    audit = {
        "seed": seed,
        "fraction": fraction,
        "manual_review_candidates": len(candidates),
        "selected": len(output),
        "target": target,
        "primary_strata": {
            f"{key[0]} | {key[1]}": {"eligible": len(groups[key]), "selected": allocations[key]}
            for key in sorted(groups)
        },
        "algorithm": "Hamilton allocation across model_slot x knowledge_domain; deterministic greedy balance across specificity, leakage, answer form, and numeric status",
    }
    return output, mapping, audit


def write_jsonl(file: Path, rows: list[dict[str, Any]]) -> None:
    file.parent.mkdir(parents=True, exist_ok=True)
    with file.open("w", encoding="utf-8", newline="\n") as handle:
        for row in rows:
            handle.write(json.dumps(row, ensure_ascii=False, sort_keys=True) + "\n")


def sha256_file(file: Path) -> str:
    return hashlib.sha256(file.read_bytes()).hexdigest().upper()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--responses", required=True, type=Path)
    parser.add_argument("--overlap-output", required=True, type=Path)
    parser.add_argument("--mapping-output", required=True, type=Path)
    parser.add_argument("--audit-output", required=True, type=Path)
    parser.add_argument("--seed", type=int, default=20260828)
    parser.add_argument("--fraction", type=float, default=0.25)
    parser.add_argument("--blind-salt-env", default="TURKCUISINE_BLINDING_SALT")
    args = parser.parse_args()
    blind_salt = os.environ.get(args.blind_salt_env, "")
    if not blind_salt:
        raise RuntimeError(f"private blinding salt is not set in environment variable: {args.blind_salt_env}")
    overlap, mapping, audit = select(load_jsonl(args.responses), args.seed, blind_salt, args.fraction)
    write_jsonl(args.overlap_output, overlap)
    args.mapping_output.parent.mkdir(parents=True, exist_ok=True)
    args.mapping_output.write_text(json.dumps(mapping, ensure_ascii=False, sort_keys=True, indent=2) + "\n", encoding="utf-8")
    audit["output_sha256"] = {
        args.overlap_output.name: sha256_file(args.overlap_output),
        args.mapping_output.name: sha256_file(args.mapping_output),
    }
    args.audit_output.parent.mkdir(parents=True, exist_ok=True)
    args.audit_output.write_text(json.dumps(audit, ensure_ascii=False, sort_keys=True, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(audit, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
