#!/usr/bin/env python3
"""Calculate the registered conservative main-study API cost envelope."""

from __future__ import annotations

import argparse
import json
from decimal import Decimal, ROUND_HALF_UP
from pathlib import Path


MILLION = Decimal("1000000")


def d(value):
    return Decimal(str(value))


def calculate(config):
    models = config["models"]
    if len(models) != 8 or len({x["slot"] for x in models}) != 8:
        raise ValueError("cost configuration must contain eight unique slots")
    items = d(config["items_per_slot"])
    attempts = d(config["maximum_attempts_per_item"])
    input_tokens = d(config["ceiling_input_tokens_per_attempt"])
    output_tokens = d(config["ceiling_output_tokens_per_attempt"])
    rows = []
    current_values = []
    ceiling_values = []
    for model in models:
        current = items * attempts * (
            input_tokens * d(model["current_input_per_mtok"]) / MILLION
            + output_tokens * d(model["current_output_per_mtok"]) / MILLION
        )
        ceiling = items * attempts * (
            input_tokens * d(model["ceiling_input_per_mtok"]) / MILLION
            + output_tokens * d(model["ceiling_output_per_mtok"]) / MILLION
        )
        current_values.append(current)
        ceiling_values.append(ceiling)
        rows.append({
            "slot": model["slot"],
            "model": model["model"],
            "current_max_usd": str(current.quantize(Decimal("0.000001"), rounding=ROUND_HALF_UP)),
            "conservative_max_usd": str(ceiling.quantize(Decimal("0.000001"), rounding=ROUND_HALF_UP)),
        })
    current_total = sum(current_values, Decimal("0"))
    conservative_total = sum(ceiling_values, Decimal("0"))
    contingency = conservative_total * d(config["contingency_multiplier"])
    registered_ceiling = contingency.quantize(Decimal("1"), rounding=ROUND_HALF_UP)
    if registered_ceiling < contingency:
        registered_ceiling += 1
    return {
        "verified_date": config["verified_date"],
        "currency": config["currency"],
        "assumptions": {
            "items_per_slot": int(items),
            "maximum_attempts_per_item": int(attempts),
            "ceiling_input_tokens_per_attempt": int(input_tokens),
            "ceiling_output_tokens_per_attempt": int(output_tokens),
            "contingency_multiplier": str(d(config["contingency_multiplier"])),
        },
        "slots": rows,
        "current_price_max_usd": str(current_total.quantize(Decimal("0.000001"), rounding=ROUND_HALF_UP)),
        "conservative_price_max_usd": str(conservative_total.quantize(Decimal("0.000001"), rounding=ROUND_HALF_UP)),
        "with_contingency_usd": str(contingency.quantize(Decimal("0.000001"), rounding=ROUND_HALF_UP)),
        "registered_cost_ceiling_usd": str(registered_ceiling),
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--cost-config", required=True, type=Path)
    args = parser.parse_args()
    config = json.loads(args.cost_config.read_text(encoding="utf-8"))
    print(json.dumps(calculate(config), ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
