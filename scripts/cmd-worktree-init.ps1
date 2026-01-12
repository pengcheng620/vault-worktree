# Vault Worktree: Initialize Worktree Command Implementation
# Creates Git worktrees for specified versions
# Usage: /vault-worktree:worktree-init [--versions 2025,2026,2027]

param(
    [string]$Versions = ""
)

# Load utilities
. "$(Split-Path $PSCommandPath)\lib-vault-utils.ps1"

# ═══════════════════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════

function Get-RemoteBranches {
    param(
        [Parameter(Mandatory=$true)]
        [string]$RepoPath
    )

    try {
        Push-Location $RepoPath
        $branches = @()

        # Get remote tracking branches
        $gitOutput = git branch -r 2>$null
        foreach ($line in $gitOutput) {
            $branch = $line -replace "^\s+", "" -replace "\s+->.*$", ""
            if ($branch -and $branch -notmatch "HEAD" -and $branch -notmatch "/HEAD") {
                $branches += $branch -replace "^origin/", ""
            }
        }

        Pop-Location
        return $branches | Sort-Object -Unique
    }
    catch {
        Pop-Location
        return @()
    }
}

function Find-VersionBranch {
    param(
        [Parameter(Mandatory=$true)]
        [array]$AvailableBranches,

        [Parameter(Mandatory=$true)]
        [string]$Version
    )

    # Look for R<Version>.x or R<Version> pattern
    $versionPattern = "^R$([Regex]::Escape($Version))(\.\d+)?$"

    $match = $AvailableBranches | Where-Object { $_ -match $versionPattern } | Select-Object -First 1

    return $match
}

# ═══════════════════════════════════════════════════════════════════════════
# MAIN LOGIC
# ═══════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Header "Initialize Vault Worktree Structure"

# Find vault root
Write-Host "🔍 Detecting Vault root..." -ForegroundColor Cyan
$vaultRoot = Find-VaultRoot
if (-not $vaultRoot) {
    Write-Error-Custom "Cannot find Vault root (.git directory not found)"
    Write-Info "Solution: Navigate to Vault directory and try again"
    exit 1
}

# Validate it's a git repo
if (-not (Test-VaultRoot $vaultRoot)) {
    Write-Error-Custom "Not a valid Git repository"
    exit 1
}

Write-Success "Found: $vaultRoot"

# Get available remote branches
Write-Host "📍 Discovering available versions..." -ForegroundColor Cyan
$remoteBranches = Get-RemoteBranches $vaultRoot

if ($remoteBranches.Count -eq 0) {
    Write-Error-Custom "Cannot find remote branches"
    Write-Host "   Ensure repository has remote: git remote -v" -ForegroundColor White
    Write-Host ""
    Write-Info "Solutions:"
    Write-Host "   1. Add remote: git remote add origin <url>" -ForegroundColor Cyan
    Write-Host "   2. Fetch: git fetch origin" -ForegroundColor Cyan
    Write-Host "   3. Try again: /vault-worktree:worktree-init" -ForegroundColor Cyan
    exit 1
}

# Determine which versions to create
$targetVersions = @()

if ($Versions) {
    # Use user-specified versions
    $versionList = $Versions -split "," | ForEach-Object { $_.Trim() }
    $targetVersions = $versionList
    Write-Host "   Requested: $($versionList -join ', ')" -ForegroundColor Cyan
} else {
    # Auto-detect versions from remote branches
    # Look for R2025.x, R2026.x, R2027.1 patterns
    $versionBranches = $remoteBranches | Where-Object { $_ -match "^R\d+" }
    foreach ($branch in $versionBranches) {
        if ($branch -match "^R(\d+[.\w]*)$") {
            $targetVersions += $Matches[1]
        }
    }

    if ($targetVersions.Count -gt 0) {
        Write-Host "   Auto-detected: $($targetVersions -join ', ')" -ForegroundColor Cyan
    } else {
        Write-Warning-Custom "No version branches found (pattern: R2025.x, R2026.x, etc.)"
    }
}

Write-Host "   Available branches: $($remoteBranches -join ', ')" -ForegroundColor Gray

# Create worktrees
Write-Host ""
Write-Section "Creating Worktrees"

$createdCount = 0
$skippedCount = 0
$failedCount = 0

foreach ($version in $targetVersions) {
    $versionDir = Join-Path $vaultRoot "vault-$version"
    $versionBranch = Find-VersionBranch $remoteBranches $version

    # Check if worktree already exists
    if (Test-Path $versionDir -PathType Container) {
        Write-Warning-Custom "vault-$version already exists (skipped)" -ForegroundColor Yellow
        $skippedCount++
        continue
    }

    if (-not $versionBranch) {
        Write-Error-Custom "Cannot find branch for version $version" -ForegroundColor Red
        $failedCount++
        continue
    }

    Write-Host "🔧 Creating vault-$version (based on origin/$versionBranch)..." -ForegroundColor Cyan

    try {
        Push-Location $vaultRoot

        # Create worktree
        $startTime = Get-Date
        git worktree add $versionDir "origin/$versionBranch" 2>&1 | Out-Null

        if ($LASTEXITCODE -eq 0) {
            $elapsed = (Get-Date) - $startTime
            Write-Success "vault-$version created [$('{0:mm}:{0:ss}' -f $elapsed)]"
            $createdCount++
        } else {
            Write-Error-Custom "Failed to create vault-$version"
            $failedCount++
        }

        Pop-Location
    }
    catch {
        Write-Error-Custom "Error creating vault-$version: $_"
        Pop-Location
        $failedCount++
    }
}

# Summary
Write-Host ""
Write-Section "Initialization Complete"

Write-Host "   ✓ Created: $createdCount" -ForegroundColor Green
if ($skippedCount -gt 0) {
    Write-Host "   ⊘ Skipped: $skippedCount (already exist)" -ForegroundColor Yellow
}
if ($failedCount -gt 0) {
    Write-Host "   ❌ Failed: $failedCount" -ForegroundColor Red
}

# Show final structure
Write-Host ""
Write-Section "Worktree Structure"

$versions = Get-AvailableVersions $vaultRoot
foreach ($version in $versions) {
    $versionPath = Join-Path $vaultRoot "vault-$version"
    $size = Get-DirectorySize $versionPath

    $sizeStr = if ($size -gt 1024) {
        "$([Math]::Round($size / 1024, 1))GB"
    } else {
        "${size}MB"
    }

    Write-Host "   vault-$version ($sizeStr) [OK]" -ForegroundColor Green
}

$gitSize = Get-DirectorySize (Join-Path $vaultRoot ".git")
$gitSizeStr = if ($gitSize -gt 1024) {
    "$([Math]::Round($gitSize / 1024, 1))GB"
} else {
    "${gitSize}MB"
}

Write-Host "   .git (shared) ($gitSizeStr)" -ForegroundColor Gray

# Next steps
Write-Host ""
Write-Section "🎯 Next Steps"
Write-Host "   1. /vault-worktree:switch-version $(($versions | Select-Object -Last 1))" -ForegroundColor Cyan
Write-Host "   2. /vault-worktree:switch-branch PDM-xxxxx" -ForegroundColor Cyan
Write-Host "   3. Start developing!" -ForegroundColor Cyan

Write-Host ""
Write-Info "Tip: Use /vault-worktree:status to verify setup" -ForegroundColor Cyan
Write-Host ""
