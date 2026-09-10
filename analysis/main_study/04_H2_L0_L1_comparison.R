# TurkCuisineBench — Lesson 4: H2 lexical-leakage comparison
#
# Confirmatory proposition:
#   L0 items are expected to be more difficult than L1 items.
#
# Registered inferential approach:
#   Two-sided likelihood-ratio test comparing binomial mixed-effects models.
#   Direction is evaluated from the signed L0 - L1 estimate, not from a
#   one-sided p-value.
#
#   Null: semantic_correct ~ model_slot + (1 | item_id)
#   Alt:  semantic_correct ~ model_slot + lexical_leakage + (1 | item_id)
#
# The fixed model-slot term controls for overall performance differences among
# the eight models. The item random intercept accounts for repeated model
# responses to the same Test item.

library(readr)
library(dplyr)
library(lme4)
library(emmeans)
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

h2_data <- consensus |>
  filter(technical_valid %in% TRUE) |>
  transmute(
    response_id,
    item_id = factor(item_id),
    model_slot = factor(model_slot, levels = paste0("S0", 1:8)),
    lexical_leakage = factor(lexical_leakage, levels = c("L0", "L1")),
    semantic_correct = as.integer(semantic_correct)
  )

# Lexical-leakage level is an item property, so every item must have exactly one
# level. The frozen benchmark contains 60 L0 and 12 L1 items.
h2_item_metadata <- h2_data |>
  distinct(item_id, lexical_leakage)

item_level_counts <- h2_item_metadata |>
  count(lexical_leakage, name = "items")

cat("\n--- H2 item composition ---\n")
print(item_level_counts)

stopifnot(
  nrow(h2_data) == 574,
  nrow(h2_item_metadata) == 72,
  item_level_counts$items[item_level_counts$lexical_leakage == "L0"] == 60,
  item_level_counts$items[item_level_counts$lexical_leakage == "L1"] == 12,
  all(h2_data$semantic_correct %in% c(0L, 1L))
)

fit_h2_pair <- function(optimizer_name) {
  control_settings <- glmerControl(
    optimizer = optimizer_name,
    optCtrl = list(maxfun = 200000)
  )

  null_model <- glmer(
    semantic_correct ~ model_slot + (1 | item_id),
    data = h2_data,
    family = binomial(link = "logit"),
    nAGQ = 1,
    control = control_settings
  )

  alternative_model <- glmer(
    semantic_correct ~ model_slot + lexical_leakage + (1 | item_id),
    data = h2_data,
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

h2_pair_is_usable <- function(pair) {
  !model_has_convergence_message(pair$null) &&
    !model_has_convergence_message(pair$alternative) &&
    !isSingular(pair$null, tol = 1e-4) &&
    !isSingular(pair$alternative, tol = 1e-4)
}

h2_pair <- fit_h2_pair("bobyqa")
h2_optimizer <- "bobyqa"

if (!h2_pair_is_usable(h2_pair)) {
  message("Primary optimizer produced a convergence or singularity warning; retrying with nloptwrap.")
  h2_pair <- fit_h2_pair("nloptwrap")
  h2_optimizer <- "nloptwrap"
}

h2_glmm_usable <- h2_pair_is_usable(h2_pair)

cat("\n--- H2 GLMM diagnostics ---\n")
cat("Optimizer:", h2_optimizer, "\n")
cat("Null convergence message:", model_has_convergence_message(h2_pair$null), "\n")
cat("Alternative convergence message:", model_has_convergence_message(h2_pair$alternative), "\n")
cat("Null singular:", isSingular(h2_pair$null, tol = 1e-4), "\n")
cat("Alternative singular:", isSingular(h2_pair$alternative, tol = 1e-4), "\n")
cat("GLMM usable:", h2_glmm_usable, "\n")

if (!h2_glmm_usable) {
  stop(
    "H2 mixed model remained unusable after the registered optimizer retry. ",
    "Do not manufacture a confirmatory p-value; inspect diagnostics and document the failure."
  )
}

h2_lrt <- anova(
  h2_pair$null,
  h2_pair$alternative,
  test = "Chisq"
)

h2_statistic <- unname(h2_lrt$Chisq[2])
h2_df <- unname(h2_lrt$Df[2])
h2_raw_p <- unname(h2_lrt$`Pr(>Chisq)`[2])

cat("\n--- Registered H2 likelihood-ratio test ---\n")
print(h2_lrt)

# Odds ratio: L1 relative to L0, holding model slot constant.
h2_fixed_effects <- tidy(
  h2_pair$alternative,
  effects = "fixed",
  conf.int = TRUE,
  exponentiate = TRUE
)

h2_lexical_or <- h2_fixed_effects |>
  filter(term == "lexical_leakageL1")

stopifnot(nrow(h2_lexical_or) == 1)

# Equal-weight marginal probabilities average over the eight model slots.
h2_emmeans_link <- emmeans(
  h2_pair$alternative,
  ~ lexical_leakage,
  weights = "equal"
)

h2_marginal_probabilities <- summary(
  h2_emmeans_link,
  type = "response",
  # Confidence intervals are relevant here; testing each probability against
  # 0.50 is not part of H2 and would add an unregistered, distracting test.
  infer = c(TRUE, FALSE)
) |>
  as.data.frame()

# Regridding places contrasts on the response-probability scale. The registered
# signed effect is L0 minus L1. A negative value is consistent with the proposed
# direction that L0 is harder, but does not by itself constitute support for H2.
h2_probability_grid <- regrid(
  h2_emmeans_link,
  transform = "response"
)

h2_probability_difference <- contrast(
  h2_probability_grid,
  method = list("L0_minus_L1" = c(1, -1)),
  adjust = "none"
) |>
  summary(infer = c(TRUE, TRUE)) |>
  as.data.frame()

cat("\n--- Model-adjusted marginal probabilities ---\n")
print(h2_marginal_probabilities)
cat("\n--- Model-adjusted probability difference ---\n")
print(h2_probability_difference)

# Deterministic item-cluster bootstrap.
# Each resampled item carries all technically valid model responses belonging to
# that item. Duplicated sampled items remain duplicated analytical clusters.
h2_item_statistics <- h2_data |>
  group_by(item_id, lexical_leakage) |>
  summarise(
    correct_n = sum(semantic_correct),
    valid_n = n(),
    .groups = "drop"
  )

observed_l0_accuracy <- with(
  filter(h2_item_statistics, lexical_leakage == "L0"),
  sum(correct_n) / sum(valid_n)
)

observed_l1_accuracy <- with(
  filter(h2_item_statistics, lexical_leakage == "L1"),
  sum(correct_n) / sum(valid_n)
)

observed_l0_minus_l1 <- observed_l0_accuracy - observed_l1_accuracy

set.seed(20260828)
bootstrap_repetitions <- 10000L
bootstrap_difference <- numeric(bootstrap_repetitions)

for (iteration in seq_len(bootstrap_repetitions)) {
  sampled_rows <- sample(
    seq_len(nrow(h2_item_statistics)),
    size = nrow(h2_item_statistics),
    replace = TRUE
  )

  sampled_items <- h2_item_statistics[sampled_rows, ]

  sampled_l0 <- sampled_items |>
    filter(lexical_leakage == "L0")

  sampled_l1 <- sampled_items |>
    filter(lexical_leakage == "L1")

  if (nrow(sampled_l0) == 0 || nrow(sampled_l1) == 0) {
    bootstrap_difference[iteration] <- NA_real_
  } else {
    bootstrap_difference[iteration] <-
      sum(sampled_l0$correct_n) / sum(sampled_l0$valid_n) -
      sum(sampled_l1$correct_n) / sum(sampled_l1$valid_n)
  }
}

valid_bootstrap_difference <- bootstrap_difference[is.finite(bootstrap_difference)]
bootstrap_ci <- quantile(
  valid_bootstrap_difference,
  probs = c(0.025, 0.975),
  names = FALSE,
  type = 7
)

stopifnot(length(valid_bootstrap_difference) >= 9990)

h2_result <- tibble(
  hypothesis = "H2",
  method = "Binomial GLMM likelihood-ratio test",
  optimizer = h2_optimizer,
  glmm_usable = h2_glmm_usable,
  statistic = h2_statistic,
  df = h2_df,
  raw_p = h2_raw_p,
  l1_vs_l0_odds_ratio = h2_lexical_or$estimate,
  odds_ratio_ci_low = h2_lexical_or$conf.low,
  odds_ratio_ci_high = h2_lexical_or$conf.high,
  model_adjusted_l0_minus_l1 = h2_probability_difference$estimate,
  model_adjusted_difference_ci_low = h2_probability_difference$asymp.LCL,
  model_adjusted_difference_ci_high = h2_probability_difference$asymp.UCL,
  observed_l0_accuracy = observed_l0_accuracy,
  observed_l1_accuracy = observed_l1_accuracy,
  observed_l0_minus_l1 = observed_l0_minus_l1,
  bootstrap_ci_low = bootstrap_ci[1],
  bootstrap_ci_high = bootstrap_ci[2],
  bootstrap_repetitions = bootstrap_repetitions,
  bootstrap_seed = 20260828,
  observed_direction_matches_h2 = h2_probability_difference$estimate < 0,
  provisional_evidence = if_else(
    h2_raw_p < 0.05 & h2_probability_difference$estimate < 0,
    "DIRECTION MATCHES H2 AND RAW TEST REJECTS; FINAL AFTER HOLM",
    "NO STATISTICAL SUPPORT BEFORE HOLM"
  ),
  confirmatory_holm_p = NA_real_,
  final_confirmatory_interpretation = "DEFER UNTIL H1-H3 HOLM CORRECTION"
)

h2_diagnostics <- list(
  analysis_population_n = nrow(h2_data),
  l0_items = item_level_counts$items[item_level_counts$lexical_leakage == "L0"],
  l1_items = item_level_counts$items[item_level_counts$lexical_leakage == "L1"],
  optimizer = h2_optimizer,
  null_convergence_message = h2_pair$null@optinfo$conv$lme4$messages,
  alternative_convergence_message = h2_pair$alternative@optinfo$conv$lme4$messages,
  null_singular = isSingular(h2_pair$null, tol = 1e-4),
  alternative_singular = isSingular(h2_pair$alternative, tol = 1e-4),
  glmm_usable = h2_glmm_usable,
  bootstrap_valid_repetitions = length(valid_bootstrap_difference),
  bootstrap_seed = 20260828
)

dir.create("student_outputs", showWarnings = FALSE)
write_csv(h2_result, file.path("student_outputs", "04_H2_lexical_leakage_raw.csv"))
write_csv(h2_marginal_probabilities, file.path("student_outputs", "04_H2_marginal_probabilities.csv"))
write_csv(h2_probability_difference, file.path("student_outputs", "04_H2_probability_difference.csv"))
write_csv(tibble(iteration = seq_along(bootstrap_difference), l0_minus_l1 = bootstrap_difference), file.path("student_outputs", "04_H2_bootstrap_distribution.csv"))
write_json(h2_diagnostics, file.path("student_outputs", "04_H2_diagnostics.json"), pretty = TRUE, auto_unbox = TRUE, null = "null")
saveRDS(h2_pair, file.path("student_outputs", "04_H2_fitted_models.rds"))

cat("\nLesson 4 completed.\n")
cat("H2 raw p-value:", h2_raw_p, "\n")
cat("Adjusted L0 - L1 difference:", h2_probability_difference$estimate, "\n")
cat("Observed direction matches H2:", h2_probability_difference$estimate < 0, "\n")
cat(
  "Provisional evidence:",
  if_else(
    h2_raw_p < 0.05 & h2_probability_difference$estimate < 0,
    "direction matches and raw test rejects; final inference awaits Holm correction",
    "no statistical support before Holm correction"
  ),
  "\n"
)
cat("Do not interpret confirmatory significance until Holm correction is applied to H1-H3.\n")
