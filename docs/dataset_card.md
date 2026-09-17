# Dataset Card

## Dataset summary

TurkCuisineBench is a manually curated, source-grounded benchmark for Turkish short-answer question answering in the domain of Turkish cuisine and culinary heritage.

## Current version

This repository contains the public 36-item Dev set and aggregate results for
the separate, private 72-item Test-v1 evaluation. Test-v1 has twelve items in
each of six domains, 60 L0 and 12 L1 items, six numeric-answer items, and 38
official or institutional source URLs. Eight endpoints produced 576 expected
records, of which 574 were technically valid. The Test question/answer key and
row-level records are not included. See [current study status](main_study_status.md)
and [controlled access](controlled_access.md).

`TurkCuisineBench-Dev v0.2` contains 36 frozen development items. Two independent reviewers assessed every item. Four flagged cases were resolved using wording recommendations from a third independent adjudicator, transcribed by the lead researcher and verified against official sources. The resolution changed four question formulations and changed no gold or accepted answers. A provider-neutral two-model methods pilot was completed under `pilot_run_v0.3`. All 46 non-exact responses were independently double coded, five routed cases were adjudicated, and the pilot taxonomy was frozen as `Taxonomy v1.0`. Pilot aggregates validate the pipeline and are not used for headline model ranking.

## Languages

- Canonical language: Turkish (`tr`)
- Manuscript language: English
- A validated English paired version is not currently available.

## Tasks

- Closed-book short-answer question answering
- Factual cultural and culinary knowledge evaluation
- Abstention-aware model evaluation

## Knowledge domains

- Dishes, products, and geographic associations
- Ingredients and composition
- Preparation and cooking techniques
- Geographical indications and product specifications
- Culinary terminology and traditional practices
- Culinary history, heritage, and cultural context

The operational definitions and decision boundary between geographic association (K1) and registered product specification (K4) are frozen in [`main_study_protocol_v1.0.md`](main_study_protocol_v1.0.md).

## Public Dev data fields

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

The small L1 set limits precision; a nonsignificant lexical-cue contrast does
not establish equivalence. Multiple items share sources, and item-level Wilson
intervals are descriptive rather than source-cluster adjusted. Exact correctness
is nested within semantic correctness. The extreme-scale H3 model does not
support an unqualified confirmatory interpretation; see the
[dated reporting amendment](interpretation_amendment_2026-09-17.md).

## Personal and sensitive information

The released benchmark item files do not contain reviewer identities,
signatures, personal contact details, or identifiable forms. Author attribution
and the corresponding author's institutional contact are public. Historical
Dev workflow workbooks contain de-identified Dev review records, not private
Test review workbooks.

## Licensing

Author-created public software uses MIT. Covered public Dev material, original documentation and aggregate results use CC BY 4.0 under the revised 17 September 2026 decision in `LICENSES.md`. Active Test, private reviewer records, manuscripts and third-party works are excluded. See `controlled_access.md` for confidential audit requests.
