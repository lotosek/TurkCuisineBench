# Main-study status

Last updated: 2026-08-31

## Current gate

M0 governance is **complete**. Identifiable contribution records remain private, and only public-safe research artifacts will be released. M1 source-fact construction and M2 automated item construction/QC are complete. Seventy-two private items were created from 38 accessible official-source URLs, with twelve items in each of K1–K6, 60 L0 items, 12 L1 items, no L2 items, and six numeric items.

M3 is **complete**. Two independent validators reviewed all 72 items against the official sources. Pre-adjudication final-action agreement was 17/18 (94.4%) in the prospectively locked primary set, 26/30 (86.7%) in the prespecified risk sensitivity set, and 61/72 (84.7%) in the supplementary full-set comparison. Cohen's κ is 0 in all three comparisons because Reviewer B used only the `accept` category; raw agreement and marginal distributions therefore remain the primary interpretation. Eleven disagreements were resolved by lead-researcher adjudication: ten Reviewer A revisions were adopted and one custom source-grounded revision was entered. The final disposition is 61 unchanged items, 11 revised items, and zero exclusions.

The private 72-item Test content, question-only execution file, and private scoring key were frozen and checksummed on 2026-08-28. This closes the **Test-content component of M4 only**. No question, gold answer, reviewer rationale, adjudication record, or checksum is stored in Git, and no main-study Test request has been sent to any model.

The provisional M4 panel contains eight slots across OpenAI, Anthropic, Google, and Groq. Neutral non-benchmark access probes passed for all eight slots and every provider returned the requested model ID. Google AI Studio currently shows `No billing account`; because Free Tier and Paid Tier have different documented data-use treatment, the private Test cannot be sent to Gemini until Paid Tier is verified or the panel is prospectively amended. The panel is therefore not frozen.

The main-study runner has passed an offline dummy dry-run and a negative authorization test: with `execution_authorized=false`, it refuses network execution before loading any provider request. This is preparation evidence only and does not close M4. Full M4 remains open until the Gemini data-use gate is resolved and the exact panel, current cost ceiling, final prompt/configuration, and final non-Test fixture dry run are frozen together.

The non-provider-dependent M4 methods components are now prospectively frozen: Statistical Analysis Plan v1.0, the deterministic 25% blinded review-overlap selector, and seed `20260828`. The selector uses a separate private blinding salt, so its public seed does not reveal model identities. A three-item synthetic dry run passed without network access; it must be repeated after the exact provider panel and final configuration are frozen. Checksums and the remaining blockers are recorded in [`m4_methods_manifest_v0.1.md`](m4_methods_manifest_v0.1.md).

All eight requested model IDs and public list prices were rechecked against official provider documentation on 2026-08-31. A deliberately conservative three-attempt, full-token-use envelope plus 50% contingency produces a registered USD 5 run ceiling. Technical access now passes for all eight slots, but the Gemini data-use tier still prevents panel freeze and Test execution. Details are in [`model_cost_envelope_v0.1.md`](model_cost_envelope_v0.1.md).

## Open controls

- Keep reviewer identities, signed or identifiable forms, Test gold answers, accepted-answer inventories, and model-to-review mappings outside Git.
- Remove the de-identified Dev adjudicator case pack from the eventual public release or replace it with a blank/synthetic template.
- The six-domain inconsistency was resolved prospectively by explicitly defining `K1 — Dishes, Products & Geographic Associations` and distinguishing it from K4 product specifications before Test item selection.
- The complete legacy `F001–F118` master was not saved locally. The new private candidate namespace is therefore `TF001–TF072`; it does not claim identity with the legacy IDs. The 36 frozen Dev fact IDs remain the authoritative exclusion list.
- The original `local_terminology` composition flag was broadened in practice. Before Test freeze it was renamed `terminology_or_traditional_practice`, matching the operational K5 construct and preventing a misleading locality-only interpretation.

## Next authorized work

1. Resolve the Gemini Paid Tier/data-use requirement or prospectively amend the panel.
2. Freeze the exact equal-treatment panel and final prompt/configuration; the overlap seed/script, Statistical Analysis Plan v1.0, and USD 5 cost ceiling are already prospectively frozen.
3. Run the final dry run on synthetic/non-Test fixtures only and record the M4 authorization decision.
4. Do not call model endpoints with Test questions until Gate M4 passes.

Aggregate candidate-stage QA is recorded in [`main_study_candidate_audit_v0.1.md`](main_study_candidate_audit_v0.1.md), and the completed public-safe M3 outcome is recorded in [`main_study_item_validation_report_v1.0.md`](main_study_item_validation_report_v1.0.md). The provisional provider-neutral panel is recorded in [`model_panel_manifest_v0.1.md`](model_panel_manifest_v0.1.md).
