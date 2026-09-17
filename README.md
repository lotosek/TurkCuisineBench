# TurkCuisineBench

**Repository status:** Public-safe research repository; active Test-v1 content
is withheld.

TurkCuisineBench is a source-grounded Turkish short-answer benchmark for
evaluating large language models on factual knowledge of Turkish cuisine,
culinary techniques, local terminology, geographical-indication
specifications, and food-related cultural heritage.

## Current status

- The author submitted manuscript revision 1.4 to *Language Resources and
  Evaluation* and opted into Research Square In Review on 17 September 2026.
  The opt-in acknowledgement is not journal acceptance or confirmation that
  the preprint is public. No public manuscript DOI has been verified here.
- The 36-item development set is frozen as `TurkCuisineBench-Dev v0.2` with
  recorded SHA-256 checksums.
- The two-model methods pilot is complete. Its purpose was pipeline and
  taxonomy validation, not model ranking.
- The independent 72-item Test-v1 benchmark was constructed from 38 official
  or institutional URLs, validated, frozen, and evaluated with eight model
  endpoints from four providers.
- The main run produced 576 expected records: 574 technically valid responses
  and two technical invalids. Human semantic review resolved all 326 valid
  non-exact responses.
- The locked final consensus contains 230 semantically correct responses,
  including 43 correct non-exact responses; 283 incorrect responses; 61
  explicit abstentions; and two technical invalids.
- Pre-adjudication agreement on the independently selected 82-response overlap
  was 80/82 (97.6%; Cohen's κ = .875). Three blinded discrepancies were
  adjudicated only after the independent ratings were locked.
- H1 (model-slot differences) was supported after Holm correction; H2 was not.
  H3 recovered 43 correct answers (+7.49 points), but its unqualified confirmatory
  interpretation is withheld because of the extreme stacked-model scale. Original
  test outputs and multiplicity families are preserved; see the dated
  [interpretation amendment](docs/interpretation_amendment_2026-09-17.md).
- Gates M0–M8 are complete. The current public-safe status is documented in
  [`docs/main_study_status.md`](docs/main_study_status.md).

Use the [documentation index](docs/README.md) to distinguish current reporting
from frozen plans and historical workflow files. The manuscript's research
snapshot is `82719f07b11b3e962dad368778ac3a146443e9e7`; subsequent documentation
updates do not silently replace it.

No model generated or adjudicated semantic-correctness or error-taxonomy
labels. The active Test questions, answer key, raw responses, row-level human
records, reviewer mappings, and private checksums remain outside Git.

## Repository structure

```text
analysis/main_study/       Public-safe main-study analysis modules
configs/                   Secret-free model and execution configuration
data/dev/                  Frozen Dev items and fixed pilot requests
data/test_private/         Placeholder only; active Test content is excluded
docs/                      Protocols, reports, dataset card, and release checks
evaluation/                Execution, scoring, overlap-selection, and tests
paper/                     Manuscript status and submission planning
results/main_study/        Aggregate main-study tables and figure
results/pilot/             Aggregate methods-pilot reporting
workbooks/                 Development-stage workflow workbooks
```

## Main-study results and reproducibility

The public aggregate results are in
[`results/main_study/`](results/main_study/). The directory includes model
performance, the H1–H3 confirmatory table, all 28 gated pairwise comparisons,
subgroup summaries, pre-adjudication reliability, the exploratory error
taxonomy, feasibility-gate outcomes, and post-hoc source-cluster sensitivity
results.

The executed public-safe R modules and the post-hoc Python audit are in
[`analysis/main_study/`](analysis/main_study/). They can be rerun only by an
authorized reviewer who has a local copy of the locked private consensus file;
the code never requires that file to be copied into this repository.

## Evaluation principle

Each question is sent as a new stateless request. Tools, web browsing,
retrieval, and conversational memory are disabled. Responses are preserved
verbatim before Turkish-aware normalization.

- `CO`: exact normalized match to a frozen accepted answer, or a human-verified
  semantically correct non-exact response.
- `IN`: source-incompatible content response.
- `NA`: explicit `Bilmiyorum` response; valid but counted as not correct.
- `TECHNICAL_INVALID`: request or completion failure kept separate from
  semantic correctness.

The frozen Dev set may be used to debug prompting, capture, normalization,
abstention, scoring, and review workflows. It must not be used for headline
leaderboard claims.

## Data and release policy

This repository exposes only development material and aggregate main-study
evidence permitted by the contamination and reviewer-provenance policy. Test-v1
row-level material remains available only through controlled confidential
access. A public Test release, if made, will be versioned separately after a
successor active Test is deployed.

## Citation and license

Citation metadata is available in [`CITATION.cff`](CITATION.cff).
No independently archived repository DOI or public manuscript DOI has been
verified for this record. `CITATION.cff.template` is an unused historical
template, not citation metadata for the current repository.

Author-created public code uses MIT; covered public Dev material, documentation
and aggregate results use CC BY 4.0. Scope and exclusions are specified in
[`LICENSES.md`](LICENSES.md). Active Test and private reviewer records are excluded.
See [controlled access](docs/controlled_access.md) for confidential audit requests.
