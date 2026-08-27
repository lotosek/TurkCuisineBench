# Release Checklist

## Evidence and validation

- [x] Both original reviewer forms archived outside Git.
- [x] Reviewer decisions transcribed and integrity-checked against the source workbooks.
- [x] All disagreements adjudicated against the official source.
- [x] Reviewer identities removed from repository files.
- [ ] All source URLs checked immediately before release.
- [ ] Excluded candidates retained in a private development log.

## Data freeze

- [x] Dev version frozen and checksum recorded.
- [x] Pilot response-error taxonomy frozen as `Taxonomy v1.0`.
- [ ] Main Test version frozen and checksum recorded.
- [x] Dev gold and accepted-answer files locked before pilot execution.
- [ ] Public and hidden release components explicitly identified.
- [x] No API key, credential, personal form, or signature tracked by Git.

## Pilot and evaluation

- [x] Two exact pilot model configurations recorded.
- [x] Seventy-two pilot responses captured successfully.
- [x] Scorer unit tests pass.
- [x] Every manual-review row resolved.
- [x] Systematic prompt and scoring issues resolved before Test.
- [x] Main-study sequence and decision gates versioned before Test construction.
- [ ] Main evaluation includes diverse model families and exact version identifiers.
- [ ] Raw responses, latency, errors, and settings retained where permitted.

## Manuscript and repository

- [ ] English manuscript complete.
- [ ] Related work addresses current Turkish and culinary benchmarks.
- [ ] Data statement, ethics statement, and limitations included.
- [x] README and Dataset Card match the frozen Dev files.
- [ ] Code runs from a clean environment.
- [ ] Public license selected after rights review.
- [ ] `CITATION.cff` finalized.
- [ ] Public repository URL and release identifier added to the manuscript.
- [ ] arXiv version linked to the dataset record after posting.
