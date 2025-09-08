# BPOE: Cross-linking pass (Civium canonicals)

**Goal:** Every entry point points to CoCivium canonicals pinned to a release tag.

- Maintain `docs/Civium-Canonicals.md` (CoModules) and glossary “See also” (GIBindex).
- Append “Canonical References” to README where relevant.
- Prefer tag-pinned links for provenance; bump tag only during explicit migration.
- Rebase rule: keep canonicals from `main` (`git checkout --ours <path>`); accept net-new only.
