# Main-study status

Last updated: 2026-08-31

## Current gate

M0 governance is **complete**. Identifiable contribution records remain private, and only public-safe research artifacts will be released. M1 source-fact construction and M2 automated item construction/QC are complete. Seventy-two private items were created from 38 accessible official-source URLs, with twelve items in each of K1–K6, 60 L0 items, 12 L1 items, no L2 items, and six numeric items.

M3 is **complete**. Two independent validators reviewed all 72 items against the official sources. Pre-adjudication final-action agreement was 17/18 (94.4%) in the prospectively locked primary set, 26/30 (86.7%) in the prespecified risk sensitivity set, and 61/72 (84.7%) in the supplementary full-set comparison. Cohen's κ is 0 in all three comparisons because Reviewer B used only the `accept` category; raw agreement and marginal distributions therefore remain the primary interpretation. Eleven disagreements were resolved by lead-researcher adjudication: ten Reviewer A revisions were adopted and one custom source-grounded revision was entered. The final disposition is 61 unchanged items, 11 revised items, and zero exclusions.

The private 72-item Test content, question-only execution file, and private scoring key were frozen and checksummed on 2026-08-28. No question, gold answer, reviewer rationale, adjudication record, response text, or private checksum is stored in Git.

The frozen M4 panel contains eight slots across OpenAI, Anthropic, Google, and Groq. Neutral non-benchmark access probes passed for all eight slots and every provider returned the requested model ID. Google AI Studio showed Tier 1/Paid with a positive prepaid balance on 2026-08-31, with automatic reload off. Personal billing identifiers and payment details remain private.

The main-study runner passed the final offline dummy dry run and a negative authorization test: with `execution_authorized=false`, it refuses network execution before loading any provider request. The exact panel, current cost ceiling, prompt/configuration, and non-Test fixture dry run were frozen together on 2026-08-31. **Gate M4 is complete.**

Main-study execution was completed in the frozen interleaved order on 2026-08-31. All 576 expected model–item records were captured, with 72 records for each slot, no terminal request error, and no requested/returned model-ID drift. There were 574 technically valid responses and two technically invalid empty responses: one length termination in S07 and one provider content-filter termination in S06. Both slot-level invalid rates were 1.4%, below the prespecified 5% stopping threshold. Three transient technical failures succeeded on the second identical attempt. **Gate M5 is complete.** Aggregate execution QA is reported in [`m5_execution_report_v1.0.md`](m5_execution_report_v1.0.md).

M6 automatic routing and reviewer-material preparation were completed on 2026-08-31 under the frozen scorer. The 576 records comprise 187 exact registered-answer matches, 61 explicit abstentions, 326 technically valid non-exact responses requiring semantic review, and two technical invalids. Before any non-exact response was semantically inspected, the registered 25% selector froze an 82-response independent overlap. Private workbooks contain all 326 lead-review rows and only the frozen 82 rows for the second reviewer. Both passed identity-leakage, formula, row-count, and rendered-layout checks. This preparation closed the material-generation stage but did not itself close Gate M6. Public-safe preparation details are in [`m6_scoring_and_review_preparation_v1.0.md`](m6_scoring_and_review_preparation_v1.0.md).

Both independent 82-row overlap returns were completed and locked on 2026-09-02. Final-decision agreement was 80/82 (97.6%; Cohen's κ = .875). Among the 72 responses jointly coded `IN`, error-operation and semantic-target agreement were both 100% (κ = 1.000). Correct-variant agreement among eight jointly correct responses was 7/8 (87.5%; κ = .810) and is treated as descriptive because of the small denominator. Three model-blinded cases require adjudication: two final-decision disagreements and one correct-variant-only disagreement. The lead-perspective overlap codes were transferred into the 326-row lead workbook, leaving 244 rows open. **Gate M6 therefore remains open only for completion of the full lead review; pre-adjudication overlap reliability is locked.** Public-safe results are in [`m7_pre_adjudication_overlap_report_v1.0.md`](m7_pre_adjudication_overlap_report_v1.0.md).

All eight requested model IDs and public list prices were rechecked against official provider documentation on 2026-08-31. A deliberately conservative three-attempt, full-token-use envelope plus 50% contingency produces a registered USD 5 run ceiling. Technical access and the required data-use tier pass for all eight slots. Details are in [`model_cost_envelope_v0.1.md`](model_cost_envelope_v0.1.md).

## Open controls

- Keep reviewer identities, signed or identifiable forms, Test gold answers, accepted-answer inventories, and model-to-review mappings outside Git.
- Remove the de-identified Dev adjudicator case pack from the eventual public release or replace it with a blank/synthetic template.
- The six-domain inconsistency was resolved prospectively by explicitly defining `K1 — Dishes, Products & Geographic Associations` and distinguishing it from K4 product specifications before Test item selection.
- The complete legacy `F001–F118` master was not saved locally. The new private candidate namespace is therefore `TF001–TF072`; it does not claim identity with the legacy IDs. The 36 frozen Dev fact IDs remain the authoritative exclusion list.
- The original `local_terminology` composition flag was broadened in practice. Before Test freeze it was renamed `terminology_or_traditional_practice`, matching the operational K5 construct and preventing a misleading locality-only interpretation.

## Next authorized work

1. The lead researcher completes the remaining 244 blinded manual-review rows; the transferred 82 overlap ratings stay unchanged.
2. A model-blinded adjudicator completes the three-case adjudication form without altering the locked independent ratings.
3. Lock and checksum the completed lead and adjudication files before unsealing response identities.
4. Keep all Test questions, outputs, reviewer files, blind mappings, and scoring materials outside Git.

Aggregate candidate-stage QA is recorded in [`main_study_candidate_audit_v0.1.md`](main_study_candidate_audit_v0.1.md), and the completed public-safe M3 outcome is recorded in [`main_study_item_validation_report_v1.0.md`](main_study_item_validation_report_v1.0.md). The provisional provider-neutral panel is recorded in [`model_panel_manifest_v0.1.md`](model_panel_manifest_v0.1.md).
