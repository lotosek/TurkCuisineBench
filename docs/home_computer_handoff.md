# Continuing TurkCuisineBench on another computer

## Why the current task may not appear

The active research task is a local Codex task attached to a specific folder on the current computer. It is not the same object as an ordinary ChatGPT conversation. Signing in to the same OpenAI account provides account and subscription access on another device, but the local Codex task and its working directory may not appear there automatically.

The repository is therefore the durable cross-computer handoff record. The Git history, versioned protocol, code, and public-safe documentation should be treated as the shared project state; private research records must be transferred separately.

## On the home computer

1. Sign in to Codex with the same OpenAI account and the same authentication method used on the current computer.
2. Clone the repository, or pull the latest `main` branch if it already exists:

   ```text
   git clone https://github.com/lotosek/TurkCuisineBench.git
   ```

   or:

   ```text
   git pull origin main
   ```

3. Open the cloned `TurkCuisineBench` folder as the Codex project.
4. Start a new Codex task with the following prompt:

   > Continue the TurkCuisineBench study from `docs/main_study_protocol_v1.0.md`. The Dev pilot, double coding, third-review adjudication, and Taxonomy v1.0 freeze are complete. Start with Phase M0 and do not run main-study models until Gates M0–M4 are complete. Preserve Dev/Test separation and keep private Test answers and reviewer records outside Git.

5. Verify the local checkout:

   ```text
   python evaluation/test_scorer.py
   ```

6. Confirm that the test output reports all scorer and technical-validity cases as passing.

## Private files that do not travel through GitHub

Transfer the following through a private, access-controlled channel rather than committing them:

- the frozen pilot consensus and taxonomy workbook;
- original reviewer returns and adjudication records;
- private source-fact and excluded-candidate registers;
- the private Test item and answer-key files once created;
- model-to-review mappings;
- raw provider logs and request identifiers;
- API configuration containing credentials.

Preserve original filenames and SHA-256 checksums after transfer. Do not place these files under a Git-tracked directory.

## Current project state

- Frozen development resource: `TurkCuisineBench-Dev v0.2`.
- Completed provider-neutral methods pilot: `pilot_run_v0.3`.
- Completed manual review: 46 non-exact responses double coded.
- Completed adjudication: five routed cases resolved.
- Frozen response-error taxonomy: `Taxonomy v1.0`.
- Next authorized stage: Phases M0–M4 in `docs/main_study_protocol_v1.0.md`.

## Continuity rule

Do not attempt to reconstruct the study solely from chat history. Before each substantive phase, pull the repository, read the current protocol and decision log, and commit only public-safe changes. Keep the private audit archive synchronized separately.
