# Provisional manuscript outline

## Working title

**TurkCuisineBench: A Source-Grounded Benchmark for Evaluating Large Language Model Knowledge of Turkish Cuisine**

## Target journal

Primary target: *Language Resources and Evaluation*.

## Abstract structure

1. Problem: culturally and linguistically grounded evaluation remains limited for specialized Turkish knowledge.
2. Resource: a source-grounded Turkish short-answer benchmark covering culinary composition, techniques, geographical indications, terminology, and heritage.
3. Method: official-source fact selection, item-level provenance, risk metadata, independent validation, conservative normalization, and abstention-aware scoring.
4. Evaluation: diverse open and proprietary model families under fixed closed-book conditions.
5. Findings: performance differences by knowledge domain, specificity, answer form, and risk class.
6. Contribution: benchmark, evaluation toolkit, documentation, and limitations.

## 1. Introduction

- Motivation for culturally grounded and domain-specific LLM evaluation.
- Why Turkish cuisine is linguistically, technically, and culturally challenging.
- Limitations of translated, multiple-choice, and weakly sourced benchmarks.
- Research questions and contributions.

## 2. Related work

- Turkish-language LLM benchmarks.
- Cultural-knowledge evaluation.
- Culinary and food-related NLP benchmarks.
- Dataset documentation and validation practices.
- Short-answer scoring and benchmark contamination.

## 3. Benchmark design

- Scope and knowledge-domain taxonomy.
- Official-source selection and source-fact registry.
- Candidate generation, inclusion, revision, and exclusion.
- L0/L1 specificity and lexical-leakage controls.
- Gold and accepted-answer construction.
- Temporal-stability and numeric-answer handling.

## 4. Human validation

- Reviewer recruitment and qualifications.
- Independent review instructions.
- Duplicate and risk-based review design.
- Adjudication and audit trail.
- Ethical and authorship considerations.

Provisional reporting sentence: “Two independent reviewers assessed all 36 Dev items. Four flagged cases were resolved using independent adjudicator wording recommendations, transcribed by the lead researcher and verified against official sources before the v0.2 freeze.”

## 5. Evaluation protocol

- Dev/Test separation.
- Pilot purpose and freeze gate.
- Model selection and exact version reporting.
- Turkish prompt and closed-book conditions.
- Normalization, abstention, and manual-review routing.
- Metrics and uncertainty reporting.

## 6. Results

- Overall performance with uncertainty.
- Results by knowledge domain and specificity.
- Local terminology and technical-knowledge errors.
- Abstention and calibration behaviour.
- Robustness and sensitivity analyses.

## 7. Discussion

- What model errors reveal about Turkish cultural and culinary knowledge.
- Implications for culturally grounded benchmark design.
- Source authority versus lived cultural variation.
- Contamination and longitudinal maintenance.

## 8. Limitations and ethics

- Selective institutional-source coverage.
- Regional variation and contested terminology.
- Model access, version drift, cost, and reproducibility.
- Responsible release of Test data and reviewer records.

## 9. Conclusion

- Summary of empirical and resource contributions.
- Maintenance and future multilingual extension.

## Planned main tables

1. Comparison with existing Turkish and cultural benchmarks.
2. Benchmark composition by knowledge domain, specificity, and answer type.
3. Reviewer agreement and adjudication outcomes.
4. Model-level results with confidence intervals.
5. Performance by domain and risk class.
6. Error taxonomy and representative de-identified examples.
