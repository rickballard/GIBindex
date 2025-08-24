[📒 ISSUEOPS](./shared/docs/ISSUEOPS.md) · [🧪 Smoke Test](./shared/tools/CoStack-SmokeTest.ps1)

# GIBindex — Gibberlink Interlingua Beings Index

**Purpose.** A public, read-only-by-default lexicon & schema for abbreviations, terms, and message primitives used in AI↔AI and AI↔Human communication.  Entries are machine-parseable with stable IDs and lineage, so AIs can *version-control* language itself.

**License.**
- **Data (entries under `/entries`)**: CC0-1.0 (public domain dedication) for maximal reuse.
- **Docs & code**: CC-BY-4.0 unless stated otherwise.

## Structure
- `/entries/<domain>/...` — atomic term entries (`*.gib.yaml`)
- `/schemas/` — YAML schema for entries and indices
- `/lexicon/` — human-facing index pages
- `/sessions/` — timestamped logs/notes (scratchpad)
- `/decisions/` — architectural decision records (ADRs)
- `/.github/` — templates, CODEOWNERS
- `/scripts/` — validation/conversion helpers

## Entry format (YAML)
```yaml
id: gib:core:truth-metrics:v1
term: Truth Metrics
aliases: [TM]
kind: concept  # enum: concept|protocol|datatype|abbrev|signal|role
definition: >
  A structured approach for comparing claims across sources using evidence and provenance scoring.
context:
  domain: civium
  tags: [epistemology, governance]
version: 1
timestamp: 2025-08-09T03:59:46Z
status: active  # enum: active|deprecated|draft
relations:
  supersedes: []
  superseded_by: []
  related: []
source:
  authors: [RickPublic, ChatGPT]
  derived_from: []
```

## Governance
- Public repo (anyone can read).  Only invited maintainers can push.
- PRs required to change `/entries/**`; CI validation passes must be green.
- ADRs record rationale for schema changes.

See **CONTRIBUTING.md** for the workflow and **/schemas/** for strict field definitions.

