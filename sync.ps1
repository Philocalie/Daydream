# GitHub Auto Sync Script for Daydream Vault
$RepoPath = "C:\NAS\Daydream"
$LogFile = "$RepoPath\.sync.log"
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

function Write-Log {
    param([string]$Message)
    $log = "[$Timestamp] $Message"
    Write-Output $log
    Add-Content -Path $LogFile -Value $log
}

Write-Log "=== Sync Start ==="
Set-Location $RepoPath

try {
    $pullResult = git pull origin main 2>&1
    Write-Log "Pull: $pullResult"
} catch {
    Write-Log "Pull failed: $_"
}

$hasChanges = git status --porcelain
if ($hasChanges) {
    Write-Log "Changes detected, committing..."
    git add -A 2>&1 | Out-Null
    $commitMsg = "auto sync $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    git commit -m $commitMsg 2>&1 | ForEach-Object { Write-Log "Commit: $_" }
    try {
        $pushResult = git push origin main 2>&1
        Write-Log "Push: $pushResult"
        Write-Log "Sync successful!"
    } catch {
        Write-Log "Push failed: $_"
    }
} else {
    Write-Log "No changes, skipped"
}
Write-Log "=== Sync End ==="
Write-Log ""
