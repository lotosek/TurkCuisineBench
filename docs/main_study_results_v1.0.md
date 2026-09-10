# Main-study aggregate results v1.0

## Scope

This public-safe report summarizes the locked TurkCuisineBench Test-v1
evaluation without exposing active Test content or row-level human records. The
primary analysis population contains 574 technically valid responses from 72
items and eight model endpoints; two additional expected responses were
technically invalid.

## Confirmatory findings

The registered H1–H3 family used Holm correction.

| Hypothesis | Result | Holm-adjusted decision |
|---|---|---|
| H1: model-slot differences | χ²(7) = 177.181; raw p = 7.67 × 10⁻³⁵; Holm p = 2.30 × 10⁻³⁴ | Supported |
| H2: lexical-cue contrast | adjusted L0−L1 difference = −0.061, 95% CI [−0.447, 0.326]; Holm p = .750 | Not supported |
| H3: semantic recovery | 43 recovered responses; +7.49 points, 95% item-bootstrap CI [4.36, 11.19]; Holm p = 1.30 × 10⁻²⁷ | Supported |

The significant H1 gate opened a separate 28-comparison Holm family. Nineteen
paired McNemar contrasts remained significant. Observed rank order must not be
treated as complete pairwise separation.

## Response flow and error profile

- Normalized exact match accepted 187/574 valid responses (32.6%).
- Human semantic resolution accepted 230/574 (40.1%).
- Sixty-one valid responses were explicit abstentions (10.6%).
- Among 283 incorrect responses, 238 were substitutions, 35 omissions, and 10
  additions.

## Reliability

The two reviewers agreed on 80/82 independently completed response decisions
(97.6%; Cohen's κ = .875). Reliability was calculated before adjudication.
Three blinded discrepancies were adjudicated afterward and only then used to
construct final consensus.

## Secondary and post-hoc boundaries

The expanded secondary mixed model and model-by-domain interaction were not
fitted because their frozen feasibility gates failed. Descriptive subgroup
profiles were retained without post-output category collapse.

The source-URL-clustered models and coverage audit were added post hoc during
manuscript-level audit. They preserved the substantive H1, H2, and H3
conclusions but remain outside both Holm families. The benchmark is not a
province-, region-, community-, or source-family-representative sample.

Machine-readable aggregate tables and the figure are in
[`results/main_study/`](../results/main_study/). Public-safe analysis modules
are in [`analysis/main_study/`](../analysis/main_study/).
