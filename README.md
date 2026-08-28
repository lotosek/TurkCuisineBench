# TurkCuisineBench

**Repository status:** Private development workspace; not a public benchmark release.

TurkCuisineBench is a source-grounded, Turkish-language short-answer benchmark for evaluating large language models on knowledge of Turkish cuisine, culinary techniques, local terminology, geographical-indication specifications, and food-related cultural heritage.

The benchmark is designed around item-level provenance, conservative answer normalization, explicit ambiguity and leakage metadata, and human validation against official or institutional sources.

## Current development status

- The 36-item Dev set is frozen as `TurkCuisineBench-Dev v0.2` with recorded SHA-256 checksums.
- Two independent reviewer forms have been archived outside Git and transcribed into the de-identified validation workbook.
- Thirty-two items received complete, concordant acceptance. Four flagged cases (`D002`, `D021`, `D022`, and `D034`) were resolved using wording recommendations from a third independent adjudicator, transcribed by the lead researcher and checked against the official sources.
- Adjudication changed question wording only; no gold answer or accepted-answer set was changed.
- A provider-neutral 72-response methods pilot was completed under `pilot_run_v0.3`: 36 single-shot requests for `gpt-5.5-2026-04-23` through the OpenAI Responses API and 36 for `openai/gpt-oss-120b` through Groq's OpenAI-compatible API. All 72 requests completed without empty or truncated responses.
- All 46 non-exact pilot responses received independent double coding. Pre-adjudication decision agreement was 93.5% (Cohen's κ = .801); operation coding among the 35 responses jointly coded incorrect was perfectly concordant (κ = 1.000). Five routed cases were resolved through third-review adjudication.
- The final pilot consensus contains 21 exact accepted-answer matches and 9 manually verified correct responses, for 30/72 semantic accuracy (41.7%). These aggregate figures validate the pipeline and are not used as a model leaderboard.
- The pilot error taxonomy is frozen as `Taxonomy v1.0` for prospective main-study coding.
- The main Test benchmark is private and is not included in this repository. Its 72-item content was frozen after M3 validation on 2026-08-28; full M4 and all model execution remain blocked. The current prospective gate status is recorded in [`docs/main_study_status.md`](docs/main_study_status.md).
- Two independent validators completed all 72 items. Eleven disagreements were resolved by lead-researcher adjudication, producing 61 unchanged items, 11 source-grounded revisions, and no exclusions. The locked 18-item primary agreement analysis remains distinct from the supplementary all-item comparison.
- A public-safe aggregate validation report is available at [`docs/main_study_item_validation_report_v1.0.md`](docs/main_study_item_validation_report_v1.0.md). Private questions, keys, reviewer labels, rationales, adjudication records, and hashes remain outside Git.
- The provisional eight-model M4 panel and provider-neutral prompt rules are documented in [`docs/model_panel_manifest_v0.1.md`](docs/model_panel_manifest_v0.1.md); this is not authorization to execute the private Test.
- Statistical Analysis Plan v1.0 and the deterministic, privately salted 25% response-review overlap selector are frozen before Test responses; their checksums and preparatory non-Test dry-run record are in [`docs/m4_methods_manifest_v0.1.md`](docs/m4_methods_manifest_v0.1.md).
- Official model IDs and prices were rechecked symmetrically across all four providers, and a conservative USD 5 execution ceiling was registered in [`docs/model_cost_envelope_v0.1.md`](docs/model_cost_envelope_v0.1.md). Anthropic and Google access probes remain pending.
- No model-level pilot ranking is released. Private reviewer returns, adjudication records, model-to-review mappings, and row-level consensus audit files remain outside Git.

The frozen Dev set may be used to debug the prompt, response capture, normalization, abstention, and scoring pipeline. It must not be used for headline leaderboard claims. The main Test set will remain separate and private until its evaluation protocol is frozen.

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

The ordered main-study workflow, decision gates, review design, and planned analysis are specified in [`docs/main_study_protocol_v1.0.md`](docs/main_study_protocol_v1.0.md).

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
