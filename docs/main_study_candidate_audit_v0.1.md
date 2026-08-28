# Main-Study Candidate Audit v0.1

Audit date: 2026-08-28  
Release scope: aggregate, public-safe metadata only; no Test question, gold answer, accepted-answer inventory, or reviewer identity is included.

## Outcome

The private candidate master contains 72 candidate items and 72 unique source-fact identifiers in the new `TF001–TF072` namespace. These records are candidates, not a frozen Test. All rows remain pending human source validation.

| Check | Result |
|---|---:|
| Candidate items | 72 |
| Unique candidate item IDs | 72 |
| Unique candidate source-fact IDs | 72 |
| Official-source URLs | 38/38 accessible |
| Items per K1–K6 domain | 12 each |
| Lexical cue levels | 60 L0; 12 L1; 0 L2 |
| Numeric/temporal items | 6 |
| Terminology/traditional-practice items | 16 |
| Technical culinary process/tool items | 12 |
| Cultural/heritage-context items | 12 |
| Single-word gold answers | 36 |
| Items with multiple preregistered accepted forms | 53 |
| Gold answers represented in preregistered accepted-answer lists | 72/72 |
| Missing core fields | 0 |
| Exact Test–Dev question matches | 0 |
| Same-source and same-gold Test–Dev matches | 0 |
| Spreadsheet formula errors | 0 |

The automated screen found three repeated normalized gold answers: one answer occurs in three candidates and two answers occur in two candidates each. These are legitimate category or locality answers, not duplicate source facts. They remain visible to human validators and will be reconsidered if they create answer-frequency or construct-redundancy concerns.

## M3 sampling correction

An initial workbook implementation treated the 18-item stratified overlap as the entire second-review set. Retrospective comparison with the protocol showed that all L1, numeric, and medium/high ambiguity candidates also require a second independent review. The implementation was corrected prospectively, before human main-study validation and before all Test model requests:

- 18 balanced items remain the primary agreement sample (25% of 72).
- Twelve additional medium-ambiguity candidates are included by the risk-expansion rule.
- The full second-review set therefore contains 30 items.
- Primary agreement will be reported on the balanced 18-item subset; a sensitivity agreement estimate will be reported on all 30 enriched rows.

## Interpretation and remaining limits

Automated checks establish structural integrity; they do not prove factual correctness, ambiguity resolution, domain validity, or construct-level separation from Dev. M3 reviewers must open every cited official source, verify the requested relation and gold scope, assess accepted-answer completeness, and adjudicate every disagreement or low-confidence judgment. No candidate may be promoted to the frozen Test solely because this audit passed.
