# Changelog

## Unreleased

### Frozen Dev v0.2

- Resolved the four flagged Dev cases (`D002`, `D021`, `D022`, and `D034`) using independent adjudicator wording recommendations transcribed by the lead researcher and verified against official sources.
- Revised the wording of four Turkish questions; changed zero gold answers and zero accepted-answer sets.
- Frozen the 36-item Dev set and recorded SHA-256 checksums for its XLSX and CSV representations.
- Added validation workflow v0.4 and pilot execution package v0.2.
- Regenerated all 72 fixed pilot requests from the frozen Dev questions.

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

- Configure and run the two-model pilot.
- Resolve pilot scoring issues before freezing the main Test protocol.
- Complete, validate, and evaluate the main Test benchmark.
