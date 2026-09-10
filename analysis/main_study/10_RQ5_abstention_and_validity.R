# TurkCuisineBench — Lesson 10: RQ5 abstention and technical validity
#
# Learning objectives:
#   1. Keep explicit abstention separate from technical invalidity.
#   2. Use technically valid responses as the abstention denominator.
#   3. Use expected responses as the technical-validity denominator.
#   4. Report counts, rates, and Wilson intervals without adding post-hoc tests.
#
# Interpretation:
#   - An explicit abstention is a valid model response and is semantically
#     incorrect for the primary accuracy outcome.
#   - A technical invalid is excluded from the primary semantic denominator and
#     is summarized against all expected responses.

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

stopifnot(
  nrow(consensus) == 576,
  n_distinct(consensus$model_slot) == 8,
  sum(consensus$technical_valid %in% TRUE) == 574,
  sum(consensus$technical_valid %in% FALSE) == 2,
  sum(consensus$explicit_abstention %in% TRUE) == 61,
  all(
    consensus$final_decision[consensus$explicit_abstention %in% TRUE] == "NA"
  ),
  all(
    consensus$explicit_abstention[consensus$final_decision == "NA"] %in% TRUE
  )
)

model_outcomes <- consensus |>
  group_by(model_slot, provider, requested_model_id) |>
  summarise(
    expected_responses = n(),
    technically_valid_responses = sum(technical_valid %in% TRUE),
    technically_invalid_responses = sum(technical_valid %in% FALSE),
    explicit_abstentions = sum(explicit_abstention %in% TRUE),
    .groups = "drop"
  ) |>
  arrange(model_slot)

overall_outcomes <- consensus |>
  summarise(
    expected_responses = n(),
    technically_valid_responses = sum(technical_valid %in% TRUE),
    technically_invalid_responses = sum(technical_valid %in% FALSE),
    explicit_abstentions = sum(explicit_abstention %in% TRUE)
  ) |>
  mutate(
    model_slot = "ALL",
    provider = "ALL_PROVIDERS",
    requested_model_id = "ALL_MODELS"
  ) |>
  select(
    model_slot,
    provider,
    requested_model_id,
    everything()
  )

rq5_results <- bind_rows(model_outcomes, overall_outcomes) |>
  mutate(
    abstention_rate_among_valid =
      explicit_abstentions / technically_valid_responses,
    technical_invalid_rate_among_expected =
      technically_invalid_responses / expected_responses,
    technical_validity_rate_among_expected =
      technically_valid_responses / expected_responses
  )

abstention_ci <- binom.confint(
  x = rq5_results$explicit_abstentions,
  n = rq5_results$technically_valid_responses,
  methods = "wilson"
)

technical_invalid_ci <- binom.confint(
  x = rq5_results$technically_invalid_responses,
  n = rq5_results$expected_responses,
  methods = "wilson"
)

technical_validity_ci <- binom.confint(
  x = rq5_results$technically_valid_responses,
  n = rq5_results$expected_responses,
  methods = "wilson"
)

rq5_results <- rq5_results |>
  mutate(
    abstention_wilson_ci_low = abstention_ci$lower,
    abstention_wilson_ci_high = abstention_ci$upper,
    technical_invalid_wilson_ci_low = technical_invalid_ci$lower,
    technical_invalid_wilson_ci_high = technical_invalid_ci$upper,
    technical_validity_wilson_ci_low = technical_validity_ci$lower,
    technical_validity_wilson_ci_high = technical_validity_ci$upper,
    inference_status = "SECONDARY_DESCRIPTIVE"
  )

stopifnot(
  nrow(model_outcomes) == 8,
  all(model_outcomes$expected_responses == 72),
  sum(model_outcomes$expected_responses) == 576,
  sum(model_outcomes$technically_valid_responses) == 574,
  sum(model_outcomes$technically_invalid_responses) == 2,
  sum(model_outcomes$explicit_abstentions) == 61,
  all(
    rq5_results$abstention_rate_among_valid >=
      rq5_results$abstention_wilson_ci_low
  ),
  all(
    rq5_results$abstention_rate_among_valid <=
      rq5_results$abstention_wilson_ci_high
  )
)

technical_invalid_reasons <- consensus |>
  filter(technical_valid %in% FALSE) |>
  count(
    model_slot,
    provider,
    requested_model_id,
    finish_reason,
    name = "technical_invalid_responses"
  ) |>
  arrange(model_slot, finish_reason)

stopifnot(sum(technical_invalid_reasons$technical_invalid_responses) == 2)

cat("\n--- RQ5 model-level abstention and validity profile ---\n")
print(
  rq5_results |>
    filter(model_slot != "ALL") |>
    select(
      model_slot,
      requested_model_id,
      expected_responses,
      technically_valid_responses,
      technically_invalid_responses,
      explicit_abstentions,
      abstention_rate_among_valid,
      abstention_wilson_ci_low,
      abstention_wilson_ci_high,
      technical_invalid_rate_among_expected
    ),
  n = Inf,
  width = Inf
)

cat("\n--- RQ5 overall profile ---\n")
print(
  rq5_results |>
    filter(model_slot == "ALL"),
  n = Inf,
  width = Inf
)

cat("\n--- RQ5 technical-invalid reasons ---\n")
print(technical_invalid_reasons, n = Inf, width = Inf)

output_dir <- "student_outputs"
dir.create(output_dir, showWarnings = FALSE)

write_csv(
  rq5_results,
  file.path(output_dir, "10_RQ5_abstention_and_validity_profiles.csv")
)
write_csv(
  technical_invalid_reasons,
  file.path(output_dir, "10_RQ5_technical_invalid_reasons.csv")
)

rq5_metadata <- list(
  status = "secondary_descriptive",
  abstention_denominator = "Technically valid responses",
  technical_validity_denominator = "Expected responses",
  abstention_scoring = "Semantically incorrect but not an error-operation case",
  technical_invalid_scoring =
    "Excluded from primary semantic accuracy; included as incorrect only in sensitivity estimate",
  confidence_interval = "Wilson 95% CI",
  additional_inferential_p_values = 0
)

write_json(
  rq5_metadata,
  file.path(output_dir, "10_RQ5_abstention_and_validity_metadata.json"),
  pretty = TRUE,
  auto_unbox = TRUE
)

cat("\nLesson 10 completed.\n")
cat("Expected responses:", nrow(consensus), "\n")
cat("Technically valid responses:", sum(consensus$technical_valid %in% TRUE), "\n")
cat("Technically invalid responses:", sum(consensus$technical_valid %in% FALSE), "\n")
cat("Explicit abstentions:", sum(consensus$explicit_abstention %in% TRUE), "\n")
cat("Additional inferential p-values created: 0\n")
cat("Do not merge abstentions with technical-invalid responses.\n")
