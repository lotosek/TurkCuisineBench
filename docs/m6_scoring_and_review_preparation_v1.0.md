# Main-study M6 scoring and review preparation v1.0

Status: **Automatic routing and prospective overlap selection complete; independent human coding remains open**

Preparation date: 2026-08-31

## Scope

This record documents the public-safe preparation of blinded semantic-review materials after Gate M5. It contains no Test question, answer, response text, reviewer label, model-to-response mapping, private checksum, credential, or personal identifier.

## Frozen automatic routing

The main-study adapter applies `scorer_tr_v0.1` without changing the pilot-frozen Turkish normalization, exact-match, or explicit-abstention rules. Technically invalid responses are isolated before correctness scoring and never presented as semantic errors.

| Route | Count | Treatment |
|---|---:|---|
| `CO` | 187 | Exact normalized match to a prospectively registered accepted answer; no manual review |
| `NA` | 61 | Explicit knowledge abstention under the frozen rule; no manual review |
| `REVIEW` | 326 | Technically valid non-exact response requiring source-based semantic review |
| `TECHNICAL_INVALID` | 2 | Excluded from semantic scoring and reported separately |
| Total | 576 | Complete response ledger |

The automatic and final human labels remain distinct. A manually accepted non-exact response may recover correctness for that response but cannot expand the frozen accepted-answer inventory post hoc.

## Prospective overlap selection

The registered selector was applied before any non-exact response was semantically inspected. The second-review target is the ceiling of 25% of 326 manual-review candidates: 82 responses (25.15%). Hamilton allocation balanced the primary model-slot × knowledge-domain strata, followed by deterministic balance across knowledge specificity, lexical cue level, answer form, and numeric status. The public seed is `20260828`; the separate blinding salt and all mappings remain private.

## Reviewer materials

Two private workbooks were generated outside Git:

- lead researcher: all 326 manual-review candidates, split across three review sheets;
- second reviewer: only the frozen 82-response overlap, in an independently ordered review sheet.

Both workbooks use opaque response identifiers and omit provider, model, request, and execution-run identifiers. Frozen question/response/answer/source evidence is visually separated from editable coding cells. Data validation exposes only the pilot-frozen decision, correct-variant, error-operation, and semantic-target codes. Formula-driven quality control requires a source check, confidence rating, and rationale and routes low-confidence, `ESCALATE`, and fallback cases to adjudication.

The workbooks also reproduce the frozen taxonomy, semantic-target definitions, and correct-but-non-exact variant codes without modification. Two technically invalid responses appear only in the lead workbook's separate technical-outcome sheet and receive no semantic decision.

## Verification completed

- 326 lead-review rows and 82 second-review rows reconciled against the private routing ledger;
- zero model/provider identity fields or execution-run identifiers detected in either workbook;
- zero spreadsheet formula errors detected after XLSX export and re-import;
- every worksheet rendered and visually inspected;
- the previously observed wide/blank `START_HERE` layout defect was corrected before release to reviewers;
- all private inputs, outputs, blinding mappings, selection records, and integrity checksums remain outside Git.

## Gate state

M6 is not complete merely because the files exist. Gate M6 closes only after the lead researcher completes all 326 codes, the second reviewer independently completes all 82 overlap codes, both files are locked before comparison, and pre-adjudication agreement records are generated. Model identities must remain sealed through reliability calculation and adjudication.
