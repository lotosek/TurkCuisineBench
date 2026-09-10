# TurkCuisineBench — Lesson 2: Model-level descriptive performance
#
# Learning objectives:
#   1. Distinguish the expected-response and technically valid populations.
#   2. Calculate semantic accuracy with the preregistered primary denominator.
#   3. Calculate the technical-invalid-as-incorrect sensitivity estimate.
#   4. Calculate exact accuracy, abstention, and non-exact recovery.
#   5. Add Wilson 95% confidence intervals and create a descriptive figure.
#
# This lesson does NOT test whether models differ significantly.
# Overlapping or non-overlapping confidence intervals are not a substitute for
# the preregistered paired inferential tests.

library(readr)
library(dplyr)
library(binom)
library(ggplot2)

# Lesson 1 should already have created the object `consensus`.
# The following block makes Lesson 2 independently reproducible if RStudio was
# restarted after Lesson 1.
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

# Primary denominator:
#   technically valid responses for the relevant model.
# Sensitivity denominator:
#   all 72 expected responses, with technical invalidity counted as incorrect.
model_counts <- consensus |>
  group_by(model_slot, provider, requested_model_id) |>
  summarise(
    expected_n = n(),
    valid_n = sum(technical_valid %in% TRUE),
    invalid_n = sum(technical_valid %in% FALSE),
    semantic_correct_n = sum(semantic_correct %in% TRUE),
    exact_correct_n = sum(exact_correct %in% TRUE),
    explicit_abstention_n = sum(explicit_abstention %in% TRUE),
    manual_review_n = sum(manual_review %in% TRUE),
    correct_non_exact_n = sum(correct_but_non_exact %in% TRUE),
    .groups = "drop"
  ) |>
  arrange(model_slot)

cat("\n--- Raw model-level counts ---\n")
print(model_counts)

# Scientific meaning of the main measures:
#
# semantic_accuracy:
#   final human-consensus correctness among technically valid responses.
#
# expected_population_accuracy:
#   sensitivity estimate that counts a technical invalid response as incorrect.
#
# exact_accuracy:
#   correctness detected by the frozen exact-answer matcher alone.
#
# abstention_rate:
#   explicit BİLMİYORUM-type responses among technically valid responses.
#
# non_exact_recovery_rate:
#   manually verified correct answers divided by responses routed to manual
#   review. This describes what exact matching would otherwise miss.
model_performance <- model_counts |>
  mutate(
    semantic_accuracy = semantic_correct_n / valid_n,
    expected_population_accuracy = semantic_correct_n / expected_n,
    exact_accuracy = exact_correct_n / valid_n,
    abstention_rate = explicit_abstention_n / valid_n,
    non_exact_recovery_rate = correct_non_exact_n / manual_review_n
  )

# Wilson intervals are preferred over the simple Wald interval for binomial
# proportions because they behave better near 0 or 1 and with modest n.
semantic_ci <- binom.confint(
  x = model_performance$semantic_correct_n,
  n = model_performance$valid_n,
  methods = "wilson"
)

exact_ci <- binom.confint(
  x = model_performance$exact_correct_n,
  n = model_performance$valid_n,
  methods = "wilson"
)

model_performance <- model_performance |>
  mutate(
    semantic_ci_low = semantic_ci$lower,
    semantic_ci_high = semantic_ci$upper,
    exact_ci_low = exact_ci$lower,
    exact_ci_high = exact_ci$upper
  ) |>
  arrange(desc(semantic_accuracy))

cat("\n--- Model-level descriptive performance ---\n")
print(
  model_performance |>
    select(
      model_slot,
      requested_model_id,
      valid_n,
      semantic_correct_n,
      semantic_accuracy,
      semantic_ci_low,
      semantic_ci_high,
      expected_population_accuracy,
      exact_accuracy,
      abstention_rate,
      non_exact_recovery_rate
    )
)

# Reconcile totals before saving.
stopifnot(
  nrow(model_performance) == 8,
  all(model_performance$expected_n == 72),
  sum(model_performance$expected_n) == 576,
  sum(model_performance$valid_n) == 574,
  sum(model_performance$invalid_n) == 2,
  sum(model_performance$semantic_correct_n) == 230,
  sum(model_performance$exact_correct_n) == 187,
  sum(model_performance$explicit_abstention_n) == 61,
  all(model_performance$semantic_ci_low <= model_performance$semantic_accuracy),
  all(model_performance$semantic_ci_high >= model_performance$semantic_accuracy)
)

dir.create("student_outputs", showWarnings = FALSE)

write_csv(
  model_performance,
  file.path("student_outputs", "02_model_descriptive_performance.csv")
)

# Descriptive figure with Wilson 95% confidence intervals.
performance_figure <- ggplot(
  model_performance,
  aes(
    x = reorder(requested_model_id, semantic_accuracy),
    y = semantic_accuracy
  )
) +
  geom_errorbar(
    aes(ymin = semantic_ci_low, ymax = semantic_ci_high),
    width = 0.16,
    colour = "#6B7280"
  ) +
  geom_point(size = 2.8, colour = "#0F766E") +
  coord_flip() +
  scale_y_continuous(
    labels = scales::label_percent(accuracy = 1),
    limits = c(0, 1)
  ) +
  labs(
    title = "TurkCuisineBench main-study semantic accuracy",
    subtitle = "Points are model estimates; bars are Wilson 95% confidence intervals",
    x = NULL,
    y = "Semantic accuracy"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.major.y = element_blank(),
    plot.title.position = "plot"
  )

ggsave(
  filename = file.path("student_outputs", "02_model_semantic_accuracy.png"),
  plot = performance_figure,
  width = 8.5,
  height = 5.5,
  dpi = 300
)

cat("\nLesson 2 completed successfully.\n")
cat("Saved: student_outputs/02_model_descriptive_performance.csv\n")
cat("Saved: student_outputs/02_model_semantic_accuracy.png\n")
cat("No model-difference significance test was performed.\n")

