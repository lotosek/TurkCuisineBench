# Post-analysis interpretation amendment

Date: 17 September 2026. Scope: manuscript reporting; no scoring or model rerun.
This amendment follows inspection of completed results and is not prospective
registration. Frozen protocols, labels, accepted answers, executed scripts,
original exports, and both Holm families remain unchanged.

## H3

Exact correctness is nested within semantic correctness by construction. Of 574
valid responses, 187 are correct under both methods, 43 only after semantic
resolution, 344 under neither, and none only under exact matching. The planned
stacked GLMM produced a random-effect SD of 85.635 and an extreme conditional
odds ratio. Absence of a convergence warning and `isSingular = FALSE` do not
establish a regular likelihood approximation under this extreme scale.

The original LRT and three-member Holm-adjusted p-value remain as prespecified
numerical output, but the revised manuscript withholds an unqualified confirmatory
H3 decision. Interpretation emphasizes recovery of 43/574 (7.49 percentage points),
with item-cluster bootstrap 95% interval [4.36, 11.19] and explicitly post-hoc
source-cluster interval [3.92, 11.53]. Nonnegative recovery is structurally
guaranteed; its magnitude and types are the substantive findings. These intervals
do not establish a prespecified practical-importance threshold. The post-hoc
source-cluster model does not retroactively validate the original GLMM.

`13_table2_confirmatory_H1_H3.csv` is retained byte-for-byte as historical output.
Use `submission_interpretation_v1.1.csv` for revised reporting status. H1/H2
p-values and the 28-pair family are not recomputed or selectively reduced.
No new confirmatory tests are introduced.

## H2 and source dependence

The H2 probability contrast averages model levels equally on the logit scale
before back-transformation at a zero item random effect. It is not an arithmetic
mean of model probabilities or an integral over item effects. The source-clustered
H1 global sensitivity does not validate the 19 item-paired significant comparisons
individually. Wilson intervals are descriptive item-level intervals, not
source-cluster-adjusted intervals.

## Content and supplementary reporting

Existing recovery labels comprise 20 semantic paraphrases, 14 harmless modifiers,
8 word-order variants and 1 more-specific correct answer. These are not recoded
and do not establish a specifically morphological cause of recovery. The revised
supplement adds already-public Dev examples and existing model-level error
summaries. No active Test content or private human records are released.

Technical references: [lme4](https://lme4.github.io/lme4/reference/isSingular.html)
and [emmeans](https://rvlenth.github.io/emmeans/articles/transformations.html).
