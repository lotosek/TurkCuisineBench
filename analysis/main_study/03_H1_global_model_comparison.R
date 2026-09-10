# TurkCuisineBench — Lesson 3: H1 global model comparison
#
# Confirmatory question:
#   Does semantic accuracy differ across the eight model slots after accounting
#   for repeated evaluation of the same Test items?
#
# Prespecified primary test:
#   Likelihood-ratio test (LRT) comparing two binomial mixed-effects models.
#
#   Null:        semantic_correct ~ 1          + (1 | item_id)
#   Alternative: semantic_correct ~ model_slot + (1 | item_id)
#
# The item random intercept accounts for the fact that each Test item is answered
# by multiple models and that some items are intrinsically easier than others.
#
# IMPORTANT:
#   This script produces the raw H1 p-value. Do not make the final confirmatory
#   decision until H1, H2, and H3 have all received Holm correction.

library(readr)
library(dplyr)
library(tidyr)
library(lme4)
library(broom.mixed)
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

# Primary semantic analysis excludes technical invalidity from the denominator.
h1_data <- consensus |>
  filter(technical_valid %in% TRUE) |>
  transmute(
    response_id,
    item_id = factor(item_id),
    model_slot = factor(model_slot, levels = paste0("S0", 1:8)),
    semantic_correct = as.integer(semantic_correct)
  )

stopifnot(
  nrow(h1_data) == 574,
  nlevels(h1_data$item_id) == 72,
  nlevels(h1_data$model_slot) == 8,
  all(h1_data$semantic_correct %in% c(0L, 1L))
)

cat("\nH1 analysis population:", nrow(h1_data), "technically valid responses\n")
cat("Item clusters:", nlevels(h1_data$item_id), "\n")
cat("Model levels:", paste(levels(h1_data$model_slot), collapse = ", "), "\n")

# Maximum-likelihood estimation with the same integration setting in both
# nested models. nAGQ = 1 is the Laplace approximation used by glmer.
fit_pair <- function(optimizer_name) {
  control_settings <- glmerControl(
    optimizer = optimizer_name,
    optCtrl = list(maxfun = 200000)
  )

  null_model <- glmer(
    semantic_correct ~ 1 + (1 | item_id),
    data = h1_data,
    family = binomial(link = "logit"),
    nAGQ = 1,
    control = control_settings
  )

  alternative_model <- glmer(
    semantic_correct ~ model_slot + (1 | item_id),
    data = h1_data,
    family = binomial(link = "logit"),
    nAGQ = 1,
    control = control_settings
  )

  list(null = null_model, alternative = alternative_model)
}

model_has_convergence_message <- function(model) {
  messages <- model@optinfo$conv$lme4$messages
  !is.null(messages) && length(messages) > 0
}

pair_is_usable <- function(pair) {
  !model_has_convergence_message(pair$null) &&
    !model_has_convergence_message(pair$alternative) &&
    !isSingular(pair$null, tol = 1e-4) &&
    !isSingular(pair$alternative, tol = 1e-4)
}

# First registered optimizer attempt.
h1_pair <- fit_pair("bobyqa")
h1_optimizer <- "bobyqa"

# A single documented standard optimizer retry is permitted if necessary.
if (!pair_is_usable(h1_pair)) {
  message("Primary optimizer produced a convergence or singularity warning; retrying with nloptwrap.")
  h1_pair <- fit_pair("nloptwrap")
  h1_optimizer <- "nloptwrap"
}

h1_glmm_usable <- pair_is_usable(h1_pair)

cat("\n--- GLMM diagnostics ---\n")
cat("Optimizer:", h1_optimizer, "\n")
cat("Null convergence message:", model_has_convergence_message(h1_pair$null), "\n")
cat("Alternative convergence message:", model_has_convergence_message(h1_pair$alternative), "\n")
cat("Null singular:", isSingular(h1_pair$null, tol = 1e-4), "\n")
cat("Alternative singular:", isSingular(h1_pair$alternative, tol = 1e-4), "\n")
cat("GLMM usable:", h1_glmm_usable, "\n")

# Prespecified fallback: Cochran's Q on items with valid responses from all
# eight models. It is calculated regardless, but becomes the inferential H1
# test only when the mixed model is unusable.
h1_wide <- h1_data |>
  select(item_id, model_slot, semantic_correct) |>
  pivot_wider(names_from = model_slot, values_from = semantic_correct) |>
  arrange(item_id)

complete_h1_wide <- h1_wide |>
  filter(if_all(starts_with("S"), ~ !is.na(.x)))

q_matrix <- as.matrix(select(complete_h1_wide, starts_with("S")))
k_models <- ncol(q_matrix)
column_totals <- colSums(q_matrix)
row_totals <- rowSums(q_matrix)

q_numerator <- (k_models - 1) * (
  k_models * sum(column_totals^2) - sum(column_totals)^2
)
q_denominator <- k_models * sum(row_totals) - sum(row_totals^2)
q_statistic <- q_numerator / q_denominator
q_df <- k_models - 1
q_p_value <- pchisq(q_statistic, df = q_df, lower.tail = FALSE)

cat("\nCochran Q common-valid items:", nrow(complete_h1_wide), "\n")
cat("Cochran Q statistic:", q_statistic, "df:", q_df, "raw p:", q_p_value, "\n")

if (h1_glmm_usable) {
  h1_lrt <- anova(
    h1_pair$null,
    h1_pair$alternative,
    test = "Chisq"
  )

  h1_method <- "Binomial GLMM likelihood-ratio test"
  h1_statistic <- unname(h1_lrt$Chisq[2])
  # lme4 names the likelihood-ratio degrees-of-freedom column `Df`.
  h1_df <- unname(h1_lrt$Df[2])
  h1_raw_p <- unname(h1_lrt$`Pr(>Chisq)`[2])

  cat("\n--- Registered H1 result: GLMM LRT ---\n")
  print(h1_lrt)
} else {
  h1_method <- "Cochran Q fallback"
  h1_statistic <- q_statistic
  h1_df <- q_df
  h1_raw_p <- q_p_value

  cat("\n--- Registered H1 result: Cochran Q fallback ---\n")
  cat("Statistic:", h1_statistic, "df:", h1_df, "raw p:", h1_raw_p, "\n")
}

# These odds ratios compare each model slot with S01, the reference category.
# They are diagnostic/descriptive at this stage and are not the registered set
# of 28 Holm-corrected pairwise model contrasts.
h1_fixed_effects <- tidy(
  h1_pair$alternative,
  effects = "fixed",
  conf.int = TRUE,
  exponentiate = TRUE
)

h1_result <- tibble(
  hypothesis = "H1",
  method = h1_method,
  optimizer = h1_optimizer,
  glmm_usable = h1_glmm_usable,
  statistic = h1_statistic,
  df = h1_df,
  raw_p = h1_raw_p,
  confirmatory_holm_p = NA_real_,
  final_confirmatory_interpretation = "DEFER UNTIL H1-H3 HOLM CORRECTION"
)

h1_diagnostics <- list(
  analysis_population_n = nrow(h1_data),
  item_clusters = nlevels(h1_data$item_id),
  model_levels = levels(h1_data$model_slot),
  optimizer = h1_optimizer,
  null_convergence_message = h1_pair$null@optinfo$conv$lme4$messages,
  alternative_convergence_message = h1_pair$alternative@optinfo$conv$lme4$messages,
  null_singular = isSingular(h1_pair$null, tol = 1e-4),
  alternative_singular = isSingular(h1_pair$alternative, tol = 1e-4),
  glmm_usable = h1_glmm_usable,
  cochran_q_common_valid_items = nrow(complete_h1_wide),
  cochran_q_statistic = unname(q_statistic),
  cochran_q_df = q_df,
  cochran_q_raw_p = unname(q_p_value)
)

dir.create("student_outputs", showWarnings = FALSE)
write_csv(h1_result, file.path("student_outputs", "03_H1_global_test_raw.csv"))
write_csv(h1_fixed_effects, file.path("student_outputs", "03_H1_fixed_effects_diagnostic.csv"))
write_json(h1_diagnostics, file.path("student_outputs", "03_H1_diagnostics.json"), pretty = TRUE, auto_unbox = TRUE, null = "null")
saveRDS(h1_pair, file.path("student_outputs", "03_H1_fitted_models.rds"))

cat("\nLesson 3 completed.\n")
cat("H1 method used:", h1_method, "\n")
cat("H1 raw p-value:", h1_raw_p, "\n")
cat("Do not interpret confirmatory significance until Holm correction is applied to H1-H3.\n")
