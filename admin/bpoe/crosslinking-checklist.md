# BPOE: Cross-linking pass (Civium canonicals)

**Goal:** Glossary pages carry “See also” links to CoCivium canonicals pinned to the migration tag.

- Add / update `docs/glossary/*` entries with tag-pinned links to civium PREAMBLE & Core Assumption.
- Ensure README remains owned by `main` when rebasing mixed ops/doc branches.
- Run link check; fix 404s.

Rebase rule:
- Keep canonical files from `main` (`git checkout --ours`).
- Accept net-new files from feature branches.
