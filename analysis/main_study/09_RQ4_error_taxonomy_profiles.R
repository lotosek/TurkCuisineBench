# TurkCuisineBench — Lesson 9: RQ4 error-taxonomy profiles
#
# Learning objectives:
#   1. Distinguish error prevalence from error composition.
#   2. Describe primary operations and semantic targets overall and by model.
#   3. Use technically valid responses and final-IN responses as two explicit
#      denominators so abstentions are not silently reclassified as errors.
#   4. Keep taxonomy comparisons exploratory and avoid unregistered p-values.
#
# Denominators:
#   prevalence_among_valid = category count / all technically valid responses
#   composition_among_errors = category count / all final-IN responses

library(readr)
library(dplyr)
library(tidyr)
library(binom)
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

valid_responses <- consensus |>
  filter(technical_valid %in% TRUE)

error_responses <- valid_responses |>
  filter(final_decision == "IN")

stopifnot(
  nrow(valid_responses) == 574,
  nrow(error_responses) == 283,
  all(!is.na(error_responses$error_operation)),
  all(error_responses$error_operation != ""),
  all(!is.na(error_responses$semantic_target)),
  all(error_responses$semantic_target != ""),
  all(is.na(error_responses$secondary_operation))
)

# Error taxonomy fields must occur only when the final semantic decision is IN.
non_error_taxonomy_leakage <- valid_responses |>
  filter(
    final_decision != "IN",
    !is.na(error_operation) | !is.na(semantic_target)
  )

stopifnot(nrow(non_error_taxonomy_leakage) == 0)

operation_levels <- sort(unique(error_responses$error_operation))
target_levels <- sort(unique(error_responses$semantic_target))

stopifnot(
  identical(operation_levels, c("ADDITION", "OMISSION", "SUBSTITUTION")),
  length(target_levels) == 7
)

model_key <- consensus |>
  distinct(model_slot, provider, requested_model_id) |>
  arrange(model_slot)

model_denominators <- valid_responses |>
  group_by(model_slot) |>
  summarise(valid_responses = n(), .groups = "drop") |>
  left_join(
    error_responses |>
      count(model_slot, name = "error_responses"),
    by = "model_slot"
  ) |>
  left_join(model_key, by = "model_slot")

stopifnot(
  nrow(model_denominators) == 8,
  sum(model_denominators$valid_responses) == 574,
  sum(model_denominators$error_responses) == 283
)

error_long <- bind_rows(
  error_responses |>
    transmute(
      item_id,
      model_slot,
      taxonomy_dimension = "error_operation",
      category = error_operation
    ),
  error_responses |>
    transmute(
      item_id,
      model_slot,
      taxonomy_dimension = "semantic_target",
      category = semantic_target
    )
)

taxonomy_inventory <- bind_rows(
  tibble(
    taxonomy_dimension = "error_operation",
    category = operation_levels
  ),
  tibble(
    taxonomy_dimension = "semantic_target",
    category = target_levels
  )
)

# Overall counts with both denominators.
overall_counts <- error_long |>
  count(taxonomy_dimension, category, name = "category_count") |>
  mutate(
    technically_valid_responses = nrow(valid_responses),
    final_in_responses = nrow(error_responses),
    prevalence_among_valid =
      category_count / technically_valid_responses,
    composition_among_errors =
      category_count / final_in_responses
  )

# Deterministic item-cluster bootstrap for overall proportions. Each sampled
# item carries all technically valid model responses associated with that item.
bootstrap_seed <- 20260828
bootstrap_repetitions <- 10000L
set.seed(bootstrap_seed)

overall_bootstrap_summaries <- vector(
  "list",
  nrow(taxonomy_inventory)
)
overall_bootstrap_records <- vector(
  "list",
  nrow(taxonomy_inventory)
)

for (category_index in seq_len(nrow(taxonomy_inventory))) {
  current_dimension <-
    taxonomy_inventory$taxonomy_dimension[category_index]
  current_category <- taxonomy_inventory$category[category_index]

  category_indicator <- if (current_dimension == "error_operation") {
    valid_responses$final_decision == "IN" &
      valid_responses$error_operation == current_category
  } else if (current_dimension == "semantic_target") {
    valid_responses$final_decision == "IN" &
      valid_responses$semantic_target == current_category
  } else {
    stop("Unexpected taxonomy dimension: ", current_dimension)
  }

  item_statistics <- valid_responses |>
    mutate(
      is_any_error = final_decision == "IN",
      is_category = category_indicator
    ) |>
    group_by(item_id) |>
    summarise(
      valid_n = n(),
      error_n = sum(is_any_error),
      category_n = sum(is_category),
      .groups = "drop"
    ) |>
    arrange(item_id)

  stopifnot(nrow(item_statistics) == 72)

  bootstrap_indices <- matrix(
    sample.int(
      nrow(item_statistics),
      size = nrow(item_statistics) * bootstrap_repetitions,
      replace = TRUE
    ),
    nrow = nrow(item_statistics),
    ncol = bootstrap_repetitions
  )

  sampled_valid <- matrix(
    item_statistics$valid_n[bootstrap_indices],
    nrow = nrow(item_statistics),
    ncol = bootstrap_repetitions
  )
  sampled_errors <- matrix(
    item_statistics$error_n[bootstrap_indices],
    nrow = nrow(item_statistics),
    ncol = bootstrap_repetitions
  )
  sampled_category <- matrix(
    item_statistics$category_n[bootstrap_indices],
    nrow = nrow(item_statistics),
    ncol = bootstrap_repetitions
  )

  bootstrap_prevalence <-
    colSums(sampled_category) / colSums(sampled_valid)
  bootstrap_composition <-
    colSums(sampled_category) / colSums(sampled_errors)

  valid_bootstrap <-
    is.finite(bootstrap_prevalence) & is.finite(bootstrap_composition)

  stopifnot(sum(valid_bootstrap) >= 9990)

  prevalence_ci <- quantile(
    bootstrap_prevalence[valid_bootstrap],
    probs = c(0.025, 0.975),
    names = FALSE,
    type = 7
  )
  composition_ci <- quantile(
    bootstrap_composition[valid_bootstrap],
    probs = c(0.025, 0.975),
    names = FALSE,
    type = 7
  )

  overall_bootstrap_summaries[[category_index]] <- tibble(
    taxonomy_dimension = current_dimension,
    category = current_category,
    prevalence_bootstrap_ci_low = prevalence_ci[1],
    prevalence_bootstrap_ci_high = prevalence_ci[2],
    composition_bootstrap_ci_low = composition_ci[1],
    composition_bootstrap_ci_high = composition_ci[2],
    valid_bootstrap_repetitions = sum(valid_bootstrap)
  )

  overall_bootstrap_records[[category_index]] <- tibble(
    taxonomy_dimension = current_dimension,
    category = current_category,
    iteration = seq_len(bootstrap_repetitions),
    prevalence_among_valid = bootstrap_prevalence,
    composition_among_errors = bootstrap_composition
  )
}

overall_profiles <- overall_counts |>
  left_join(
    bind_rows(overall_bootstrap_summaries),
    by = c("taxonomy_dimension", "category")
  ) |>
  arrange(taxonomy_dimension, desc(category_count))

overall_bootstrap <- bind_rows(overall_bootstrap_records)

# Complete model × category grids retain meaningful zero cells.
model_category_grid <- taxonomy_inventory |>
  crossing(model_slot = model_key$model_slot)

model_category_counts <- error_long |>
  count(
    model_slot,
    taxonomy_dimension,
    category,
    name = "category_count"
  )

model_profiles <- model_category_grid |>
  left_join(
    model_category_counts,
    by = c("model_slot", "taxonomy_dimension", "category")
  ) |>
  mutate(category_count = coalesce(category_count, 0L)) |>
  left_join(model_denominators, by = "model_slot") |>
  mutate(
    prevalence_among_valid = category_count / valid_responses,
    composition_among_errors = category_count / error_responses
  )

prevalence_wilson <- binom.confint(
  x = model_profiles$category_count,
  n = model_profiles$valid_responses,
  methods = "wilson"
)

composition_wilson <- binom.confint(
  x = model_profiles$category_count,
  n = model_profiles$error_responses,
  methods = "wilson"
)

model_profiles <- model_profiles |>
  mutate(
    prevalence_wilson_ci_low = prevalence_wilson$lower,
    prevalence_wilson_ci_high = prevalence_wilson$upper,
    composition_wilson_ci_low = composition_wilson$lower,
    composition_wilson_ci_high = composition_wilson$upper,
    inference_status = "EXPLORATORY_DESCRIPTIVE"
  ) |>
  select(
    taxonomy_dimension,
    category,
    model_slot,
    provider,
    requested_model_id,
    category_count,
    valid_responses,
    prevalence_among_valid,
    prevalence_wilson_ci_low,
    prevalence_wilson_ci_high,
    error_responses,
    composition_among_errors,
    composition_wilson_ci_low,
    composition_wilson_ci_high,
    inference_status
  ) |>
  arrange(taxonomy_dimension, category, model_slot)

operation_target_crosstab <- error_responses |>
  count(error_operation, semantic_target, name = "responses") |>
  complete(
    error_operation = operation_levels,
    semantic_target = target_levels,
    fill = list(responses = 0L)
  ) |>
  arrange(error_operation, desc(responses), semantic_target)

stopifnot(
  sum(
    overall_profiles$category_count[
      overall_profiles$taxonomy_dimension == "error_operation"
    ]
  ) == 283,
  sum(
    overall_profiles$category_count[
      overall_profiles$taxonomy_dimension == "semantic_target"
    ]
  ) == 283,
  sum(operation_target_crosstab$responses) == 283,
  nrow(model_profiles) == 8 * nrow(taxonomy_inventory),
  nrow(overall_bootstrap) ==
    nrow(taxonomy_inventory) * bootstrap_repetitions
)

cat("\n--- RQ4 overall error-operation profile ---\n")
print(
  overall_profiles |>
    filter(taxonomy_dimension == "error_operation"),
  n = Inf,
  width = Inf
)

cat("\n--- RQ4 overall semantic-target profile ---\n")
print(
  overall_profiles |>
    filter(taxonomy_dimension == "semantic_target"),
  n = Inf,
  width = Inf
)

cat("\n--- RQ4 model-level error totals ---\n")
print(
  model_denominators |>
    select(
      model_slot,
      requested_model_id,
      valid_responses,
      error_responses
    ),
  n = Inf,
  width = Inf
)

output_dir <- "student_outputs"
dir.create(output_dir, showWarnings = FALSE)

write_csv(
  overall_profiles,
  file.path(output_dir, "09_RQ4_overall_error_taxonomy_profiles.csv")
)
write_csv(
  model_profiles,
  file.path(output_dir, "09_RQ4_model_error_taxonomy_profiles.csv")
)
write_csv(
  operation_target_crosstab,
  file.path(output_dir, "09_RQ4_operation_target_crosstab.csv")
)
write_csv(
  overall_bootstrap,
  file.path(output_dir, "09_RQ4_error_taxonomy_bootstrap_distribution.csv.gz")
)

rq4_metadata <- list(
  status = "exploratory_descriptive",
  technically_valid_denominator = nrow(valid_responses),
  final_in_denominator = nrow(error_responses),
  operation_categories = operation_levels,
  semantic_target_categories = target_levels,
  secondary_operation_used = FALSE,
  pooled_intervals = "Item-cluster percentile bootstrap 95% CI",
  model_intervals = "Wilson 95% CI; descriptive only",
  bootstrap_repetitions = bootstrap_repetitions,
  bootstrap_seed = bootstrap_seed,
  additional_inferential_p_values = 0
)

write_json(
  rq4_metadata,
  file.path(output_dir, "09_RQ4_error_taxonomy_metadata.json"),
  pretty = TRUE,
  auto_unbox = TRUE
)

cat("\nLesson 9 completed.\n")
cat("Technically valid responses:", nrow(valid_responses), "\n")
cat("Final-IN responses:", nrow(error_responses), "\n")
cat("Primary operation categories:", length(operation_levels), "\n")
cat("Semantic target categories:", length(target_levels), "\n")
cat("Secondary operations used: 0\n")
cat("Additional inferential p-values created: 0\n")
cat("Interpret model-category profiles as exploratory descriptions.\n")
