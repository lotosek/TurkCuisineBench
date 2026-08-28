# Main-study model cost envelope v0.1

Status: **prices verified; conservative ceiling registered; exact panel access still pending**

Verified: 2026-08-28

## Price record

| Slot | Exact requested model ID | Current USD per 1M input/output tokens | Conservative ceiling rate used |
|---|---|---:|---:|
| S01 | `gpt-5.5-2026-04-23` | 5.00 / 30.00 | 5.00 / 30.00 |
| S02 | `gpt-5.4-mini-2026-03-17` | 0.75 / 4.50 | 0.75 / 4.50 |
| S03 | `claude-sonnet-5` | 2.00 / 10.00 promotional rate through 2026-08-31 | 3.00 / 15.00 post-promotion rate |
| S04 | `claude-haiku-4-5-20251001` | 1.00 / 5.00 | 1.00 / 5.00 |
| S05 | `gemini-3.6-flash` | 0.75 / 3.75 promotional rate through 2026-12-31 | 1.50 / 7.50 post-promotion rate |
| S06 | `gemini-3.5-flash-lite` | 0.30 / 2.50 | 0.30 / 2.50 |
| S07 | `openai/gpt-oss-120b` | 0.15 / 0.60 | 0.15 / 0.60 |
| S08 | `qwen/qwen3.6-27b` | 0.60 / 3.00 | 0.60 / 3.00 |

Official price and model-ID sources: [OpenAI GPT-5.5](https://developers.openai.com/api/docs/models/gpt-5.5), [OpenAI GPT-5.4 Mini](https://developers.openai.com/api/docs/models/gpt-5.4-mini), [Anthropic model overview](https://platform.claude.com/docs/en/about-claude/models/overview), [Gemini pricing](https://ai.google.dev/gemini-api/docs/pricing), and [Groq supported models](https://console.groq.com/docs/models).

## Ceiling assumptions

- 72 items for each of eight model slots;
- no more than three total attempts per item, representing the initial attempt plus the two permitted technical-only retries;
- 512 input tokens per attempt, intentionally above the expected short prompt;
- the full 128-token output ceiling consumed on every attempt;
- higher post-promotion prices used for Claude Sonnet 5 and Gemini 3.6 Flash;
- an additional 50% contingency after the already conservative token and retry assumptions;
- standard synchronous list prices; no free-tier, cache, batch, flex, or volume discount is assumed.

Under current promotional prices, the all-attempt maximum is USD 2.807654. Under the conservative ceiling rates it is USD 3.243110; applying the 50% contingency yields USD 4.864666. The registered run ceiling is therefore **USD 5.00**. This is a budget stop rule, not an expected charge: actual cost should be materially lower because answers are short and technical retries are exceptional.

The calculation is reproducible with:

```text
python evaluation/estimate_main_study_cost.py --cost-config configs/main_study_costs_2026-08-28.json
```

Prices must be checked again immediately before execution. Any increase that would exceed USD 5, or any access-driven model replacement, requires a dated protocol amendment before Test calls.
