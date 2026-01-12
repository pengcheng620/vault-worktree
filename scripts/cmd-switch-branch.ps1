# Vault Worktree: Switch Branch Command Implementation
# Switches to a different Git branch within current version
# Usage: /vault-worktree:switch-branch PDM-49690 [--pull]

param(
    [Parameter(Position=0, Mandatory=$true)]
    [string]$BranchName,

    [switch]$Pull
)

# Load utilities
. "$(Split-Path $PSCommandPath)\lib-vault-utils.ps1"

# ═══════════════════════════════════════════════════════════════════════════
# MAIN LOGIC
# ═══════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Header "Switching Git Branch"

# Find vault root
$vaultRoot = Find-VaultRoot
if (-not $vaultRoot) {
    Write-Error-Custom "Cannot find Vault root (.git directory not found)"
    Write-Info "Solution: Navigate to Vault directory and try again"
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

# Get all available branches
Write-Host "🔍 Detecting available branches..." -ForegroundColor Cyan
$allBranches = Get-Branches $currentVersionPath

if ($allBranches.Count -eq 0) {
    Write-Error-Custom "No branches found in vault-$currentVersion"
    exit 1
}

# Find matching branch (support both short and full names)
# Priority: exact match > lpc/ prefix match
$targetBranch = $null

# Check for exact match first
$exactMatch = $allBranches | Where-Object { $_ -eq $BranchName }
if ($exactMatch) {
    $targetBranch = $exactMatch
}

# If no exact match, try lpc/ prefix
if (-not $targetBranch) {
    $prefixMatches = $allBranches | Where-Object { $_ -like "lpc/$BranchName*" }
    if ($prefixMatches) {
        if ($prefixMatches -is [array]) {
            $targetBranch = $prefixMatches[0]  # Take first if multiple matches
            Write-Host "   Found multiple matches, using: $targetBranch" -ForegroundColor Yellow
        } else {
            $targetBranch = $prefixMatches
        }
    }
}

# If still no match, try substring match (for PDM-XXXXX style)
if (-not $targetBranch) {
    $substringMatches = $allBranches | Where-Object { $_ -like "*$BranchName*" }
    if ($substringMatches) {
        if ($substringMatches -is [array]) {
            $targetBranch = $substringMatches[0]
            Write-Host "   Found substring match: $targetBranch" -ForegroundColor Yellow
        } else {
            $targetBranch = $substringMatches
        }
    }
}

# Branch not found
if (-not $targetBranch) {
    Write-Error-Custom "Branch ""$BranchName"" not found"
    Write-Host ""
    Write-Host "Available branches:" -ForegroundColor White
    foreach ($branch in $allBranches | Select-Object -First 10) {
        if ($branch -like "lpc/*") {
            Write-Host "   - $branch" -ForegroundColor Cyan
        } elseif ($branch -like "remotes/origin/*") {
            Write-Host "   - $branch" -ForegroundColor Gray
        } else {
            Write-Host "   - $branch" -ForegroundColor White
        }
    }

    if ($allBranches.Count -gt 10) {
        Write-Host "   ... and $($allBranches.Count - 10) more" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Info "Try: /vault-worktree:switch-branch <branch-name>"
    exit 1
}

Write-Success "Found: $targetBranch"

# Check for uncommitted changes
Write-Host "🔄 Checking working directory..." -ForegroundColor Cyan
$hasUncommitted = Test-HasUncommittedChanges $currentVersionPath
if ($hasUncommitted) {
    $changeCount = Get-UncommittedChangeCount $currentVersionPath
    Write-Warning-Custom "Uncommitted changes in current branch ($changeCount file(s))"
    Write-Host ""
    Write-Info "Options:"
    Write-Host "   1. Commit changes: git add . && git commit -m ""...""" -ForegroundColor Cyan
    Write-Host "   2. Stash changes:  git stash" -ForegroundColor Cyan
    Write-Host "   3. Discard changes: git checkout -- ." -ForegroundColor Cyan
    Write-Host ""
    Write-Warning-Custom "Cannot switch branches with uncommitted changes"
    exit 1
}

Write-Success "Working directory clean"

# Switch branch
Write-Host "🔧 Switching to branch..." -ForegroundColor Cyan
try {
    Push-Location $currentVersionPath

    git checkout $targetBranch 2>&1 | Out-Null

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Switched to: $targetBranch"
        Pop-Location

        # Pull if requested
        if ($Pull) {
            Write-Host ""
            Write-Section "Pulling Latest Code"
            Write-Host "   Running: git pull origin $targetBranch" -ForegroundColor Cyan

            Push-Location $currentVersionPath
            $pullOutput = git pull origin $targetBranch 2>&1
            Pop-Location

            if ($LASTEXITCODE -eq 0) {
                Write-Success "Latest code pulled"
            } else {
                Write-Warning-Custom "Pull completed with warnings:"
                Write-Host $pullOutput -ForegroundColor Yellow
            }
        }
    } else {
        Write-Error-Custom "Failed to switch to branch"
        Write-Host "   Git error output above" -ForegroundColor White
        Pop-Location
        exit 1
    }
}
catch {
    Write-Error-Custom "Error switching branch: $_"
    Pop-Location
    exit 1
}

# Show final status
Write-Host ""
Write-Success "Switched to branch: $targetBranch"
Write-Host ""

# Show commit info
$branch = Get-CurrentBranch $currentVersionPath
$status = Get-GitStatus $currentVersionPath

if ($status.LastCommit) {
    Write-Host "   Latest commit: $($status.LastCommit)" -ForegroundColor Gray
}

Write-Host ""
Write-Section "💡 Next Steps"
Write-Host "   1. Check status:    /vault-worktree:status" -ForegroundColor Cyan
Write-Host "   2. View changes:    git diff" -ForegroundColor Cyan
Write-Host "   3. Start coding:    cd h:" -ForegroundColor Cyan
Write-Host ""
