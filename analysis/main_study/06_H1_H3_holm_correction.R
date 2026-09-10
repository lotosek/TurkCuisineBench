# TurkCuisineBench — Lesson 6: Holm correction for H1-H3
#
# Learning objectives:
#   1. Treat H1, H2, and H3 as one prespecified confirmatory family.
#   2. Distinguish raw p-values from family-wise Holm-adjusted p-values.
#   3. Apply both statistical rejection and any directional requirement when
#      deciding whether a hypothesis is supported.
#   4. Determine whether the separate H1 pairwise-comparison gate opens.
#
# IMPORTANT:
#   - Run Lessons 3, 4, and 5 first.
#   - This script creates a new final confirmatory table. It does not overwrite
#     the three raw hypothesis-result files.

library(readr)
library(dplyr)
library(jsonlite)

output_dir <- "student_outputs"

h1_path <- file.path(output_dir, "03_H1_global_test_raw.csv")
h2_path <- file.path(output_dir, "04_H2_lexical_leakage_raw.csv")
h3_path <- file.path(output_dir, "05_H3_exact_vs_semantic_raw.csv")

stopifnot(
  file.exists(h1_path),
  file.exists(h2_path),
  file.exists(h3_path)
)

h1 <- read_csv(h1_path, show_col_types = FALSE)
h2 <- read_csv(h2_path, show_col_types = FALSE)
h3 <- read_csv(h3_path, show_col_types = FALSE)

stopifnot(
  nrow(h1) == 1,
  nrow(h2) == 1,
  nrow(h3) == 1,
  h1$hypothesis == "H1",
  h2$hypothesis == "H2",
  h3$hypothesis == "H3",
  h1$glmm_usable %in% TRUE,
  h2$glmm_usable %in% TRUE,
  h3$glmm_usable %in% TRUE,
  is.finite(h1$raw_p),
  is.finite(h2$raw_p),
  is.finite(h3$raw_p)
)

# Construct one row per confirmatory hypothesis. Effect sizes remain on the
# prespecified, interpretable scale for each question.
confirmatory_results <- bind_rows(
  tibble(
    hypothesis = "H1",
    test = h1$method,
    statistic = h1$statistic,
    df = h1$df,
    raw_p = h1$raw_p,
    directional_requirement_met = TRUE,
    effect_estimate = NA_real_,
    effect_ci_low = NA_real_,
    effect_ci_high = NA_real_,
    effect_definition = "Global model-slot effect; no single scalar effect",
    scale_note = "Pairwise effects follow only if the Holm-adjusted H1 gate opens"
  ),
  tibble(
    hypothesis = "H2",
    test = h2$method,
    statistic = h2$statistic,
    df = h2$df,
    raw_p = h2$raw_p,
    directional_requirement_met = h2$observed_direction_matches_h2,
    effect_estimate = h2$model_adjusted_l0_minus_l1,
    effect_ci_low = h2$model_adjusted_difference_ci_low,
    effect_ci_high = h2$model_adjusted_difference_ci_high,
    effect_definition = "Model-adjusted probability difference: L0 minus L1",
    scale_note = "Negative values match the H2 direction; L1 contains 12 items"
  ),
  tibble(
    hypothesis = "H3",
    test = h3$method,
    statistic = h3$statistic,
    df = h3$df,
    raw_p = h3$raw_p,
    directional_requirement_met = h3$observed_direction_matches_h3,
    effect_estimate = h3$observed_semantic_minus_exact,
    effect_ci_low = h3$bootstrap_ci_low,
    effect_ci_high = h3$bootstrap_ci_high,
    effect_definition = "Observed paired accuracy difference: semantic minus exact",
    scale_note = paste0(
      "Item-cluster bootstrap CI; conditional model-scale warning=",
      h3$model_scale_warning
    )
  )
) |>
  mutate(
    hypothesis = factor(hypothesis, levels = c("H1", "H2", "H3"))
  ) |>
  arrange(hypothesis)

alpha <- 0.05
family_size <- nrow(confirmatory_results)

stopifnot(family_size == 3)

confirmatory_results <- confirmatory_results |>
  mutate(
    confirmatory_family = "H1-H3",
    family_size = family_size,
    adjustment = "Holm",
    alpha = alpha,
    holm_p = p.adjust(raw_p, method = "holm"),
    holm_reject = holm_p < alpha,
    hypothesis_supported = holm_reject & directional_requirement_met,
    final_confirmatory_interpretation = case_when(
      hypothesis == "H1" & hypothesis_supported ~
        "SUPPORTED: semantic accuracy differs across model slots",
      hypothesis == "H1" ~
        "NOT SUPPORTED: no confirmatory model-slot difference detected",
      hypothesis == "H2" & hypothesis_supported ~
        "SUPPORTED: L0 accuracy is lower than L1 accuracy",
      hypothesis == "H2" & holm_reject & !directional_requirement_met ~
        "NOT SUPPORTED: a difference was detected in the opposite direction",
      hypothesis == "H2" ~
        "NOT SUPPORTED: the observed L0-L1 difference was not detected",
      hypothesis == "H3" & hypothesis_supported ~
        paste0(
          "SUPPORTED: semantic review recovers additional correct responses; ",
          "interpret the paired recovery effect because the conditional model ",
          "scale is extreme"
        ),
      hypothesis == "H3" & holm_reject & !directional_requirement_met ~
        "NOT SUPPORTED: a difference was detected in the opposite direction",
      TRUE ~
        "NOT SUPPORTED: no confirmatory exact-semantic difference detected"
    )
  )

# Holm-adjusted p-values cannot be smaller than their corresponding raw values.
stopifnot(all(confirmatory_results$holm_p >= confirmatory_results$raw_p))

h1_pairwise_gate_open <- confirmatory_results |>
  filter(hypothesis == "H1") |>
  pull(holm_reject)

stopifnot(length(h1_pairwise_gate_open) == 1)

display_table <- confirmatory_results |>
  transmute(
    hypothesis = as.character(hypothesis),
    statistic,
    df,
    raw_p,
    holm_p,
    directional_requirement_met,
    holm_reject,
    hypothesis_supported,
    final_confirmatory_interpretation
  )

cat("\n--- Final H1-H3 Holm-corrected confirmatory results ---\n")
print(display_table, n = Inf, width = Inf)
cat("\nH1 pairwise-comparison gate open:", h1_pairwise_gate_open, "\n")

write_csv(
  confirmatory_results |>
    mutate(hypothesis = as.character(hypothesis)),
  file.path(output_dir, "06_confirmatory_H1_H3_holm_results.csv")
)

holm_metadata <- list(
  family = "H1-H3",
  family_size = family_size,
  method = "Holm",
  alpha = alpha,
  h1_pairwise_gate_open = h1_pairwise_gate_open,
  source_files = c(
    "03_H1_global_test_raw.csv",
    "04_H2_lexical_leakage_raw.csv",
    "05_H3_exact_vs_semantic_raw.csv"
  )
)

write_json(
  holm_metadata,
  file.path(output_dir, "06_confirmatory_H1_H3_holm_metadata.json"),
  pretty = TRUE,
  auto_unbox = TRUE
)

cat("\nLesson 6 completed.\n")
cat("Confirmatory family size:", family_size, "\n")
cat("Adjustment method: Holm\n")
cat("H1 pairwise-comparison gate open:", h1_pairwise_gate_open, "\n")
cat("Use Holm-adjusted p-values for final H1-H3 decisions.\n")
