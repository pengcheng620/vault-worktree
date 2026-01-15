# Vault Worktree: Diagnose Command Implementation
# Complete environment diagnostics for troubleshooting
# Usage: /vault-worktree:diagnose [--verbose]

param(
    [switch]$Verbose
)

# Load utilities
. "$(Split-Path $PSCommandPath)\lib-vault-utils.ps1"

# ═══════════════════════════════════════════════════════════════════════════
# MAIN LOGIC
# ═══════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Header "Vault Environment Diagnostics"

# ═══════════════════════════════════════════════════════════════════════════
# SYSTEM INFORMATION
# ═══════════════════════════════════════════════════════════════════════════

Write-Section "System Environment"

# Windows version
try {
    $osInfo = Get-WmiObject Win32_OperatingSystem -ErrorAction SilentlyContinue
    $windowsVersion = if ($osInfo) {
        "$($osInfo.Caption) (Build $($osInfo.BuildNumber))"
    } else {
        "Windows (version unknown)"
    }
    Write-Host "   Windows: $windowsVersion" -ForegroundColor White
}
catch {
    Write-Host "   Windows: (unable to detect)" -ForegroundColor Gray
}

# PowerShell version
$psVersion = "$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor).$($PSVersionTable.PSVersion.Patch)"
Write-Host "   PowerShell: $psVersion" -ForegroundColor White

# Git version
try {
    $gitVersion = git --version 2>$null
    Write-Host "   Git: $gitVersion" -ForegroundColor White
}
catch {
    Write-Warning-Custom "Git not found in PATH"
}

# ═══════════════════════════════════════════════════════════════════════════
# VAULT ROOT DETECTION
# ═══════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Section "Vault Root Detection"

$vaultRoot = Find-VaultRoot
if ($vaultRoot) {
    Write-Host "   Root: $vaultRoot" -ForegroundColor Green

    $gitPath = Join-Path $vaultRoot ".git"
    if (Test-Path $gitPath -PathType Container) {
        Write-Success "Git repository valid"
    } else {
        Write-Error-Custom "Git repository not found!"
    }
} else {
    Write-Error-Custom "Vault root not found"
    Write-Host "   (No .git directory detected in parent hierarchy)" -ForegroundColor White
    Write-Host ""
    exit 1
}

# ═══════════════════════════════════════════════════════════════════════════
# WORKTREE STRUCTURE
# ═══════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Section "Worktree Structure"

$versions = Get-AvailableVersions $vaultRoot
$totalSize = 0

foreach ($version in $versions) {
    $versionPath = Join-Path $vaultRoot "vault-$version"
    $size = Get-DirectorySize $versionPath

    $statusIcon = "✓"
    if (-not (Test-Path $versionPath -PathType Container)) {
        $statusIcon = "❌"
    }

    $sizeStr = if ($size -gt 1024) {
        "$([Math]::Round($size / 1024, 1))GB"
    } else {
        "${size}MB"
    }

    $currentVersion = Get-CurrentVersion $vaultRoot
    if ($version -eq $currentVersion) {
        Write-Host "   $statusIcon vault-$version ($sizeStr) [CURRENT]" -ForegroundColor Green
    } else {
        Write-Host "   $statusIcon vault-$version ($sizeStr)" -ForegroundColor White
    }

    $totalSize += $size
}

if ($versions.Count -eq 0) {
    Write-Warning-Custom "No Vault versions found"
    Write-Host ""
    Write-Info "To initialize versions, run:"
    Write-Host "   /vault-worktree:worktree-init" -ForegroundColor Cyan
}

# Git database size
$gitSize = Get-DirectorySize (Join-Path $vaultRoot ".git")
$gitSizeStr = if ($gitSize -gt 1024) {
    "$([Math]::Round($gitSize / 1024, 1))GB"
} else {
    "${gitSize}MB"
}

Write-Host "   .git (shared): $gitSizeStr" -ForegroundColor Gray

# Total and free space
$totalSizeStr = if ($totalSize -gt 1024) {
    "$([Math]::Round($totalSize / 1024, 1))GB"
} else {
    "${totalSize}MB"
}

Write-Host "   Total Size: $totalSizeStr" -ForegroundColor White

$freeSpace = Get-FreeSpace $vaultRoot
Write-Host "   Free Space: ${freeSpace}GB" -ForegroundColor White

if ($freeSpace -lt 5) {
    Write-Warning-Custom "Low disk space (less than 5GB free)"
}

# ═══════════════════════════════════════════════════════════════════════════
# CURRENT MAPPING
# ═══════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Section "Current H: Mapping"

$hMapping = Get-HMapping
if ($hMapping) {
    Write-Host "   H: → $hMapping" -ForegroundColor Green

    $currentVersion = Get-CurrentVersion $vaultRoot
    if ($currentVersion) {
        $currentVersionPath = Join-Path $vaultRoot "vault-$currentVersion"
        $branch = Get-CurrentBranch $currentVersionPath
        Write-Host "   Version: $currentVersion" -ForegroundColor White
        if ($branch) {
            Write-Host "   Branch: $branch" -ForegroundColor Cyan
        }

        $hasUncommitted = Test-HasUncommittedChanges $currentVersionPath
        if ($hasUncommitted) {
            $changeCount = Get-UncommittedChangeCount $currentVersionPath
            Write-Warning-Custom "Has uncommitted changes ($changeCount file(s))"
        } else {
            Write-Success "Working directory clean"
        }
    }
} else {
    Write-Warning-Custom "H: drive not mapped"
    Write-Host ""
    Write-Info "To map H: drive:"
    Write-Host "   /vault-worktree:switch-version 2027" -ForegroundColor Cyan
}

# ═══════════════════════════════════════════════════════════════════════════
# BUILD STATUS (if verbose)
# ═══════════════════════════════════════════════════════════════════════════

if ($Verbose -and $hMapping) {
    Write-Host ""
    Write-Section "Build Directories"

    $directories = @("bin", "obj", "packages")
    foreach ($dir in $directories) {
        $dirPath = Join-Path $hMapping $dir
        $size = Get-DirectorySize $dirPath

        $sizeStr = if ($size -gt 1024) {
            "$([Math]::Round($size / 1024, 1))GB"
        } else {
            "${size}MB"
        }

        Write-Host "   $dir/: $sizeStr" -ForegroundColor White

        if ($dir -eq "packages" -and $size -gt 10240) {
            Write-Warning-Custom "packages/ is large (may slow compilation)"
        }
    }
}

# ═══════════════════════════════════════════════════════════════════════════
# DETAILED BRANCH INFO (if verbose)
# ═══════════════════════════════════════════════════════════════════════════

if ($Verbose) {
    Write-Host ""
    Write-Section "Branch Information"

    foreach ($version in $versions) {
        $versionPath = Join-Path $vaultRoot "vault-$version"
        $branch = Get-CurrentBranch $versionPath
        $allBranches = Get-Branches $versionPath

        Write-Host "   vault-$version:" -ForegroundColor Cyan
        Write-Host "      Current: $branch" -ForegroundColor White

        # Show uncommitted status
        $hasUncommitted = Test-HasUncommittedChanges $versionPath
        if ($hasUncommitted) {
            $changeCount = Get-UncommittedChangeCount $versionPath
            Write-Host "      Uncommitted: $changeCount file(s)" -ForegroundColor Yellow
        }

        # Show unpushed count
        $unpushedCount = Get-UnpushedCommitCount $versionPath
        if ($unpushedCount -gt 0) {
            Write-Host "      Unpushed: $unpushedCount commit(s)" -ForegroundColor Yellow
        }

        Write-Host "      Total branches: $($allBranches.Count)" -ForegroundColor Gray
    }
}

# ═══════════════════════════════════════════════════════════════════════════
# GIT CONFIG (if verbose)
# ═══════════════════════════════════════════════════════════════════════════

if ($Verbose -and $vaultRoot) {
    Write-Host ""
    Write-Section "Git Configuration"

    try {
        Push-Location $vaultRoot

        $userName = git config user.name 2>$null
        $userEmail = git config user.email 2>$null
        $autoCrlf = git config core.autocrlf 2>$null
        $ignoreCase = git config core.ignorecase 2>$null

        Write-Host "   user.name: $userName" -ForegroundColor White
        Write-Host "   user.email: $userEmail" -ForegroundColor White
        Write-Host "   core.autocrlf: $autoCrlf" -ForegroundColor White
        Write-Host "   core.ignorecase: $ignoreCase" -ForegroundColor White

        Pop-Location
    }
    catch {
        Pop-Location
        Write-Host "   (unable to read git config)" -ForegroundColor Gray
    }
}

# ═══════════════════════════════════════════════════════════════════════════
# OVERALL STATUS
# ═══════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Section "Overall Status"

$issues = @()

if (-not $hMapping) {
    $issues += "H: drive not mapped"
}

if ($versions.Count -eq 0) {
    $issues += "No Vault versions initialized"
}

if ($freeSpace -lt 5) {
    $issues += "Low disk space"
}

if ($issues.Count -eq 0) {
    Write-Success "All systems operational ✓"
    Write-Host "   → Ready to work!" -ForegroundColor Green
} else {
    Write-Warning-Custom "Issues detected:"
    foreach ($issue in $issues) {
        Write-Host "   ⚠️  $issue" -ForegroundColor Yellow
    }
}

Write-Host ""

if ($Verbose) {
    Write-Host "💡 Tip: Share this output with tech support for troubleshooting" -ForegroundColor Cyan
}

Write-Host ""
