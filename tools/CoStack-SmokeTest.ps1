<# 
 CoStack-SmokeTest.ps1
 Smoke test for "Co Stack" GitHub Projects v2 auto-add workflow.
 - Resolves project number
 - Captures baseline item count
 - Opens a temporary issue in a target repo
 - Waits for the workflow run non-interactively and saves logs
 - Polls for project count bump
 - Closes the temporary issue
#>

[CmdletBinding()]
param(
  [string]$Owner         = 'rickballard',
  [string]$ProjectTitle  = 'Co Stack',
  [string]$TestRepo      = 'CoCivium',
  [string]$WorkflowFile  = 'auto-add-to-project.yml',
  [int]$RunWaitSec       = 180,
  [int]$CountWaitSec     = 120
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Require-Cli([string]$Name, [string[]]$VersionArgs=@('--version')){
  try { & $Name @VersionArgs | Out-Null } catch { throw "Required CLI '$Name' not found in PATH. Please install it and try again." }
}

Require-Cli 'gh'

# Ensure gh is authenticated
$auth = (& gh auth status 2>&1) -join "`n"
if($LASTEXITCODE -ne 0){
  throw "GitHub CLI is not authenticated. Run: gh auth login  (or ensure GH_TOKEN is set)"
}

Write-Host "== Resolving project number for '$ProjectTitle' under @$Owner =="
$projListJson = gh api graphql -F login=$Owner -f query='
  query($login:String!){
    user(login:$login){
      projectsV2(first:100){ nodes{ number title } }
    }
  }'

$projNum = (($projListJson | ConvertFrom-Json).data.user.projectsV2.nodes |
  Where-Object { $_.title -eq $ProjectTitle } |
  Select-Object -ExpandProperty number -First 1)

if(-not $projNum){ throw "Project '$ProjectTitle' not found for @$Owner." }
Write-Host "Project number: $projNum"

Write-Host "== Capturing baseline count =="
$beforeJson = gh api graphql -F login=$Owner -F number=$projNum -f query='
  query($login:String!,$number:Int!){
    user(login:$login){ projectV2(number:$number){ items(first:1){ totalCount } } }
  }'
$before = [int](( $beforeJson | ConvertFrom-Json ).data.user.projectV2.items.totalCount)
Write-Host "Baseline items: $before"

Write-Host "== Opening temporary issue in $Owner/$TestRepo =="
$stamp = Get-Date -Format s
$title = "[ops-test] auto-add check $stamp"
$issueJson = gh api -X POST "repos/$Owner/$TestRepo/issues" -f title="$title" -f body="Temporary workflow check triggered by CoStack-SmokeTest.ps1"
$issue = $issueJson | ConvertFrom-Json
$issueUrl  = $issue.html_url
$issueNum  = [int]$issue.number
$issueNode = $issue.node_id
Write-Host "Opened issue #$issueNum -> $issueUrl"

Write-Host "== Waiting for workflow run to appear (up to $RunWaitSec s) =="
$deadline = (Get-Date).AddSeconds($RunWaitSec)
$runId = $null
do {
  Start-Sleep -Seconds 5
  $runsJson = gh run list -R "$Owner/$TestRepo" --workflow $WorkflowFile --limit 20 --json databaseId,displayTitle,createdAt,status
  $runs = $runsJson | ConvertFrom-Json
  $run = $runs | Where-Object { $_.displayTitle -like "*$title*" } | Select-Object -First 1
  if($run){ $runId = $run.databaseId }
} while(-not $runId -and (Get-Date) -lt $deadline)

if(-not $runId){
  Write-Warning "Could not locate a workflow run for '$title' within $RunWaitSec seconds."
} else {
  Write-Host "Found run id: $runId. Watching to completion..."
  # Watch non-interactively and capture exit status
  gh run watch $runId -R "$Owner/$TestRepo" --exit-status
  $logPath = Join-Path (Get-Location) ("CoStack-run-$runId.log")
  gh run view $runId -R "$Owner/$TestRepo" --log | Set-Content -Encoding UTF8 $logPath
  Write-Host "Saved logs: $logPath"
}

Write-Host "== Polling for project count bump (up to $CountWaitSec s) =="
$deadline2 = (Get-Date).AddSeconds($CountWaitSec)
$now = $before
do {
  Start-Sleep -Seconds 5
  $nowJson = gh api graphql -F login=$Owner -F number=$projNum -f query='
    query($login:String!,$number:Int!){
      user(login:$login){ projectV2(number:$number){ items(first:1){ totalCount } } }
    }'
  $now = [int](( $nowJson | ConvertFrom-Json ).data.user.projectV2.items.totalCount)
  Write-Host "Project count: $now"
} while($now -le $before -and (Get-Date) -lt $deadline2)

Write-Host "== Cleanup =="
try {
  if($issueNum){
    gh api -X PATCH "repos/$Owner/$TestRepo/issues/$issueNum" -f state=closed | Out-Null
    Write-Host "Closed temp issue #$issueNum"
  }
} catch {
  Write-Warning "Failed to close temp issue #$($issueNum): $($_.Exception.Message)"
}

Write-Host "== Result =="
if($now -gt $before){
  Write-Host ("PASS: Project item count increased ({0} -> {1})" -f $before,$now) -ForegroundColor Green
  exit 0
} else {
  Write-Host ("FAIL: Project item count did not increase (still {0}). Inspect the saved run logs (if any) and the repo's Actions tab." -f $now) -ForegroundColor Yellow
  exit 1
}

