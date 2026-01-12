# PreToolUse Hook: Validate version match for file modifications
# Purpose: Prevent cross-version file modifications
# This script warns if you're modifying a file in one version while H: is mapped to another

param(
    [string]$FilePath = $null
)

try {
    # If no file path provided, exit silently
    if (-not $FilePath) {
        exit 0
    }

    # Get current H: drive mapping
    $hDriveMapping = subst h: 2>$null | Select-String "h:" | ForEach-Object {
        $_.ToString().Split()[-1]
    }

    if (-not $hDriveMapping) {
        # H: not mapped yet, not a problem
        exit 0
    }

    # Determine file's version from its path
    $fileVersion = $null

    # Check if file is in vault-2025, vault-2026, vault-2027 directory
    if ($FilePath -match '\\vault-(\d{4}(?:\.\d)?)[\\\/]') {
        $fileVersion = $matches[1]
    }
    elseif ($FilePath -match '\\vault-([a-z0-9.]+)[\\\/]') {
        $fileVersion = $matches[1]
    }

    if (-not $fileVersion) {
        # File is not in any vault version directory
        exit 0
    }

    # Get current H: mapping version
    $mappedVersion = $null
    if ($hDriveMapping -match '\\vault-(\d{4}(?:\.\d)?)\s*$') {
        $mappedVersion = $matches[1]
    }
    elseif ($hDriveMapping -match '\\vault-([a-z0-9.]+)\s*$') {
        $mappedVersion = $matches[1]
    }

    if (-not $mappedVersion) {
        # Couldn't determine mapped version
        exit 0
    }

    # Compare versions
    if ($fileVersion -ne $mappedVersion) {
        Write-Host ""
        Write-Host "⚠️  VERSION MISMATCH DETECTED" -ForegroundColor Yellow
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
        Write-Host "File belongs to: vault-$fileVersion" -ForegroundColor Cyan
        Write-Host "H: drive mapped to: vault-$mappedVersion" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "This file modification may cause conflicts!" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "💡 Suggested actions:" -ForegroundColor Green
        Write-Host "   1. Switch to correct version: /vault-worktree:switch-version $fileVersion" -ForegroundColor Green
        Write-Host "   2. Or verify this is intentional cross-version change" -ForegroundColor Green
        Write-Host ""

        # Warn but allow (onFailure: warn in hooks.json)
        exit 1
    }

    # Versions match, all good
    exit 0
}
catch {
    # On any error, silently allow the operation
    Write-Error $_.Exception.Message -ErrorAction SilentlyContinue
    exit 0
}
