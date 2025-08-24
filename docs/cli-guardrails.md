# CLI Guardrails (PowerShell)

**Always re-orient PS7 before any new instruction set.** Use:

```powershell
C:\Users\Chris\Documents\GitHub\CoModules = Join-Path $HOME 'Documents\GitHub\GIBindex'
if(!(Test-Path -LiteralPath $repo)){ throw "Repo not found: $repo" }
Set-Location -LiteralPath $repo; git status -sb;
```

See `scripts/enter.ps1` for the repo-scoped mutex and `-Force` pattern.
