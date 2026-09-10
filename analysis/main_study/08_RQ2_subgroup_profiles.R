# TurkCuisineBench — Lesson 8: RQ2 descriptive subgroup profiles
#
# Learning objectives:
#   1. Inspect item composition before interpreting subgroup accuracy.
#   2. Preserve the frozen subgroup labels without post-output regrouping.
#   3. Estimate pooled subgroup accuracy with item-cluster bootstrap intervals.
#   4. Mark sparse and degenerate cells instead of over-interpreting them.
#
# IMPORTANT:
#   - This lesson is secondary/descriptive. It does not create additional
#     confirmatory p-values.
#   - H2 remains the registered inferential analysis for lexical cue level.
#   - A model-by-subgroup confidence interval is descriptive and is not a test
#     of a model-by-subgroup interaction.

library(readr)
library(dplyr)
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

subgroup_variables <- c(
  "knowledge_domain",
  "knowledge_specificity",
  "lexical_leakage",
  "answer_form",
  "numeric_answer"
)

item_metadata <- consensus |>
  distinct(
    item_id,
    knowledge_domain,
    knowledge_specificity,
    lexical_leakage,
    answer_form,
    numeric_answer
  )

stopifnot(
  nrow(item_metadata) == 72,
  !anyDuplicated(item_metadata$item_id)
)

valid_responses <- consensus |>
  filter(technical_valid %in% TRUE) |>
  mutate(semantic_correct = as.integer(semantic_correct))

stopifnot(
  nrow(valid_responses) == 574,
  !anyNA(valid_responses$semantic_correct),
  all(valid_responses$semantic_correct %in% c(0L, 1L))
)

model_key <- consensus |>
  distinct(model_slot, provider, requested_model_id) |>
  arrange(model_slot)

stopifnot(nrow(model_key) == 8)

# Freeze the factor-level inventory exactly as recorded in the Test metadata.
item_composition <- bind_rows(lapply(subgroup_variables, function(variable) {
  item_metadata |>
    transmute(
      subgroup = variable,
      level = as.character(.data[[variable]])
    ) |>
    count(subgroup, level, name = "items") |>
    arrange(level)
})) |>
  mutate(
    sparse_level_lt5_items = items < 5,
    single_item_level = items == 1
  )

stopifnot(
  all(
    item_composition |>
      group_by(subgroup) |>
      summarise(total_items = sum(items), .groups = "drop") |>
      pull(total_items) == 72
  )
)

cat("\n--- RQ2 frozen item composition ---\n")
print(item_composition, n = Inf, width = Inf)

bootstrap_seed <- 20260828
bootstrap_repetitions <- 10000L
set.seed(bootstrap_seed)

pooled_summaries <- list()
bootstrap_records <- list()
model_summaries <- list()
summary_index <- 0L

for (variable in subgroup_variables) {
  subgroup_data <- valid_responses |>
    transmute(
      item_id,
      model_slot,
      level = as.character(.data[[variable]]),
      semantic_correct
    )

  subgroup_item_statistics <- subgroup_data |>
    group_by(level, item_id) |>
    summarise(
      correct_n = sum(semantic_correct),
      valid_n = n(),
      .groups = "drop"
    )

  variable_levels <- sort(unique(subgroup_item_statistics$level))

  for (current_level in variable_levels) {
    summary_index <- summary_index + 1L

    level_items <- subgroup_item_statistics |>
      filter(level == current_level) |>
      arrange(item_id)

    item_n <- nrow(level_items)
    valid_n <- sum(level_items$valid_n)
    correct_n <- sum(level_items$correct_n)
    accuracy <- correct_n / valid_n

    bootstrap_indices <- matrix(
      sample.int(
        item_n,
        size = item_n * bootstrap_repetitions,
        replace = TRUE
      ),
      nrow = item_n,
      ncol = bootstrap_repetitions
    )

    sampled_correct <- matrix(
      level_items$correct_n[bootstrap_indices],
      nrow = item_n,
      ncol = bootstrap_repetitions
    )
    sampled_valid <- matrix(
      level_items$valid_n[bootstrap_indices],
      nrow = item_n,
      ncol = bootstrap_repetitions
    )

    bootstrap_accuracy <-
      colSums(sampled_correct) / colSums(sampled_valid)

    bootstrap_ci <- quantile(
      bootstrap_accuracy,
      probs = c(0.025, 0.975),
      names = FALSE,
      type = 7
    )

    bootstrap_degenerate <-
      length(unique(bootstrap_accuracy)) == 1L

    pooled_summaries[[summary_index]] <- tibble(
      subgroup = variable,
      level = current_level,
      items = item_n,
      valid_responses = valid_n,
      semantic_correct = correct_n,
      semantic_accuracy = accuracy,
      bootstrap_ci_low = bootstrap_ci[1],
      bootstrap_ci_high = bootstrap_ci[2],
      sparse_level_lt5_items = item_n < 5,
      single_item_level = item_n == 1L,
      bootstrap_degenerate = bootstrap_degenerate
    )

    bootstrap_records[[summary_index]] <- tibble(
      subgroup = variable,
      level = current_level,
      iteration = seq_len(bootstrap_repetitions),
      semantic_accuracy = bootstrap_accuracy
    )
  }

  model_level_summary <- subgroup_data |>
    group_by(model_slot, level) |>
    summarise(
      items = n_distinct(item_id),
      valid_responses = n(),
      semantic_correct = sum(semantic_correct),
      semantic_accuracy = semantic_correct / valid_responses,
      .groups = "drop"
    ) |>
    left_join(model_key, by = "model_slot")

  model_level_ci <- binom.confint(
    x = model_level_summary$semantic_correct,
    n = model_level_summary$valid_responses,
    methods = "wilson"
  )

  model_summaries[[variable]] <- model_level_summary |>
    mutate(
      subgroup = variable,
      wilson_ci_low = model_level_ci$lower,
      wilson_ci_high = model_level_ci$upper,
      sparse_cell_lt5_items = items < 5,
      single_item_cell = items == 1L
    ) |>
    select(
      subgroup,
      level,
      model_slot,
      provider,
      requested_model_id,
      items,
      valid_responses,
      semantic_correct,
      semantic_accuracy,
      wilson_ci_low,
      wilson_ci_high,
      sparse_cell_lt5_items,
      single_item_cell
    )
}

pooled_subgroup_performance <- bind_rows(pooled_summaries) |>
  arrange(match(subgroup, subgroup_variables), level)

subgroup_bootstrap <- bind_rows(bootstrap_records)

model_by_subgroup_performance <- bind_rows(model_summaries) |>
  arrange(match(subgroup, subgroup_variables), level, model_slot)

stopifnot(
  nrow(pooled_subgroup_performance) == nrow(item_composition),
  all(
    pooled_subgroup_performance$semantic_accuracy >=
      pooled_subgroup_performance$bootstrap_ci_low
  ),
  all(
    pooled_subgroup_performance$semantic_accuracy <=
      pooled_subgroup_performance$bootstrap_ci_high
  ),
  nrow(subgroup_bootstrap) ==
    nrow(pooled_subgroup_performance) * bootstrap_repetitions
)

cat("\n--- RQ2 pooled descriptive subgroup performance ---\n")
print(pooled_subgroup_performance, n = Inf, width = Inf)

cat("\n--- RQ2 sparse subgroup levels requiring caution ---\n")
sparse_levels <- pooled_subgroup_performance |>
  filter(sparse_level_lt5_items | bootstrap_degenerate)

if (nrow(sparse_levels) == 0) {
  cat("None\n")
} else {
  print(
    sparse_levels |>
      select(
        subgroup,
        level,
        items,
        semantic_accuracy,
        bootstrap_ci_low,
        bootstrap_ci_high,
        bootstrap_degenerate
      ),
    n = Inf,
    width = Inf
  )
}

output_dir <- "student_outputs"
dir.create(output_dir, showWarnings = FALSE)

write_csv(
  item_composition,
  file.path(output_dir, "08_RQ2_item_composition.csv")
)
write_csv(
  pooled_subgroup_performance,
  file.path(output_dir, "08_RQ2_pooled_subgroup_performance.csv")
)
write_csv(
  model_by_subgroup_performance,
  file.path(output_dir, "08_RQ2_model_by_subgroup_performance.csv")
)
write_csv(
  subgroup_bootstrap,
  file.path(output_dir, "08_RQ2_subgroup_bootstrap_distribution.csv.gz")
)

rq2_metadata <- list(
  status = "secondary_descriptive",
  inferential_exception = "Lexical cue inference is reported only under H2",
  subgroup_variables = subgroup_variables,
  frozen_levels_preserved = TRUE,
  pooled_interval = "Item-cluster percentile bootstrap 95% CI",
  model_by_subgroup_interval = "Wilson 95% CI; descriptive only",
  bootstrap_repetitions = bootstrap_repetitions,
  bootstrap_seed = bootstrap_seed,
  sparse_level_rule = "Fewer than five Test items",
  multiplicity_tests_added = 0
)

write_json(
  rq2_metadata,
  file.path(output_dir, "08_RQ2_subgroup_analysis_metadata.json"),
  pretty = TRUE,
  auto_unbox = TRUE
)

cat("\nLesson 8 completed.\n")
cat("Subgroup variables:", length(subgroup_variables), "\n")
cat("Frozen subgroup levels:", nrow(pooled_subgroup_performance), "\n")
cat("Sparse levels (<5 items):", sum(pooled_subgroup_performance$sparse_level_lt5_items), "\n")
cat("Degenerate bootstrap levels:", sum(pooled_subgroup_performance$bootstrap_degenerate), "\n")
cat("Additional inferential p-values created: 0\n")
cat("Interpret sparse and single-item levels descriptively only.\n")
