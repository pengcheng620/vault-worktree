# Vault Worktree: Switch Version Command Implementation (v2.0)
# Maps H: drive to a specific Vault version with primary worktree awareness
# Usage: /vault-worktree:switch-version R2027.1 [--sync] [--set-primary]

param(
    [Parameter(Position=0, Mandatory=$false)]
    [string]$Version,

    [switch]$Sync,

    [switch]$SetPrimary
)

# Load utilities
. "$(Split-Path $PSCommandPath)\lib-vault-utils.ps1"
. "$(Split-Path $PSCommandPath)\lib-vault-config.ps1"

# ═══════════════════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════

function Find-VersionByBranchOrName {
    param(
        [Parameter(Mandatory=$true)]
        [pscustomobject]$Config,

        [Parameter(Mandatory=$true)]
        [string]$VersionOrBranch
    )

    if (-not $Config) {
        return $null
    }

    # Try direct branch match first
    $version = $Config.versions | Where-Object { $_.branch -eq $VersionOrBranch } | Select-Object -First 1
    if ($version) {
        return $version
    }

    # Try directory name match
    $version = $Config.versions | Where-Object { $_.directory -eq "vault-$VersionOrBranch" } | Select-Object -First 1
    if ($version) {
        return $version
    }

    # Try short version match (R2027.1 → 2027.1, 2027)
    $shortVersion = $VersionOrBranch -replace "^R", ""
    $version = $Config.versions | Where-Object { $_.branch -match "^R$([Regex]::Escape($shortVersion))" } | Select-Object -First 1
    if ($version) {
        return $version
    }

    return $null
}

# ═══════════════════════════════════════════════════════════════════════════
# MAIN LOGIC
# ═══════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Header "Switch Vault Version (v2.0)"

# Find vault root
Write-Host "🔍 Detecting Vault root..." -ForegroundColor Cyan
$vaultRoot = Find-VaultRoot
if (-not $vaultRoot) {
    Write-Error-Custom "Cannot find Vault root (.git directory not found)"
    Write-Host "   Current location: $(Get-Location)" -ForegroundColor White
    Write-Host ""
    Write-Info "Solution:"
    Write-Host "   1. Navigate to Vault root: cd D:\Works\Vault\vault"
    Write-Host "   2. Initialize worktree: /vault-worktree:worktree-init"
    exit 1
}

if (-not (Test-VaultRoot $vaultRoot)) {
    Write-Error-Custom "Invalid Vault root (no .git directory)"
    exit 1
}

Write-Success "Found: $vaultRoot"

# Load configuration
Write-Host "📋 Loading configuration..." -ForegroundColor Cyan
$config = Get-VaultConfig
if (-not $config) {
    Write-Error-Custom "No configuration found"
    Write-Info "Initialize worktree first:"
    Write-Host "   /vault-worktree:worktree-init" -ForegroundColor Cyan
    exit 1
}

$primaryVersion = Get-PrimaryVersion -Config $config
Write-Success "Config loaded - Primary version: $($primaryVersion.branch ?? 'not set')"

# Show available versions
Write-Host ""
Write-Section "Available Versions"

$allVersions = Get-AllVersions -Config $config
if ($allVersions.Count -eq 0) {
    Write-Error-Custom "No versions configured"
    Write-Info "Initialize worktree:"
    Write-Host "   /vault-worktree:worktree-init" -ForegroundColor Cyan
    exit 1
}

foreach ($v in $allVersions) {
    $marker = if ($v.is_primary) { " [PRIMARY]" } else { "" }
    Write-Host "   $($v.branch)$marker" -ForegroundColor $(if ($v.is_primary) { "Green" } else { "White" })
}

# Determine target version
$targetVersion = $null

if (-not $Version) {
    # No version specified: use primary
    if ($primaryVersion) {
        Write-Host ""
        Write-Info "No version specified. Using PRIMARY: $($primaryVersion.branch)"
        $targetVersion = $primaryVersion
    } else {
        Write-Error-Custom "No version specified and no primary version set"
        Write-Info "Either specify version or set primary:"
        Write-Host "   /vault-worktree:switch-version $($allVersions[0].branch) --set-primary" -ForegroundColor Cyan
        exit 1
    }
} else {
    # Version specified: find it
    $targetVersion = Find-VersionByBranchOrName -Config $config -VersionOrBranch $Version
    if (-not $targetVersion) {
        Write-Error-Custom "Version ""$Version"" not found"
        Write-Info "Available versions:"
        foreach ($v in $allVersions) {
            Write-Host "   - $($v.branch)" -ForegroundColor Cyan
        }
        exit 1
    }
}

# Check for uncommitted changes in current version
$currentVersion = Get-CurrentVersion $vaultRoot
$currentVersionInfo = if ($currentVersion) { Get-VersionByBranch $currentVersion -Config $config } else { $null }
$currentVersionPath = if ($currentVersionInfo) { Join-Path $vaultRoot $currentVersionInfo.directory } else { $null }

if ($currentVersionPath -and (Test-Path $currentVersionPath) -and $currentVersionInfo.branch -ne $targetVersion.branch) {
    $hasChanges = Test-HasUncommittedChanges $currentVersionPath
    if ($hasChanges) {
        Write-Warning-Custom "Uncommitted changes in $($currentVersionInfo.directory)"
        $changeCount = Get-UncommittedChangeCount $currentVersionPath
        Write-Host "   Files modified: $changeCount" -ForegroundColor Yellow
        Write-Host ""
        Write-Info "Options:"
        Write-Host "   1. Commit: cd h: && git add . && git commit -m ""...""" -ForegroundColor Cyan
        Write-Host "   2. Stash:  cd h: && git stash" -ForegroundColor Cyan
        Write-Host "   3. Continue (changes will be preserved)" -ForegroundColor Cyan
    }
}

# Map H: drive to target version
Write-Host ""
Write-Section "Mapping H: Drive"

$targetPath = Join-Path $vaultRoot $targetVersion.directory

if (-not (Test-Path $targetPath)) {
    Write-Error-Custom "Target version directory not found: $($targetVersion.directory)"
    Write-Info "Reinitialize worktree:"
    Write-Host "   /vault-worktree:worktree-init --versions $($targetVersion.branch)" -ForegroundColor Cyan
    exit 1
}

Write-Host "Mapping H: to $($targetVersion.directory)..." -ForegroundColor Cyan
$mapSuccess = Set-HMapping $targetPath
if (-not $mapSuccess) {
    Write-Error-Custom "Failed to map H: drive"
    Write-Info "Possible causes:"
    Write-Host "   - Missing administrator privileges" -ForegroundColor White
    Write-Host "   - H: is in use by another application" -ForegroundColor White
    exit 1
}

Write-Success "H: ⇒ $($targetVersion.directory)"

# Set as primary if requested
if ($SetPrimary) {
    Write-Host ""
    Write-Section "Setting as Primary"
    Write-Host "Setting $($targetVersion.branch) as primary version..." -ForegroundColor Cyan

    if (Set-PrimaryVersion -Branch $targetVersion.branch -Config $config) {
        Write-Success "Primary version updated: $($targetVersion.branch)"
        $targetVersion.is_primary = $true
    } else {
        Write-Warning-Custom "Failed to set primary version"
    }
}

# Get status in target version
Write-Host ""
Write-Section "Version Information"

$branch = Get-CurrentBranch $targetPath
Write-Host "   Branch: $branch" -ForegroundColor Cyan

$hasUncommitted = Test-HasUncommittedChanges $targetPath
$changeCount = Get-UncommittedChangeCount $targetPath
$unpushed = Get-UnpushedCommitCount $targetPath

if ($hasUncommitted) {
    Write-Host "   Uncommitted: $changeCount file(s)" -ForegroundColor Yellow
} else {
    Write-Host "   Uncommitted: none" -ForegroundColor Green
}

if ($unpushed -gt 0) {
    Write-Host "   Unpushed commits: $unpushed" -ForegroundColor Yellow
} else {
    Write-Host "   Unpushed commits: none" -ForegroundColor Green
}

# Show primary marker
if ($targetVersion.is_primary) {
    Write-Host "   Role: PRIMARY (default version)" -ForegroundColor Green
}

# Sync if requested
if ($Sync) {
    Write-Host ""
    Write-Section "Syncing with Remote"
    Write-Host "Running: git fetch origin --prune" -ForegroundColor Cyan

    try {
        Push-Location $targetPath

        $output = git fetch origin --prune 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Sync complete"
        } else {
            Write-Warning-Custom "Sync completed with warnings"
        }

        Pop-Location
    }
    catch {
        Write-Warning-Custom "Sync error: $_"
        Pop-Location
    }
}

# Final summary
Write-Host ""
Write-Section "✅ Switch Complete"

Write-Host "   Current: $($targetVersion.branch)" -ForegroundColor Green
Write-Host "   Location: H: ⇒ $($targetVersion.directory)" -ForegroundColor Green
Write-Host "   Branch: $branch" -ForegroundColor Green

Write-Host ""
Write-Section "🎯 Next Steps"

Write-Host "   1. Switch branch:  /vault-worktree:switch-branch PDM-xxxxx" -ForegroundColor Cyan
Write-Host "   2. Check status:   /vault-worktree:status" -ForegroundColor Cyan
Write-Host "   3. Start coding:   cd h:" -ForegroundColor Cyan

if ($SetPrimary) {
    Write-Host "   4. Primary set:    $($targetVersion.branch) is now default" -ForegroundColor Green
}

Write-Host ""
