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
| Provisional configuration | `configs/main_study_config.example.json` | `936C4F25A5D473FDE53083EA217EB3D7A13480EB2DA68D0FA607149A9B0C27C4` | not final; panel access pending |
| Main runner | `evaluation/run_main_study.py` | `CD3EFF8DDDCA989AFAE9C059855083F17FFE355021CDE3960F36A40885D9C21C` | authorization lock retained |
| Provider-payload test | `evaluation/test_main_study_payloads.py` | `BFCF0EE5C92D3B27566199A6598CBE0FA97A0168925F53C59DBDFDAC2CBA4035` | passed |
| Neutral access-probe utility | `evaluation/probe_model_access.py` | `FE29FD523E46F0D5FC0FFF324500BC8A4D4C2F780922DB85D27E40EDB5EC9BF1` | network opt-in; sends no benchmark content |
| Access-probe test | `evaluation/test_probe_model_access.py` | `AF5E7D896F4210EF3AD92B2FD33AE48B3AD573270238D609B99CF972C6894895` | offline test only |
| Price snapshot | `configs/main_study_costs_2026-08-28.json` | `BC8642B7EF332631535F92FC715CCC09D04A76679A74D3A1FCF1E0B014241238` | recheck before execution |
| Cost calculator | `evaluation/estimate_main_study_cost.py` | `09159DBD9DD242E248A89FCFD86ABEE2036612A73ED0AD6C3D4C264FCE339483` | USD 5 ceiling |
| Cost test | `evaluation/test_estimate_main_study_cost.py` | `BD0AA610430E8E281992E71EFA6387E758DA104E82AC52B179B8A2FC2D8CADF7` | passed |

The selector allocates exactly `ceil(0.25 × manual-review candidates)` across model-slot × knowledge-domain strata using Hamilton allocation and balances knowledge specificity, lexical cue level, answer form, and numeric status within those strata. Model-to-blind-code assignment additionally requires a private salt supplied through `TURKCUISINE_BLINDING_SALT`; the public seed cannot reveal the mapping.

The preparatory dry run used three synthetic, non-culinary Test items, generated 24 scheduled requests across the eight provisional slots, made no network call, and produced schedule hash `2278113054669e6ec639e81d5384ab4ac40ba0e40e0da7742bb277eff9ed32b7`. This confirms schema, prompt construction, and deterministic scheduling only. A final non-Test fixture dry run must be repeated after the exact panel and final configuration are frozen.

Full M4 remains open pending Anthropic and Google access probes, current availability and price verification, exact equal-treatment model-panel and cost-ceiling freeze, final configuration checksum, and repeated non-Test dry run.
