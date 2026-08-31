#!/usr/bin/env python3
import json
from pathlib import Path

from estimate_main_study_cost import calculate


root = Path(__file__).resolve().parents[1]
config = json.loads((root / "configs" / "main_study_costs_2026-08-31.json").read_text(encoding="utf-8"))
result = calculate(config)
assert len(result["slots"]) == 8
assert result["conservative_price_max_usd"] == "3.243110"
assert result["with_contingency_usd"] == "4.864666"
assert result["registered_cost_ceiling_usd"] == "5"
assert result["verified_date"] == "2026-08-31"
assert all(float(row["conservative_max_usd"]) >= float(row["current_max_usd"]) for row in result["slots"])
print("PASS: conservative three-attempt cost envelope and USD 5 ceiling")
