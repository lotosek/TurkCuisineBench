# Historical development workbooks

These files document Dev validation and pilot preparation. They are not the
current main-study results, a final manuscript supplement, or private Test
review workbooks. De-identified Dev review/adjudication records must not be
confused with independently blinded Test response ratings.

- `Validation_and_Pilot_Workflow_v0.4` records the frozen Dev workflow.
- Earlier workflow and adjudicator workbooks preserve earlier Dev decisions.
- Pilot execution workbooks preserve preparation-stage configurations; the
  completed scientific pilot is documented in
  [pilot_run_v0.3](../docs/pilot_run_report_v0.3.md).
- Current public main-study supplementary material is
  [`ESM_1.xlsx`](../results/main_study/ESM_1.xlsx), not these workbooks.

## Known historical hyperlink-cache defect

The pilot execution workbooks v0.1, v0.2, and v0.3_configured each contain 36
cached error values for `HYPERLINK` formulas in `Dev_Items!Q4:Q39`. The stored
message identifies the generating engine's unsupported `HYPERLINK` function.
It is not evidence that the source URL is inaccessible or that a numerical
result is erroneous. Source URL text remains present. Do not treat a cached
preview error as a validation decision; use the source URLs in the frozen Dev
CSV or workbook. Native Excel recalculation was not reverified in this audit.

The originals are intentionally not overwritten: two of these workbooks have
recorded freeze hashes. The current frozen Dev workbook and `ESM_1.xlsx` have
no cached cell errors in the structural audit. No workbook formulas were
recomputed or human ratings changed by this documentation correction.

These historical workflow files are excluded from the scoped public reuse
grants in [LICENSES.md](../LICENSES.md). New identifiable or private reviewer
returns must remain outside Git, even if based on one of these templates.
