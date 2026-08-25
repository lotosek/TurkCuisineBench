# TurkCuisineBench-Dev v0.2 Validation Report

## Scope

This report documents the validation and freeze of the 36-item Turkish development set. It does not report pilot scores or main benchmark results.

## Review design

- Two independent reviewers assessed all 36 Dev items against the supplied official-source URLs.
- Reviewer A recorded 34 accept and 2 revise decisions.
- Reviewer B recorded 35 accept and 1 revise decisions; one additional case contained a field-level clarity concern requiring resolution.
- Thirty-two items were retained through complete concordant review.
- Four cases (`D002`, `D021`, `D022`, and `D034`) were routed to a third independent adjudicator.

## Adjudication outcome

The adjudicator supplied wording recommendations for the four flagged cases. The lead researcher transcribed those recommendations into the de-identified workflow and checked the final formulations against the official sources. The original reviewer and adjudicator files remain in the private research archive and are not stored in Git.

| Item | Resolution | Gold/accepted-answer change |
|---|---|---|
| D002 | Clarified that the traditional drying surface is a woven mat/cover. | None |
| D021 | Specified that the invitation occurs on the day after the engagement ceremony. | None |
| D022 | Added the Afyon sıra yemeği context to delimit the culinary term. | None |
| D034 | Removed the unnecessarily broad word “dönem”. | None |

## Freeze outcome

- Final item count: 36
- Question wording changes after duplicate review: 4
- Gold-answer changes: 0
- Accepted-answer changes: 0
- Unresolved Dev validation cases: 0
- Frozen release: `TurkCuisineBench-Dev v0.2`
- Frozen XLSX and CSV checksums: recorded in `data/dev/SHA256SUMS_v0.2.txt`

The Dev set is frozen for the methods pilot. It remains separate from the main Test benchmark and must not be used for headline model-ranking claims.
