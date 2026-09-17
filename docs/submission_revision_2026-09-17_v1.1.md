# Submission revision 1.1

Date: 17 September 2026. This is a reporting and packaging revision, not a new
data freeze, model run, or prospective statistical registration.

## Decisions and reasons

- Retain the original numerical exports and both Holm families. A dated
  [interpretation amendment](interpretation_amendment_2026-09-17.md) withholds an
  unqualified H3 confirmatory decision because convergence alone does not
  resolve the extreme conditional scale and structural nesting. Report the
  magnitude and types of paired recovery instead of asserting a validated LRT.
- Define the H2 estimand exactly as implemented: equal-weight model-level
  estimated marginal means on the logit scale, then back-transformation at a
  zero item random effect. No post-result change of estimand is made.
- Separate the source-clustered global sensitivity analysis from the 28
  item-paired comparisons. Descriptive Wilson intervals do not incorporate
  shared-source dependence.
- Consolidate the public supplement as `results/main_study/ESM_1.xlsx`.
  Preserve S1–S5 and S4b; add four existing public Dev examples as S6,
  model-specific operation and target counts as S7–S8, and frozen recovery
  variant counts as S9. This answers the model-specific part of RQ4 without
  additional inferential tests or disclosure of Test items.
- Redraw Figure 1 from unchanged aggregate estimates at 1200 dpi, rather than
  increasing only the resolution metadata of the old raster image.
- Correct bibliographic metadata and avoid attributing all recovered answers
  to Turkish morphology. The design does not estimate a between-language effect.
- Adopt MIT for covered original public code and CC BY 4.0 for covered original
  public research material to enable attribution-based reuse. This author-
  authorized decision supersedes the earlier rights-reserved policy for those
  components only. [LICENSES.md](../LICENSES.md) defines the boundary; active Test,
  confidential human records, manuscript drafts, and third-party works are not
  covered by the grants. No universal licensing practice is claimed.
- Document feasible [controlled-access criteria](controlled_access.md) without
  inventing a guaranteed response time or future Test release date.

The immutable numerical export `13_table2_confirmatory_H1_H3.csv` and historical
`public_analysis_manifest_v1.0.json` are not the current reporting decision.
Use `submission_reporting_manifest_v1.1.json` and
`submission_interpretation_v1.1.csv` in `results/main_study/` together with the
amendment. Historical supplementary files should not be uploaded alongside
the revised `ESM_1.xlsx`.

No journal submission or public release of the confidential editorial package
is performed by this revision. A cover letter with current author-profile
evidence and the submission-interface declarations still require author review.

## External guidance consulted

- [LRE submission guidelines](https://link.springer.com/journal/10579/submission-guidelines)
- [MIT license](https://opensource.org/license/mit)
- [CC BY 4.0 terms](https://creativecommons.org/licenses/by/4.0/)
- [Creative Commons licensing considerations](https://creativecommons.org/cc-license-your-work/)
- [lme4 singularity diagnostics](https://lme4.github.io/lme4/reference/isSingular.html)
- [emmeans transformations](https://rvlenth.github.io/emmeans/articles/transformations.html)
