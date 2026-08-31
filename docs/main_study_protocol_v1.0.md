# TurkCuisineBench Main Study Protocol v1.0

**Status:** Prospectively frozen before main-study responses; Gates M0–M5 completed and M6 reviewer materials prepared on 2026-08-31.

**Canonical language:** Turkish benchmark items and responses; English manuscript and repository documentation.
**Primary purpose:** Evaluate model knowledge of Turkish cuisine under source-grounded, closed-book, provider-neutral conditions while preserving strict Dev/Test separation.

## 1. Non-negotiable decisions inherited from the pilot

1. `TurkCuisineBench-Dev v0.2` remains a development resource. It may be used only for prompt, parser, normalization, abstention, scoring, and reviewer-workflow debugging.
2. Dev items and facts must not appear in the main Test set, including paraphrased duplicates of the same underlying fact.
3. `Taxonomy v1.0` is frozen before Test responses are inspected. New patterns may be recorded as `OTHER_EMERGENT`, but the taxonomy may not be silently changed during model comparison.
4. The accepted-answer inventory is frozen before model execution and is never expanded from observed model outputs.
5. Semantic accuracy after blinded human resolution is the primary outcome. Exact-match accuracy, abstention, technical validity, and error distributions are secondary outcomes.
6. Every model receives the same items, Turkish instruction, closed-book restrictions, eligibility rules, and correctness-independent retry policy.
7. Pre-adjudication agreement and post-adjudication consensus are stored and reported separately.
8. Private Test answers, reviewer identities, model-to-review mappings, and signed or identifiable records remain outside Git.

## 2. Planned design at a glance

| Component | Prospective specification |
|---|---|
| Test size | 72 scored items; if fewer than 72 survive validation, expand the official-source fact pool before model execution rather than weakening inclusion rules |
| Knowledge domains | Six domains, target 12 items per domain |
| Lexical cue level | 60 L0 items and 12 L1 boundary items; no L2 items |
| Knowledge specificity | Recorded separately as General, Regional, Local, Technical, or a justified compound label |
| Numeric answers | Controlled minority of 4–6 items |
| Sources | Official or institutional sources, with preference for TÜRKPATENT, UNESCO, and Turkish Ministry/Kültür Portalı records |
| Primary model panel | Preferred eight models; minimum six, representing at least three providers, at least two open-weight models, and more than one capability/size tier |
| Primary sampling | One independent, stateless response per model-item pair |
| Preferred workload | 72 items × 8 models = 576 primary responses |
| Human review | Lead researcher reviews 100% of non-exact responses under model blinding |
| Reliability overlap | A preselected stratified 25% of non-exact responses receives a second independent review |
| Adjudication | Every overlap disagreement, every `ESCALATE`, and every low-confidence case |
| Primary outcome | Reconciled semantic accuracy among technically valid responses |

The 72-item target provides twelve items per domain and a manageable paired design. It is a coverage and feasibility target, not a claim of universal statistical adequacy. Confidence intervals and item-clustered analyses must accompany all estimates.

### Frozen operational domain definitions

The six domains are mutually exclusive primary labels assigned to the fact requested by the question. Secondary culinary features may be recorded in notes, but they do not change the primary domain.

| Code | Domain | Operational inclusion rule |
|---|---|---|
| K1 | Dishes, Products & Geographic Associations | The requested fact is the official geographic association, locality, or regional attribution of a named dish or food product. Product names that directly reveal the answer are excluded as L2. |
| K2 | Ingredients & Composition | The requested fact is an ingredient, component, filling, garnish, raw material, or compositional relation. |
| K3 | Preparation & Cooking Techniques | The requested fact is a preparation sequence, cooking method, tool, vessel, fuel, temperature stage, or transformation process. |
| K4 | Geographical Indications & Product Specifications | The requested fact is a registered specification, measurable production constraint, product class, registration attribute, or other requirement established by an official GI record. Geographic origin alone remains K1. |
| K5 | Culinary Terminology & Traditional Practices | The requested fact is a culinary term, named local practice, service convention, production role, or customary action. |
| K6 | Culinary History, Heritage & Cultural Context | The requested fact is a historical person/event, heritage-list context, ritual meaning, social function, transmission context, or commemorative association. |

These labels describe knowledge content rather than empirical difficulty. Specificity and lexical leakage remain separate item-level variables.

## 3. Research questions and hypotheses

### Research questions

- **RQ1:** How does source-grounded semantic accuracy differ across the evaluated models?
- **RQ2:** How does performance vary by knowledge domain, knowledge specificity, lexical cue level, answer form, and numeric-answer status?
- **RQ3:** How large is the gap between strict normalized exact match and adjudicated semantic accuracy?
- **RQ4:** Which error operations and semantic targets are most prevalent overall and within each model?
- **RQ5:** How frequently do models abstain or produce technically invalid responses under identical closed-book conditions?

### Confirmatory hypotheses

- **H1:** Semantic accuracy differs across models under the paired Test-item design.
- **H2:** Accuracy is lower on L0 than on L1 lexical-cue items because L1 questions contain limited contextual cues. This contrast concerns `lexical_leakage`, not the separate `knowledge_specificity` field.
- **H3:** Strict exact-match accuracy is lower than adjudicated semantic accuracy because some correct Turkish answers use legitimate inflectional, word-order, paraphrastic, or more-specific forms.

Error-category differences are exploratory unless a directional hypothesis is registered before model execution.

## 4. Phase M0 — Governance and private workspace

### Actions

1. Create a private main-study directory outside the public repository.
2. Copy the frozen Dev files, `Taxonomy v1.0`, prompt, scorer, normalization tests, and pilot audit checksums into a read-only archive.
3. Record the principal investigator, item validators, response reviewers, and adjudicator using private reviewer codes rather than names in analytical files.
4. Record the study-classification decision and the public/private data boundary.
5. Define contribution credit in advance. Assistance alone does not imply authorship; acknowledgements require consent, and authorship follows substantive scholarly contribution.
6. Create an append-only decision log. Every later protocol change receives a new dated entry and version number.

### Gate M0

- [ ] Private archive created and backed up.
- [ ] Roles and identifiers recorded privately.
- [x] Study classification and data-governance position documented.
- [ ] Frozen pilot files and checksums archived.
- [ ] No credentials, personal reviewer data, or private Test keys are tracked by Git.

## 5. Phase M1 — Test source-fact audit

### Actions

1. Start from unused validated source facts; exclude every fact underlying a Dev item.
2. Detect construct duplicates, not merely identical wording. Two questions testing the same dish–fact relation count as an overlap even if phrased differently.
3. Re-open every official source URL and record access date, document title, issuing institution, relevant page/section, and source stability.
4. Exclude inaccessible, superseded, weakly authoritative, temporally unstable, or culturally contested facts unless the uncertainty is explicitly part of the item design.
5. Preserve every rejected candidate with `item_status=excluded` and a specific `exclusion_reason`.
6. Expand the source-fact pool from new official records if fewer than 72 defensible, non-overlapping items remain.

### Required Test item fields

`item_id`, `source_fact_id`, `knowledge_domain`, `knowledge_specificity`, `question_tr`, `gold_answer`, `accepted_answers`, `source_url`, `source_type`, `source_location`, `source_access_date`, `lexical_leakage`, `ambiguity_risk`, `temporal_stability`, `numeric_answer`, `answer_form`, `item_status`, `exclusion_reason`, and `notes`.

### Gate M1

- [ ] Dev/Test fact-level overlap equals zero.
- [ ] Every retained item has an accessible official/institutional source.
- [ ] Every exclusion is preserved with a reason.
- [ ] At least 72 candidates survive source and duplication screening.

## 6. Phase M2 — Item writing and leakage control

### Actions

1. Write Turkish short-answer questions that request one clearly defined fact.
2. Prefer L0 wording. Permit only twelve L1 boundary cases needed for realistic contextual variation.
3. Exclude all L2 questions where the answer is directly recoverable from the wording, named product, or trivial geographic cue.
4. Keep numeric questions to 4–6 items and predefine acceptable units, ranges, and equivalent expressions.
5. Build accepted answers from source-supported linguistic variants before any model output is seen.
6. Do not add merely plausible synonyms. Each accepted form must preserve the same referent, relation, quantity, and scope.
7. Run automated checks for duplicate `item_id`, duplicate `source_fact_id`, empty fields, malformed URLs, duplicate questions, gold-answer leakage, and Dev/Test overlap.

### Planned composition controls

- Exactly 12 items from each of the six knowledge domains.
- 60 L0 and 12 L1 items; 0 L2.
- At least 16 items targeting culinary terminology or a named traditional practice, role, service convention, or customary action. This operational flag is broader than geographic locality alone and is reported as `terminology_or_traditional_practice`.
- At least 12 technical culinary-process/tool items.
- At least 12 cultural/heritage-context items.
- At least 16 single-word gold answers.
- At least 12 items with more than one preregistered accepted form.
- Four to six numeric/temporal answers.

These answer-form and content targets may overlap; they are not mutually exclusive strata.

### Gate M2

- [x] Composition targets satisfied.
- [x] All 72 items pass leakage and ambiguity checks.
- [x] Accepted answers were written without access to model outputs.
- [x] Automated integrity checks pass.

## 7. Phase M3 — Independent item validation

### Actions

1. The lead researcher verifies every retained item against the official source.
2. Each item receives one independent validation by a qualified colleague who has not seen model outputs.
3. Before validation begins, select a stratified 25% of items for a second independent validation. Balance the overlap by domain, specificity, answer form, numeric status, and ambiguity risk.
4. Require 100% additional review for all L1, numeric, medium/high ambiguity, or low-confidence cases even if this exceeds 25%.
   The locked 18-item stratified subset is the primary agreement sample. Risk-triggered additions are also double-reviewed but are reported separately as a sensitivity agreement estimate because the enriched set is not prevalence-representative.
5. Validate source support, question clarity, gold correctness, accepted-answer completeness, leakage level, and domain assignment separately.
6. Route all disagreements and low-confidence decisions to adjudication. Preserve the pre-adjudication labels.
7. Revise items only from source-grounded reviewer recommendations; rerun all integrity checks after revision.

### Gate M3

- [x] Every final item has lead-researcher and independent-review approval.
- [x] The 18-item primary agreement sample and all risk-triggered additions are complete; agreement is reported separately for the primary sample and the full enriched second-review set before adjudication.
- [x] All disagreements and flags are resolved.
- [x] No item remains medium/high ambiguity without an explicit inclusion justification.

Implementation record (2026-08-28): both independent validators completed all 72 items. The locked 18-item comparison remains the primary agreement result, the risk-expanded 30-item set remains the prespecified sensitivity result, and the all-72 comparison is supplementary. Eleven disagreements were resolved by lead-researcher adjudication; this decision stage is not counted as a third independent review.

## 8. Phase M4 — Freeze Test, models, prompt, and analysis

### Test freeze

1. Assign final immutable Test IDs.
2. Export the private Test item file and a question-only execution file.
3. Compute SHA-256 checksums for both files.
4. Store the answer key privately and expose only the question-only execution file to the runner.
5. Create a Test freeze report containing composition counts, exclusions, reviewer outcome, and checksum values.

### Model-panel freeze

1. Select the exact models only after checking current access, cost, provider terms, and reproducibility constraints.
2. Prefer eight models; do not proceed with fewer than six without a documented protocol amendment.
3. Include at least three providers, at least two open-weight models, and more than one capability/size tier.
4. Record requested and returned model identifiers, provider, endpoint, access date, deployment/snapshot information, and known version-drift limitations.
5. Do not label providers as directly comparable on token efficiency when tokenizers or usage accounting differ.

### Execution freeze

1. Freeze one Turkish answer-only prompt.
2. Use a new stateless request for every model-item pair.
3. Disable tools, web access, retrieval, browsing, and conversational memory.
4. Use the same completion-token ceiling. Use low reasoning effort where exposed; otherwise omit the unsupported control and document the difference.
5. Use temperature zero where supported. Do not invent an equivalent parameter for endpoints that do not expose one.
6. Fix a deterministic randomization seed. Randomize item order within model and interleave model runs in blocks where feasible to reduce time-of-day and provider-drift confounding.
7. Define a technical response as valid only when the request succeeds, the answer is non-empty, and no length/content-filter/incomplete termination occurs.
8. Never retry because an answer is wrong. Permit only logged technical retries under the same request settings.
9. If a protocol defect affects comparability, stop and rerun the complete model panel under a new version.

### Analysis freeze

1. Register RQ1–RQ5, H1–H3, primary and secondary metrics, denominators, exclusion rules, overlap fraction, confidence-interval method, and multiplicity correction.
2. Freeze the exact model list and model display order before unsealing identities.
3. Freeze the statistical script and unit tests against synthetic data.

### Gate M4

- [x] Test and question-only files checksummed.
- [x] Exact model panel and expected cost recorded.
- [x] Prompt and execution configuration frozen.
- [x] Review-overlap seed and sampling script frozen.
- [x] Statistical analysis plan versioned.
- [x] Dry run uses non-Test fixture items only.

## 9. Phase M5 — Main model execution

### Actions

1. Run scorer and request-client tests in a clean environment.
2. Execute models in the frozen block order within the shortest practical collection window.
3. Write raw responses to a private append-only log immediately after each request.
4. Record request status, timestamps, latency, returned model identifier, completion metadata, token usage, and retry history.
5. Stop the run if the answer key becomes exposed to a model, the prompt changes, or a systematic capture defect appears.
6. At completion, reconcile expected and observed counts: `72 × number_of_models` primary records.
7. Compute checksums for raw logs and create a technical-validity report before scoring correctness.

### Gate M5

- [x] Expected response count reconciled.
- [x] Technical failures classified without reference to correctness.
- [x] No Test key or accepted-answer field entered a request payload.
- [x] Raw logs and metadata checksummed.

## 10. Phase M6 — Automatic scoring and blinded manual review

### Automatic stage

1. Normalize Turkish casing, whitespace, punctuation, and predefined orthographic variants using the frozen scorer.
2. Assign `CO` only to exact normalized matches against preregistered accepted answers.
3. Assign `NA` only to an explicit abstention defined by the protocol.
4. Route every other technically valid response to manual review.
5. Keep automatic and final labels in separate columns.

### Blinding and overlap selection

1. Replace provider/model identifiers with opaque run IDs before human review.
2. After automatic routing but before anyone reads non-exact responses, select 25% of manual-review rows using the frozen seed.
3. Stratify the overlap by model slot, knowledge domain, knowledge specificity, L0/L1 lexical cue level, answer form, and numeric status.
4. Lock and checksum the overlap list. Do not increase or redirect overlap after seeing model quality.

### Coding

1. The lead researcher codes 100% of non-exact responses.
2. The second reviewer independently codes only the frozen overlap.
3. Reviewers judge the response against the frozen question, gold answer, accepted answers, and official source.
4. For `CO`, record one correct-variant code. For `IN`, record one primary error operation and one semantic target. Use `MIXED` only when one operation is insufficient.
5. Record source check and confidence. Use `OTHER_EMERGENT` only when every frozen category has been tested and rejected.
6. Do not discuss overlap labels before both reviewer files are locked.

### Gate M6

- [ ] Every non-exact response has a complete lead-researcher code.
- [ ] Every preselected overlap response has an independent second code.
- [x] No reviewer sheet contains model/provider identity.
- [ ] Pre-adjudication agreement tables are locked.

## 11. Phase M7 — Reliability and adjudication

### Reliability

1. Calculate raw agreement and Cohen's κ for final decision on the preselected overlap only.
2. Calculate operation agreement and κ only among overlap cases jointly coded `IN`.
3. Report denominators explicitly; do not combine correct-variant and error-operation labels into one κ.
4. If a category is too rare for stable κ, report counts and raw agreement and state the limitation.

### Adjudication

1. Route every overlap disagreement, `ESCALATE`, low-confidence case, and internally inconsistent code bundle to the adjudicator.
2. The adjudicator remains model-blinded and sees both reviewer labels, rationales, the frozen item record, and the official source.
3. Store adjudication decisions separately from the two independent reviewer records.
4. Document whether explanatory prose was written by the adjudicator or reconstructed by the lead researcher.
5. Unseal model identities only after all final consensus rows are locked and checksummed.

### Gate M7

- [ ] Agreement statistics calculated from pre-adjudication overlap only.
- [ ] Every routed case resolved.
- [ ] Consensus table locked and checksummed.
- [ ] Model mapping remains sealed until consensus lock.

## 12. Phase M8 — Statistical analysis

### Primary metric

For each model:

`semantic_accuracy = (exact CO + manually resolved CO) / technically valid responses`

Report the number of technically invalid responses separately. Add a sensitivity analysis that treats invalid responses as incorrect when the invalid rate is non-zero.

### Secondary metrics

- Normalized exact-match accuracy.
- Explicit-abstention rate.
- Technical-validity rate.
- Correct-but-non-exact recovery rate.
- Accuracy by domain, specificity, answer form, and numeric status.
- Error-operation prevalence over all eligible responses.
- Error-operation composition over final `IN` responses.
- Semantic-target prevalence and composition.
- Latency and token usage as descriptive provider-specific metadata, not directly comparable efficiency scores unless measurement equivalence is established.

### Inferential plan

1. Report model-wise point estimates with 95% item-cluster bootstrap confidence intervals using at least 10,000 paired item resamples.
2. For planned pairwise model comparisons, use paired binary outcomes on common valid items and report effect sizes with confidence intervals.
3. Use McNemar tests for prespecified pairwise accuracy contrasts and apply Holm correction across the registered comparison family.
4. Estimate a mixed-effects logistic model with model, domain, and specificity as fixed effects and item as a random intercept, provided convergence and cell counts are adequate.
5. Treat sparse subgroup and error-category analyses as exploratory. Report counts alongside percentages and avoid ranking models on very small strata.
6. Run sensitivity analyses for exact match versus semantic accuracy, invalid-response handling, and exclusion of the controlled numeric subset.

### Gate M8

- [ ] All tables reconcile with the locked consensus record.
- [ ] Primary results are reproducible from one analysis command.
- [ ] Confidence intervals, denominators, and multiplicity decisions are reported.
- [ ] Exploratory analyses are labelled as exploratory.

## 13. Phase M9 — Reporting and release

### Manuscript

1. Write the manuscript in English while preserving Turkish benchmark examples with English glosses where needed.
2. Report Dev validation, pilot reliability, and main-study response reliability separately.
3. Describe model/provider constraints symmetrically and distinguish requested from returned model identifiers.
4. Include data, ethics, limitations, contamination, maintenance, and AI-assistance statements.
5. Do not present the pilot as a preliminary leaderboard.

### Repository and archival release

1. Run a secret and personal-data scan before every push.
2. Publish source code, environment files, prompt, scorer tests, protocol, aggregate tables, and the permitted dataset components.
3. Keep signed reviewer forms, identities, private correspondence, API request identifiers, and hidden Test answers outside Git.
4. Create a sanitized public provenance file without local computer paths.
5. Finalize `CITATION.cff`, license files, repository version, and release notes.
6. Create an immutable tagged release and archive it with a persistent identifier.
7. Link the repository and archived release in the English manuscript and arXiv record.

### Gate M9

- [ ] Manuscript values match generated tables.
- [ ] Public/private boundary independently checked.
- [ ] No credentials, reviewer identities, signatures, or local absolute paths are present.
- [ ] Release tag, checksum file, citation metadata, and archive identifier agree.

## 14. Planned workload and realistic timetable

Assuming 72 Test items and eight models:

- Primary model responses: 576.
- If the pilot routing rate is approximately reproduced, roughly 350–400 responses may require lead-researcher review.
- After frozen automatic routing, 326 responses required manual review; the ceiling of the registered 25% rule therefore placed 82 responses with the second reviewer.
- Adjudication volume is expected to be substantially smaller and is triggered by disagreement or low confidence, not a fixed quota.

| Target dates | Stage | Deliverable |
|---|---|---|
| 27 Aug–3 Sep 2026 | M0–M2 | Private Test candidate table, exclusion log, leakage/duplication report |
| 4–10 Sep 2026 | M3 | Independent item validation, overlap agreement, adjudication, final 72 items |
| 11–13 Sep 2026 | M4 | Test checksum, exact model panel, cost sheet, prompt/config and analysis freeze |
| 14–16 Sep 2026 | M5 | Main model execution and technical-validity report |
| 17–27 Sep 2026 | M6 | Lead-researcher coding and independent 25% overlap |
| 28 Sep–2 Oct 2026 | M7 | Reliability, adjudication, locked consensus |
| 3–10 Oct 2026 | M8–M9 | Statistical analysis, tables, manuscript update, sanitized release package |

Dates are operational targets, not scientific inclusion criteria. If validation or source checking is incomplete, the schedule moves; the quality gates do not.

## 15. Stop rules

Pause the main study and create a versioned protocol amendment if any of the following occurs:

- fewer than 72 defensible Test items survive without relaxing L0/L1 or source rules;
- Dev/Test construct overlap is detected after freeze;
- the answer key enters a model request or reviewer identity becomes unblinded prematurely;
- a model endpoint changes materially during collection;
- a systematic response-capture or truncation defect is found;
- accepted answers or the taxonomy would need to change after model outputs are visible;
- reviewer disagreement reveals a recurrent unresolved boundary rule;
- actual cost or workload would force unequal treatment of models.

Do not repair these conditions selectively. Preserve the affected run, document exclusion, revise the protocol version, and rerun the complete comparable panel when necessary.

## 16. Methodological basis

The protocol adapts established guidance rather than treating any one paper as a complete benchmark recipe:

- Hsieh, H.-F., & Shannon, S. E. (2005). Three approaches to qualitative content analysis. *Qualitative Health Research, 15*(9), 1277–1288. https://doi.org/10.1177/1049732305276687
- MacQueen, K. M., McLellan, E., Kay, K., & Milstein, B. (1998). Codebook development for team-based qualitative analysis. *Cultural Anthropology Methods, 10*(2), 31–36. https://doi.org/10.1177/1525822X980100020301
- Artstein, R., & Poesio, M. (2008). Inter-coder agreement for computational linguistics. *Computational Linguistics, 34*(4), 555–596. https://aclanthology.org/J08-4004/
- Bender, E. M., & Friedman, B. (2018). Data statements for natural language processing. *Transactions of the Association for Computational Linguistics, 6*, 587–604. https://aclanthology.org/Q18-1041/
- Gebru, T., et al. (2021). Datasheets for datasets. *Communications of the ACM, 64*(12), 86–92. https://arxiv.org/abs/1803.09010
- Bulian, J., et al. (2022). Tomayto, tomahto. Beyond token-level answer equivalence for question answering evaluation. *Proceedings of EMNLP 2022*. https://aclanthology.org/2022.emnlp-main.20/
- Sainz, O., et al. (2023). NLP evaluation in trouble: On the need to measure LLM data contamination for each benchmark. *Findings of EMNLP 2023*. https://aclanthology.org/2023.findings-emnlp.722/

These sources support directed qualitative coding, explicit codebooks, pre-adjudication reliability, dataset documentation, semantic answer resolution, and contamination control. The exact thresholds, quotas, overlap fraction, and stop rules remain transparent study-specific design decisions.
