# Dataset Card Draft

## Dataset summary

TurkCuisineBench is a manually curated, source-grounded benchmark for Turkish short-answer question answering in the domain of Turkish cuisine and culinary heritage.

## Current version

`TurkCuisineBench-Dev v0.2` contains 36 frozen development items. Two independent reviewers assessed every item. Four flagged cases were resolved using wording recommendations from a third independent adjudicator, transcribed by the lead researcher and verified against official sources. The resolution changed four question formulations and changed no gold or accepted answers. The two-model methods pilot has been prepared but not run.

## Languages

- Canonical language: Turkish (`tr`)
- Manuscript language: English
- A validated English paired version is not currently available.

## Tasks

- Closed-book short-answer question answering
- Factual cultural and culinary knowledge evaluation
- Abstention-aware model evaluation

## Knowledge domains

- Ingredients and composition
- Preparation and cooking techniques
- Geographical indications and product specifications
- Culinary terminology and traditional practices
- Culinary history, heritage, and cultural context

## Data fields

Core fields include item and source-fact identifiers, knowledge-domain metadata, question, gold answer, accepted answers, source URL and type, lexical-leakage risk, ambiguity risk, temporal stability, numeric-answer status, development-case type, review status, and notes.

## Data creation

Facts are selected from official or institutional records. Questions and answer variants are manually constructed and reviewed. The benchmark excludes unsupported facts, unstable items without a defensible temporal policy, and questions whose wording creates unacceptable answer leakage or ambiguity.

## Intended uses

- Evaluate LLM factual knowledge of Turkish cuisine.
- Study error patterns involving local terminology and culinary heritage.
- Test conservative short-answer normalization and abstention.
- Support research on culturally grounded evaluation for Turkish NLP.

## Out-of-scope uses

- Training or fine-tuning on the Test answer key.
- Treating benchmark answers as exhaustive definitions of Turkish culinary culture.
- Ranking people, regions, or cultural traditions.
- Substituting benchmark performance for professional culinary expertise.

## Biases and limitations

Institutional-source grounding improves traceability but may underrepresent oral, household, minority, diasporic, and contested traditions. Coverage is selective rather than encyclopedic. Regional naming variation requires explicit accepted-answer management and human review.

## Personal and sensitive information

The released benchmark is not intended to contain personal data. Reviewer names, signatures, email addresses, and identifiable forms are excluded from the repository.

## Licensing

Licensing remains under review. No public reuse license is granted by this development draft.
