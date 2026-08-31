# M4 methods manifest v0.1

Status: **non-provider-dependent methods components frozen; full M4 open**

Created: 2026-08-28; updated: 2026-08-31

| Component | Version or setting | SHA-256 | State |
|---|---|---|---|
| Statistical analysis plan | `docs/statistical_analysis_plan_v1.0.md` | `4A8EC2F677B5C8292BA9E6ED005ADA74855A847A65F0D2E48188329CDB77BD20` | frozen before Test responses |
| Review-overlap selector | `evaluation/select_review_overlap.py` | `7DEC2ABC91587A1B11EA257226B3AF251BC49D99C5C619623819A5CDAA7BBC65` | frozen before Test responses |
| Overlap-selector test | `evaluation/test_select_review_overlap.py` | `4F14BFB2636A3A1EBED6B38FA0D0A8CF23C696C29F3D60E62607232C860A4E7C` | passed |
| Review-overlap seed | `20260828` | not applicable | frozen |
| Non-Test fixture | `evaluation/fixtures/non_test_questions.jsonl` | `53AFD142C35B7BDAE497165737453C8391A675A301B256682B9BD6D7FF48DEF7` | synthetic fixture only |
| Provisional configuration | `configs/main_study_config.example.json` | `86BF11A16FFEBEF06C0718B866D67867634091C96D8554192573CD9267312AFC` | not final; Gemini data-use gate pending |
| Main runner | `evaluation/run_main_study.py` | `CD3EFF8DDDCA989AFAE9C059855083F17FFE355021CDE3960F36A40885D9C21C` | authorization lock retained |
| Provider-payload test | `evaluation/test_main_study_payloads.py` | `BFCF0EE5C92D3B27566199A6598CBE0FA97A0168925F53C59DBDFDAC2CBA4035` | passed |
| Neutral access-probe utility | `evaluation/probe_model_access.py` | `FDB025306B72B73746C2C3F9518153B05DB5C84F74ABF4A57916B9ED90A792D0` | network opt-in; slot-selective; sends no benchmark content |
| Access-probe test | `evaluation/test_probe_model_access.py` | `EFFCED0311F4092BF4C6C1BC481E30CA54CFD11F3DFFB544EF47F0A72CEB631C` | passed; offline test only |
| Price snapshot | `configs/main_study_costs_2026-08-31.json` | `FF4DE82F04317C39DFBABBE675B2B506968539B5A6E644D6CCD82B66AB6A4CD7` | verified 2026-08-31; recheck before execution |
| Cost calculator | `evaluation/estimate_main_study_cost.py` | `09159DBD9DD242E248A89FCFD86ABEE2036612A73ED0AD6C3D4C264FCE339483` | USD 5 ceiling |
| Cost test | `evaluation/test_estimate_main_study_cost.py` | `C8CA8B4D96092C8FDF854A63207D388B9FA2D2F04EECE285CEFE64409642F3CE` | passed |

The selector allocates exactly `ceil(0.25 × manual-review candidates)` across model-slot × knowledge-domain strata using Hamilton allocation and balances knowledge specificity, lexical cue level, answer form, and numeric status within those strata. Model-to-blind-code assignment additionally requires a private salt supplied through `TURKCUISINE_BLINDING_SALT`; the public seed cannot reveal the mapping.

The preparatory dry run used three synthetic, non-culinary Test items, generated 24 scheduled requests across the eight provisional slots, made no network call, and produced schedule hash `2278113054669e6ec639e81d5384ab4ac40ba0e40e0da7742bb277eff9ed32b7`. This confirms schema, prompt construction, and deterministic scheduling only. A final non-Test fixture dry run must be repeated after the exact panel and final configuration are frozen.

All eight neutral access probes pass and current availability/prices were reverified on 2026-08-31. Full M4 remains open pending resolution of the Gemini Paid Tier/data-use requirement, exact equal-treatment panel and final configuration checksum, and the repeated non-Test dry run.
