# Main-study M5 execution report v1.0

Status: **M5 complete; technical reconciliation passed before correctness scoring**

Execution date: 2026-08-31  
Collection window: 07:48:50–08:27:10 UTC

## Scope

The frozen 72-item private Test was executed once against each of the eight prespecified model slots. Requests were stateless, closed-book, tool-free, and interleaved under the frozen schedule. Raw answers, Test content, request identifiers, private checksums, and model-to-review mappings remain outside Git.

## Reconciliation

| Check | Result |
|---|---:|
| Expected model–item records | 576 |
| Observed unique records | 576 |
| Records per model slot | 72 |
| Endpoint-success records | 576 |
| Technically valid responses | 574 |
| Technically invalid responses | 2 |
| Terminal request errors | 0 |
| Requested/returned model-ID drift | 0 |
| First-attempt completions | 573 |
| Second-attempt completions after technical retry | 3 |

One S07 response terminated at the length limit without visible answer text, and one S06 response was blocked by the provider's content filter without visible answer text. Neither was retried because the protocol permits retries only for transport, rate-limit, or server failures. Each affected slot therefore had one invalid response out of 72 (1.4%), below the prespecified 5% slot-level stopping threshold.

All raw response records contain request-payload and raw-payload hashes. Google did not expose request IDs through the captured response-header fields; this affects S05–S06 request-ID completeness but not response capture, model-ID reconciliation, or payload integrity.

## Cost metadata

Provider-reported token totals for successful requests imply an estimated USD 0.128569 at the frozen current list prices. This is a descriptive estimate, not an invoice reconciliation, and it may omit negligible billing effects from failed technical attempts. It remains well below the registered USD 5 execution ceiling.

## Decision

Gate M5 passed before correctness scoring. Automatic exact-match/abstention routing and blinded manual-review preparation may proceed under the frozen scorer and overlap-selection procedure.
