---
name: worktree-init
description: Initialize or recover Vault worktree structure for new setup or troubleshooting
argument-hint: [--versions 2025,2026,2027]
allowed-tools: Bash
---

# Initialize Worktree

Set up the Git worktree structure for your Vault project. Use once during initial setup or to recover from corruption.

## Usage

```
/vault-worktree:worktree-init
/vault-worktree:worktree-init --versions 2025,2026,2027
/vault-worktree:worktree-init --versions 2027.1
```

## Arguments

- `--versions`: Optional comma-separated list of versions to initialize (e.g., "2025,2026,2027" or just "2027.1")
- Default (no args): Automatically detects available remote branches and creates worktrees for each

## What This Command Does

1. **Auto-detects** Vault root directory from current location
2. **Validates** Git repository exists (has .git/ directory)
3. **Discovers** available version branches from remote
4. **Creates** worktree for each version using `git worktree add`
5. **Validates** each worktree initialization succeeds
6. **Shows** next steps for new users

## Initial Setup Example

### First Time (No Worktrees)

```
Your Vault directory currently looks like:
  D:\Works\Vault\vault\
    ├── .git/          (shared Git database)
    └── ... (source code)

After /vault-worktree:worktree-init:
  D:\Works\Vault\vault\
    ├── .git/          (shared - unchanged)
    ├── vault-2025/    (NEW - worktree for R2025.x)
    ├── vault-2026/    (NEW - worktree for R2026.x)
    ├── vault-2027/    (NEW - worktree for R2027.1)
    └── ... (source code moved into vault-2027 or similar)
```

## Output Examples

### Successful Initialization

```
🚀 Initializing Vault Worktree Structure
════════════════════════════════════════════

🔍 Detecting Vault root...
   Found: D:\Works\Vault\vault
   Git repo: ✓ Valid

📍 Discovering available versions...
   Found: R2025.x, R2026.x, R2027.1

🔧 Creating worktrees...
   ✓ vault-2025 (based on R2025.x)  [0:05]
   ✓ vault-2026 (based on R2026.x)  [0:08]
   ✓ vault-2027 (based on R2027.1)  [0:10]

✅ Initialization Complete!

📊 Final Structure:
   vault-2025  6.5GB  [OK]
   vault-2026  6.8GB  [OK]
   vault-2027  7.2GB  [OK]
   .git (shared)  500MB

🎯 Next Steps for You:
   1. /vault-worktree:switch-version 2027
   2. /vault-worktree:switch-branch lpc/PDM-xxxxx
   3. Start developing!

💡 Tip: Use /vault-worktree:status to verify setup
```

### With Custom Versions

```
/vault-worktree:worktree-init --versions 2027.1

🚀 Initializing with custom versions...
   Requested: 2027.1
   Available: R2025.x, R2026.x, R2027.1

🔧 Creating worktrees...
   ✓ vault-2027 (based on R2027.1)

⚠️  Note: Only vault-2027 created
    To add more versions later:
    /vault-worktree:worktree-init --versions 2025,2026
```

## When to Use

### Use Case 1: Brand New Setup
```
Scenario: You just cloned the Vault repository
Action: /vault-worktree:worktree-init
Result: Complete worktree structure ready
```

### Use Case 2: First-Time User
```
Scenario: New developer joining the team
Action:
  1. Clone repo: git clone <vault-url>
  2. /vault-worktree:worktree-init
  3. Ready to work in 2 minutes!
```

### Use Case 3: Recovery from Corruption
```
Scenario: Worktree structure got damaged
Action: /vault-worktree:worktree-init --versions 2027
Result: Recreates vault-2027 worktree
```

### Use Case 4: Adding New Version
```
Scenario: New release version 2028.x created
Action: /vault-worktree:worktree-init --versions 2028
Result: Creates new vault-2028 worktree
```

## Error Handling

### Error: "Not a Git repository"
```
❌ No .git directory found
   Current location: D:\Works\Vault\some-folder

Solution:
  1. cd to your Vault root: cd D:\Works\Vault\vault
  2. /vault-worktree:worktree-init
```

### Error: "No remote branches found"
```
❌ Cannot find remote version branches
   Ensure repository has remote: git remote -v

Solution:
  1. Verify remote configured: git remote add origin <url>
  2. Fetch: git fetch origin
  3. /vault-worktree:worktree-init
```

### Error: "Worktree already exists"
```
⚠️  vault-2027 already exists

Options:
  1. Skip it: /vault-worktree:worktree-init --versions 2025,2026
  2. Remove and recreate:
     git worktree remove vault-2027
     /vault-worktree:worktree-init --versions 2027
```

## Technical Details

### What Gets Created

For each version, a new worktree is created with:
- **Directory:** `vault-<version>/`
- **.git:** Symbolic link to shared `.git/`
- **Source Code:** Full project copy for that branch version
- **Working Directory:** Ready to edit and build

### Git Commands Used

```powershell
# For each version:
git worktree add "D:\Works\Vault\vault-<version>" "origin/<version-branch>"

# Creates:
# - vault-<version>/ directory
# - Checkout of origin/<version-branch>
# - Index file for that branch
# - No duplicate .git (links to shared one)
```

### Space Efficiency

```
Traditional (full clones):
  vault-2025: .git (500MB) + code (4GB) = 4.5GB each
  vault-2026: .git (500MB) + code (4GB) = 4.5GB each
  vault-2027: .git (500MB) + code (4GB) = 4.5GB each
  Total: 13.5GB ❌

Worktree (shared .git):
  .git shared: 500MB (once)
  vault-2025: code (4GB) = 4GB
  vault-2026: code (4GB) = 4GB
  vault-2027: code (4GB) = 4GB
  Total: 12.5GB ✅ (saves 1GB!)
```

## Advanced Options

### Custom Branch Mapping
```
You want vault-2027 based on different-branch instead of origin/R2027.1:

git worktree add D:\Works\Vault\vault-2027 different-branch
git worktree add D:\Works\Vault\vault-2028 origin/custom-version
```

### Removing Worktrees
```
/vault-worktree:worktree-init --versions 2025,2026
(creates new ones, doesn't touch vault-2027)

If you want to remove old worktrees:
git worktree list
git worktree remove vault-2025
```

## Tips

✅ **One-time operation:** Initialize once per clone
✅ **Safe to re-run:** Won't break existing worktrees
✅ **Add versions anytime:** Use --versions flag to add new ones
✅ **Minimal space:** Worktrees are much more efficient than full clones

## After Initialization

Your next commands typically are:
```
1. /vault-worktree:switch-version 2027
2. /vault-worktree:switch-branch PDM-xxxxx
3. /vault-worktree:status
4. [Start developing]
```

## Related Commands

- `/vault-worktree:switch-version` - Switch between initialized worktrees
- `/vault-worktree:diagnose` - Check worktree health
- `/vault-worktree:status` - View current status

---

## Implementation Instructions

When this command is invoked, execute the following PowerShell script:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-worktree-init.ps1" [-Versions <comma-separated-list>]
```

The script handles complete worktree initialization including:
- Automatic Vault root detection
- Git repository validation
- Remote branch discovery (looks for R2025.x, R2026.x, R2027.1 patterns)
- Worktree creation via `git worktree add` command
- Duplicate detection and skipping
- Comprehensive error handling and reporting
- Final structure summary and next steps

If --versions is not specified, the script auto-detects available version branches from the remote.
If --versions is specified with comma-separated values (e.g., "2025,2026,2027"), it creates worktrees for those specific versions.

## Troubleshooting

**Problem:** Initialization takes a long time
```
Solution: This is normal for first run (5-15 minutes for large repos)
Subsequent operations are much faster
```

**Problem:** One worktree fails to create
```
Solution:
  Check git log to see error
  Manually create with: git worktree add vault-<version> origin/<branch>
```

**Problem:** Need to redo initialization
```
Solution:
  1. Remove worktrees: git worktree prune
  2. Re-initialize: /vault-worktree:worktree-init
```
