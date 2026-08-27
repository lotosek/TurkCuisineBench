# Development Protocol

## Objective

TurkCuisineBench evaluates whether language models can produce concise, factually supported answers to Turkish questions concerning Turkish cuisine and culinary heritage without external tools or retrieval.

## Canonical language

Turkish is the canonical benchmark language. The research article is written in English. Any future English benchmark version must be treated as a paired translation requiring separate validation; it must not silently replace the Turkish items.

## Source policy

Candidate facts are drawn from official or institutional sources, prioritizing:

1. TÜRKPATENT geographical-indication registration documents;
2. UNESCO Intangible Cultural Heritage records;
3. Republic of Türkiye Ministry of Culture and Tourism resources;
4. other primary institutional records meeting documented inclusion criteria.

Each retained item preserves a source-fact identifier and source URL.

## Item format

- Short-answer factual question answering.
- One primary gold answer with explicitly registered accepted variants.
- No fuzzy automatic matching.
- L0 items are preferred, with a limited number of documented L1 boundary cases.
- L2 items are excluded.

## Validation

The Dev set receives full duplicate independent review. Flagged Dev cases are resolved by a third independent adjudicator against the official source; the lead researcher transcribes the de-identified outcome and provenance. The planned main benchmark uses risk-based review: all higher-risk items receive duplicate review, while lower-risk items are distributed between reviewers with stratified overlap. Any main-study disagreement will be resolved under the recorded adjudication protocol rather than by changing answers in response to model outputs.

Paper reviewer forms remain outside version control because they may contain personal data and signatures. Only de-identified decisions and adjudication outcomes may enter the research repository.

## Pilot

The Dev pilot uses two fixed model slots and one response per model-item pair. Its purpose is to test prompt behaviour, response capture, Turkish-aware normalization, abstention, and human-review routing. Pilot scores are not main benchmark results.

The configured pilot endpoints are the `gpt-5.5-2026-04-23` snapshot through the OpenAI Responses API and the hosted open-weight `openai/gpt-oss-120b` model through Groq's OpenAI-compatible Chat Completions API. Under `pilot_run_v0.3`, both receive the same 36 items, Turkish prompt, low reasoning effort, 1,024-token completion ceiling, stateless single-shot request policy, and prohibition on tools, web access, and retrieval. M2 reasoning traces are hidden so the recorded raw response contains the requested answer rather than chain-of-thought text. Temperature is set to zero where the endpoint supports it and omitted where the endpoint does not expose a compatible control; this provider constraint is disclosed rather than silently harmonized.

Provider-neutral validity rules apply to every model. A response is technically valid only if the request succeeds, the provider reports normal completion, the answer text is non-empty, and no length or content-filter termination is reported. Content correctness never triggers a retry. If a protocol-level defect requires a revised run, the complete model panel is rerun under a new protocol version rather than selectively rerunning one model. The provider, requested model identifier, returned model identifier, request identifier, timestamps, latency, token usage, completion metadata, and generation settings are recorded in the private raw log. Because the hosted open-weight endpoint does not provide a benchmark-controlled weight or serving snapshot, provider-side version drift must be reported as a reproducibility limitation.

An initial 256-token technical run was retained privately but excluded because it produced empty or truncated outputs for one endpoint and did not capture sufficient completion metadata. A single diagnostic request used to investigate that defect is also excluded. The official methods-pilot record is `pilot_run_v0.3`, in which the full two-model panel was rerun under identical eligibility and retry rules.

All 46 non-exact responses from `pilot_run_v0.3` were independently coded by two blinded reviewers. Pre-adjudication final-decision agreement was 43/46 (93.5%; Cohen's κ = .801). Among the 35 responses jointly coded `IN`, primary-operation agreement was 100% (κ = 1.000). Three final-decision disagreements and two additional correct-variant disagreements were routed to a third reviewer. The five final decision bundles were then documented by the lead researcher against the frozen question, answer inventory, reviewer evidence, and official source. The original independent labels remain unchanged in the private audit record.

The final pilot consensus contains 21 exact accepted-answer matches, 9 manually verified correct non-exact responses, 37 manually verified incorrect responses, and 5 explicit abstentions. Semantic accuracy is therefore 30/72 (41.7%), exact-match accuracy is 21/72 (29.2%), and the abstention rate is 5/72 (6.9%). These are aggregate methods-pilot outcomes and must not be presented as a model ranking. The error taxonomy is frozen as `Taxonomy v1.0` for prospective Test coding.

## Freeze rules

- Accepted answers are frozen before the official model evaluation.
- Model outputs must never be used to add post-hoc accepted answers.
- Every frozen data file receives a version identifier and checksum.
- Dev and Test remain separate; Dev results are not used as headline leaderboard results.

## Scoring

Raw responses are preserved. Normalization applies Unicode NFC, Turkish-aware lowercasing, whitespace normalization, dash normalization, removal of one exact leading `Cevap:` label, and removal of terminal punctuation. Turkish diacritics are not globally removed.

An exact match with a registered answer is labeled `CO`. An exact `Bilmiyorum` response is labeled `NA`. Every other response is routed to human review; substring and fuzzy matches are not automatically accepted.

## Limitations to report

- Culinary knowledge is regionally variable and not exhausted by institutional sources.
- Official registration records may privilege standardized formulations over lived practice.
- Short-answer scoring cannot capture all culturally plausible explanations.
- Public release may contribute to future benchmark contamination.
- Model-provider updates may limit exact longitudinal replication unless model snapshots are available.
