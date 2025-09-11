<!-- status: stub; target: 150+ words -->
<!-- status: stub; target: 150+ words -->
# Contributing to GIBindex

## Workflow
1. Open an **Entry Request** issue using the template.
2. Fork the repo and add a new `*.gib.yaml` under `/entries/<domain>/`.
3. Run `scripts/validate_entries.py` locally.
4. Submit a PR; ensure the template checklist is satisfied.

## Naming
- Filenames: `short-slug_YYYYMMDDThhmmssZ.gib.yaml` (UTC)
- `id` is stable and monotonic: `gib:<domain>:<slug>:v<version>`

## Review
- At least one maintainer approval.
- Link the issue; state rationale and impacts.



