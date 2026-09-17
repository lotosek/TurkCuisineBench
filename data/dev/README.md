# Development files

The authoritative frozen development set is `TurkCuisineBench-Dev_v0.2_frozen`
in CSV and XLSX form. The three hashes in `SHA256SUMS_v0.2.txt` cover these two
representations and `pilot_requests_v0.2.jsonl`.

The v0.1 dataset and requests are retained as historical pre-adjudication
artifacts. They must not be substituted for v0.2 or pooled with it. Four
question formulations changed during validation, with no changes to gold or
accepted-answer sets. See the [validation report](../../docs/dev_validation_report_v0.2.md).

Fixed request files preserve their preparation-stage settings. For the completed
official methods pilot, use [pilot_run_v0.3](../../docs/pilot_run_report_v0.3.md),
the example pilot configuration, and the scorer rather than assuming that an
older request artifact describes the final generation ceiling.

These are Dev items, not the private 72-item Test. Dev material is not suitable
for headline Test rankings.
