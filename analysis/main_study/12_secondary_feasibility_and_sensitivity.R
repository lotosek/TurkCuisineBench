# TurkCuisineBench — Lesson 12: Secondary-model feasibility and sensitivity
#
# Learning objectives:
#   1. Audit estimability before fitting a large secondary model.
#   2. Detect exact redundancy between answer form and numeric-answer status.
#   3. Detect sparse or outcome-separated item strata.
#   4. Apply the prespecified feasibility gate without data-driven collapsing.
#   5. Test whether the global H1 conclusion is robust to two denominator/subset
#      choices: technical invalidity counted as incorrect and numeric items
#      excluded.
#
# IMPORTANT:
#   - The secondary-model audit is not a new confirmatory hypothesis test.
#   - A failed feasibility gate is a valid scientific result; do not force a
#     model by merging frozen categories after seeing the outcomes.
#   - Sensitivity p-values do not enter the H1-H3 Holm family and do not replace
#     the registered primary H1 result.

library(readr)
library(dplyr)
library(tidyr)
library(lme4)
library(jsonlite)

if (!exists("consensus")) {
  input_path <- file.path(
    "..",
    "TurkCuisineBench_Main_Study_Final_Consensus_Private_v1.0.csv"
  )

  consensus <- read_csv(
    input_path,
    na = "",
    show_col_types = FALSE,
    locale = locale(encoding = "UTF-8")
  )
}

dir.create("student_outputs", showWarnings = FALSE)

# ---------------------------------------------------------------------------
# Part A — Feasibility audit for the registered expanded secondary model
# ---------------------------------------------------------------------------

secondary_data <- consensus |>
  filter(technical_valid %in% TRUE) |>
  transmute(
    response_id,
    item_id = factor(item_id),
    model_slot = factor(model_slot, levels = paste0("S0", 1:8)),
    knowledge_domain = factor(knowledge_domain),
    knowledge_specificity = factor(knowledge_specificity),
    lexical_leakage = factor(lexical_leakage),
    answer_form = factor(answer_form),
    numeric_answer = factor(numeric_answer),
    semantic_correct = as.integer(semantic_correct)
  )

stopifnot(
  nrow(secondary_data) == 574,
  nlevels(secondary_data$item_id) == 72,
  all(secondary_data$semantic_correct %in% c(0L, 1L))
)

# These predictors are frozen item properties and must be constant across the
# eight model responses belonging to the same item.
item_metadata_consistency <- secondary_data |>
  group_by(item_id) |>
  summarise(
    n_domain = n_distinct(knowledge_domain),
    n_specificity = n_distinct(knowledge_specificity),
    n_leakage = n_distinct(lexical_leakage),
    n_answer_form = n_distinct(answer_form),
    n_numeric = n_distinct(numeric_answer),
    .groups = "drop"
  )

stopifnot(
  all(item_metadata_consistency$n_domain == 1),
  all(item_metadata_consistency$n_specificity == 1),
  all(item_metadata_consistency$n_leakage == 1),
  all(item_metadata_consistency$n_answer_form == 1),
  all(item_metadata_consistency$n_numeric == 1)
)

# Estimability is checked on exactly the fixed-effects formula stated in the
# statistical analysis plan. A rank deficiency means at least one requested
# coefficient cannot be estimated independently of the others.
secondary_fixed_formula <- ~
  model_slot +
  knowledge_domain +
  knowledge_specificity +
  lexical_leakage +
  answer_form +
  numeric_answer

secondary_model_matrix <- model.matrix(
  secondary_fixed_formula,
  data = secondary_data
)

secondary_qr <- qr(secondary_model_matrix)
secondary_rank <- secondary_qr[["rank"]]
secondary_columns <- ncol(secondary_model_matrix)
secondary_rank_deficiency <- secondary_columns - secondary_rank

dependent_columns <- if (secondary_rank_deficiency > 0L) {
  dependent_positions <- secondary_qr[["pivot"]][
    seq.int(secondary_rank + 1L, secondary_columns)
  ]
  colnames(secondary_model_matrix)[dependent_positions]
} else {
  character(0)
}

design_matrix_audit <- tibble(
  requested_fixed_effects = paste(
    c(
      "model_slot",
      "knowledge_domain",
      "knowledge_specificity",
      "lexical_leakage",
      "answer_form",
      "numeric_answer"
    ),
    collapse = " + "
  ),
  matrix_rows = nrow(secondary_model_matrix),
  matrix_columns = secondary_columns,
  matrix_rank = secondary_rank,
  rank_deficiency = secondary_rank_deficiency,
  full_column_rank = secondary_rank_deficiency == 0L,
  aliased_columns = if (length(dependent_columns) == 0L) {
    "NONE"
  } else {
    paste(dependent_columns, collapse = "; ")
  }
)

# This cross-tab makes the source of the expected alias transparent. In this
# Test set, every numeric item has answer_form == "numeric", and no other item
# does. The two variables therefore encode the same contrast.
answer_numeric_redundancy <- secondary_data |>
  distinct(item_id, answer_form, numeric_answer) |>
  count(answer_form, numeric_answer, name = "items") |>
  arrange(answer_form, numeric_answer)

# RQ2 already used fewer than five items as the frozen sparse-stratum flag.
# Complete outcome separation is also recorded because a level with all zeros
# or all ones can yield extreme, effectively non-informative coefficients.
specificity_support <- secondary_data |>
  group_by(knowledge_specificity) |>
  summarise(
    items = n_distinct(item_id),
    valid_responses = n(),
    correct = sum(semantic_correct == 1L),
    incorrect = sum(semantic_correct == 0L),
    contains_both_outcomes = correct > 0L & incorrect > 0L,
    sparse_fewer_than_five_items = items < 5L,
    single_item_level = items == 1L,
    .groups = "drop"
  ) |>
  arrange(knowledge_specificity)

# The registered model-by-domain interaction has a stricter gate: every
# model-by-domain cell must contain both outcomes before the model is fitted.
model_domain_support <- secondary_data |>
  group_by(model_slot, knowledge_domain) |>
  summarise(
    valid_responses = n(),
    correct = sum(semantic_correct == 1L),
    incorrect = sum(semantic_correct == 0L),
    contains_both_outcomes = correct > 0L & incorrect > 0L,
    .groups = "drop"
  ) |>
  arrange(model_slot, knowledge_domain)

expanded_model_full_rank <- secondary_rank_deficiency == 0L
specificity_cells_adequate <- all(
  !specificity_support$sparse_fewer_than_five_items &
    specificity_support$contains_both_outcomes
)
interaction_cells_adequate <- all(model_domain_support$contains_both_outcomes)

# No frozen codebook rule authorizes outcome-driven merging of the sparse
# compound specificity labels. Because the expanded design is rank deficient
# and two specificity levels are single-item, completely separated strata, the
# prespecified feasibility condition is not met. The registered descriptive RQ2
# estimates remain the appropriate report for these item properties.
fit_expanded_secondary_model <-
  expanded_model_full_rank && specificity_cells_adequate

fit_model_by_domain_interaction <- interaction_cells_adequate

secondary_feasibility <- list(
  analysis_population_n = nrow(secondary_data),
  test_items = nlevels(secondary_data$item_id),
  expanded_model_matrix_columns = secondary_columns,
  expanded_model_matrix_rank = secondary_rank,
  expanded_model_rank_deficiency = secondary_rank_deficiency,
  aliased_columns = dependent_columns,
  answer_form_numeric_status_exactly_redundant =
    secondary_rank_deficiency > 0L && "numeric_answerTRUE" %in% dependent_columns,
  specificity_levels = nrow(specificity_support),
  sparse_specificity_levels = sum(specificity_support$sparse_fewer_than_five_items),
  completely_separated_specificity_levels = sum(!specificity_support$contains_both_outcomes),
  model_domain_cells = nrow(model_domain_support),
  model_domain_cells_without_both_outcomes = sum(!model_domain_support$contains_both_outcomes),
  expanded_secondary_model_status = if (fit_expanded_secondary_model) {
    "ELIGIBLE_TO_FIT"
  } else {
    "NOT_FITTED_PRESPECIFIED_FEASIBILITY_GATE_FAILED"
  },
  expanded_secondary_model_reason = paste(
    "numeric_answer is exactly redundant with the numeric answer_form level;",
    "two frozen knowledge-specificity levels contain one item each and have",
    "complete outcome separation. No post-output category collapse was used."
  ),
  model_by_domain_interaction_status = if (fit_model_by_domain_interaction) {
    "ELIGIBLE_TO_FIT"
  } else {
    "NOT_FITTED_PRESPECIFIED_CELL_SUPPORT_GATE_FAILED"
  },
  model_by_domain_interaction_reason = paste(
    sum(!model_domain_support$contains_both_outcomes),
    "model-by-domain cells do not contain both outcomes."
  ),
  inferential_status = "SECONDARY_FEASIBILITY_AUDIT_NO_NEW_CONFIRMATORY_TEST"
)

cat("\n--- Expanded secondary-model design audit ---\n")
print(design_matrix_audit)
cat("\n--- Answer-form by numeric-status item table ---\n")
print(answer_numeric_redundancy)
cat("\n--- Knowledge-specificity support ---\n")
print(specificity_support)
cat("\n--- Model-by-domain cells failing the interaction gate ---\n")
print(model_domain_support |> filter(!contains_both_outcomes))
cat("\nExpanded secondary model:", secondary_feasibility$expanded_secondary_model_status, "\n")
cat("Model-by-domain interaction:", secondary_feasibility$model_by_domain_interaction_status, "\n")

write_csv(
  design_matrix_audit,
  file.path("student_outputs", "12_secondary_design_matrix_audit.csv")
)
write_csv(
  answer_numeric_redundancy,
  file.path("student_outputs", "12_answer_form_numeric_redundancy.csv")
)
write_csv(
  specificity_support,
  file.path("student_outputs", "12_secondary_specificity_support.csv")
)
write_csv(
  model_domain_support,
  file.path("student_outputs", "12_exploratory_model_domain_support.csv")
)
write_json(
  secondary_feasibility,
  file.path("student_outputs", "12_secondary_model_feasibility.json"),
  pretty = TRUE,
  auto_unbox = TRUE,
  null = "null"
)

# ---------------------------------------------------------------------------
# Part B — Prespecified H1 sensitivity analyses
# ---------------------------------------------------------------------------

model_has_convergence_message <- function(model) {
  messages <- model@optinfo$conv$lme4$messages
  !is.null(messages) && length(messages) > 0L
}

pair_is_usable <- function(pair) {
  !model_has_convergence_message(pair$null) &&
    !model_has_convergence_message(pair$alternative) &&
    !isSingular(pair$null, tol = 1e-4) &&
    !isSingular(pair$alternative, tol = 1e-4)
}

fit_global_sensitivity <- function(data, outcome_column, analysis_label) {
  analysis_data <- data |>
    transmute(
      response_id,
      item_id = factor(item_id),
      model_slot = factor(model_slot, levels = paste0("S0", 1:8)),
      outcome = as.integer(.data[[outcome_column]])
    )

  stopifnot(all(analysis_data$outcome %in% c(0L, 1L)))

  fit_pair <- function(optimizer_name) {
    control_settings <- glmerControl(
      optimizer = optimizer_name,
      optCtrl = list(maxfun = 200000)
    )

    list(
      null = glmer(
        outcome ~ 1 + (1 | item_id),
        data = analysis_data,
        family = binomial(link = "logit"),
        nAGQ = 1,
        control = control_settings
      ),
      alternative = glmer(
        outcome ~ model_slot + (1 | item_id),
        data = analysis_data,
        family = binomial(link = "logit"),
        nAGQ = 1,
        control = control_settings
      )
    )
  }

  pair <- fit_pair("bobyqa")
  optimizer <- "bobyqa"

  if (!pair_is_usable(pair)) {
    message(analysis_label, ": retrying with nloptwrap.")
    pair <- fit_pair("nloptwrap")
    optimizer <- "nloptwrap"
  }

  glmm_usable <- pair_is_usable(pair)

  # Calculate the registered fallback on items with outcomes for all models.
  wide <- analysis_data |>
    select(item_id, model_slot, outcome) |>
    pivot_wider(names_from = model_slot, values_from = outcome) |>
    arrange(item_id) |>
    filter(if_all(starts_with("S"), ~ !is.na(.x)))

  q_matrix <- as.matrix(select(wide, starts_with("S")))
  k_models <- ncol(q_matrix)
  column_totals <- colSums(q_matrix)
  row_totals <- rowSums(q_matrix)
  q_numerator <- (k_models - 1) * (
    k_models * sum(column_totals^2) - sum(column_totals)^2
  )
  q_denominator <- k_models * sum(row_totals) - sum(row_totals^2)
  q_statistic <- q_numerator / q_denominator
  q_df <- k_models - 1L
  q_p <- pchisq(q_statistic, df = q_df, lower.tail = FALSE)

  if (glmm_usable) {
    lrt <- anova(pair$null, pair$alternative, test = "Chisq")
    method <- "Binomial GLMM likelihood-ratio test"
    statistic <- unname(lrt$Chisq[2])
    df <- unname(lrt$Df[2])
    raw_p <- unname(lrt$`Pr(>Chisq)`[2])
  } else {
    method <- "Cochran Q fallback"
    statistic <- unname(q_statistic)
    df <- q_df
    raw_p <- unname(q_p)
  }

  result <- tibble(
    analysis = analysis_label,
    analysis_population_n = nrow(analysis_data),
    item_clusters = nlevels(analysis_data$item_id),
    common_complete_items_for_q = nrow(wide),
    method = method,
    optimizer = optimizer,
    glmm_usable = glmm_usable,
    statistic = statistic,
    df = df,
    raw_p = raw_p,
    multiplicity_status = "SENSITIVITY_NOT_IN_CONFIRMATORY_HOLM_FAMILY",
    interpretation = if (raw_p < 0.05) {
      "GLOBAL_MODEL_DIFFERENCE_DETECTED_IN_SENSITIVITY_ANALYSIS"
    } else {
      "GLOBAL_MODEL_DIFFERENCE_NOT_DETECTED_IN_SENSITIVITY_ANALYSIS"
    }
  )

  diagnostics <- list(
    analysis = analysis_label,
    optimizer = optimizer,
    null_convergence_message = pair$null@optinfo$conv$lme4$messages,
    alternative_convergence_message = pair$alternative@optinfo$conv$lme4$messages,
    null_singular = isSingular(pair$null, tol = 1e-4),
    alternative_singular = isSingular(pair$alternative, tol = 1e-4),
    glmm_usable = glmm_usable,
    cochran_q_common_complete_items = nrow(wide),
    cochran_q_statistic = unname(q_statistic),
    cochran_q_df = q_df,
    cochran_q_raw_p = unname(q_p)
  )

  list(
    result = result,
    diagnostics = diagnostics,
    fitted_models = pair,
    analysis_data = analysis_data
  )
}

# Sensitivity 1: all 576 expected responses; technical invalidity = incorrect.
# Recalculate the outcome and verify it against the frozen consensus field.
expected_population_data <- consensus |>
  mutate(
    recalculated_expected_outcome = as.integer(
      technical_valid %in% TRUE & semantic_correct %in% TRUE
    )
  )

stopifnot(
  nrow(expected_population_data) == 576,
  all(
    expected_population_data$recalculated_expected_outcome ==
      as.integer(expected_population_data$semantic_correct_expected_population)
  )
)

expected_sensitivity <- fit_global_sensitivity(
  data = expected_population_data,
  outcome_column = "recalculated_expected_outcome",
  analysis_label = "INVALID_AS_INCORRECT_EXPECTED_POPULATION"
)

# Sensitivity 2: retain the primary technical-valid denominator but exclude all
# six frozen numeric items. This is a subset analysis, not a new leaderboard.
nonnumeric_data <- consensus |>
  filter(
    technical_valid %in% TRUE,
    numeric_answer %in% FALSE
  ) |>
  mutate(nonnumeric_semantic_outcome = as.integer(semantic_correct))

stopifnot(
  n_distinct(nonnumeric_data$item_id) == 66,
  nrow(nonnumeric_data) == 526,
  sum(nonnumeric_data$nonnumeric_semantic_outcome) == 212
)

nonnumeric_sensitivity <- fit_global_sensitivity(
  data = nonnumeric_data,
  outcome_column = "nonnumeric_semantic_outcome",
  analysis_label = "NUMERIC_ITEMS_EXCLUDED_VALID_POPULATION"
)

sensitivity_results <- bind_rows(
  expected_sensitivity$result,
  nonnumeric_sensitivity$result
)

sensitivity_model_profiles <- bind_rows(
  expected_sensitivity$analysis_data |>
    group_by(model_slot) |>
    summarise(
      analysis = "INVALID_AS_INCORRECT_EXPECTED_POPULATION",
      denominator = n(),
      correct = sum(outcome),
      accuracy = correct / denominator,
      .groups = "drop"
    ),
  nonnumeric_sensitivity$analysis_data |>
    group_by(model_slot) |>
    summarise(
      analysis = "NUMERIC_ITEMS_EXCLUDED_VALID_POPULATION",
      denominator = n(),
      correct = sum(outcome),
      accuracy = correct / denominator,
      .groups = "drop"
    )
) |>
  select(analysis, model_slot, denominator, correct, accuracy) |>
  arrange(analysis, model_slot)

cat("\n--- H1 sensitivity global tests ---\n")
print(sensitivity_results)
cat("\n--- Sensitivity model profiles ---\n")
print(sensitivity_model_profiles)

write_csv(
  sensitivity_results,
  file.path("student_outputs", "12_H1_sensitivity_global_tests.csv")
)
write_csv(
  sensitivity_model_profiles,
  file.path("student_outputs", "12_H1_sensitivity_model_profiles.csv")
)
write_json(
  list(
    expected_population = expected_sensitivity$diagnostics,
    numeric_items_excluded = nonnumeric_sensitivity$diagnostics
  ),
  file.path("student_outputs", "12_H1_sensitivity_diagnostics.json"),
  pretty = TRUE,
  auto_unbox = TRUE,
  null = "null"
)
saveRDS(
  list(
    expected_population = expected_sensitivity$fitted_models,
    numeric_items_excluded = nonnumeric_sensitivity$fitted_models
  ),
  file.path("student_outputs", "12_H1_sensitivity_fitted_models.rds")
)

cat("\nLesson 12 completed.\n")
cat("Expanded secondary model status:", secondary_feasibility$expanded_secondary_model_status, "\n")
cat("Model-by-domain interaction status:", secondary_feasibility$model_by_domain_interaction_status, "\n")
cat("Expected-population sensitivity raw p-value:", expected_sensitivity$result$raw_p, "\n")
cat("Numeric-exclusion sensitivity raw p-value:", nonnumeric_sensitivity$result$raw_p, "\n")
cat("Do not add these sensitivity p-values to the H1-H3 Holm family.\n")

