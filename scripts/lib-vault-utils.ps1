# Vault Worktree Utilities Library
# Shared functions for all vault-worktree commands
# Version: 0.1.0

# Colors for output
$Colors = @{
    Success = "Green"
    Warning = "Yellow"
    Error   = "Red"
    Info    = "Cyan"
    Default = "White"
}

# ═══════════════════════════════════════════════════════════════════════════
# CORE VAULT DETECTION
# ═══════════════════════════════════════════════════════════════════════════

<#
.SYNOPSIS
Finds the Vault root directory by traversing up until .git/ is found
.DESCRIPTION
Starts from current directory and traverses up the directory tree until it finds a .git/ subdirectory
.RETURNS
Full path to Vault root directory, or $null if not found
#>
function Find-VaultRoot {
    param(
        [string]$StartPath = (Get-Location).Path
    )

    $current = $StartPath
    $maxDepth = 10  # Prevent infinite loops
    $depth = 0

    while ($depth -lt $maxDepth) {
        $gitPath = Join-Path $current ".git"
        if (Test-Path $gitPath) {
            return $current
        }

        $parent = Split-Path $current -Parent
        if ($parent -eq $current) {
            # Reached filesystem root
            return $null
        }

        $current = $parent
        $depth++
    }

    return $null
}

<#
.SYNOPSIS
Gets the current H: drive mapping
.RETURNS
Path that H: is mapped to, or $null if not mapped
#>
function Get-HMapping {
    try {
        $substOutput = subst | Select-String "^H:" | Out-String
        if ($substOutput) {
            # Output format: "H: => D:\Works\Vault\vault-2027"
            $path = $substOutput -replace "^H:\s+=>\s+", "" -replace "\s+$", ""
            return $path
        }
    }
    catch {
        # Silent failure
    }
    return $null
}

<#
.SYNOPSIS
Sets the H: drive mapping to a specific directory
.PARAMETER Path
Full path to map H: drive to
#>
function Set-HMapping {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    try {
        # Remove existing H: mapping
        subst h: /d 2>$null | Out-Null
        Start-Sleep -Milliseconds 100

        # Create new mapping
        subst h: $Path

        if ($LASTEXITCODE -eq 0) {
            return $true
        }
        else {
            Write-Host "❌ Failed to map H: drive (exit code: $LASTEXITCODE)" -ForegroundColor $Colors.Error
            return $false
        }
    }
    catch {
        Write-Host "❌ Error mapping H: drive: $_" -ForegroundColor $Colors.Error
        return $false
    }
}

# ═══════════════════════════════════════════════════════════════════════════
# VERSION DETECTION
# ═══════════════════════════════════════════════════════════════════════════

<#
.SYNOPSIS
Gets all available Vault versions (vault-2025, vault-2026, vault-2027, etc.)
.PARAMETER VaultRoot
Path to Vault root directory
.RETURNS
Array of version names (2025, 2026, 2027, etc.)
#>
function Get-AvailableVersions {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VaultRoot
    )

    $versions = @()

    try {
        $versionDirs = Get-ChildItem -Path $VaultRoot -Directory -Filter "vault-*" -ErrorAction SilentlyContinue
        foreach ($dir in $versionDirs) {
            # Extract version from vault-2027 -> 2027
            $version = $dir.Name -replace "^vault-", ""
            $versions += $version
        }
    }
    catch {
        # Return empty array on error
    }

    return $versions | Sort-Object
}

<#
.SYNOPSIS
Gets the current version from H: mapping
.PARAMETER VaultRoot
Path to Vault root directory
.RETURNS
Version string (2027, 2026.x, etc.) or $null if not mapped or invalid
#>
function Get-CurrentVersion {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VaultRoot
    )

    $hMapping = Get-HMapping
    if (-not $hMapping) {
        return $null
    }

    # Extract version: D:\Works\Vault\vault-2027 -> 2027
    if ($hMapping -match "vault-(\d+[.\w]*)$") {
        return $Matches[1]
    }

    return $null
}

<#
.SYNOPSIS
Validates that a version exists
.PARAMETER VaultRoot
Path to Vault root
.PARAMETER Version
Version string to validate (2025, 2026, 2027.1, etc.)
.RETURNS
$true if version exists, $false otherwise
#>
function Test-Version {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VaultRoot,

        [Parameter(Mandatory=$true)]
        [string]$Version
    )

    $versionDir = Join-Path $VaultRoot "vault-$Version"
    return (Test-Path $versionDir -PathType Container)
}

# ═══════════════════════════════════════════════════════════════════════════
# GIT OPERATIONS
# ═══════════════════════════════════════════════════════════════════════════

<#
.SYNOPSIS
Gets the current Git branch for a version
.PARAMETER VersionPath
Full path to version directory
.RETURNS
Branch name string, or $null if not found/error
#>
function Get-CurrentBranch {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VersionPath
    )

    try {
        Push-Location $VersionPath
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
        Pop-Location
        return $branch
    }
    catch {
        Pop-Location
        return $null
    }
}

<#
.SYNOPSIS
Gets list of branches in a repository
.PARAMETER VersionPath
Full path to version directory
.RETURNS
Array of branch names
#>
function Get-Branches {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VersionPath
    )

    try {
        Push-Location $VersionPath
        $branches = @()

        # Get all branches (local and remote)
        $gitOutput = git branch -a 2>$null
        foreach ($line in $gitOutput) {
            $branch = $line -replace "^\s*[*]?\s+", "" -replace "\s+->.*$", ""
            if ($branch -and $branch -notmatch "^HEAD") {
                $branches += $branch
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

<#
.SYNOPSIS
Checks if repository has uncommitted changes
.PARAMETER VersionPath
Full path to version directory
.RETURNS
$true if has changes, $false otherwise
#>
function Test-HasUncommittedChanges {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VersionPath
    )

    try {
        Push-Location $VersionPath
        $status = git status --porcelain 2>$null
        Pop-Location

        return -not [string]::IsNullOrWhiteSpace($status)
    }
    catch {
        Pop-Location
        return $false
    }
}

<#
.SYNOPSIS
Gets count of uncommitted changes
.PARAMETER VersionPath
Full path to version directory
.RETURNS
Count of modified/untracked files
#>
function Get-UncommittedChangeCount {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VersionPath
    )

    try {
        Push-Location $VersionPath
        $status = git status --porcelain 2>$null
        Pop-Location

        return $status.Count
    }
    catch {
        Pop-Location
        return 0
    }
}

<#
.SYNOPSIS
Gets count of unpushed commits
.PARAMETER VersionPath
Full path to version directory
.RETURNS
Count of commits ahead of remote
#>
function Get-UnpushedCommitCount {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VersionPath
    )

    try {
        Push-Location $VersionPath

        # Get current branch
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
        if (-not $branch) {
            Pop-Location
            return 0
        }

        # Count commits ahead of origin
        $output = git rev-list --count @{upstream}...HEAD 2>$null
        $count = [int]$output

        Pop-Location
        return $count
    }
    catch {
        Pop-Location
        return 0
    }
}

<#
.SYNOPSIS
Gets Git status summary
.PARAMETER VersionPath
Full path to version directory
.RETURNS
Hashtable with status information
#>
function Get-GitStatus {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VersionPath
    )

    try {
        Push-Location $VersionPath

        $status = @{
            Branch = (git rev-parse --abbrev-ref HEAD 2>$null)
            HasChanges = $false
            ChangeCount = 0
            UnpushedCount = 0
            LastCommit = ""
        }

        # Get uncommitted changes
        $changes = git status --porcelain 2>$null
        if ($changes) {
            $status.HasChanges = $true
            $status.ChangeCount = $changes.Count
        }

        # Get unpushed commits
        $branch = $status.Branch
        if ($branch) {
            $unpushed = git rev-list --count @{upstream}...HEAD 2>$null
            if ($unpushed -and $unpushed -gt 0) {
                $status.UnpushedCount = [int]$unpushed
            }
        }

        # Get last commit
        $lastCommit = git log -1 --format="%h - %s (%cr)" 2>$null
        if ($lastCommit) {
            $status.LastCommit = $lastCommit
        }

        Pop-Location
        return $status
    }
    catch {
        Pop-Location
        return @{ Branch = ""; HasChanges = $false; ChangeCount = 0; UnpushedCount = 0 }
    }
}

# ═══════════════════════════════════════════════════════════════════════════
# OUTPUT FORMATTING
# ═══════════════════════════════════════════════════════════════════════════

<#
.SYNOPSIS
Prints a formatted header
.PARAMETER Title
Header title text
#>
function Write-Header {
    param([string]$Title)
    Write-Host "`n🔍 $Title" -ForegroundColor $Colors.Info
    Write-Host ("=" * 50)
}

<#
.SYNOPSIS
Prints a formatted section
.PARAMETER Title
Section title
#>
function Write-Section {
    param([string]$Title)
    Write-Host "`n📍 $Title" -ForegroundColor $Colors.Info
}

<#
.SYNOPSIS
Prints a success message
#>
function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor $Colors.Success
}

<#
.SYNOPSIS
Prints a warning message
#>
function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor $Colors.Warning
}

<#
.SYNOPSIS
Prints an error message
#>
function Write-Error-Custom {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor $Colors.Error
}

<#
.SYNOPSIS
Prints an info message
#>
function Write-Info {
    param([string]$Message)
    Write-Host "💡 $Message" -ForegroundColor $Colors.Default
}

# ═══════════════════════════════════════════════════════════════════════════
# VALIDATION
# ═══════════════════════════════════════════════════════════════════════════

<#
.SYNOPSIS
Validates vault root and returns error if invalid
.PARAMETER VaultRoot
Path to validate as vault root
.RETURNS
$true if valid (has .git), $false otherwise
#>
function Test-VaultRoot {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VaultRoot
    )

    $gitPath = Join-Path $VaultRoot ".git"
    return (Test-Path $gitPath -PathType Container)
}

# ═══════════════════════════════════════════════════════════════════════════
# DIRECTORY OPERATIONS
# ═══════════════════════════════════════════════════════════════════════════

<#
.SYNOPSIS
Gets directory size in MB
.PARAMETER Path
Path to directory
.RETURNS
Size in MB, or 0 if not found
#>
function Get-DirectorySize {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    try {
        if (-not (Test-Path $Path)) {
            return 0
        }

        $size = Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue |
                Measure-Object -Property Length -Sum |
                Select-Object -ExpandProperty Sum

        return [int]($size / 1MB)
    }
    catch {
        return 0
    }
}

<#
.SYNOPSIS
Gets free disk space on a drive
.PARAMETER Path
Path on the drive
.RETURNS
Free space in GB, or 0 if error
#>
function Get-FreeSpace {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    try {
        $drive = (Get-Item $Path).PSDrive.Name
        $freeSpace = Get-PSDrive $drive | Select-Object -ExpandProperty Free
        return [int]($freeSpace / 1GB)
    }
    catch {
        return 0
    }
}

# Export functions for use in commands
Export-ModuleMember -Function *
