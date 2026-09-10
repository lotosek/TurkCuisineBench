# Reproduce the public-safe TurkCuisineBench main-study analyses from an
# authorized local copy of the locked consensus CSV.

args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)

if (length(file_arg) != 1) {
  stop("Run this file with Rscript so its analysis directory can be resolved.")
}

runner_path <- normalizePath(sub("^--file=", "", file_arg), mustWork = TRUE)
analysis_dir <- dirname(runner_path)
old_dir <- getwd()
on.exit(setwd(old_dir), add = TRUE)
setwd(analysis_dir)

# Some Windows shells inject an unsupported C.UTF-8 locale. Reset only when R
# did not start in a UTF-8 locale so that Turkish labels remain readable.
if (!isTRUE(l10n_info()[["UTF-8"]])) {
  try(Sys.setlocale("LC_CTYPE", ""), silent = TRUE)
}

scripts <- c(
  "01_import_and_qc.R",
  "02_descriptive_model_performance.R",
  "03_H1_global_model_comparison.R",
  "04_H2_L0_L1_comparison.R",
  "05_H3_exact_vs_semantic.R",
  "06_H1_H3_holm_correction.R",
  "07_H1_pairwise_model_comparisons.R",
  "08_RQ2_subgroup_profiles.R",
  "09_RQ4_error_taxonomy_profiles.R",
  "10_RQ5_abstention_and_validity.R",
  "12_secondary_feasibility_and_sensitivity.R"
)

for (script in scripts) {
  message("Running ", script)
  source(script, local = .GlobalEnv, encoding = "UTF-8")
}

if (!dir.exists("student_outputs")) {
  stop("The analysis modules did not create student_outputs.")
}

message(
  "Public-safe main-study analysis completed. Outputs are in ",
  normalizePath("student_outputs", winslash = "/", mustWork = TRUE)
)
