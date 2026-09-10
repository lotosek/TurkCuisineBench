# TurkCuisineBench — public-safe import and integrity checks
#
# The row-level consensus file is deliberately not distributed while Test-v1
# remains active. Point TCB_CONSENSUS_PATH to an authorized local copy. The
# optional TCB_CONSENSUS_SHA256 variable lets an authorized reviewer verify a
# privately supplied checksum without publishing that checksum in Git.

library(readr)
library(dplyr)

input_path <- Sys.getenv("TCB_CONSENSUS_PATH", unset = "")
expected_sha256 <- toupper(Sys.getenv("TCB_CONSENSUS_SHA256", unset = ""))

if (!nzchar(input_path)) {
  stop(
    "TCB_CONSENSUS_PATH is not set. Point it to an authorized local copy of ",
    "the locked final-consensus CSV; do not copy that file into this repository."
  )
}

if (!file.exists(input_path)) {
  stop("Consensus CSV was not found at: ", normalizePath(input_path, mustWork = FALSE))
}

if (nzchar(expected_sha256)) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Package 'digest' is required when TCB_CONSENSUS_SHA256 is supplied.")
  }
  observed_sha256 <- toupper(digest::digest(file = input_path, algo = "sha256"))
  stopifnot(identical(observed_sha256, expected_sha256))
  checksum_status <- "PASS"
} else {
  checksum_status <- "NOT_RUN_PUBLIC_WRAPPER"
  warning(
    "No private checksum was supplied. Structural QC will run, but the input ",
    "identity check is skipped."
  )
}

consensus <- read_csv(
  input_path,
  na = "",
  show_col_types = FALSE,
  locale = locale(encoding = "UTF-8")
)

required_columns <- c(
  "response_id", "model_slot", "provider", "requested_model_id", "item_id",
  "knowledge_domain", "knowledge_specificity", "lexical_leakage", "answer_form",
  "numeric_answer", "technical_valid", "automatic_label", "final_decision",
  "error_operation", "semantic_target", "exact_correct", "explicit_abstention",
  "correct_but_non_exact", "semantic_correct"
)

missing_columns <- setdiff(required_columns, names(consensus))
if (length(missing_columns) > 0) {
  stop("Required columns are missing: ", paste(missing_columns, collapse = ", "))
}

model_balance <- consensus |>
  count(model_slot, name = "responses_per_model") |>
  arrange(model_slot)

item_balance <- consensus |>
  count(item_id, name = "responses_per_item") |>
  arrange(item_id)

stopifnot(
  nrow(consensus) == 576,
  n_distinct(consensus$response_id) == 576,
  n_distinct(consensus$model_slot) == 8,
  n_distinct(consensus$item_id) == 72,
  all(model_balance$responses_per_model == 72),
  all(item_balance$responses_per_item == 8),
  sum(consensus$technical_valid %in% TRUE) == 574,
  sum(consensus$technical_valid %in% FALSE) == 2,
  sum(consensus$automatic_label == "CO") == 187,
  sum(consensus$automatic_label == "NA") == 61,
  sum(consensus$automatic_label == "REVIEW") == 326,
  sum(consensus$automatic_label == "TECHNICAL_INVALID") == 2,
  sum(consensus$final_decision == "CO") == 230,
  sum(consensus$final_decision == "IN") == 283,
  sum(consensus$final_decision == "NA") == 61,
  sum(consensus$final_decision == "TECHNICAL_INVALID") == 2,
  nrow(filter(consensus, exact_correct %in% TRUE, !(semantic_correct %in% TRUE))) == 0,
  nrow(filter(consensus, technical_valid %in% FALSE, !is.na(semantic_correct))) == 0
)

dir.create("student_outputs", showWarnings = FALSE)
write_csv(
  tibble(
    check = c(
      "Authorized input checksum", "Expected rows", "Unique response IDs",
      "Eight balanced model slots", "Seventy-two balanced Test items",
      "Technical-validity counts", "Automatic-routing counts",
      "Final-decision counts", "Exact correctness subset rule",
      "Technical-invalid denominator rule"
    ),
    status = c(checksum_status, rep("PASS", 9))
  ),
  file.path("student_outputs", "01_qc_summary.csv")
)

message("Public-safe import and structural QC completed.")
