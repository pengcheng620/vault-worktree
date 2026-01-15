# Vault Worktree: Status Command Implementation (v2.0)
# Shows current status of Vault worktree structure and Git state
# Usage: /vault-worktree:status [--full] [--sync] [--tree]

param(
    [switch]$Full,
    [switch]$Sync,
    [switch]$Tree
)

# Load utilities
. "$(Split-Path $PSCommandPath)\lib-vault-utils.ps1"
. "$(Split-Path $PSCommandPath)\lib-vault-config.ps1"

# ═══════════════════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════

function Show-WorktreeTree {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VaultRoot,

        [Parameter(Mandatory=$true)]
        [string]$CurrentVersion,

        [Parameter(Mandatory=$false)]
        [pscustomobject]$Config = $null
    )

    Write-Host ""
    Write-Section "Worktree Structure"

    if (-not $Config) {
        $Config = Get-VaultConfig
    }

    $allVersions = Get-AllVersions -Config $Config
    $primaryVersion = Get-PrimaryVersion -Config $Config

    if ($allVersions.Count -eq 0) {
        Write-Host "   (no worktrees configured)" -ForegroundColor Gray
        return
    }

    foreach ($i = 0; $i -lt $allVersions.Count; $i++) {
        $v = $allVersions[$i]
        $isLast = ($i -eq $allVersions.Count - 1)
        $isCurrent = ($v.branch -eq $CurrentVersion)
        $isPrimary = $v.is_primary

        # Tree characters
        $treeChar = if ($isLast) { "└─" } else { "├─" }

        # Status indicators
        $statusMarkers = @()
        if ($isPrimary) { $statusMarkers += "[PRIMARY]" }
        if ($isCurrent) { $statusMarkers += "[CURRENT]" }
        $statusStr = if ($statusMarkers.Count -gt 0) { " " + ($statusMarkers -join " ") } else { "" }

        $versionPath = Join-Path $VaultRoot $v.directory
        if (Test-Path $versionPath) {
            # Get branch info
            $branch = Get-CurrentBranch $versionPath
            $hasChanges = Test-HasUncommittedChanges $versionPath
            $uncommittedCount = Get-UncommittedChangeCount $versionPath
            $unpushedCount = Get-UnpushedCommitCount $versionPath

            # Color based on status
            $branchColor = if ($hasChanges -or $unpushedCount -gt 0) { "Yellow" } else { "Green" }
            if ($isCurrent) { $branchColor = "Cyan" }

            Write-Host "   $treeChar $($v.directory)$statusStr" -ForegroundColor $branchColor
            Write-Host "   $( if ($isLast) { '   ' } else { '│  ' })├─ Branch: $branch" -ForegroundColor Gray
            Write-Host "   $( if ($isLast) { '   ' } else { '│  ' })├─ Status: $(if ($hasChanges) { '⚠️  ' + $uncommittedCount + ' changes' } else { '✓ clean' })" -ForegroundColor Gray

            if ($unpushedCount -gt 0) {
                Write-Host "   $( if ($isLast) { '   ' } else { '│  ' })├─ Unpushed: 📤 $unpushedCount commit(s)" -ForegroundColor Yellow
            }

            if ($isCurrent) {
                Write-Host "   $( if ($isLast) { '   ' } else { '│  ' })└─ ← You are here" -ForegroundColor Cyan
            }
        } else {
            Write-Host "   $treeChar $($v.directory) (missing)" -ForegroundColor Red
        }
    }

    # Git shared database
    $gitSize = Get-DirectorySize (Join-Path $VaultRoot ".git")
    $gitSizeStr = if ($gitSize -gt 1024) {
        "$([Math]::Round($gitSize / 1024, 1))GB"
    } else {
        "${gitSize}MB"
    }
    Write-Host ""
    Write-Host "   .git (shared database) - $gitSizeStr" -ForegroundColor Gray
}

function Show-ConfigStatus {
    param(
        [Parameter(Mandatory=$false)]
        [pscustomobject]$Config = $null
    )

    if (-not $Config) {
        $Config = Get-VaultConfig
    }

    if (-not $Config) {
        Write-Host "⚠️  No configuration found" -ForegroundColor Yellow
        return
    }

    Write-Host ""
    Write-Section "Configuration"

    Write-Host "   Config: $(Get-ConfigPath)" -ForegroundColor Gray
    Write-Host "   Naming Rule: $($Config.directory_naming_rule)" -ForegroundColor Gray
    Write-Host "   Primary Version: $($Config.primary_version ?? 'Not set')" -ForegroundColor Gray
    Write-Host "   Modified: $($Config.last_modified)" -ForegroundColor Gray
}

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
    Write-Info "Solution: Initialize worktree first"
    Write-Host "   /vault-worktree:worktree-init" -ForegroundColor Cyan
    exit 1
}

Write-Header "Vault Status (v2.0)"

# Get current version from H: mapping
$currentVersion = Get-CurrentVersion $vaultRoot
if (-not $currentVersion) {
    Write-Warning-Custom "H: drive not mapped to any version"
    Write-Host ""
    Write-Info "Solution: Switch to a version first"
    Write-Host "   /vault-worktree:switch-version R2027.1" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

# Load configuration
$config = Get-VaultConfig
if (-not $config) {
    Write-Warning-Custom "No configuration found"
    Write-Info "Initialize worktree to create configuration:"
    Write-Host "   /vault-worktree:worktree-init" -ForegroundColor Cyan
    exit 1
}

# Get current version info
$currentVersionInfo = Get-VersionByBranch $currentVersion -Config $config
if (-not $currentVersionInfo) {
    Write-Warning-Custom "Current version not found in configuration"
    Write-Host "Run: /vault-worktree:worktree-init to update configuration" -ForegroundColor Yellow
    exit 1
}

$currentVersionPath = Join-Path $vaultRoot $currentVersionInfo.directory

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

# Show worktree structure (tree view)
Show-WorktreeTree -VaultRoot $vaultRoot -CurrentVersion $currentVersion -Config $config

# Show current worktree details
Write-Host ""
Write-Section "Current Worktree Details"

Write-Host "   Version: $currentVersion (from H: drive)" -ForegroundColor Cyan
Write-Host "   Directory: $($currentVersionInfo.directory)" -ForegroundColor Cyan

$branch = Get-CurrentBranch $currentVersionPath
Write-Host "   Branch: $branch" -ForegroundColor Cyan

# Get change counts
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

            $lineCount = 0
            foreach ($line in $statusOutput) {
                if ($line) {
                    Write-Host "   $line" -ForegroundColor Yellow
                    $lineCount++
                }
            }

            if ($lineCount -eq 0) {
                Write-Host "   (no changes)" -ForegroundColor Gray
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
            $logOutput = git log --oneline "@{upstream}...HEAD" 2>&1
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
}

# Show configuration
Show-ConfigStatus -Config $config

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
    Write-Host "   git add . && git commit -m ""...""" -ForegroundColor Cyan
    Write-Host "   git push origin $branch" -ForegroundColor Cyan
} else {
    Write-Success "Ready to work!"
    Write-Host "   All changes committed and pushed" -ForegroundColor Gray
}

Write-Host ""
Write-Section "Next Steps"

if (-not $Full) {
    Write-Host "   1. See details: /vault-worktree:status --full" -ForegroundColor Cyan
}

Write-Host "   2. Switch version: /vault-worktree:switch-version R2027.1" -ForegroundColor Cyan
Write-Host "   3. Switch branch:  /vault-worktree:switch-branch PDM-xxxxx" -ForegroundColor Cyan
Write-Host "   4. Start coding:   cd h:" -ForegroundColor Cyan

Write-Host ""
