# TurkCuisineBench — Lesson 5: H3 exact match versus semantic accuracy
#
# Learning objectives:
#   1. Understand why exact and semantic scores are paired observations.
#   2. Test the registered scoring-method effect with a binomial GLMM.
#   3. Estimate the absolute recovery gained by semantic review.
#   4. Quantify uncertainty with a paired item-cluster bootstrap.
#
# IMPORTANT:
#   - Run 01_import_and_qc.R first in the same RStudio session, or this script
#     will import the locked private consensus file itself.
#   - H3 belongs to the H1-H3 confirmatory family. This lesson records the raw
#     p-value; the final decision is made only after Holm correction.

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

# H3 uses only technically valid responses. The two scores belong to the same
# response, so they must never be treated as independent observations.
h3_wide <- consensus |>
  filter(technical_valid %in% TRUE) |>
  transmute(
    response_id = factor(response_id),
    item_id = factor(item_id),
    model_slot = factor(model_slot, levels = paste0("S0", 1:8)),
    exact_correct = as.integer(exact_correct),
    semantic_correct = as.integer(semantic_correct)
  )

stopifnot(
  nrow(h3_wide) == 574,
  nlevels(h3_wide$response_id) == 574,
  nlevels(h3_wide$item_id) == 72,
  nlevels(h3_wide$model_slot) == 8,
  !anyNA(h3_wide$exact_correct),
  !anyNA(h3_wide$semantic_correct),
  all(h3_wide$exact_correct %in% c(0L, 1L)),
  all(h3_wide$semantic_correct %in% c(0L, 1L))
)

# Frozen hierarchy audit: an exact registered-answer match must also be
# semantically correct. Any violation would indicate a data construction error.
exact_semantic_conflicts <- h3_wide |>
  filter(exact_correct == 1L, semantic_correct == 0L)

if (nrow(exact_semantic_conflicts) > 0) {
  stop(
    "H3 audit failed: exact-correct/semantic-incorrect records were found. ",
    "Do not continue until the locked consensus construction is audited."
  )
}

h3_paired_cells <- h3_wide |>
  count(exact_correct, semantic_correct, name = "responses") |>
  arrange(exact_correct, semantic_correct)

cat("\n--- H3 paired score table ---\n")
print(h3_paired_cells)

exact_correct_n <- sum(h3_wide$exact_correct)
semantic_correct_n <- sum(h3_wide$semantic_correct)
recovered_correct_n <- sum(
  h3_wide$exact_correct == 0L & h3_wide$semantic_correct == 1L
)

stopifnot(
  exact_correct_n == 187,
  semantic_correct_n == 230,
  recovered_correct_n == 43
)

# Stack the two paired scores. Each response now contributes exactly two rows.
h3_long <- h3_wide |>
  pivot_longer(
    cols = c(exact_correct, semantic_correct),
    names_to = "scoring_method",
    values_to = "correct"
  ) |>
  mutate(
    scoring_method = factor(
      scoring_method,
      levels = c("exact_correct", "semantic_correct"),
      labels = c("exact", "semantic")
    )
  )

stopifnot(
  nrow(h3_long) == 1148,
  all(count(h3_long, response_id)$n == 2)
)

# Registered models:
#   Null: model-slot adjustment plus item and response random intercepts.
#   Alternative: null model plus the scoring-method effect.
# The response random intercept preserves exact/semantic pairing. The item
# random intercept preserves repeated testing of the same 72 items by models.
fit_h3_pair <- function(optimizer_name) {
  control_settings <- glmerControl(
    optimizer = optimizer_name,
    optCtrl = list(maxfun = 200000)
  )

  null_model <- glmer(
    correct ~ model_slot + (1 | item_id) + (1 | response_id),
    data = h3_long,
    family = binomial(link = "logit"),
    nAGQ = 1,
    control = control_settings
  )

  alternative_model <- glmer(
    correct ~ model_slot + scoring_method +
      (1 | item_id) + (1 | response_id),
    data = h3_long,
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

h3_pair_is_usable <- function(pair) {
  !model_has_convergence_message(pair$null) &&
    !model_has_convergence_message(pair$alternative) &&
    !isSingular(pair$null, tol = 1e-4) &&
    !isSingular(pair$alternative, tol = 1e-4)
}

h3_pair <- fit_h3_pair("bobyqa")
h3_optimizer <- "bobyqa"

if (!h3_pair_is_usable(h3_pair)) {
  message(
    "Primary optimizer produced a convergence or singularity warning; ",
    "retrying with nloptwrap."
  )
  h3_pair <- fit_h3_pair("nloptwrap")
  h3_optimizer <- "nloptwrap"
}

h3_glmm_usable <- h3_pair_is_usable(h3_pair)

cat("\n--- H3 GLMM diagnostics ---\n")
cat("Optimizer:", h3_optimizer, "\n")
cat(
  "Null convergence message:",
  model_has_convergence_message(h3_pair$null),
  "\n"
)
cat(
  "Alternative convergence message:",
  model_has_convergence_message(h3_pair$alternative),
  "\n"
)
cat("Null singular:", isSingular(h3_pair$null, tol = 1e-4), "\n")
cat(
  "Alternative singular:",
  isSingular(h3_pair$alternative, tol = 1e-4),
  "\n"
)
cat("GLMM usable:", h3_glmm_usable, "\n")

if (!h3_glmm_usable) {
  stop(
    "H3 mixed model remained unusable after the registered optimizer retry. ",
    "Do not manufacture a confirmatory p-value; inspect and document the failure."
  )
}

h3_lrt <- anova(h3_pair$null, h3_pair$alternative, test = "Chisq")
h3_statistic <- unname(h3_lrt$Chisq[2])
h3_df <- unname(h3_lrt$Df[2])
h3_raw_p <- unname(h3_lrt$`Pr(>Chisq)`[2])

cat("\n--- Registered H3 likelihood-ratio test ---\n")
print(h3_lrt)

# Model-based odds ratio: semantic scoring relative to exact scoring, holding
# model slot constant and retaining the registered random-effects structure.
h3_fixed_effects <- tidy(
  h3_pair$alternative,
  effects = "fixed",
  conf.int = TRUE,
  exponentiate = TRUE
)

h3_scoring_or <- h3_fixed_effects |>
  filter(term == "scoring_methodsemantic")

stopifnot(nrow(h3_scoring_or) == 1)

# Because exact correctness is structurally a subset of semantic correctness,
# discordant pairs can occur only in the exact=0/semantic=1 direction. This may
# produce extremely large conditional random-effect scales and odds ratios even
# when the model converges. Response-scale EMM transformations are therefore not
# used for H3: near-zero conditional probabilities at random effects equal to
# zero would be misleading population summaries. The registered LRT is retained,
# while the absolute paired recovery and its item-cluster bootstrap interval are
# the primary interpretable effect-size estimates.
h3_alternative_varcorr <- as.data.frame(VarCorr(h3_pair$alternative))
h3_max_random_effect_sd <- max(
  h3_alternative_varcorr$sdcor[
    is.na(h3_alternative_varcorr$var2) &
      h3_alternative_varcorr$var1 == "(Intercept)"
  ]
)

h3_structural_one_way_discordance <-
  sum(h3_wide$exact_correct == 1L & h3_wide$semantic_correct == 0L) == 0L &&
  recovered_correct_n > 0L

h3_model_scale_warning <-
  h3_max_random_effect_sd > 10 || h3_scoring_or$estimate > 1e4

cat("\n--- H3 conditional model-scale diagnostic ---\n")
cat("Largest alternative-model random-effect SD:", h3_max_random_effect_sd, "\n")
cat("Semantic-versus-exact conditional odds ratio:", h3_scoring_or$estimate, "\n")
cat("Structural one-way discordance:", h3_structural_one_way_discordance, "\n")
cat("Model-scale warning:", h3_model_scale_warning, "\n")

if (h3_model_scale_warning) {
  message(
    "H3 model converged, but structural one-way discordance produced an ",
    "extreme conditional scale. Retain the registered LRT; interpret the ",
    "observed paired recovery and item-cluster bootstrap as the primary ",
    "effect-size evidence."
  )
}

# Observed absolute recovery and paired item-cluster bootstrap.
observed_exact_accuracy <- mean(h3_wide$exact_correct)
observed_semantic_accuracy <- mean(h3_wide$semantic_correct)
observed_semantic_minus_exact <-
  observed_semantic_accuracy - observed_exact_accuracy

h3_item_statistics <- h3_wide |>
  group_by(item_id) |>
  summarise(
    exact_correct_n = sum(exact_correct),
    semantic_correct_n = sum(semantic_correct),
    valid_n = n(),
    .groups = "drop"
  )

stopifnot(nrow(h3_item_statistics) == 72)

set.seed(20260828)
bootstrap_repetitions <- 10000L
bootstrap_difference <- numeric(bootstrap_repetitions)

for (iteration in seq_len(bootstrap_repetitions)) {
  sampled_rows <- sample(
    seq_len(nrow(h3_item_statistics)),
    size = nrow(h3_item_statistics),
    replace = TRUE
  )

  sampled_items <- h3_item_statistics[sampled_rows, ]

  bootstrap_difference[iteration] <-
    sum(sampled_items$semantic_correct_n) /
      sum(sampled_items$valid_n) -
    sum(sampled_items$exact_correct_n) /
      sum(sampled_items$valid_n)
}

valid_bootstrap_difference <-
  bootstrap_difference[is.finite(bootstrap_difference)]

bootstrap_ci <- quantile(
  valid_bootstrap_difference,
  probs = c(0.025, 0.975),
  names = FALSE,
  type = 7
)

stopifnot(length(valid_bootstrap_difference) == bootstrap_repetitions)

h3_result <- tibble(
  hypothesis = "H3",
  method = "Binomial GLMM likelihood-ratio test",
  optimizer = h3_optimizer,
  glmm_usable = h3_glmm_usable,
  statistic = h3_statistic,
  df = h3_df,
  raw_p = h3_raw_p,
  semantic_vs_exact_odds_ratio = h3_scoring_or$estimate,
  odds_ratio_ci_low = h3_scoring_or$conf.low,
  odds_ratio_ci_high = h3_scoring_or$conf.high,
  largest_random_effect_sd = h3_max_random_effect_sd,
  structural_one_way_discordance = h3_structural_one_way_discordance,
  model_scale_warning = h3_model_scale_warning,
  exact_correct_n = exact_correct_n,
  semantic_correct_n = semantic_correct_n,
  recovered_correct_n = recovered_correct_n,
  observed_exact_accuracy = observed_exact_accuracy,
  observed_semantic_accuracy = observed_semantic_accuracy,
  observed_semantic_minus_exact = observed_semantic_minus_exact,
  bootstrap_ci_low = bootstrap_ci[1],
  bootstrap_ci_high = bootstrap_ci[2],
  bootstrap_repetitions = bootstrap_repetitions,
  bootstrap_seed = 20260828,
  observed_direction_matches_h3 =
    observed_semantic_minus_exact > 0,
  confirmatory_holm_p = NA_real_,
  final_confirmatory_interpretation =
    "DEFER UNTIL H1-H3 HOLM CORRECTION"
)

h3_diagnostics <- list(
  analysis_population_n = nrow(h3_wide),
  stacked_observations_n = nrow(h3_long),
  response_clusters = nlevels(h3_wide$response_id),
  item_clusters = nlevels(h3_wide$item_id),
  model_levels = levels(h3_wide$model_slot),
  exact_semantic_conflicts = nrow(exact_semantic_conflicts),
  optimizer = h3_optimizer,
  null_convergence_message = h3_pair$null@optinfo$conv$lme4$messages,
  alternative_convergence_message =
    h3_pair$alternative@optinfo$conv$lme4$messages,
  null_singular = isSingular(h3_pair$null, tol = 1e-4),
  alternative_singular = isSingular(h3_pair$alternative, tol = 1e-4),
  glmm_usable = h3_glmm_usable,
  largest_alternative_random_effect_sd = h3_max_random_effect_sd,
  structural_one_way_discordance = h3_structural_one_way_discordance,
  model_scale_warning = h3_model_scale_warning,
  bootstrap_valid_repetitions = length(valid_bootstrap_difference),
  bootstrap_seed = 20260828
)

dir.create("student_outputs", showWarnings = FALSE)
write_csv(
  h3_result,
  file.path("student_outputs", "05_H3_exact_vs_semantic_raw.csv")
)
write_csv(
  h3_paired_cells,
  file.path("student_outputs", "05_H3_paired_score_table.csv")
)
write_csv(
  h3_fixed_effects,
  file.path("student_outputs", "05_H3_fixed_effects_diagnostic.csv")
)
write_csv(
  tibble(
    iteration = seq_along(bootstrap_difference),
    semantic_minus_exact = bootstrap_difference
  ),
  file.path("student_outputs", "05_H3_bootstrap_distribution.csv")
)
write_json(
  h3_diagnostics,
  file.path("student_outputs", "05_H3_diagnostics.json"),
  pretty = TRUE,
  auto_unbox = TRUE,
  null = "null"
)
saveRDS(
  h3_pair,
  file.path("student_outputs", "05_H3_fitted_models.rds")
)

cat("\nLesson 5 completed.\n")
cat("H3 raw p-value:", h3_raw_p, "\n")
cat("Exact correct:", exact_correct_n, "/", nrow(h3_wide), "\n")
cat("Semantic correct:", semantic_correct_n, "/", nrow(h3_wide), "\n")
cat("Recovered correct non-exact responses:", recovered_correct_n, "\n")
cat(
  "Observed semantic - exact difference:",
  observed_semantic_minus_exact,
  "\n"
)
cat(
  "Observed direction matches H3:",
  observed_semantic_minus_exact > 0,
  "\n"
)
cat(
  "Paired item-bootstrap 95% CI:",
  bootstrap_ci[1], "to", bootstrap_ci[2],
  "\n"
)
cat("Conditional model-scale warning:", h3_model_scale_warning, "\n")
cat(
  "Do not interpret confirmatory significance until Holm correction is ",
  "applied to H1-H3.\n",
  sep = ""
)
