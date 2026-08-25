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
