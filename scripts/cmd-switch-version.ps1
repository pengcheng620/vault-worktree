# Vault Worktree: Switch Version Command Implementation
# Maps H: drive to a specific Vault version
# Usage: /vault-worktree:switch-version 2027 [--sync]

param(
    [Parameter(Position=0, Mandatory=$true)]
    [string]$Version,

    [switch]$Sync
)

# Load utilities
. "$(Split-Path $PSCommandPath)\lib-vault-utils.ps1"

# ═══════════════════════════════════════════════════════════════════════════
# MAIN LOGIC
# ═══════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Header "Switching Vault Version"

# Find vault root
Write-Host "🔍 Detecting Vault root..." -ForegroundColor Cyan
$vaultRoot = Find-VaultRoot
if (-not $vaultRoot) {
    Write-Error-Custom "Cannot find Vault root (.git directory not found)"
    Write-Host "   Current location: $(Get-Location)" -ForegroundColor White
    Write-Host ""
    Write-Info "Solution:"
    Write-Host "   1. Navigate to Vault root directory: cd D:\Works\Vault\vault"
    Write-Host "   2. Run the command again: /vault-worktree:switch-version 2027"
    exit 1
}

# Validate vault root
if (-not (Test-VaultRoot $vaultRoot)) {
    Write-Error-Custom "Invalid Vault root (no .git directory found)"
    exit 1
}

Write-Success "Found: $vaultRoot"

# Get available versions
Write-Host "📍 Discovering available versions..." -ForegroundColor Cyan
$availableVersions = Get-AvailableVersions $vaultRoot

if ($availableVersions.Count -eq 0) {
    Write-Error-Custom "No Vault version directories found"
    Write-Host "   Expected directories: vault-2025, vault-2026, vault-2027, etc." -ForegroundColor White
    Write-Host ""
    Write-Info "To initialize versions, run:"
    Write-Host "   /vault-worktree:worktree-init" -ForegroundColor Cyan
    exit 1
}

Write-Host "   Found: $($availableVersions -join ', ')"

# Validate requested version
if ($availableVersions -notcontains $Version) {
    Write-Error-Custom "Version ""$Version"" not found"
    Write-Host "   Available versions: $($availableVersions -join ', ')" -ForegroundColor White
    Write-Host ""
    Write-Info "Solutions:"
    Write-Host "   1. Use an available version: /vault-worktree:switch-version $(($availableVersions)[0])" -ForegroundColor Cyan
    Write-Host "   2. Create missing version: /vault-worktree:worktree-init --versions $Version" -ForegroundColor Cyan
    exit 1
}

# Get current version to check for uncommitted changes
$currentVersion = Get-CurrentVersion $vaultRoot
$currentVersionPath = if ($currentVersion) { Join-Path $vaultRoot "vault-$currentVersion" } else { $null }

if ($currentVersionPath -and (Test-Path $currentVersionPath)) {
    $hasChanges = Test-HasUncommittedChanges $currentVersionPath
    if ($hasChanges) {
        Write-Warning-Custom "Uncommitted changes in vault-$currentVersion"
        $changeCount = Get-UncommittedChangeCount $currentVersionPath
        Write-Host "   Files modified: $changeCount"
        Write-Host ""
        Write-Info "Options:"
        Write-Host "   1. Commit changes: cd h: && git add . && git commit -m ""...""" -ForegroundColor Cyan
        Write-Host "   2. Stash changes: cd h: && git stash" -ForegroundColor Cyan
        Write-Host "   3. Continue anyway (changes will be preserved)" -ForegroundColor Cyan
    }
}

# Map H: drive
Write-Host "🔧 Mapping H: drive..." -ForegroundColor Cyan
$versionPath = Join-Path $vaultRoot "vault-$Version"

$mapSuccess = Set-HMapping $versionPath
if (-not $mapSuccess) {
    Write-Error-Custom "Failed to map H: drive to vault-$Version"
    Write-Host "   Ensure you have administrator privileges" -ForegroundColor White
    Write-Host "   Or check if H: is in use by another process" -ForegroundColor White
    exit 1
}

Write-Success "H: => $versionPath"

# Get status in new version
Write-Host "📊 Getting version status..." -ForegroundColor Cyan
$branch = Get-CurrentBranch $versionPath
$unpushed = Get-UnpushedCommitCount $versionPath

if ($branch) {
    Write-Host "   Branch: $branch" -ForegroundColor White
    if ($unpushed -gt 0) {
        Write-Host "   Unpushed commits: $unpushed" -ForegroundColor Yellow
    }
}

$hasUncommitted = Test-HasUncommittedChanges $versionPath
if ($hasUncommitted) {
    $changeCount = Get-UncommittedChangeCount $versionPath
    Write-Warning-Custom "Working directory has $changeCount uncommitted file(s)"
} else {
    Write-Host "   Status: working directory clean" -ForegroundColor Green
}

# Sync if requested
if ($Sync) {
    Write-Host ""
    Write-Section "Syncing All Versions"
    Write-Host "   Running: git fetch origin --prune" -ForegroundColor Cyan

    try {
        Push-Location $versionPath

        # Fetch all remotes
        $output = git fetch origin --prune 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "All versions synced with remote"

            # Show which branches were updated
            $versionDirs = Get-ChildItem -Path $vaultRoot -Directory -Filter "vault-*" -ErrorAction SilentlyContinue
            foreach ($dir in $versionDirs) {
                $version = $dir.Name -replace "^vault-", ""
                if ($version -eq $Version) {
                    Write-Host "   ✓ vault-$version (current)" -ForegroundColor Green
                } else {
                    Write-Host "   ✓ vault-$version" -ForegroundColor White
                }
            }
        } else {
            Write-Warning-Custom "Sync had warnings or errors:"
            Write-Host $output -ForegroundColor Yellow
        }

        Pop-Location
    }
    catch {
        Write-Warning-Custom "Sync error: $_"
        Pop-Location
    }
}

# Final status
Write-Host ""
Write-Success "Switched to vault-$Version"
Write-Host ""
Write-Section "💡 Next Steps"
Write-Host "   1. Switch branch: /vault-worktree:switch-branch PDM-xxxxx" -ForegroundColor Cyan
Write-Host "   2. Check status:  /vault-worktree:status" -ForegroundColor Cyan
Write-Host "   3. Start coding:  cd h:" -ForegroundColor Cyan
Write-Host ""
