# Changelog

## 2026-08-31 — Main-study M5 execution completed

- Captured all 576 prespecified model–item records in the frozen interleaved schedule, with 72 records for each of eight slots.
- Reconciled 574 technically valid and two technically invalid responses, zero terminal request errors, zero model-ID drift, and three successful technical retries.
- Kept raw response text, Test materials, request identifiers, and private checksums outside Git; added only a public-safe aggregate M5 report.
- Estimated successful-request list-price cost at USD 0.128569, well below the registered USD 5 ceiling.

## 2026-08-31 — Gate M4 completed prospectively

- Verified Gemini Tier 1/Paid status with a positive prepaid balance and automatic reload disabled; retained personal billing evidence outside Git.
- Froze the exact equal-treatment eight-model panel and `configs/main_study_config_v1.0.json` with the public authorization lock set to `false`.
- Re-ran all unit tests and the final 24-request synthetic dry run; the deterministic schedule hash remained unchanged.
- Closed Gate M4 before any private Test request and authorized the transition to append-only private M5 execution.

## 2026-08-31 — Eight-slot access verified; Gemini data-use gate retained

- Passed neutral `Return exactly OK.` access probes for Claude Sonnet 5, Claude Haiku 4.5, Gemini 3.6 Flash, and Gemini 3.5 Flash-Lite without sending benchmark content; all requested and returned model IDs matched.
- Added slot-selective, bounded-time access probes after Gemini 3.6 Flash exceeded the initial 30-second observation window.
- Reverified official list prices and retained the conservative USD 5 ceiling.
- Kept M4 open because the Gemini project has no billing account and Free Tier submissions have different documented data-use treatment from Paid Tier submissions.

## 2026-08-28 — M0 governance state finalized before Test execution

- Marked M0 governance complete and retained the private/public data boundary.
- No main-study Test request or model output had been collected when this prospective governance change was recorded.
- Added an explicit opt-in access-probe utility that sends only `Return exactly OK.` and records sanitized model-access results.

## 2026-08-28 — Main-study M3 completion and private Test-content freeze

- Completed two independent official-source validations for all 72 private Test items while retaining the prospectively locked 18-item primary agreement set and 30-item risk sensitivity set.
- Recorded pre-adjudication final-action agreement of 94.4% for the primary 18, 86.7% for the risk 30, and 84.7% for the supplementary all-72 comparison. Cohen's κ is 0 because Reviewer B used only one action category and is interpreted with raw agreement and margins.
- Resolved 11 disagreements through lead-researcher adjudication without treating the lead as a third independent reviewer: 10 Reviewer A revisions adopted, one custom source-grounded revision, and no exclusions.
- Frozen 61 unchanged and 11 revised items in a private 72-item Test master with separate question-only and private-key JSONL files and verified SHA-256 checksums.
- Kept all Test wording, answers, reviewer/adjudication records, mappings, and checksums outside Git; only aggregate M3 status is public-safe.
- Prospectively froze Statistical Analysis Plan v1.0, the deterministic 25% response-review overlap selector, and seed `20260828`; blind-code generation additionally requires a private salt that is not stored in Git.
- Passed selector unit tests and a 24-request offline schedule dry run using three synthetic non-Test fixtures; no provider endpoint was called.
- Rechecked all eight requested IDs and list prices on official provider documentation, registered a reproducible conservative USD 5 run ceiling, and added payload tests for provider-neutral reasoning controls.
- Corrected the Anthropic request builder to transmit explicit thinking disablement, set Gemini to its lowest supported `minimal` level, and hid Groq reasoning traces from the answer field.
- Left M0 and full M4 open at that checkpoint. No Test endpoint call was authorized until the remaining governance record, access probes, exact equal-treatment panel, current prices/cost ceiling, configuration, analysis plan, and final non-Test fixture dry run were frozen.

## 2026-08-28 — Main-study M0 audit and domain freeze

- Recorded a conditional M0 pass for M1–M2 preparation, including frozen-artifact checksums, private role codes, ethics status, and Git privacy controls.
- Identified that the complete `F001–F118` master pool had not been saved locally; the frozen 36 Dev fact IDs remain the authoritative Test-exclusion list while the official-source pool is reconstructed and expanded.
- Resolved a prospective documentation inconsistency by defining all six knowledge domains and adding `K1 — Dishes, Products & Geographic Associations` before Test item selection.
- Corrected the protocol terminology so L0/L1 denotes lexical cue level (`lexical_leakage`) rather than the separate knowledge-specificity variable.
- Added an ignore rule for future adjudicator workbooks; the existing tracked Dev adjudicator pack is de-identified and must not enter the eventual sanitized public release.
- Constructed a private 72-item main-study candidate set in the new `TF001–TF072` namespace from official TÜRKPATENT, Ministry Culture Portal, and UNESCO records; no Test questions or answers were added to Git.
- Passed candidate-stage automated QC: 12 items per domain, 60 L0/12 L1/0 L2, six numeric items, complete accepted-answer coverage, no exact Dev-question overlap, no same-source/same-gold Dev reuse, and no formula errors.
- Verified live accessibility of all 38 unique official-source URLs used by the candidate pool.
- Corrected the M3 implementation to preserve an 18-item balanced primary agreement sample while expanding second review to 30 items under the prespecified L1/numeric/ambiguity risk rule.
- Renamed the overbroad `local_terminology` mix flag to `terminology_or_traditional_practice` before Test freeze.
- Added a provisional eight-slot, four-provider M4 model/prompt manifest. Non-Test probes passed for both OpenAI and both Groq slots; Anthropic and Google access remains pending.
- Added a provider-neutral main-study runner with an M4 authorization lock, question-only schema enforcement, deterministic interleaving, technical-only retries, model-drift stop, and raw-capture hashing. Syntax, dry-run, and closed-gate refusal tests passed without Test data.

## 2026-08-27 — Pilot consensus and Taxonomy v1.0 freeze

- Completed independent double coding of all 46 non-exact pilot responses.
- Recorded pre-adjudication decision agreement of 93.5% (Cohen's κ = .801) and primary-operation agreement of 100% among the 35 jointly incorrect cases (κ = 1.000).
- Resolved five routed cases through third-review adjudication while preserving both original reviewer sheets unchanged.
- Frozen the response-error taxonomy as `Taxonomy v1.0` for prospective Test coding.
- Recorded an aggregate pilot consensus of 30/72 semantically correct responses (41.7%), including 21 exact matches and 9 manually verified correct non-exact responses. No model-level pilot ranking is released.
- Added a versioned main-study protocol with ordered gates for private Test construction, model execution, blinded review, analysis, and release.

## 2026-08-26 — Provider-neutral methods pilot v0.3

- Completed 72 technically valid single-shot requests: 36 per fixed model endpoint.
- Applied the same items, Turkish prompt, low reasoning effort, 1,024-token completion ceiling, statelessness, tool prohibition, and technical validity rules to both models.
- Added response-status, finish-reason, incomplete-detail, latency, and token-usage capture to the private raw log.
- Excluded the earlier 256-token technical run and one diagnostic request from scientific results; the full two-model panel was rerun rather than selectively rerunning one endpoint.
- Produced a de-identified scored table with automatic labels and blank fields for shared manual review. No model ranking is reported from the pilot.

## Unreleased

### Frozen Dev v0.2

- Resolved the four flagged Dev cases (`D002`, `D021`, `D022`, and `D034`) using independent adjudicator wording recommendations transcribed by the lead researcher and verified against official sources.
- Revised the wording of four Turkish questions; changed zero gold answers and zero accepted-answer sets.
- Frozen the 36-item Dev set and recorded SHA-256 checksums for its XLSX and CSV representations.
- Added validation workflow v0.4 and pilot execution package v0.2.
- Regenerated all 72 fixed pilot requests from the frozen Dev questions.
- Initially fixed the pilot endpoints as `gpt-5.5-2026-04-23` (OpenAI Responses API) and `openai/gpt-oss-120b` (Groq OpenAI-compatible API); this pre-run state was later superseded by the completed `pilot_run_v0.3` record.
- Set low reasoning effort for both pilot models, hid M2 reasoning traces, and raised the generation ceiling from 64 to 256 tokens to reduce incomplete-response risk.

### Added

- Initial private repository structure.
- Thirty-six-item Turkish Dev set.
- Fixed 72-request pilot package covering two model slots.
- Conservative Turkish-aware exact-match scorer.
- Normalization unit tests.
- Development protocol, dataset-card draft, release checklist, and English manuscript outline.
- De-identified reviewer decisions and reconciliation workbook v0.3.
- Private archival record and SHA-256 checksums for both original reviewer workbooks; the originals remain outside Git.
- De-identified independent adjudicator pack limited to the four unresolved Dev cases.

### Pending

- Freeze the exact main-study model panel, execution manifest, review overlap, and statistical analysis plan.
- Execute, adjudicate, analyze, and release the main study under the versioned protocol.
