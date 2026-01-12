---
name: worktree-init
description: Initialize or recover Vault worktree structure with v2.0 branch-name based directories
argument-hint: [--versions R2027.1,R2027] [--primary R2027.1]
allowed-tools: Bash
---

# Initialize Worktree (v2.0)

Set up the Git worktree structure for your Vault project with improved directory naming that matches your git branches.

## What's New in v2.0

✨ **Key Improvements:**
- **Branch-based naming**: Directories now mirror branch names (vault-R2027.1 instead of vault-2027)
- **Configuration storage**: Persistent config in `~/.claude/vault-worktree.config.json`
- **Primary worktree support**: Designate main working directory
- **Automatic cleanup**: Old v1.x directories removed automatically
- **Full compatibility**: Upgrade from v1.x with zero manual work

## Usage

```bash
# Initialize all detected version branches (recommended)
/vault-worktree:worktree-init

# Initialize specific versions
/vault-worktree:worktree-init --versions R2027.1,R2027

# Specify a primary version
/vault-worktree:worktree-init --versions R2027.1,R2027 --primary R2027.1

# Auto-detect from remote
/vault-worktree:worktree-init --auto-detect
```

## Arguments

- `--versions`: Comma-separated list of branch names (e.g., "R2027.1,R2027" or "R2027")
  - Accepts full branch names: R2027.1, R2025.x, etc.
  - Accepts version shorthand: 2027 (auto-expands to R2027.x)
  - Default (no args): Auto-detects all R* branches

- `--primary`: Designate the primary worktree (e.g., "R2027.1")
  - This version will be marked as [PRIMARY] in config
  - Suggested for your main development branch
  - Default: First version created

- `--auto-detect`: Explicitly trigger auto-detection mode

## What This Command Does

1. **Detects Vault root** from current location
2. **Validates Git repository** exists
3. **Discovers remote branches** (R2025.x, R2026.x, R2027.1 patterns)
4. **Creates configuration** file at ~/.claude/vault-worktree.config.json
5. **Cleans old worktrees** (vault-2027 style directories from v1.x)
6. **Creates new worktrees** with branch-based names (vault-R2027.1, vault-R2027, etc.)
7. **Stores metadata** including primary version and naming rules
8. **Shows configuration status** with all created versions

## Directory Structure

### Before v2.0 (Old)
```
vault/
├── .git/              (shared git database)
├── vault-2025/        (old naming)
├── vault-2026/        (old naming)
└── vault-2027/        (old naming)
```

### After v2.0 (New)
```
vault/
├── .git/              (shared git database)
├── vault-R2025.x/     (branch-based names)
├── vault-R2026.x/     (branch-based names)
└── vault-R2027.1/     (branch-based names, marked [PRIMARY])

~/.claude/
└── vault-worktree.config.json  (NEW - persistent config)
```

## Configuration Storage

Configuration is stored in: **`~/.claude/vault-worktree.config.json`**

**Example config:**
```json
{
  "version": "2.0.0",
  "created_date": "2025-01-12 10:30:00",
  "last_modified": "2025-01-12 10:30:00",
  "vault_root": "D:\\Works\\Vault\\vault",
  "primary_version": "R2027.1",
  "primary_directory": "vault",
  "directory_naming_rule": "branch-name",
  "versions": [
    {
      "branch": "R2027.1",
      "directory": "vault-R2027.1",
      "is_primary": true,
      "added_date": "2025-01-12 10:30:00"
    },
    {
      "branch": "R2027",
      "directory": "vault-R2027",
      "is_primary": false,
      "added_date": "2025-01-12 10:30:00"
    }
  ]
}
```

## Output Examples

### Successful Initialization (v2.0)

```
🚀 Initialize Vault Worktree Structure (v2.0)
════════════════════════════════════════════

🔍 Detecting Vault root...
   Found: D:\Works\Vault\vault
   Git repo: ✓ Valid

📍 Discovering available branches...
   Auto-detected: R2025.x, R2026.x, R2027.1
   Available: R2025.x, R2026.x, R2027.1, main, dev

⚙️  Configuration
   Config: C:\Users\yourname\.claude\vault-worktree.config.json
   Naming rule: branch-name
   Primary version: will set to first

🧹 Checking for old worktree directories...
   Found old worktree directories from v1.x:
     - D:\Works\Vault\vault\vault-2025
     - D:\Works\Vault\vault\vault-2026
     - D:\Works\Vault\vault\vault-2027

   These will be removed during initialization to avoid conflicts.

   Removing vault-2025...
   Removing vault-2026...
   Removing vault-2027...
   ✓ Cleanup complete

🔧 Creating Worktrees
   🔧 Creating vault-R2025.x (based on origin/R2025.x)...
   ✓ vault-R2025.x created [00:15]

   🔧 Creating vault-R2026.x (based on origin/R2026.x)...
   ✓ vault-R2026.x created [00:12]

   🔧 Creating vault-R2027.1 (based on origin/R2027.1)...
   ✓ vault-R2027.1 created [00:18]

✅ Initialization Complete

   ✓ Created: 3
   ⊘ Skipped: 0

📦 Worktree Structure

   vault-R2025.x [PRIMARY] (6.5GB)
   vault-R2026.x (6.8GB)
   vault-R2027.1 (7.2GB)
   .git (shared) (500MB)

📋 Vault Worktree Configuration
═══════════════════════════════════════════
Config file: C:\Users\yourname\.claude\vault-worktree.config.json
Version: 2.0.0
Created: 2025-01-12 10:30:00
Modified: 2025-01-12 10:30:00

Vault Root: D:\Works\Vault\vault
Naming Rule: branch-name
Primary Version: R2025.x

Configured Versions:
  - Branch: R2025.x [PRIMARY]
    Directory: vault-R2025.x
    Added: 2025-01-12 10:30:00

  - Branch: R2026.x
    Directory: vault-R2026.x
    Added: 2025-01-12 10:30:00

  - Branch: R2027.1 [PRIMARY]
    Directory: vault-R2027.1
    Added: 2025-01-12 10:30:00

🎯 Next Steps
   1. /vault-worktree:switch-version R2027.1
   2. /vault-worktree:switch-branch PDM-xxxxx
   3. Start developing!

💡 Tip: Use /vault-worktree:status to verify setup
```

### With Custom Primary Version

```
/vault-worktree:worktree-init --versions R2027.1,R2027 --primary R2027.1

✅ Initialization Complete

📦 Worktree Structure
   vault-R2027.1 [PRIMARY] (7.2GB)    ← marked as primary
   vault-R2027 (7.0GB)
   .git (shared) (500MB)
```

### Skipping Existing Worktrees

```
/vault-worktree:worktree-init

⚙️  Configuration
   Config: C:\Users\yourname\.claude\vault-worktree.config.json
   Naming rule: branch-name
   Primary version: R2027.1 (existing)

🔧 Creating Worktrees
   ⊘ vault-R2027.1 already exists (skipped)
   ⊘ vault-R2027 already exists (skipped)

✅ Initialization Complete
   ✓ Created: 0
   ⊘ Skipped: 2
```

## When to Use

### Use Case 1: Brand New Setup
```
Scenario: You just cloned the Vault repository
Action: /vault-worktree:worktree-init
Result: Complete worktree structure with v2.0 directories
```

### Use Case 2: First-Time User
```
Scenario: New developer joining the team
Action:
  1. Clone repo: git clone <vault-url>
  2. /vault-worktree:worktree-init
  3. Ready to work in 2 minutes!
```

### Use Case 3: Upgrade from v1.x
```
Scenario: You have existing vault-2027/ directories from v1.x
Action: /vault-worktree:worktree-init
Result:
  - Auto-detects old vault-2027, vault-2026 etc.
  - Removes them automatically
  - Creates new vault-R2027.1 style directories
  - Zero manual cleanup needed!
```

### Use Case 4: Adding New Version
```
Scenario: New release version R2028.x created
Action: /vault-worktree:worktree-init --versions R2028.x
Result: Creates new vault-R2028.x worktree
```

### Use Case 5: Designating Primary Worktree
```
Scenario: You want vault-R2027.1 to be your main development version
Action: /vault-worktree:worktree-init --primary R2027.1
Result:
  - vault-R2027.1 marked as [PRIMARY]
  - Config updated for all commands to reference it
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

### Error: "Cannot find remote branches"
```
❌ Cannot find remote branches
   Ensure repository has remote: git remote -v

Solution:
  1. Verify remote configured: git remote add origin <url>
  2. Fetch: git fetch origin
  3. /vault-worktree:worktree-init
```

### Error: "No branches to initialize"
```
❌ No branches to initialize

Solution:
  1. Verify your remote has R* pattern branches
  2. Run: git branch -r
  3. Should see: origin/R2025.x, origin/R2026.x, etc.
```

### Error: "Could not remove old directory"
```
⚠️  Could not remove vault-2027: Permission denied

Solution:
  1. Ensure PowerShell is running as Administrator
  2. Close any programs accessing the directory
  3. Try again: /vault-worktree:worktree-init
```

## Naming Rules

The `directory_naming_rule` determines how directories are named:

### branch-name (Default v2.0)
- Pattern: `vault-<branch-name>`
- Example: `vault-R2027.1`, `vault-R2026.x`, `vault-R2025.x`
- ✅ Advantage: Directory name exactly matches branch name
- ✅ No confusion about versions
- ✅ Recommended for all new projects

### version-only (Legacy)
- Pattern: `vault-<version>`
- Example: `vault-2027`, `vault-2026`
- ⚠️ Legacy from v1.x, kept for compatibility
- ❌ Doesn't match branch names
- ❌ Use only if you prefer old naming scheme

Current config uses: **branch-name**

## Technical Details

### What Gets Created

For each branch, a new worktree is created with:
- **Directory:** `vault-<branch-name>/` (e.g., vault-R2027.1/)
- **.git:** Symbolic link to shared `.git/`
- **Source Code:** Full project copy for that branch version
- **Working Directory:** Ready to edit and build

### Git Commands Used

```powershell
# For each branch:
git worktree add "D:\Works\Vault\vault-R2027.1" "origin/R2027.1"

# Creates:
# - vault-R2027.1/ directory
# - Checkout of origin/R2027.1
# - Index file for that branch
# - No duplicate .git (links to shared one)
```

### Storage Efficiency

```
Traditional (full clones):
  vault-2025: .git (500MB) + code (4GB) = 4.5GB each
  vault-2026: .git (500MB) + code (4GB) = 4.5GB each
  vault-2027: .git (500MB) + code (4GB) = 4.5GB each
  Total: 13.5GB ❌

Worktree (shared .git):
  .git shared: 500MB (once)
  vault-R2025.x: code (4GB) = 4GB
  vault-R2026.x: code (4GB) = 4GB
  vault-R2027.1: code (4GB) = 4GB
  Total: 12.5GB ✅ (saves 1GB!)
```

## v1.x to v2.0 Migration

The upgrade is **automatic and seamless**:

1. **Old Structure Detected** - Script finds vault-2027, vault-2026 etc.
2. **User Notified** - Shows what will be removed
3. **Clean Removal** - Properly removes git worktree entries and directories
4. **New Structure Created** - Creates vault-R2027.1, vault-R2027 etc.
5. **Config Saved** - Stores all info in ~/.claude/vault-worktree.config.json
6. **Zero Manual Work** - No user action needed!

**What happens to your changes?**
- ✅ Any uncommitted changes are preserved before removal
- ✅ Git history is not affected (shared .git database)
- ✅ Branches and commits all intact
- ✅ Safe to run multiple times

## Tips

✅ **One-time operation:** Initialize once per clone
✅ **Safe to re-run:** Won't break existing worktrees (skips them)
✅ **Add versions anytime:** Use --versions flag to add new ones
✅ **Minimal space:** Worktrees are much more efficient than full clones
✅ **Config persistent:** Settings saved for other commands to use

## After Initialization

Your next commands typically are:
```
1. /vault-worktree:switch-version R2027.1
2. /vault-worktree:switch-branch PDM-xxxxx
3. /vault-worktree:status
4. [Start developing]
```

## Related Commands

- `/vault-worktree:switch-version` - Switch between initialized worktrees
- `/vault-worktree:switch-branch` - Switch git branches
- `/vault-worktree:status` - View worktree structure and configuration
- `/vault-worktree:diagnose` - Check worktree health

---

## Implementation Instructions

When this command is invoked, execute the following PowerShell script:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-worktree-init.ps1" [-Versions <branch-names>] [-Primary <branch-name>] [-AutoDetect]
```

The script handles:
- Automatic Vault root detection
- Git repository validation
- Remote branch discovery (looks for R\d+ patterns)
- Configuration file initialization (v2.0 feature)
- Old v1.x worktree cleanup and removal
- Worktree creation via `git worktree add`
- Duplicate detection and skipping
- Comprehensive error handling
- Final structure summary with configuration display

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
  Manually create with: git worktree add vault-<branch> origin/<branch>
```

**Problem:** Configuration file not found
```
Solution:
  Config is stored in: ~/.claude/vault-worktree.config.json
  Check if directory exists: dir %USERPROFILE%\.claude\
  Re-initialize: /vault-worktree:worktree-init
```

**Problem:** Still seeing old vault-2027 directories after init
```
Solution:
  These should have been auto-cleaned
  Manually remove: git worktree prune
  Then re-initialize: /vault-worktree:worktree-init
```

## FAQ

**Q: Can I use both v1.x (vault-2027) and v2.0 (vault-R2027.1) naming?**
A: No, v2.0 is a clean break. Init will remove old dirs and create new ones.

**Q: What if I have custom branch names (not R\d+ pattern)?**
A: Specify them explicitly: `/vault-worktree:worktree-init --versions my-custom-branch`

**Q: Is my configuration portable?**
A: Config is per-machine (~/.claude/vault-worktree.config.json). Each machine initializes independently.

**Q: Can I change the primary version later?**
A: Yes, use: `/vault-worktree:switch-version --set-primary R2027.1`
