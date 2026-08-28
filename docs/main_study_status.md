# Main-study status

Last updated: 2026-08-28

## Current gate

M0 has a **conditional governance pass**, M1 source-fact construction is complete at the candidate stage, and M2 automated item construction/QC has passed. Seventy-two private candidates were created from 38 accessible official-source URLs, with twelve items in each of K1–K6, 60 L0 items, 12 L1 items, no L2 items, and six numeric items. All candidates remain `candidate_pending_validation`.

M3 materials are prepared but M3 is not complete. The locked primary agreement sample contains 18 balanced items; the prespecified risk rule expands second independent review to 30 items so that all L1, numeric, and medium/high ambiguity cases are covered. The main-study Test set has not been frozen and no main-study Test request has been sent to any model.

The provisional M4 panel contains eight slots across OpenAI, Anthropic, Google, and Groq. Non-benchmark access probes passed for the two OpenAI and two Groq slots. Anthropic and Google remain unprobed because credentials are absent; the panel is therefore not frozen.

The main-study runner has passed an offline dummy dry-run and a negative authorization test: with `execution_authorized=false`, it refuses network execution before loading any provider request. This is preparation evidence only and does not close M4.

## Open controls

- Obtain and archive a written institutional ethics/exemption determination before treating the human-validation stage as complete or making an exemption claim in the manuscript.
- Keep reviewer identities, signed or identifiable forms, Test gold answers, accepted-answer inventories, and model-to-review mappings outside Git.
- Remove the de-identified Dev adjudicator case pack from the eventual public release or replace it with a blank/synthetic template.
- The six-domain inconsistency was resolved prospectively by explicitly defining `K1 — Dishes, Products & Geographic Associations` and distinguishing it from K4 product specifications before Test item selection.
- The complete legacy `F001–F118` master was not saved locally. The new private candidate namespace is therefore `TF001–TF072`; it does not claim identity with the legacy IDs. The 36 frozen Dev fact IDs remain the authoritative exclusion list.
- The original `local_terminology` composition flag was broadened in practice. Before Test freeze it was renamed `terminology_or_traditional_practice`, matching the operational K5 construct and preventing a misleading locality-only interpretation.

## Next authorized work

1. Obtain and archive the institutional ethics/exemption determination.
2. Complete lead and independent item validation for all 72 candidates; complete the second review for the locked 30-row set.
3. Adjudicate disagreements, preserve pre-adjudication labels, revise only from official-source evidence, and rerun all QC.
4. Replace excluded candidates from new official sources rather than weakening quotas or ambiguity rules.
5. Obtain Anthropic and Gemini access, run non-Test probes, then freeze the final Test, prompt, eight-model panel, runner, and checksums under M4.
6. Do not call model endpoints with Test questions until Gates M0–M4 all pass.

Aggregate candidate-stage QA is recorded in [`main_study_candidate_audit_v0.1.md`](main_study_candidate_audit_v0.1.md). The provisional provider-neutral panel is recorded in [`model_panel_manifest_v0.1.md`](model_panel_manifest_v0.1.md).
