# TurkCuisineBench — Lesson 7: gated H1 pairwise model comparisons
#
# Learning objectives:
#   1. Enforce the Holm-adjusted H1 global-test gate.
#   2. Compare every pair of eight models on common-valid items only.
#   3. Estimate paired accuracy differences and item-bootstrap intervals.
#   4. Apply two-sided exact McNemar tests and Holm correction to all 28 tests.
#
# IMPORTANT:
#   - Run Lesson 6 first.
#   - The 28 pairwise comparisons are a separate multiplicity family from H1-H3.
#   - Bootstrap confidence intervals are effect-size intervals and are not
#     multiplicity-adjusted. Family-wise inference uses the Holm-adjusted
#     McNemar p-values.

library(readr)
library(dplyr)
library(jsonlite)

output_dir <- "student_outputs"
gate_path <- file.path(output_dir, "06_confirmatory_H1_H3_holm_results.csv")

if (!file.exists(gate_path)) {
  stop("Lesson 6 output is missing. Run 06_H1_H3_holm_correction.R first.")
}

gate_results <- read_csv(gate_path, show_col_types = FALSE)

h1_gate <- gate_results |>
  filter(hypothesis == "H1") |>
  pull(holm_reject)

stopifnot(length(h1_gate) == 1, !is.na(h1_gate))

if (!h1_gate) {
  stop(
    "The Holm-adjusted H1 global-test gate is closed. ",
    "Pairwise model results must not be interpreted."
  )
}

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

model_key <- consensus |>
  distinct(model_slot, provider, requested_model_id) |>
  arrange(model_slot)

stopifnot(
  nrow(model_key) == 8,
  identical(model_key$model_slot, paste0("S0", 1:8))
)

pairwise_data <- consensus |>
  filter(technical_valid %in% TRUE) |>
  transmute(
    item_id,
    model_slot,
    semantic_correct = as.integer(semantic_correct)
  )

stopifnot(
  nrow(pairwise_data) == 574,
  !anyNA(pairwise_data$semantic_correct),
  all(pairwise_data$semantic_correct %in% c(0L, 1L)),
  !anyDuplicated(pairwise_data[c("item_id", "model_slot")])
)

model_combinations <- combn(model_key$model_slot, 2)
stopifnot(ncol(model_combinations) == 28)

bootstrap_seed <- 20260828
bootstrap_repetitions <- 10000L
set.seed(bootstrap_seed)

pair_summaries <- vector("list", ncol(model_combinations))
bootstrap_records <- vector("list", ncol(model_combinations))

for (pair_index in seq_len(ncol(model_combinations))) {
  model_a_slot <- model_combinations[1, pair_index]
  model_b_slot <- model_combinations[2, pair_index]
  pair_id <- sprintf("PW%02d", pair_index)

  model_a <- pairwise_data |>
    filter(model_slot == model_a_slot) |>
    select(item_id, correct_a = semantic_correct)

  model_b <- pairwise_data |>
    filter(model_slot == model_b_slot) |>
    select(item_id, correct_b = semantic_correct)

  # inner_join() implements the registered common-valid-item rule.
  paired <- inner_join(model_a, model_b, by = "item_id") |>
    arrange(item_id)

  common_valid_items <- nrow(paired)

  stopifnot(
    common_valid_items %in% c(70L, 71L, 72L),
    !anyDuplicated(paired$item_id)
  )

  accuracy_a <- mean(paired$correct_a)
  accuracy_b <- mean(paired$correct_b)
  accuracy_difference <- accuracy_a - accuracy_b

  both_correct <- sum(paired$correct_a == 1L & paired$correct_b == 1L)
  a_only_correct <- sum(paired$correct_a == 1L & paired$correct_b == 0L)
  b_only_correct <- sum(paired$correct_a == 0L & paired$correct_b == 1L)
  both_incorrect <- sum(paired$correct_a == 0L & paired$correct_b == 0L)
  discordant_n <- a_only_correct + b_only_correct

  stopifnot(
    both_correct + a_only_correct + b_only_correct + both_incorrect ==
      common_valid_items
  )

  # Two-sided exact McNemar test. Conditional on the discordant count, the
  # number favouring model A is Binomial(discordant_n, 0.5) under the null.
  mcnemar_raw_p <- if (discordant_n == 0L) {
    1
  } else {
    binom.test(
      x = a_only_correct,
      n = discordant_n,
      p = 0.5,
      alternative = "two.sided"
    )$p.value
  }

  matched_odds_ratio <- case_when(
    a_only_correct == 0L && b_only_correct == 0L ~ NA_real_,
    b_only_correct == 0L ~ Inf,
    TRUE ~ a_only_correct / b_only_correct
  )

  paired_delta <- paired$correct_a - paired$correct_b

  bootstrap_indices <- matrix(
    sample.int(
      common_valid_items,
      size = common_valid_items * bootstrap_repetitions,
      replace = TRUE
    ),
    nrow = common_valid_items,
    ncol = bootstrap_repetitions
  )

  bootstrap_differences <- colMeans(
    matrix(
      paired_delta[bootstrap_indices],
      nrow = common_valid_items,
      ncol = bootstrap_repetitions
    )
  )

  bootstrap_ci <- quantile(
    bootstrap_differences,
    probs = c(0.025, 0.975),
    names = FALSE,
    type = 7
  )

  model_a_id <- model_key$requested_model_id[
    model_key$model_slot == model_a_slot
  ]
  model_b_id <- model_key$requested_model_id[
    model_key$model_slot == model_b_slot
  ]

  pair_summaries[[pair_index]] <- tibble(
    pair_id = pair_id,
    model_a_slot = model_a_slot,
    model_a_id = model_a_id,
    model_b_slot = model_b_slot,
    model_b_id = model_b_id,
    common_valid_items = common_valid_items,
    correct_a = sum(paired$correct_a),
    correct_b = sum(paired$correct_b),
    accuracy_a = accuracy_a,
    accuracy_b = accuracy_b,
    accuracy_difference_a_minus_b = accuracy_difference,
    bootstrap_ci_low = bootstrap_ci[1],
    bootstrap_ci_high = bootstrap_ci[2],
    both_correct = both_correct,
    a_only_correct = a_only_correct,
    b_only_correct = b_only_correct,
    both_incorrect = both_incorrect,
    discordant_n = discordant_n,
    matched_odds_ratio_a_vs_b = matched_odds_ratio,
    mcnemar_method = "Two-sided exact conditional McNemar test",
    raw_p = mcnemar_raw_p
  )

  bootstrap_records[[pair_index]] <- tibble(
    pair_id = pair_id,
    iteration = seq_len(bootstrap_repetitions),
    accuracy_difference_a_minus_b = bootstrap_differences
  )
}

pairwise_results <- bind_rows(pair_summaries) |>
  mutate(
    comparison_family = "H1 pairwise model comparisons",
    family_size = n(),
    adjustment = "Holm",
    alpha = 0.05,
    holm_p = p.adjust(raw_p, method = "holm"),
    holm_reject = holm_p < alpha,
    higher_accuracy_model = case_when(
      accuracy_difference_a_minus_b > 0 ~ model_a_id,
      accuracy_difference_a_minus_b < 0 ~ model_b_id,
      TRUE ~ "TIE"
    ),
    bootstrap_ci_multiplicity_adjusted = FALSE
  )

pairwise_bootstrap <- bind_rows(bootstrap_records)

stopifnot(
  nrow(pairwise_results) == 28,
  all(pairwise_results$family_size == 28),
  all(pairwise_results$holm_p >= pairwise_results$raw_p),
  nrow(pairwise_bootstrap) == 28 * bootstrap_repetitions
)

display_results <- pairwise_results |>
  arrange(holm_p, desc(abs(accuracy_difference_a_minus_b))) |>
  transmute(
    pair_id,
    model_a_id,
    model_b_id,
    common_valid_items,
    difference = accuracy_difference_a_minus_b,
    ci_low = bootstrap_ci_low,
    ci_high = bootstrap_ci_high,
    raw_p,
    holm_p,
    holm_reject
  )

significant_results <- display_results |>
  filter(holm_reject)

cat("\n--- H1 pairwise family summary ---\n")
cat("Comparisons:", nrow(pairwise_results), "\n")
cat("Two-sided exact McNemar tests:", nrow(pairwise_results), "\n")
cat("Holm-significant comparisons:", nrow(significant_results), "\n")
cat("Common-valid item range:",
    min(pairwise_results$common_valid_items), "to",
    max(pairwise_results$common_valid_items), "\n")

cat("\n--- Holm-significant pairwise comparisons ---\n")
if (nrow(significant_results) == 0) {
  cat("None\n")
} else {
  print(significant_results, n = Inf, width = Inf)
}

cat("\n--- All 28 pairwise comparisons, ordered by Holm p ---\n")
print(display_results, n = Inf, width = Inf)

write_csv(
  pairwise_results,
  file.path(output_dir, "07_H1_pairwise_model_results.csv")
)
write_csv(
  model_key,
  file.path(output_dir, "07_model_key.csv")
)
write_csv(
  pairwise_bootstrap,
  file.path(output_dir, "07_H1_pairwise_bootstrap_distribution.csv.gz")
)

pairwise_metadata <- list(
  gate = "Holm-adjusted H1 global test",
  gate_open = h1_gate,
  comparison_family_size = 28,
  test = "Two-sided exact conditional McNemar test",
  p_adjustment = "Holm",
  alpha = 0.05,
  denominator = "Common technically valid items for each model pair",
  effect = "Paired semantic-accuracy difference, model A minus model B",
  confidence_interval = "Paired item-cluster percentile bootstrap 95% CI",
  confidence_intervals_multiplicity_adjusted = FALSE,
  bootstrap_repetitions = bootstrap_repetitions,
  bootstrap_seed = bootstrap_seed
)

write_json(
  pairwise_metadata,
  file.path(output_dir, "07_H1_pairwise_analysis_metadata.json"),
  pretty = TRUE,
  auto_unbox = TRUE
)

cat("\nLesson 7 completed.\n")
cat("H1 pairwise gate was open:", h1_gate, "\n")
cat("Pairwise comparisons tested:", nrow(pairwise_results), "\n")
cat("Holm-significant comparisons:", nrow(significant_results), "\n")
cat("Use the sign of A-minus-B to identify the higher-performing model.\n")
cat("Bootstrap confidence intervals are not multiplicity-adjusted.\n")
