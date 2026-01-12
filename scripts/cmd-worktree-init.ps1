# Vault Worktree: Initialize Worktree Command Implementation (v2.0)
# Creates Git worktrees with branch-name based directory structure
# Usage: /vault-worktree:worktree-init [--versions R2027.1,R2027] [--primary R2027.1]

param(
    [string]$Versions = "",
    [string]$Primary = "",
    [switch]$AutoDetect = $false
)

# Load libraries
. "$(Split-Path $PSCommandPath)\lib-vault-utils.ps1"
. "$(Split-Path $PSCommandPath)\lib-vault-config.ps1"

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
        [string]$VersionOrBranch
    )

    # Direct match first
    $match = $AvailableBranches | Where-Object { $_ -eq $VersionOrBranch } | Select-Object -First 1
    if ($match) {
        return $match
    }

    # If looks like version (just number), try R<version>.x pattern
    if ($VersionOrBranch -match "^\d+$") {
        $versionPattern = "^R$([Regex]::Escape($VersionOrBranch))(\.\d+)?$"
        $match = $AvailableBranches | Where-Object { $_ -match $versionPattern } | Select-Object -First 1
        if ($match) {
            return $match
        }
    }

    return $null
}

function Clean-OldWorktrees {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VaultRoot,

        [Parameter(Mandatory=$false)]
        [string[]]$NewDirectories = @()
    )

    Write-Host "🧹 Checking for old worktree directories..." -ForegroundColor Cyan

    $oldDirs = @()
    Get-ChildItem $VaultRoot -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $name = $_.Name
        # Old pattern: vault-2025, vault-2026, vault-2027 etc.
        if ($name -match "^vault-\d+$" -and $NewDirectories -notcontains $name) {
            $oldDirs += $_
        }
    }

    if ($oldDirs.Count -gt 0) {
        Write-Warning-Custom "Found old worktree directories from v1.x:"
        foreach ($dir in $oldDirs) {
            Write-Host "  - $($dir.FullName)" -ForegroundColor Yellow
        }
        Write-Host ""
        Write-Info "These will be removed during initialization to avoid conflicts."
        Write-Host ""

        foreach ($dir in $oldDirs) {
            try {
                Write-Host "   Removing $($dir.Name)..." -ForegroundColor Gray
                # Remove git worktree entry first
                Push-Location $VaultRoot
                git worktree remove "$($dir.FullName)" --force 2>&1 | Out-Null
                Pop-Location

                # Then remove directory
                Remove-Item $dir.FullName -Recurse -Force | Out-Null
            }
            catch {
                Write-Warning-Custom "Could not remove $($dir.Name): $_"
            }
        }
        Write-Host "   ✓ Cleanup complete" -ForegroundColor Green
        Write-Host ""
    }
}

# ═══════════════════════════════════════════════════════════════════════════
# MAIN LOGIC
# ═══════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Header "Initialize Vault Worktree Structure (v2.0)"

# Find vault root
Write-Host "🔍 Detecting Vault root..." -ForegroundColor Cyan
$vaultRoot = Find-VaultRoot
if (-not $vaultRoot) {
    Write-Error-Custom "Cannot find Vault root (.git directory not found)"
    Write-Info "Solution: Navigate to Vault directory and try again"
    exit 1
}

if (-not (Test-VaultRoot $vaultRoot)) {
    Write-Error-Custom "Not a valid Git repository"
    exit 1
}

Write-Success "Found: $vaultRoot"

# Get available remote branches
Write-Host "📍 Discovering available branches..." -ForegroundColor Cyan
$remoteBranches = Get-RemoteBranches $vaultRoot

if ($remoteBranches.Count -eq 0) {
    Write-Error-Custom "Cannot find remote branches"
    Write-Info "Solutions:"
    Write-Host "   1. Add remote: git remote add origin <url>" -ForegroundColor Cyan
    Write-Host "   2. Fetch: git fetch origin" -ForegroundColor Cyan
    Write-Host "   3. Try again: /vault-worktree:worktree-init" -ForegroundColor Cyan
    exit 1
}

# Filter to version branches (R2025.x, R2026.x, R2027.1, etc.)
$versionBranches = $remoteBranches | Where-Object { $_ -match "^R\d+" }
Write-Host "   Auto-detected: $($versionBranches -join ', ')" -ForegroundColor Cyan
Write-Host "   Available: $($remoteBranches -join ', ')" -ForegroundColor Gray

# Determine target branches
$targetBranches = @()

if ($Versions) {
    # User specified branches
    $versionList = $Versions -split "," | ForEach-Object { $_.Trim() }
    Write-Host "   Requested: $($versionList -join ', ')" -ForegroundColor Cyan

    foreach ($v in $versionList) {
        $found = Find-VersionBranch $remoteBranches $v
        if ($found) {
            $targetBranches += $found
        } else {
            Write-Warning-Custom "Could not find branch for: $v"
        }
    }
} elseif ($AutoDetect) {
    $targetBranches = $versionBranches
} else {
    # Default: use all version branches
    $targetBranches = $versionBranches
}

if ($targetBranches.Count -eq 0) {
    Write-Error-Custom "No branches to initialize"
    exit 1
}

# Initialize or load configuration
Write-Host ""
Write-Section "Configuration"

$config = Get-VaultConfig -VaultRoot $vaultRoot

if (-not $config) {
    Write-Host "Creating new configuration..." -ForegroundColor Cyan
    $primaryBranch = if ($Primary) { Find-VersionBranch $targetBranches $Primary } else { $targetBranches[0] }
    $config = New-VaultConfig -VaultRoot $vaultRoot -PrimaryVersion $primaryBranch -NamingRule "branch-name"
}

Write-Host "   Config: $(Get-ConfigPath)"
Write-Host "   Naming rule: $($config.directory_naming_rule)"
Write-Host "   Primary version: $($config.primary_version ?? 'will set to first')"

# Generate directory names based on naming rule
$newDirectories = @()
$versionMap = @()

foreach ($branch in $targetBranches) {
    $existingVersion = Get-VersionByBranch $branch -Config $config

    if ($existingVersion) {
        $directory = $existingVersion.directory
    } else {
        # Generate new directory name
        if ($config.directory_naming_rule -eq "version-only") {
            $version = $branch -replace "^R(\d+).*$", '$1'
            $directory = "vault-$version"
        } else {
            # branch-name rule: vault-R2027.1
            $directory = "vault-$branch"
        }
    }

    $newDirectories += $directory
    $versionMap += @{
        branch    = $branch
        directory = $directory
        path      = Join-Path $vaultRoot $directory
    }
}

# Clean old worktrees
Clean-OldWorktrees -VaultRoot $vaultRoot -NewDirectories $newDirectories

# Create worktrees
Write-Host ""
Write-Section "Creating Worktrees"

$createdCount = 0
$skippedCount = 0
$failedCount = 0
$createdVersions = @()

foreach ($mapping in $versionMap) {
    $branch = $mapping.branch
    $directory = $mapping.directory
    $path = $mapping.path

    # Check if worktree already exists
    if (Test-Path $path -PathType Container) {
        Write-Warning-Custom "$directory already exists (skipped)"
        $skippedCount++
        continue
    }

    Write-Host "🔧 Creating $directory (based on origin/$branch)..." -ForegroundColor Cyan

    try {
        Push-Location $vaultRoot

        $startTime = Get-Date
        git worktree add $path "origin/$branch" 2>&1 | Out-Null

        if ($LASTEXITCODE -eq 0) {
            $elapsed = (Get-Date) - $startTime
            Write-Success "$directory created [$('{0:mm}:{0:ss}' -f $elapsed)]"
            $createdCount++
            $createdVersions += @{
                branch    = $branch
                directory = $directory
            }
        } else {
            Write-Error-Custom "Failed to create $directory"
            $failedCount++
        }

        Pop-Location
    }
    catch {
        Write-Error-Custom "Error creating $directory : $_"
        Pop-Location
        $failedCount++
    }
}

# Update configuration with created versions
$config = Get-VaultConfig
foreach ($created in $createdVersions) {
    $isPrimary = ($Primary -and (Find-VersionBranch @($created.branch) $Primary) -eq $created.branch) -or
                 ($createdVersions[0].branch -eq $created.branch -and -not $config.primary_version)
    Add-VersionToConfig -Branch $created.branch -Directory $created.directory -IsPrimary $isPrimary -Config $config
}

# If primary not set yet, set first created
$config = Get-VaultConfig
if ($createdVersions.Count -gt 0 -and -not $config.primary_version) {
    Set-PrimaryVersion -Branch $createdVersions[0].branch
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

$allVersions = Get-AllVersions
foreach ($v in $allVersions) {
    $versionPath = Join-Path $vaultRoot $v.directory
    if (Test-Path $versionPath) {
        $size = Get-DirectorySize $versionPath
        $sizeStr = if ($size -gt 1024) {
            "$([Math]::Round($size / 1024, 1))GB"
        } else {
            "${size}MB"
        }

        $primaryMarker = if ($v.is_primary) { " [PRIMARY]" } else { "" }
        Write-Host "   $($v.directory)$primaryMarker ($sizeStr)" -ForegroundColor Green
    }
}

$gitSize = Get-DirectorySize (Join-Path $vaultRoot ".git")
$gitSizeStr = if ($gitSize -gt 1024) {
    "$([Math]::Round($gitSize / 1024, 1))GB"
} else {
    "${gitSize}MB"
}

Write-Host "   .git (shared) ($gitSizeStr)" -ForegroundColor Gray

# Show configuration status
Write-Host ""
Show-ConfigStatus

# Next steps
Write-Host ""
Write-Section "🎯 Next Steps"
$firstPrimary = $allVersions | Where-Object { $_.is_primary } | Select-Object -First 1
if ($firstPrimary) {
    Write-Host "   1. /vault-worktree:switch-version $($firstPrimary.branch)" -ForegroundColor Cyan
} else {
    Write-Host "   1. /vault-worktree:switch-version R2027.1" -ForegroundColor Cyan
}
Write-Host "   2. /vault-worktree:switch-branch PDM-xxxxx" -ForegroundColor Cyan
Write-Host "   3. Start developing!" -ForegroundColor Cyan

Write-Host ""
Write-Info "Tip: Use /vault-worktree:status to verify setup" -ForegroundColor Cyan
Write-Host ""
