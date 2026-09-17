# Main-study analysis code

This directory contains the public-safe analysis modules for the frozen
TurkCuisineBench main study. The R modules `02`–`10` and `12` are the executed
analysis modules used for the reported model performance, H1–H3 tests,
pairwise comparisons, subgroup summaries, error taxonomy, abstention/validity,
and prespecified feasibility and sensitivity checks. The public `01` import
wrapper replaces the confidential input checksum with environment variables.

The scripts preserve the executed analysis, including original machine-generated
H3 decision labels. For current manuscript interpretation, read the
[17 September reporting amendment](../../docs/interpretation_amendment_2026-09-17.md)
and `results/main_study/submission_interpretation_v1.1.csv`: the unqualified H3
confirmatory decision is withheld because of the model-scale limitation.

## Confidential input boundary

The active Test-v1 questions, accepted answers, raw responses, reviewer
rationales, reviewer mappings, and private checksums are not distributed.
Authorized reviewers can run the public-safe code against a locally supplied
locked consensus CSV. Generated row-level or fitted-model outputs must not be
committed.

Set the input outside this repository:

```powershell
$env:TCB_CONSENSUS_PATH = "C:\secure\TurkCuisineBench_Main_Study_Final_Consensus_Private_v1.0.csv"
$env:TCB_CONSENSUS_SHA256 = "<privately supplied checksum>"  # optional but recommended
Rscript analysis/main_study/run_public_analysis.R
```

Install R dependencies once with:

```powershell
Rscript analysis/main_study/00_install_packages.R
```

The main runner does not execute the confidential workbook-level reliability
reconciliation or the private M8 checksum manifest. Their de-identified
aggregate results are published in `results/main_study/`.

## Post-hoc source-cluster audit

The source-cluster sensitivity can be regenerated from the same authorized
consensus file:

```powershell
python -m pip install -r analysis/main_study/requirements-posthoc.txt
python analysis/main_study/posthoc_source_cluster_audit.py
```

This audit uses source-URL-clustered sandwich covariance and a 10,000-replicate
source-URL cluster bootstrap with seed `20260828`. It is explicitly post hoc
and does not alter either Holm family.

## Public results

The checked aggregate publication tables and figure are in
[`results/main_study/`](../../results/main_study/). They contain no Test
question, accepted answer, raw response, reviewer rationale, reviewer mapping,
or private checksum.
