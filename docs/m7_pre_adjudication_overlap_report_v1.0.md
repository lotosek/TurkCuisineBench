# Main-study M7 pre-adjudication overlap report v1.0

Status: **Independent overlap reliability locked before adjudication; full lead review and adjudication remain open**

Analysis date: 2026-09-02

## Scope and data boundary

This public-safe report summarizes the prospectively selected 25% overlap among main-study responses routed to semantic review. It contains no Test question, answer, model response, source-row detail, reviewer rationale, model-to-response mapping, personal identifier, private checksum, or adjudicated label.

Both independent workbooks contained the same 82 opaque response identifiers and frozen evidence records. Every row had a decision, source check, confidence rating, rationale, and internally consistent conditional code. All 164 independent rating rows were marked complete, and neither workbook contained model or provider identity.

## Final-decision reliability

| Lead perspective \ Second reviewer | `CO` | `IN` | Row total |
|---|---:|---:|---:|
| `CO` | 8 | 0 | 8 |
| `IN` | 2 | 72 | 74 |
| Column total | 10 | 72 | 82 |

The reviewers agreed on 80 of 82 final decisions: 97.56% raw agreement. Chance-expected agreement was 80.43%, producing Cohen's κ = .875. This is the registered primary pre-adjudication reliability result.

## Taxonomy reliability

Error-operation reliability was calculated only among the 72 responses independently classified `IN` by both reviewers. All 72 operation codes agreed: 2 `ADDITION`, 10 `OMISSION`, and 60 `SUBSTITUTION`. Raw agreement and Cohen's κ were both 1.000.

Semantic-target coding also agreed for all 72 jointly incorrect responses (κ = 1.000). The agreed target counts were 16 `ATTRIBUTE_SPECIFICATION`, 11 `CULTURAL_HERITAGE`, 12 `INGREDIENT_COMPOSITION`, 6 `NUMERIC_TEMPORAL`, 10 `PLACE_ACTOR_RELATION`, 6 `TECHNIQUE_TOOL_PROCESS`, and 11 `TERMINOLOGY_ENTITY`.

Correct-variant agreement is descriptive because only eight responses were independently classified `CO` by both reviewers. Seven of eight variant codes agreed (87.50%; κ = .810). This coefficient is supplementary and should be interpreted cautiously because of the small denominator.

## Adjudication triggers

Three model-blinded cases require adjudication:

- two final-decision disagreements, each accompanied by conditional-code differences;
- one correct-variant disagreement with agreement on the `CO` decision.

There were no `ESCALATE` decisions, low-confidence ratings, or internally incomplete code bundles. Adjudication will resolve final labels but will not replace or recalculate the independent pre-adjudication reliability estimates.

## Remaining M6 work

The two returned files were both 82-row overlap workbooks. The lead-perspective ratings have been transferred into the private 326-row lead workbook, leaving 244 non-overlap responses for lead-researcher coding. Consequently, the independent overlap and reliability requirements are complete, but Gate M6 remains open until all 326 lead-review rows are complete.

## Next gate

1. Complete the remaining 244 lead-review rows without using the second reviewer's labels.
2. Complete the three-case model-blinded adjudication form.
3. Lock and checksum both completed outputs.
4. Join the final semantic labels to the sealed response mapping only after coding and adjudication are complete.
