---
name: switch-version
description: Switch to a Vault version with intelligent defaulting to primary worktree. Configuration-aware with flexible version matching (v2.0)
argument-hint: [<version>] [--sync] [--set-primary]
allowed-tools: Bash
---

# Switch Vault Version (v2.0)

Switch the H: drive mapping to a specific Vault version with smart defaulting. Defaults to your primary worktree if no version specified, with full support for flexible version matching and dynamic primary designation.

## Usage

```bash
/vault-worktree:switch-version              # Switch to PRIMARY version (default)
/vault-worktree:switch-version R2027.1      # Switch to specific version
/vault-worktree:switch-version 2027         # Short version (matches R2027.x)
/vault-worktree:switch-version 2027.1 --sync        # With remote sync
/vault-worktree:switch-version R2027.1 --set-primary # Set as new primary
```

## Arguments

- `<version>`: Target version (optional - defaults to primary if not specified)
  - Full format: `R2027.1`, `R2026.x`, `R2025.1`
  - Short format: `2027`, `2027.1`, `2026` (auto-matches to R prefix)
  - Directory format: `vault-R2027.1` (auto-detected)
- `--sync`: Optional flag to run `git fetch origin --prune` to sync with remote
- `--set-primary`: Optional flag to designate target version as new primary worktree

## What This Command Does

1. **Loads configuration** from ~/.claude/vault-worktree.config.json
2. **Determines target version:**
   - If specified: validates and locates requested version
   - If not specified: uses primary version from config (if set)
   - Otherwise: returns error asking to set primary or specify version
3. **Validates** target version directory exists with correct structure
4. **Warns** if switching away from a version with uncommitted changes
5. **Maps** H: drive to the target version directory using Windows `subst` command
6. **Optionally syncs** with remote if `--sync` flag is used
7. **Optionally sets as primary** if `--set-primary` flag is used
8. **Confirms** successful switch with version, branch, and status information

## Output Example (Default to Primary)

```
🚀 Switch Vault Version (v2.0)
════════════════════════════════════════════

📦 Available Versions

   ├─ R2025.x [PRIMARY]
   ├─ R2026.x
   └─ R2027.1

No version specified. Using PRIMARY: R2027.1

📍 Mapping H: Drive

Mapping H: to vault-R2027.1...
✅ H: ⇒ vault-R2027.1

📋 Version Information

   Branch: lpc/PDM-49688
   Uncommitted: none
   Unpushed commits: none
   Role: PRIMARY (default version)

✅ Switch Complete

   Current: R2027.1
   Location: H: ⇒ vault-R2027.1
   Branch: lpc/PDM-49688

🎯 Next Steps

   1. Switch branch:  /vault-worktree:switch-branch PDM-xxxxx
   2. Check status:   /vault-worktree:status
   3. Start coding:   cd h:
```

## Common Scenarios

### Scenario 1: Use Primary Version (Default)
When you have a primary worktree set and want to switch to it:

```bash
/vault-worktree:switch-version

→ Primary R2027.1 is automatically selected
→ H: maps to vault-R2027.1
→ Ready to work
```

### Scenario 2: Switch to Specific Version
When you need to work on a different version:

```bash
/vault-worktree:switch-version R2026.x

→ H: now points to vault-R2026.x
→ Current branch shown
→ Status displayed
```

### Scenario 3: Flexible Version Input
All these match R2027.1:

```bash
/vault-worktree:switch-version R2027.1    ✅ Full format
/vault-worktree:switch-version 2027.1     ✅ Short format
/vault-worktree:switch-version 2027       ✅ Partial (matches 2027.x)
/vault-worktree:switch-version vault-R2027.1  ✅ Directory format
```

### Scenario 4: Switch and Designate New Primary
When switching to a version you want as your new default:

```bash
/vault-worktree:switch-version R2026.x --set-primary

→ H: maps to vault-R2026.x
→ R2026.x is saved as new primary in config
→ Future /vault-worktree:switch-version defaults to R2026.x
→ Configuration updated
```

### Scenario 5: Switch and Sync Latest Code
When switching versions and want the latest remote changes:

```bash
/vault-worktree:switch-version R2027.1 --sync

→ H: maps to vault-R2027.1
→ Runs git fetch origin --prune
→ All tracking branches updated
→ Ready to work with latest code
```

### Scenario 6: Emergency Switch from Any Directory
Works from anywhere in your Vault project:

```bash
cd D:\Works\Vault\vault\Client\InventorVault
/vault-worktree:switch-version R2026.x

→ Auto-detects D:\Works\Vault as Vault root
→ Switches to vault-R2026.x
→ Works even from nested directories
```

## Configuration and Primary Version

### Setting a Primary Version During Init

When you initialize the worktree for the first time:

```bash
/vault-worktree:worktree-init

→ Creates initial configuration
→ First version is marked as [PRIMARY]
→ Configuration saved to ~/.claude/vault-worktree.config.json
```

### Changing Primary Version Later

You can change which version is primary anytime:

```bash
/vault-worktree:switch-version R2026.x --set-primary

→ Switches to R2026.x
→ Updates config to mark R2026.x as primary
→ Future commands default to this version
```

### View Current Configuration

See which version is primary and all configuration:

```bash
/vault-worktree:status

→ Shows tree with [PRIMARY] marker on primary version
→ Shows configuration location and settings
→ Helpful for understanding current state
```

## Error Handling

### Error: No Version Specified and No Primary Set

```
❌ No version specified and no primary version set

   Either specify version or set primary:
   /vault-worktree:switch-version R2027.1 --set-primary

Solution: First time setup - specify a version with --set-primary
```

### Error: Version Not Found

```
❌ Version "R2028.1" not found

   Available versions:
   - R2025.x
   - R2026.x
   - R2027.1

Solution: Use one of the listed versions, or create new with /vault-worktree:worktree-init
```

### Error: Uncommitted Changes

```
⚠️  Uncommitted changes in vault-R2027.1

   Files modified: 2
   - src/class1.cs
   - src/class2.cs

Options:
   1. Commit: cd h: && git add . && git commit -m "..."
   2. Stash:  cd h: && git stash
   3. Continue (changes will be preserved)
```

### Error: H: Drive Mapping Failed

```
❌ Failed to map H: drive

   Possible causes:
   - Missing administrator privileges
   - H: is in use by another application

Solution: Close other applications using H:, or run with admin privileges
```

### Error: Not in a Git Repository

```
❌ Cannot find Vault root (.git directory not found)

   Current location: D:\Some\Random\Path

Solution:
   1. Navigate to Vault root: cd D:\Works\Vault\vault
   2. Then: /vault-worktree:switch-version
```

## Tips

✅ **Set primary on first use:** Use `--set-primary` when setting up your workflow
✅ **Commit before switching:** Avoid losing work with uncommitted changes
✅ **Sync regularly:** Use `--sync` when collaborating with team members
✅ **Check status:** Always verify with `/vault-worktree:status` if unsure
✅ **Use shorthand:** `R2027.1` → `2027.1` → `2027` all work
✅ **Default to primary:** Most users just use `/vault-worktree:switch-version` without args

## Integration with Other Commands

Typical daily workflow with switch-version:

```bash
# Morning: Start with status and sync
/vault-worktree:status --sync

# Switch versions if needed
/vault-worktree:switch-version R2027.1

# Switch to feature branch
/vault-worktree:switch-branch PDM-49688

# Work on code
cd h:
[edit files]

# Before committing: check full status
/vault-worktree:status --full

# Commit and push
git add .
git commit -m "..."
git push origin PDM-49688

# Back to main branch
/vault-worktree:switch-branch main
```

## What Happens Behind the Scenes

### Version Matching Strategy

The command uses intelligent matching to find your version:

1. **Direct branch match:** `R2027.1` → searches for exact branch name
2. **Directory match:** `vault-R2027.1` → searches for directory name
3. **Short format:** `2027` → searches for `R2027.x` using regex
4. Returns first match or error if none found

This makes input flexible - users can say `2027`, `2027.1`, or `R2027.1` and they all work.

### Configuration Storage

Configuration is stored in your user home directory:
- **Location:** `C:\Users\YourName\.claude\vault-worktree.config.json`
- **Format:** JSON with versions array and primary_version field
- **Scope:** Per-machine (doesn't sync across computers)
- **Updated by:** All commands (init, switch-version with --set-primary, etc.)
- **Never deleted:** Persistent across sessions

### Primary Version Concept

Primary version is:
- **Default:** Used when no version argument specified
- **Configurable:** Changed anytime with `--set-primary`
- **Persistent:** Saved to config, survives restarts
- **Purpose:** Reduces typing for your main development version
- **Optional:** Not required if you always specify version

---

## Implementation Instructions

When this command is invoked, execute the following PowerShell script:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-switch-version.ps1" [-Version <version>] [-Sync] [-SetPrimary]
```

The script handles:
- Configuration loading from ~/.claude/vault-worktree.config.json
- Automatic Vault root detection from current directory
- Version validation and flexible matching (branch name, directory name, short format)
- Default to primary version if no version specified
- Uncommitted changes detection and warnings
- H: drive mapping via `subst` command
- Optional remote sync with `git fetch origin --prune`
- Optional primary version update with --set-primary flag
- Comprehensive status reporting and next steps

Parameters:
- `-Version`: Optional target version (defaults to primary if omitted)
- `-Sync`: Optional flag for git fetch
- `-SetPrimary`: Optional flag to update primary version designation

## v2.0 Improvements

✨ **New in v2.0:**
- Config-based version management (persistent ~/.claude/vault-worktree.config.json)
- Primary worktree concept - designate your main development version
- Flexible version matching - `2027`, `2027.1`, `R2027.1` all work
- Optional version argument - defaults to primary if not specified
- Dynamic primary designation - change anytime with --set-primary
- Directory naming matches git branches - vault-R2027.1 instead of vault-2027
- Intelligent version lookup strategy with multiple fallback patterns
- Better error messages and setup guidance

