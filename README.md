# TurkCuisineBench

**Repository status:** Private development workspace; not a public benchmark release.

TurkCuisineBench is a source-grounded, Turkish-language short-answer benchmark for evaluating large language models on knowledge of Turkish cuisine, culinary techniques, local terminology, geographical-indication specifications, and food-related cultural heritage.

The benchmark is designed around item-level provenance, conservative answer normalization, explicit ambiguity and leakage metadata, and human validation against official or institutional sources.

## Current development status

- A 36-item Dev set has been prepared.
- Two independent reviewer forms have been archived outside Git and transcribed into the de-identified validation workbook.
- Thirty-two items received complete, concordant acceptance. Four items (`D002`, `D021`, `D022`, and `D034`) require documented independent adjudication because of revision flags, a field-level clarity concern, or one missing required judgment.
- A de-identified four-case adjudicator pack has been prepared so a third independent reviewer can resolve only the flagged cases against the official sources.
- A 72-response methods pilot package has been prepared for two fixed model slots.
- The main Test benchmark is under development and is not included in this repository.
- No pilot scores or headline model comparisons have been released.

The current Dev files are **not formally frozen**. Reviewer evidence is archived and transcribed, but the four pending cases must be adjudicated and the resulting Dev file must receive a recorded checksum before the pilot is run or a final benchmark release is claimed.

## Repository structure

```text
data/dev/                 Development items and fixed pilot requests
data/test_private/        Placeholder only; private Test answers are excluded
docs/                     Development protocol, dataset card, and release checklist
evaluation/               Pilot runner, scorer, and normalization tests
configs/                  Secret-free example model configuration
paper/                    English manuscript outline and table plan
workbooks/                Editable internal research workbooks
```

## Evaluation principle

Each question is sent as a new stateless request. Tools, web browsing, retrieval, and conversational memory are disabled. Responses are preserved verbatim before Turkish-aware normalization.

- `CO`: exact normalized match to a pre-registered accepted answer.
- `NA`: explicit `Bilmiyorum` response.
- `REVIEW`: all other responses, requiring manual resolution as `CO`, `IN`, or `NA` without post-hoc expansion of accepted answers.

## Data and release policy

This repository is private during development to reduce benchmark leakage and prevent premature distribution of unfrozen gold answers. Reviewer identities, signed forms, API credentials, and private Test answer keys must never be committed.

At public release, the repository will provide code, versioned documentation, evaluation settings, and the permitted benchmark components. The dataset is expected to receive a separate Hugging Face Dataset Card and an archived release identifier.

## Citation

Citation metadata will be finalized after the author list, manuscript title, release version, repository URL, and persistent identifier have been confirmed. See `CITATION.cff.template`.

## License

No public reuse license has yet been granted. See `LICENSES.md`.
