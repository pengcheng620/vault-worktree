# Vault Worktree: Status Command Implementation
# Shows current status of Vault worktree and Git
# Usage: /vault-worktree:status [--full] [--sync]

param(
    [switch]$Full,
    [switch]$Sync
)

# Load utilities
. "$(Split-Path $PSCommandPath)\lib-vault-utils.ps1"

# ═══════════════════════════════════════════════════════════════════════════
# MAIN LOGIC
# ═══════════════════════════════════════════════════════════════════════════

Write-Host ""

# Find vault root
$vaultRoot = Find-VaultRoot
if (-not $vaultRoot) {
    Write-Error-Custom "Not in a Git repository"
    Write-Host "   Current location: $(Get-Location)" -ForegroundColor White
    Write-Host ""
    Write-Info "Solution: Map a version first"
    Write-Host "   /vault-worktree:switch-version 2027" -ForegroundColor Cyan
    exit 1
}

# Get current version
$currentVersion = Get-CurrentVersion $vaultRoot
if (-not $currentVersion) {
    Write-Error-Custom "H: drive not mapped"
    Write-Host ""
    Write-Info "Solution:"
    Write-Host "   /vault-worktree:switch-version 2027" -ForegroundColor Cyan
    exit 1
}

$currentVersionPath = Join-Path $vaultRoot "vault-$currentVersion"

# Sync if requested
if ($Sync) {
    Write-Host "🔄 Syncing all versions with remote..." -ForegroundColor Cyan
    try {
        Push-Location $currentVersionPath
        $fetchOutput = git fetch origin --prune 2>&1
        Pop-Location

        if ($LASTEXITCODE -eq 0) {
            Write-Success "Sync complete"
        } else {
            Write-Warning-Custom "Sync completed with warnings"
        }
        Write-Host ""
    }
    catch {
        Write-Warning-Custom "Sync error: $_"
        Pop-Location
        Write-Host ""
    }
}

# Get status information
Write-Header "Vault Status"

Write-Section "Current Version & Branch"
Write-Host "   Version: $currentVersion" -ForegroundColor Cyan
Write-Host "   Path: $currentVersionPath" -ForegroundColor Gray

$branch = Get-CurrentBranch $currentVersionPath
Write-Host "   Branch: $branch" -ForegroundColor Cyan

# Get uncommitted and unpushed counts
$hasUncommitted = Test-HasUncommittedChanges $currentVersionPath
$changeCount = Get-UncommittedChangeCount $currentVersionPath
$unpushedCount = Get-UnpushedCommitCount $currentVersionPath

# Status indicator
Write-Host ""
if ($hasUncommitted -or $unpushedCount -gt 0) {
    Write-Warning-Custom "Working directory has changes"
} else {
    Write-Success "Working directory clean"
}

# Show details in --full mode
if ($Full) {
    Write-Host ""
    Write-Section "Modified Files"

    if ($hasUncommitted) {
        try {
            Push-Location $currentVersionPath
            $statusOutput = git status --short 2>&1
            Pop-Location

            foreach ($line in $statusOutput) {
                if ($line) {
                    Write-Host "   $line" -ForegroundColor Yellow
                }
            }
        }
        catch {
            Pop-Location
            Write-Host "   (Unable to get file list)" -ForegroundColor Gray
        }
    } else {
        Write-Host "   (no modified files)" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Section "Unpushed Commits"

    if ($unpushedCount -gt 0) {
        try {
            Push-Location $currentVersionPath
            $logOutput = git log --oneline @{upstream}...HEAD 2>&1
            Pop-Location

            foreach ($line in $logOutput) {
                if ($line) {
                    Write-Host "   * $line" -ForegroundColor Green
                }
            }
        }
        catch {
            Pop-Location
            Write-Host "   (Unable to get commit list)" -ForegroundColor Gray
        }
    } else {
        Write-Host "   (no unpushed commits)" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Section "Remote Status"

    try {
        Push-Location $currentVersionPath
        $trackingInfo = git status --branch --porcelain 2>&1 | Select-Object -First 1
        Pop-Location

        if ($trackingInfo) {
            Write-Host "   $trackingInfo" -ForegroundColor White
        } else {
            Write-Host "   (unknown)" -ForegroundColor Gray
        }
    }
    catch {
        Pop-Location
        Write-Host "   (Unable to check)" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Section "Other Versions"

    $versions = Get-AvailableVersions $vaultRoot
    foreach ($ver in $versions) {
        $verPath = Join-Path $vaultRoot "vault-$ver"
        $verBranch = Get-CurrentBranch $verPath
        $verUncommitted = Get-UncommittedChangeCount $verPath
        $verUnpushed = Get-UnpushedCommitCount $verPath

        if ($ver -eq $currentVersion) {
            Write-Host "   ✓ vault-$ver (current) - $verBranch" -ForegroundColor Green
        } else {
            Write-Host "   vault-$ver - $verBranch" -ForegroundColor White
        }

        if ($verUncommitted -gt 0) {
            Write-Host "     └─ $verUncommitted uncommitted file(s)" -ForegroundColor Yellow
        }
        if ($verUnpushed -gt 0) {
            Write-Host "     └─ $verUnpushed unpushed commit(s)" -ForegroundColor Yellow
        }
    }
}

# Summary
Write-Host ""
Write-Section "Summary"

if ($hasUncommitted -or $unpushedCount -gt 0) {
    if ($changeCount -gt 0) {
        Write-Host "   📝 Uncommitted: $changeCount file(s)" -ForegroundColor Yellow
    }
    if ($unpushedCount -gt 0) {
        Write-Host "   📤 Unpushed: $unpushedCount commit(s)" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Info "Actions needed:"
    Write-Host "   - Commit: git add . && git commit -m ""...""" -ForegroundColor Cyan
    Write-Host "   - Push:   git push origin $branch" -ForegroundColor Cyan
} else {
    Write-Success "Ready to work!"
    Write-Host "   All changes committed and pushed"
}

Write-Host ""
Write-Section "Next Steps"

if (-not $Full) {
    Write-Host "   1. See details: /vault-worktree:status --full" -ForegroundColor Cyan
}

Write-Host "   2. Switch branch: /vault-worktree:switch-branch PDM-xxxxx" -ForegroundColor Cyan
Write-Host "   3. Start coding:  cd h:" -ForegroundColor Cyan
Write-Host ""
