# Public-safe dependency installer for the TurkCuisineBench main-study analysis.

packages <- c(
  "binom",
  "broom.mixed",
  "dplyr",
  "emmeans",
  "ggplot2",
  "jsonlite",
  "lme4",
  "readr",
  "scales",
  "tidyr"
)

missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]

if (length(missing) > 0) {
  install.packages(missing, repos = "https://cloud.r-project.org")
} else {
  message("All required R packages are already installed.")
}
