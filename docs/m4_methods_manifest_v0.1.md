# M4 methods manifest v0.1

Status: **non-provider-dependent methods components frozen; full M4 open**

Date: 2026-08-28

| Component | Version or setting | SHA-256 | State |
|---|---|---|---|
| Statistical analysis plan | `docs/statistical_analysis_plan_v1.0.md` | `4A8EC2F677B5C8292BA9E6ED005ADA74855A847A65F0D2E48188329CDB77BD20` | frozen before Test responses |
| Review-overlap selector | `evaluation/select_review_overlap.py` | `7DEC2ABC91587A1B11EA257226B3AF251BC49D99C5C619623819A5CDAA7BBC65` | frozen before Test responses |
| Overlap-selector test | `evaluation/test_select_review_overlap.py` | `4F14BFB2636A3A1EBED6B38FA0D0A8CF23C696C29F3D60E62607232C860A4E7C` | passed |
| Review-overlap seed | `20260828` | not applicable | frozen |
| Non-Test fixture | `evaluation/fixtures/non_test_questions.jsonl` | `53AFD142C35B7BDAE497165737453C8391A675A301B256682B9BD6D7FF48DEF7` | synthetic fixture only |
| Provisional configuration | `configs/main_study_config.example.json` | `0AA7AC4F7CDCCF7988498B04AA4B8B997108A19A5B2F57AEEB199098D781092A` | not final; panel access pending |
| Main runner | `evaluation/run_main_study.py` | `0A109F78AFC458143AE11F44C3B62B1C2CD6D46EE658B8B22CAF52BCD5FA248D` | authorization lock retained |

The selector allocates exactly `ceil(0.25 × manual-review candidates)` across model-slot × knowledge-domain strata using Hamilton allocation and balances knowledge specificity, lexical cue level, answer form, and numeric status within those strata. Model-to-blind-code assignment additionally requires a private salt supplied through `TURKCUISINE_BLINDING_SALT`; the public seed cannot reveal the mapping.

The preparatory dry run used three synthetic, non-culinary Test items, generated 24 scheduled requests across the eight provisional slots, made no network call, and produced schedule hash `2278113054669e6ec639e81d5384ab4ac40ba0e40e0da7742bb277eff9ed32b7`. This confirms schema, prompt construction, and deterministic scheduling only. A final non-Test fixture dry run must be repeated after the exact panel and final configuration are frozen.

Full M4 remains open pending the institutional M0 record, Anthropic and Google access probes, current availability and price verification, exact equal-treatment model-panel and cost-ceiling freeze, final configuration checksum, and repeated non-Test dry run.
