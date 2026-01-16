# Vault Worktree: Configuration Management Library
# Handles reading and writing vault-worktree.config.json
# Located in: ~/.claude/vault-worktree.config.json

$script:CONFIG_FILE = "$env:USERPROFILE\.claude\vault-worktree.config.json"
$script:CONFIG_VERSION = "2.0.0"

# ═══════════════════════════════════════════════════════════════════════════
# PRIVATE: Configuration I/O
# ═══════════════════════════════════════════════════════════════════════════

function Initialize-ConfigFile {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VaultRoot
    )

    # Create .claude directory if not exists
    $claudeDir = "$env:USERPROFILE\.claude"
    if (-not (Test-Path $claudeDir)) {
        New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
    }

    # Default configuration
    $defaultConfig = @{
        version              = $script:CONFIG_VERSION
        created_date         = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
        last_modified        = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
        vault_root           = $VaultRoot
        primary_version      = $null
        primary_directory    = "vault"
        directory_naming_rule = "branch-name"  # branch-name | version-only
        versions             = @()
    }

    $defaultConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $script:CONFIG_FILE -Force
    return $defaultConfig
}

function Read-ConfigFile {
    if (-not (Test-Path $script:CONFIG_FILE)) {
        return $null
    }

    try {
        $json = Get-Content -Path $script:CONFIG_FILE -Raw | ConvertFrom-Json
        return $json
    }
    catch {
        Write-Warning "Failed to read config file: $_"
        return $null
    }
}

function Write-ConfigFile {
    param(
        [Parameter(Mandatory=$true)]
        [pscustomobject]$Config
    )

    # Update last_modified timestamp
    $Config.last_modified = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

    # Ensure .claude directory exists
    $claudeDir = "$env:USERPROFILE\.claude"
    if (-not (Test-Path $claudeDir)) {
        New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
    }

    try {
        $Config | ConvertTo-Json -Depth 10 | Set-Content -Path $script:CONFIG_FILE -Force
        return $true
    }
    catch {
        Write-Warning "Failed to write config file: $_"
        return $false
    }
}

# ═══════════════════════════════════════════════════════════════════════════
# PUBLIC: Configuration Operations
# ═══════════════════════════════════════════════════════════════════════════

function Get-VaultConfig {
    param(
        [Parameter(Mandatory=$false)]
        [string]$VaultRoot = $null
    )

    $config = Read-ConfigFile
    
    if (-not $config) {
        if (-not $VaultRoot) {
            return $null
        }
        # Initialize new config if not exists
        $config = Initialize-ConfigFile $VaultRoot
    }

    return $config
}

function New-VaultConfig {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VaultRoot,

        [Parameter(Mandatory=$false)]
        [string]$PrimaryVersion = $null,

        [Parameter(Mandatory=$false)]
        [string]$NamingRule = "branch-name"
    )

    $config = @{
        version              = $script:CONFIG_VERSION
        created_date         = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
        last_modified        = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
        vault_root           = $VaultRoot
        primary_version      = $PrimaryVersion
        primary_directory    = "vault"
        directory_naming_rule = $NamingRule
        versions             = @()
    } | ConvertTo-Json -Depth 10 -AsHashtable

    if (Write-ConfigFile $config) {
        return $config
    }
    return $null
}

function Add-VersionToConfig {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Branch,

        [Parameter(Mandatory=$false)]
        [string]$Directory = $null,

        [Parameter(Mandatory=$false)]
        [bool]$IsPrimary = $false,

        [Parameter(Mandatory=$false)]
        [pscustomobject]$Config = $null
    )

    if (-not $Config) {
        $Config = Get-VaultConfig
    }

    if (-not $Config) {
        return $false
    }

    # Generate directory name if not provided
    if (-not $Directory) {
        if ($Config.directory_naming_rule -eq "version-only") {
            # Extract version number from branch (R2027.1 → 2027)
            $version = $Branch -replace "^R(\d+).*$", '$1'
            $Directory = "vault-$version"
        } else {
            # Use full branch name (R2027.1 → vault-R2027.1)
            $Directory = "vault-$Branch"
        }
    }

    # Check if version already exists
    $existing = $Config.versions | Where-Object { $_.branch -eq $Branch }
    if ($existing) {
        return $false  # Already exists
    }

    # If this is primary, unset others
    if ($IsPrimary) {
        $Config.versions | ForEach-Object { $_.is_primary = $false }
        $Config.primary_version = $Branch
    }

    $newVersion = @{
        branch      = $Branch
        directory   = $Directory
        is_primary  = $IsPrimary
        added_date  = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    } | ConvertTo-Json -Depth 10 -AsHashtable

    $Config.versions += $newVersion

    return (Write-ConfigFile $Config)
}

function Get-VersionByBranch {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Branch,

        [Parameter(Mandatory=$false)]
        [pscustomobject]$Config = $null
    )

    if (-not $Config) {
        $Config = Get-VaultConfig
    }

    if (-not $Config) {
        return $null
    }

    return $Config.versions | Where-Object { $_.branch -eq $Branch } | Select-Object -First 1
}

function Get-PrimaryVersion {
    param(
        [Parameter(Mandatory=$false)]
        [pscustomobject]$Config = $null
    )

    if (-not $Config) {
        $Config = Get-VaultConfig
    }

    if (-not $Config) {
        return $null
    }

    # First check explicit primary_version
    if ($Config.primary_version) {
        return Get-VersionByBranch $Config.primary_version -Config $Config
    }

    # Otherwise return first marked as primary
    return $Config.versions | Where-Object { $_.is_primary -eq $true } | Select-Object -First 1
}

function Get-AllVersions {
    param(
        [Parameter(Mandatory=$false)]
        [pscustomobject]$Config = $null
    )

    if (-not $Config) {
        $Config = Get-VaultConfig
    }

    if (-not $Config) {
        return @()
    }

    return @($Config.versions)
}

function Set-PrimaryVersion {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Branch,

        [Parameter(Mandatory=$false)]
        [pscustomobject]$Config = $null
    )

    if (-not $Config) {
        $Config = Get-VaultConfig
    }

    if (-not $Config) {
        return $false
    }

    # Verify branch exists
    $version = Get-VersionByBranch $Branch -Config $Config
    if (-not $version) {
        return $false
    }

    # Unset all primaries
    $Config.versions | ForEach-Object { $_.is_primary = $false }

    # Set this one as primary
    ($Config.versions | Where-Object { $_.branch -eq $Branch })[0].is_primary = $true
    $Config.primary_version = $Branch

    return (Write-ConfigFile $Config)
}

# ═══════════════════════════════════════════════════════════════════════════
# PUBLIC: Diagnostic Functions
# ═══════════════════════════════════════════════════════════════════════════

function Show-ConfigStatus {
    param(
        [Parameter(Mandatory=$false)]
        [pscustomobject]$Config = $null
    )

    if (-not $Config) {
        $Config = Get-VaultConfig
    }

    if (-not $Config) {
        Write-Host "⚠️  No configuration found at $script:CONFIG_FILE" -ForegroundColor Yellow
        return
    }

    Write-Host ""
    Write-Host "📋 Vault Worktree Configuration" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════" -ForegroundColor Gray
    Write-Host "Config file: $script:CONFIG_FILE"
    Write-Host "Version: $($Config.version)"
    Write-Host "Created: $($Config.created_date)"
    Write-Host "Modified: $($Config.last_modified)"
    Write-Host ""
    Write-Host "Vault Root: $($Config.vault_root)"
    Write-Host "Naming Rule: $($Config.directory_naming_rule)"
    Write-Host "Primary Version: $($Config.primary_version ?? 'Not set')"
    Write-Host ""
    Write-Host "Configured Versions:" -ForegroundColor Cyan
    foreach ($v in $Config.versions) {
        $primary = if ($v.is_primary) { " [PRIMARY]" } else { "" }
        Write-Host "  - Branch: $($v.branch)$primary"
        Write-Host "    Directory: $($v.directory)"
        Write-Host "    Added: $($v.added_date)"
    }
    Write-Host ""
}

function Get-ConfigPath {
    return $script:CONFIG_FILE
}