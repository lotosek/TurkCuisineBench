# Main-study aggregate results

These files contain public-safe aggregates from the locked 72-item, eight-endpoint
TurkCuisineBench Test-v1 evaluation and four already-public Dev examples. They contain no Test question, Test accepted
answer, raw model response, row-level reviewer decision or rationale, reviewer
mapping, blinding material, or private checksum.

| File | Contents |
|---|---|
| `ESM_1.xlsx` | Current Online Resource 1 v1.1: Tables S1–S9, including S4b, corrected Dev examples and model-level errors |
| `TurkCuisineBench_Online_Resource_1_v1.0.xlsx` | Superseded historical supplement; do not submit alongside ESM_1.xlsx |
| `13_table1_model_performance.csv` | Model-level semantic, exact, abstention, invalidity, and recovery estimates |
| `13_table2_confirmatory_H1_H3.csv` | Unchanged original H1–H3 numerical output; H3 reporting is superseded by the interpretation amendment |
| `submission_interpretation_v1.1.csv` | Original numerical output plus current reporting status; unqualified confirmatory H3 decision withheld |
| `submission_reporting_manifest_v1.1.json` | Current reporting status and links; historical v1.0 manifest retained unchanged |
| `model_error_operations_v1.1.csv` | Model-specific operation counts and denominators; Table S7 |
| `model_error_targets_v1.1.csv` | Model-specific semantic-target counts and denominators; Table S8 |
| `model_error_profiles_v1.1.csv` | Existing detailed model-specific exploratory profiles; Wilson intervals are descriptive, not source-cluster adjusted |
| `public_dev_examples_v1.1.csv` | Four already-public, unchanged Dev examples; Table S6 |
| `recovered_answer_variants_v1.1.csv` | Counts of existing correct non-exact variant labels; Table S9 |
| `13_table3_H1_pairwise_comparisons.csv` | All 28 gated pairwise comparisons; manuscript Online Resource Table S1 |
| `13_table4_secondary_subgroup_results.csv` | Prespecified descriptive subgroup profiles; manuscript Online Resource Table S2 |
| `13_table5_pre_adjudication_reliability.csv` | Independently locked overlap reliability aggregates |
| `13_table6_exploratory_error_taxonomy.csv` | Error-operation and semantic-target distributions |
| `13_table7_secondary_model_status.csv` | Feasibility-gate outcomes for secondary models |
| `posthoc_source_cluster_sensitivity.csv` | Source-URL-clustered sandwich sensitivity models |
| `posthoc_source_cluster_bootstrap.csv` | Source-URL cluster-bootstrap interval for semantic recovery |
| `posthoc_coverage_summary.csv` | Aggregate geography and source-family coverage audit |
| `figure1_model_semantic_accuracy.png` | Model-level semantic accuracy with Wilson intervals |
| `figure1_model_semantic_accuracy_v1.1.png` | Same estimates redrawn at 1200 dpi for submission |

The confirmatory family and pairwise family use separate Holm corrections. The
subgroup, taxonomy, abstention, coverage, and source-cluster analyses retain
their prespecified descriptive, exploratory, sensitivity, or post-hoc labels;
they must not be promoted to confirmatory findings.

See the [dated reporting amendment](../../docs/interpretation_amendment_2026-09-17.md)
for the H3 model-scale reservation and precise H2 estimand. Frozen output files
remain reproducible; current interpretation must not be inferred from the old
machine-generated `hypothesis_supported` field alone. In the reporting CSV,
decision columns prefixed `original_` preserve historical interpretation;
`reporting_status` is authoritative. The only item-level content
in the revised public supplement is four already-public Dev examples, never Test.
