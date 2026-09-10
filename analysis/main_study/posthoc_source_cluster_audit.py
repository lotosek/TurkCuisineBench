"""Public-safe source-cluster sensitivity analysis for TurkCuisineBench.

The active Test-v1 row-level consensus is not distributed. Set
TCB_CONSENSUS_PATH to an authorized local copy. Only aggregate outputs are
written. Questions, answers, model responses, rationales, and reviewer fields
are neither selected nor exported by this script.
"""

from __future__ import annotations

import os
from pathlib import Path

import numpy as np
import pandas as pd
import statsmodels.api as sm
import statsmodels.formula.api as smf


SEED = 20260828
BOOTSTRAP_REPETITIONS = 10_000
OUTPUT_DIR = Path(__file__).resolve().parent / "posthoc_outputs"


def as_bool(series: pd.Series) -> pd.Series:
    return series.astype(str).str.strip().str.lower().map({"true": True, "false": False})


def coefficient_row(result, term: str, analysis: str) -> dict[str, object]:
    estimate = float(result.params[term])
    low, high = [float(x) for x in result.conf_int().loc[term]]
    return {
        "analysis": analysis,
        "effect": term,
        "odds_ratio": float(np.exp(estimate)),
        "ci_low": float(np.exp(low)),
        "ci_high": float(np.exp(high)),
        "p_value": float(result.pvalues[term]),
        "cluster_unit": "source_url",
        "source_clusters": int(result.cov_kwds["groups"].nunique()),
        "analysis_role": "POST_HOC_ROBUSTNESS",
    }


def main() -> None:
    input_value = os.environ.get("TCB_CONSENSUS_PATH", "").strip()
    if not input_value:
        raise SystemExit(
            "TCB_CONSENSUS_PATH is not set. Point it to an authorized local "
            "copy of the locked final-consensus CSV."
        )

    input_path = Path(input_value).expanduser().resolve()
    if not input_path.is_file():
        raise SystemExit(f"Consensus CSV was not found: {input_path}")

    columns = [
        "response_id",
        "item_id",
        "model_slot",
        "source_url",
        "lexical_leakage",
        "technical_valid",
        "exact_correct",
        "semantic_correct",
    ]
    data = pd.read_csv(input_path, usecols=columns, keep_default_na=False)
    data["technical_valid"] = as_bool(data["technical_valid"])
    valid = data.loc[data["technical_valid"]].copy()
    valid["exact_correct"] = as_bool(valid["exact_correct"]).astype(int)
    valid["semantic_correct"] = as_bool(valid["semantic_correct"]).astype(int)

    if not (
        len(data) == 576
        and len(valid) == 574
        and valid["item_id"].nunique() == 72
        and valid["model_slot"].nunique() == 8
        and valid["source_url"].nunique() == 38
        and int((valid["semantic_correct"] - valid["exact_correct"]).sum()) == 43
    ):
        raise SystemExit("The authorized input failed the frozen structural checks.")

    cluster_options = {
        "groups": valid["source_url"],
        "use_correction": True,
    }

    h1 = smf.glm(
        "semantic_correct ~ C(model_slot)", data=valid, family=sm.families.Binomial()
    ).fit(cov_type="cluster", cov_kwds=cluster_options)
    model_terms = [name for name in h1.params.index if name.startswith("C(model_slot)")]
    restriction = np.zeros((len(model_terms), len(h1.params)))
    for row, term in enumerate(model_terms):
        restriction[row, h1.params.index.get_loc(term)] = 1
    h1_test = h1.wald_test(restriction, scalar=True)

    valid["lexical_leakage"] = pd.Categorical(
        valid["lexical_leakage"], categories=["L0", "L1"]
    )
    h2 = smf.glm(
        "semantic_correct ~ C(model_slot) + C(lexical_leakage)",
        data=valid,
        family=sm.families.Binomial(),
    ).fit(cov_type="cluster", cov_kwds=cluster_options)

    stacked = pd.concat(
        [
            valid.assign(scoring_method="exact", correct=valid["exact_correct"]),
            valid.assign(scoring_method="semantic", correct=valid["semantic_correct"]),
        ],
        ignore_index=True,
    )
    stacked["scoring_method"] = pd.Categorical(
        stacked["scoring_method"], categories=["exact", "semantic"]
    )
    h3 = smf.glm(
        "correct ~ C(model_slot) + C(scoring_method)",
        data=stacked,
        family=sm.families.Binomial(),
    ).fit(
        cov_type="cluster",
        cov_kwds={"groups": stacked["source_url"], "use_correction": True},
    )

    rows = [
        {
            "analysis": "H1 model-slot global effect",
            "effect": "C(model_slot)",
            "wald_chi_square": float(h1_test.statistic),
            "df": len(model_terms),
            "p_value": float(h1_test.pvalue),
            "cluster_unit": "source_url",
            "source_clusters": valid["source_url"].nunique(),
            "analysis_role": "POST_HOC_ROBUSTNESS",
        },
        coefficient_row(h2, "C(lexical_leakage)[T.L1]", "H2 L1 versus L0"),
        coefficient_row(h3, "C(scoring_method)[T.semantic]", "H3 semantic versus exact"),
    ]

    cluster_totals = (
        valid.assign(recovered=valid["semantic_correct"] - valid["exact_correct"])
        .groupby("source_url", sort=True)
        .agg(valid_responses=("response_id", "size"), recovered=("recovered", "sum"))
        .reset_index(drop=True)
    )
    rng = np.random.default_rng(SEED)
    sampled = rng.choice(
        len(cluster_totals),
        size=(BOOTSTRAP_REPETITIONS, len(cluster_totals)),
        replace=True,
    )
    recovered = cluster_totals["recovered"].to_numpy()[sampled].sum(axis=1)
    denominators = cluster_totals["valid_responses"].to_numpy()[sampled].sum(axis=1)
    recovery_distribution = recovered / denominators
    recovery_low, recovery_high = np.percentile(recovery_distribution, [2.5, 97.5])

    OUTPUT_DIR.mkdir(exist_ok=True)
    pd.DataFrame(rows).to_csv(
        OUTPUT_DIR / "posthoc_source_cluster_sensitivity.csv", index=False
    )
    pd.DataFrame(
        [
            {
                "effect": "semantic_minus_exact_probability",
                "estimate": 43 / 574,
                "ci_low": recovery_low,
                "ci_high": recovery_high,
                "bootstrap_repetitions": BOOTSTRAP_REPETITIONS,
                "seed": SEED,
                "resampling_unit": "source_url",
                "source_clusters": len(cluster_totals),
                "analysis_role": "POST_HOC_ROBUSTNESS",
            }
        ]
    ).to_csv(OUTPUT_DIR / "posthoc_source_cluster_bootstrap.csv", index=False)

    print(f"Wrote aggregate post-hoc outputs to {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
