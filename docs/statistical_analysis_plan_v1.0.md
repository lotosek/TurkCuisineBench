# TurkCuisineBench main-study statistical analysis plan v1.0

Status: **prospectively specified; no Test response has been collected or inspected**

Date: 2026-08-28
Unit of evaluation: one model response to one frozen Test item
Planned panel: eight model slots and 72 immutable Test items (576 expected primary responses)

## 1. Scope and decision hierarchy

This plan operationalizes RQ1–RQ5 and H1–H3 in `main_study_protocol_v1.0.md`. The confirmatory family comprises H1–H3 only. Domain, model-by-domain, knowledge-specificity, answer-form, numeric-item, error-operation, and semantic-target breakdowns are secondary or exploratory unless explicitly identified below. No accepted answer, taxonomy category, hypothesis, contrast family, or denominator rule may be changed after a Test response is inspected without a dated protocol amendment and a complete comparable-panel rerun where the change affects scoring.

## 2. Analysis populations

1. **Expected-response population:** all 576 preregistered model-item pairs.
2. **Technically valid population:** expected responses that satisfy the frozen transport, non-empty-output, and completion-status rules.
3. **Common-valid paired population:** for a specific two-model contrast, items with technically valid responses from both models.
4. **Manual-review population:** technically valid responses not classified automatically as exact `CO` or explicit `NA`.
5. **Final-consensus population:** technically valid responses after automatic scoring, blinded human review, reliability analysis, and adjudication are locked.

The primary semantic-accuracy denominator is the technically valid population for each model. Counts and rates of technical invalidity are always reported separately. A prespecified sensitivity analysis uses the expected-response population and counts technically invalid responses as incorrect.

## 3. Outcomes

### Primary outcome

`semantic_correct = 1` for final `CO` and `0` for final `IN` or `NA`. The primary model-level estimate is:

`semantic_accuracy = sum(semantic_correct) / technically_valid_n`

### Secondary outcomes

- normalized exact-match accuracy among technically valid responses;
- explicit-abstention rate among technically valid responses;
- technical-validity rate among expected responses;
- correct-but-non-exact recovery rate among manual-review responses;
- semantic accuracy by knowledge domain, knowledge specificity, lexical cue level, answer form, and numeric-answer status;
- prevalence of each primary error operation over eligible technically valid responses;
- error-operation and semantic-target composition among final `IN` responses;
- latency and token-use summaries as provider-specific descriptive metadata only.

## 4. Confirmatory hypotheses and tests

### H1: model differences in semantic accuracy

The global confirmatory test is a likelihood-ratio comparison of two binomial mixed-effects models fitted to the final-consensus population: a null model with item random intercept only and an alternative model adding model slot as a fixed effect. If the prespecified mixed model fails to converge or is singular after documented standard optimizer checks, report the failure and use Cochran's Q test over items with valid responses from all eight models as the fallback global test. Pairwise model contrasts are then estimated on common-valid items with paired accuracy differences, paired item-bootstrap 95% confidence intervals, and two-sided McNemar tests. Holm correction is applied across the complete family of 28 pairwise model contrasts. Both raw and adjusted p-values are retained.

### H2: L0 versus L1 lexical cue level

Test the preregistered directional proposition that L0 accuracy is lower than L1 accuracy in a binomial mixed-effects model containing lexical cue level and model slot as fixed effects and item as a random intercept. Report the L0–L1 marginal probability difference, odds ratio, 95% confidence interval, and two-sided p-value; the direction is evaluated from the signed estimate rather than by using a one-sided test. Because L1 contains only 12 items, the result is interpreted cautiously and accompanied by item-cluster bootstrap intervals.

### H3: exact match versus semantic accuracy

Within technically valid responses, compare the paired binary exact-match and final semantic-correctness indicators. Report the absolute recovery difference and its paired item-cluster bootstrap 95% confidence interval. The confirmatory test is the scoring-method effect in a binomial mixed-effects model on two stacked observations per response, with scoring method and model slot as fixed effects and random intercepts for item and response ID. This retains the within-response pairing and repeated use of each item across models. Because exact correctness must be a subset of semantic correctness under the frozen scoring hierarchy, any exact-correct/semantic-incorrect record triggers an audit before analysis continues.

The H1 global test, H2, and H3 form one three-test confirmatory family and receive Holm correction. The 28 H1 pairwise contrasts form a separate, prespecified post-global-test family and receive their own Holm correction. Pairwise results are interpreted only if the H1 global test rejects after correction.

## 5. Estimation and uncertainty

- Model-level proportions are reported as counts, denominators, percentages, and 95% Wilson intervals.
- Differences involving repeated evaluation of the same items use 10,000 deterministic paired item-cluster bootstrap resamples with seed `20260828`.
- A bootstrap draw samples 72 item IDs with replacement and carries all eligible model responses for each sampled item; duplicated item draws remain duplicated analytical clusters.
- Percentile intervals are primary. If the bootstrap distribution is degenerate, report the point estimate, observed counts, and the degeneracy instead of manufacturing an interval.
- Effect sizes take priority over null-hypothesis tests: absolute percentage-point difference, matched odds ratio where defined, and model-based odds ratio are reported with uncertainty.

## 6. Secondary and exploratory models

A secondary binomial mixed-effects model includes model slot, knowledge domain, knowledge specificity, lexical cue level, answer form, and numeric status as fixed effects with item as a random intercept. Model-by-domain interactions are exploratory and fitted only if all required cells contain both outcomes and the model converges without singularity. Sparse categories are collapsed only according to the frozen codebook; otherwise they are reported descriptively. Error-operation and semantic-target comparisons are exploratory, use counts with row and column percentages, and do not support a model leaderboard when a cell contains fewer than five observations.

## 7. Reliability analysis

Reliability is calculated only on the preselected 25% manual-review overlap and before adjudication. Report raw agreement and Cohen's κ for the final `CO`/`IN`/`NA` decision. Report error-operation agreement and κ only among overlap responses independently coded `IN` by both reviewers. Denominators, marginal distributions, and category counts accompany every coefficient. If a reviewer uses one category only or a coefficient is otherwise prevalence-limited, retain the coefficient but prioritize raw agreement and describe the limitation. Lead-researcher adjudication is not included as an independent rating.

## 8. Missingness, invalidity, exclusions, and stop rules

- No substantively wrong answer is retried or excluded.
- Logged technical retries follow the frozen runner policy; only the final technically eligible attempt enters correctness analysis, while all attempts remain auditable.
- Primary pairwise tests use common-valid items; the count of excluded non-common items is reported for every contrast.
- The expected-population sensitivity analysis codes all technical invalidity as incorrect.
- A model slot with more than 5% technically invalid expected responses triggers the protocol stop rule before correctness comparison.
- Model-ID drift, Test-key exposure, capture defects, prompt/configuration drift, or any proposed post-output answer/taxonomy change triggers a halt and versioned protocol review.

## 9. Blinding and reproducibility

Provider and model identities are replaced with opaque blind codes before manual review. The blind-code mapping is generated using a private blinding salt, stored separately, and is not opened until the consensus record is locked and checksummed; the public overlap seed alone cannot reveal the mapping. The 25% overlap is selected once by `evaluation/select_review_overlap.py` with seed `20260828`, after automatic routing but before responses are read. The overlap list and sealed mapping receive SHA-256 checksums. Primary tables must be generated from the locked consensus record by one versioned analysis command, with software versions, warnings, convergence diagnostics, and session information archived.

## 10. Planned reporting tables

1. Expected, valid, invalid, exact-correct, semantic-correct, abstention, and manually reviewed counts by model.
2. Model semantic accuracy with 95% intervals and expected-population sensitivity results.
3. H1 global test and corrected pairwise contrasts with effect sizes and common-valid denominators.
4. H2 L0/L1 and secondary domain/specificity/answer-form/numeric estimates.
5. H3 exact-to-semantic recovery analysis.
6. Pre-adjudication response-review reliability and adjudication counts.
7. Exploratory error-operation and semantic-target distributions.

## 11. Version lock

Version 1.0 becomes analytically frozen only when its SHA-256 value is entered in the private M4 manifest together with the exact model panel, prompt/configuration, Test checksums, overlap selector version, and non-Test dry-run record. Editorial clarifications that do not alter an outcome, denominator, hypothesis, contrast, or decision rule may be logged without changing the version; all analytical changes require a new version and explicit amendment.
