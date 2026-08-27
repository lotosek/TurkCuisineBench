# Changelog

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

- Construct and independently validate the 72-item private Test set.
- Freeze the exact main-study model panel, execution manifest, review overlap, and statistical analysis plan.
- Execute, adjudicate, analyze, and release the main study under the versioned protocol.
