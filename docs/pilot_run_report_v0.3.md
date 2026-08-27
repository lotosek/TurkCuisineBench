# TurkCuisineBench methods pilot report v0.3

## Status

`pilot_run_v0.3` is the official two-model methods-pilot run for the frozen 36-item `TurkCuisineBench-Dev v0.2` set. Its purpose is to validate request execution, response capture, normalization, abstention detection, automatic exact matching, and routing to manual review. It is not a leaderboard and must not be used for headline model comparisons.

## Provider-neutral design

- 36 identical Turkish items per model endpoint;
- one fresh, stateless request per item;
- identical Turkish instruction and answer format;
- low reasoning effort;
- 1,024-token completion ceiling;
- tools, web access, retrieval, and conversational memory disabled;
- no retry triggered by answer content or correctness;
- the same technical-validity rules for all endpoints.

Temperature was set to zero where supported and omitted where the endpoint did not expose a compatible control. This provider-level difference is recorded explicitly.

## Technical outcome

| Model slot | Requested and returned model | Requests | Request errors | Empty responses | Incomplete or length-terminated responses |
|---|---|---:|---:|---:|---:|
| M1 | `gpt-5.5-2026-04-23` | 36 | 0 | 0 | 0 |
| M2 | `openai/gpt-oss-120b` via Groq | 36 | 0 | 0 | 0 |

The private raw log records completion metadata and token usage. Across the 36 requests, M1 used 3,166 input tokens and 5,917 output tokens, including 5,544 reported reasoning tokens. M2 used 5,506 input tokens and 2,392 output tokens, including 1,905 reported reasoning tokens. Token counts are tokenizer- and provider-specific and must not be treated as directly comparable measures of efficiency.

## Automatic routing outcome

| Model slot | Exact accepted match (`CO`) | Explicit abstention (`NA`) | Manual review required |
|---|---:|---:|---:|
| M1 | 17 | 0 | 19 |
| M2 | 4 | 5 | 27 |

These are routing counts, not final accuracy results. Responses outside the frozen exact accepted-answer set are sent to the same manual-review procedure for both models. The accepted-answer inventory must not be expanded post hoc from model outputs.

## Excluded technical records

An earlier 256-token run is retained in the private archive but excluded from scientific analysis. Although all HTTP requests returned successfully, 12 M1 records contained empty answer text and at least one additional response appeared truncated. The earlier runner did not preserve enough completion metadata to classify these cases reliably. A single M1 diagnostic request used to investigate the defect is also excluded.

The correction was not applied selectively: after increasing the completion ceiling and adding completion-metadata capture, the complete 36-item panel was rerun for both models under `pilot_run_v0.3`.

## Manual review and adjudication outcome

All 46 non-exact responses received independent, model-blinded coding by two reviewers. Pre-adjudication final-decision agreement was 43/46 (93.5%; Cohen's κ = .801). The 35 responses jointly coded `IN` had perfect agreement on the primary error operation (κ = 1.000). Three final-decision disagreements and two additional correct-variant disagreements were routed to third-review adjudication; all five were resolved.

| Final aggregate outcome | n | Rate over 72 valid responses |
|---|---:|---:|
| Exact accepted-answer match | 21 | 29.2% |
| Manually verified correct non-exact response | 9 | 12.5% |
| Semantically correct total | 30 | 41.7% |
| Manually verified incorrect response | 37 | 51.4% |
| Explicit abstention | 5 | 6.9% |

The five explanatory decision notes were documented by the lead researcher after adjudication from the recorded final code bundles, reviewer evidence, and cited official sources. They are audit documentation and are not represented as verbatim adjudicator prose. Original independent labels were preserved unchanged.

## Next gate

The pilot pipeline and `Taxonomy v1.0` are frozen. The next stage is construction and validation of an independent private Test set, followed by pre-registration of the exact model panel, execution configuration, overlap sample, and statistical analysis plan. No Test model request may be sent before those materials are versioned and checksummed.

## Integrity records

- Private raw log SHA-256: `F85112F64ED2770D01577DBC8F412F17E7A1189C24B9C8D23242D9C221F50D24`
- De-identified scored-table SHA-256: `60B682D7F5AF9F519C667B0AEECB5EFDA41AE9AF69B07EBDFBE994F866A5E25A`
