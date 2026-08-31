# TurkCuisineBench Main-Study Model and Prompt Manifest v0.1

Status: **FROZEN — Gate M4 passed on 2026-08-31 before Test execution.**
Prepared: 2026-08-28; frozen: 2026-08-31 (Europe/Istanbul)
Execution control: Test calls require the frozen private question-only file and a private execution copy of `configs/main_study_config_v1.0.json` in which only the authorization lock is changed from `false` to `true` after checksum verification.

## 1. Provider-neutral selection rule

The panel is selected by prespecified structural criteria rather than by expected performance: eight text-generation models; at least three inference providers; at least two openly available/open-weight model families; at least two capability/cost tiers; and exact provider-returned model identifiers archived at execution. A developer and its inference host are recorded separately. No provider receives extra tools, retrieval, web access, examples, feedback, or retries for substantive errors.

## 2. Frozen eight-model panel

| Slot | Inference provider | Model developer/family | Exact requested model ID | Tier | Open-weight | Access-probe result | M4 state |
|---|---|---|---|---|---:|---|---|
| S01 | OpenAI API | OpenAI GPT | `gpt-5.5-2026-04-23` | frontier | no | PASS; returned requested ID and `OK` | frozen/ready |
| S02 | OpenAI API | OpenAI GPT | `gpt-5.4-mini-2026-03-17` | efficient | no | PASS; returned requested ID and `OK` | frozen/ready |
| S03 | Anthropic Claude API | Anthropic Claude | `claude-sonnet-5` | frontier/standard | no | PASS 2026-08-28; returned requested ID and `OK` | frozen/ready |
| S04 | Anthropic Claude API | Anthropic Claude | `claude-haiku-4-5-20251001` | efficient | no | PASS 2026-08-28; returned requested ID and `OK` | frozen/ready |
| S05 | Google Gemini API | Google Gemini | `gemini-3.6-flash` | high capability/throughput | no | PASS 2026-08-31; returned requested ID and `OK` | frozen/ready; Paid Tier verified |
| S06 | Google Gemini API | Google Gemini | `gemini-3.5-flash-lite` | efficient | no | PASS 2026-08-31; returned requested ID and `OK` | frozen/ready; Paid Tier verified |
| S07 | GroqCloud | OpenAI GPT-OSS | `openai/gpt-oss-120b` | large open-weight | yes | PASS with minimum supported reasoning effort (`low`) and 128-token completion budget | frozen/ready |
| S08 | GroqCloud | Alibaba Qwen | `qwen/qwen3.6-27b` | mid-size open-weight | yes | PASS with reasoning disabled and returned `OK` | frozen/ready |

Replacement rule: a slot may be replaced only before Test execution, for documented access, retirement, endpoint, or budget failure. The replacement must preserve the provider/tier/open-weight structure. No replacement may be based on Dev performance alone. Any replacement requires a dated protocol amendment and a new access probe.

## 3. Frozen task prompt

System instruction:

> You are completing a closed-book Turkish short-answer benchmark about Turkish cuisine and culinary heritage. Do not browse, call tools, or use external sources. Give only the requested answer in Turkish, without explanation. If you do not know, output exactly: BİLMİYORUM

User message template:

> Soru: {{question_tr}}  
> Yanıt:

The prompt contains no worked example and no gold-answer information. The same Unicode text is sent to every provider. Provider-specific wrapper syntax is permitted only where required by the API and is logged.

## 4. Generation profile

- One fresh, stateless request per item; no conversation carry-over.
- Tools, browsing, retrieval, grounding, citations, files, and provider-side agents disabled.
- Lowest supported reasoning/thinking mode: OpenAI `none`; Anthropic explicitly disabled; Gemini `minimal`; Qwen `none`; and GPT-OSS `low`, because its endpoint does not permit disabling reasoning. The exact request field and returned usage are logged. These differences are platform constraints, not hidden harmonization.
- Reasoning traces are excluded from the recorded answer field. Groq receives `reasoning_format=hidden`; OpenAI reasoning output is not read as answer text; Anthropic thinking is disabled; and Gemini thinking summaries are not requested.
- Temperature `0` where supported. Claude Sonnet 5 and Gemini 3.x reject or discourage non-default sampling controls, so those fields are omitted and the omission is recorded rather than emulated client-side.
- Maximum completion budget: 128 provider-reported completion tokens. Visible responses are never substantively truncated by the scorer; termination metadata is retained.
- UTF-8 input/output; raw response retained before normalization.
- No retry because an answer is wrong, verbose, or surprising. Up to two retries are allowed only for logged transport/rate-limit/server failures, using the identical payload and model ID.
- A request is technically valid only when it succeeds, returns non-empty visible text, and has no incomplete/content-filter/length termination that prevents an answer.

## 5. Ordering and run control

- Deterministic seed: `20260828`.
- Generate a locked item order per model before execution and archive it with the Test freeze.
- Interleave providers in fixed blocks to reduce time-of-day and endpoint-drift confounding.
- Record UTC timestamps, provider request ID, requested and returned model ID, endpoint, status, stop reason, latency, token usage, retry count, and raw body hash for every attempt.
- Stop the full run if a model ID drifts, a prompt field is silently changed, more than 5% of a slot is technically invalid, or raw-capture reconciliation fails.

## 6. Scoring isolation

The execution file contains only `item_id` and `question_tr`. Gold answers, accepted answers, source facts, reviewer decisions, and taxonomy labels remain in the private key. Accepted answers and the error taxonomy are frozen before any Test output is inspected. Exact-match normalization is deterministic; all remaining technically valid responses are resolved under blinded human coding.

## 7. Verification record and current blockers

The OpenAI, Groq, and Google model lists were checked through authenticated model-list endpoints without exposing credentials. All eight access probes used only the neutral string `Return exactly OK.` and no benchmark content. On 2026-08-31, all eight requested IDs and their public list prices were rechecked on official documentation. The conservative, reproducible USD 5 run ceiling is recorded in [`model_cost_envelope_v0.1.md`](model_cost_envelope_v0.1.md). Prices and availability must still be checked immediately before execution because they can change.

Google AI Studio showed Tier 1/Paid with a positive prepaid balance on 2026-08-31; automatic reload was off. This resolved the S05–S06 data-use-tier condition before any Test request. Personal billing identifiers, payment details, and balance evidence remain outside Git.

Official references checked on 2026-08-31:

- OpenAI API model availability and pricing: https://platform.openai.com/docs/models and https://openai.com/api/pricing/
- Anthropic model IDs/versioning and pricing: https://platform.claude.com/docs/en/about-claude/models/overview and https://platform.claude.com/docs/en/about-claude/pricing
- Google Gemini model IDs and pricing: https://ai.google.dev/gemini-api/docs/models and https://ai.google.dev/gemini-api/docs/pricing
- Groq production models and pricing: https://console.groq.com/docs/models

M0–M3 and the private Test/question-only checksum step are complete. All eight access probes pass. The exact panel and `configs/main_study_config_v1.0.json` were frozen, and the final non-Test dry run passed with schedule hash `2278113054669e6ec639e81d5384ab4ac40ba0e40e0da7742bb277eff9ed32b7`. Gate M4 is complete.
