# Main-study status

Last updated: 2026-09-17

## Current state

The frozen main study has completed construction, validation, execution, human
semantic review, adjudication, and statistical analysis. Gates M0–M8 are
closed. Test-v1 remains an active private benchmark and is not included in this
repository.

| Gate | Public-safe status |
|---|---|
| M0 — governance and release boundary | Complete |
| M1–M2 — official-source fact and item construction | Complete |
| M3 — independent item validation and Test freeze | Complete |
| M4 — model panel, prompt, configuration, and analysis-plan freeze | Complete |
| M5 — eight-endpoint execution | Complete |
| M6 — automatic routing and blinded semantic review | Complete |
| M7 — pre-adjudication reliability and final consensus | Complete |
| M8 — confirmatory, secondary, exploratory, and sensitivity analysis | Complete |

## Frozen benchmark and execution

- Test-v1 contains 72 Turkish short-answer items supported by 38 accessible
  official or institutional source URLs.
- The six knowledge domains contain 12 items each. The lexical-cue composition
  is 60 L0, 12 L1, and no L2; six items have numeric answers.
- Two independent validators reviewed all 72 items before Test freeze. Eleven
  disagreements were resolved through lead-researcher source adjudication,
  producing 61 unchanged items, 11 source-grounded revisions, and no
  exclusions.
- Eight model endpoints from four providers answered every item in a frozen
  interleaved order, producing 576 expected records. Of these, 574 were
  technically valid and two were technically invalid; no requested/returned
  model-ID drift occurred.
- Automatic routing produced 187 exact accepted-answer matches, 61 explicit
  abstentions, 326 valid non-exact responses for model-blinded semantic review,
  and two technical invalids.

## Human review and final consensus

The lead researcher completed all 326 semantic-review rows. Before semantic
inspection, a deterministic stratified selector froze an 82-row independent
overlap. The two reviewers agreed on 80/82 final decisions (97.6%; Cohen's
κ = .875). Agreement was 72/72 for error operation and semantic target among
responses both reviewers classified as incorrect. Three blinded discrepancies
were adjudicated after the independent ratings were locked; adjudicated labels
were never substituted into the reliability calculation.

Final consensus contains 230 semantically correct responses, 283 incorrect
responses, 61 explicit abstentions, and two technical invalids. All semantic
decisions and taxonomy labels were assigned by human reviewers, not by a
generative-AI judge.

## Statistical analysis

- H1 was supported: semantic accuracy differed across model slots,
  likelihood-ratio χ²(7) = 177.181, Holm-adjusted p = 2.30 × 10⁻³⁴. Nineteen
  of 28 gated pairwise McNemar comparisons remained significant after their
  separate Holm correction.
- H2 was not supported: the adjusted L0-minus-L1 probability difference was
  −0.061 (95% CI [−0.447, 0.326]), Holm-adjusted p = .750.
- H3 was supported: semantic review recovered 43 correct non-exact responses,
  an absolute gain of 7.49 percentage points (item-cluster bootstrap 95% CI
  [4.36, 11.19]), Holm-adjusted p = 1.30 × 10⁻²⁷.
- The prespecified expanded secondary model and model-by-domain interaction
  were not fitted because their frozen feasibility gates failed. No
  post-output category collapse was used.
- Both prespecified H1 sensitivity analyses preserved the global conclusion.

The post-hoc source-dependence audit also preserved the substantive
conclusions: source-URL-clustered H1 Wald χ²(7) = 72.44 (p = 4.75 × 10⁻¹³), H2
L1-versus-L0 OR = 1.10 (95% CI [0.44, 2.74], p = .833), and H3
semantic-versus-exact OR = 1.48 (95% CI [1.22, 1.79], p = 6.65 × 10⁻⁵). The
source-cluster bootstrap interval for the 7.49-point semantic recovery was
[3.92, 11.53]. These are post-hoc robustness diagnostics and are not members of
either Holm family.

Aggregate tables, the model-performance figure, and public-safe analysis code
are available in [`results/main_study/`](../results/main_study/) and
[`analysis/main_study/`](../analysis/main_study/).

## Confidentiality boundary

The active Test questions, gold and accepted-answer inventories, raw model
responses, row-level reviewer decisions and rationales, reviewer identities,
model-to-blind mappings, blinding salt, and private checksums remain outside
Git. Authorized editorial audit can use the locked confidential files without
changing the public-release boundary.

## Remaining submission and release work

The confidential editorial audit package has been assembled outside Git and
verified by file hashes and recalculation of locked-rating agreement. Online
Resource 1 is available in `results/main_study/`. All 38 source URLs were
accessible on 17 September 2026. `CITATION.cff` is complete; no DOI has been
assigned. The author elected to retain rights without a public reuse license.

For submission, use the updated manuscript with its exact repository commit,
upload Online Resource 1 as the public supplement, and supply the confidential
audit package only through a channel that preserves editorial confidentiality.
Test-v1 remains private until a separately documented release decision.
