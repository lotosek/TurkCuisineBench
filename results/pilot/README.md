# Pilot results

The official methods-pilot run is `pilot_run_v0.3`. It contains 36 single-shot responses from each of two fixed model endpoints. All 72 requests were technically valid. All 46 non-exact responses subsequently received independent double coding, and five routed cases received third-review adjudication.

The earlier 256-token run is a private technical pre-run and is excluded from scientific results because it produced empty or truncated responses for one endpoint and did not preserve sufficient completion metadata. A separate single-item diagnostic request is also excluded. When the protocol defect was corrected, both models—not only the affected endpoint—were rerun in full under the same provider-neutral validity and retry rules.

The final aggregate consensus is 21 exact accepted-answer matches, 9 manually verified correct non-exact responses, 37 manually verified incorrect responses, and 5 explicit abstentions. This corresponds to 30/72 semantic accuracy (41.7%), 21/72 exact-match accuracy (29.2%), and a 5/72 abstention rate (6.9%). Pre-adjudication decision agreement was 93.5% (Cohen's κ = .801), while primary-operation agreement among jointly incorrect cases was 100% (κ = 1.000).

The pilot is a methods check rather than a leaderboard. No model-level consensus ranking is released from this pilot. Private raw logs retain provider request identifiers and detailed metadata; reviewer returns, row-level consensus records, and model-to-review mappings remain outside Git.
