---
description: View Vault worktree structure and Git status with tree view (v2.0)
argument-hint: [--full] [--sync]
allowed-tools: Bash
---

# View Status (v2.0)

Check your Vault worktree structure and Git status. Shows all versions in a tree view with clear status indicators.

## Usage

```bash
/vault-worktree:status              # Quick status check (default)
/vault-worktree:status --full       # Detailed Git information
/vault-worktree:status --sync       # Fetch latest then show status
```

## Arguments

- `--full`: Show detailed Git status including all changes and commits
- `--sync`: Run `git fetch` to sync all versions before showing status

## What Each Mode Does

### Default Mode (No Flags)

Quick overview - best for daily checks and before starting work.

Shows:
- ✨ **Worktree Structure Tree** - All versions at a glance with [PRIMARY] and [CURRENT] markers
- Current H: drive mapping
- Current Git branch
- Uncommitted file count
- Unpushed commit count
- Configuration info (naming rule, primary version)
- Overall readiness status

Perfect for: Daily start, status checks, quick verification

### --full Mode

Complete Git information - see exactly what changed and all details.

Shows:
- Same as default mode
- Plus: Detailed list of modified files with status
- Plus: Detailed list of unpushed commits
- Plus: Remote branch sync status
- Plus: All other versions' status

Perfect for: Before committing, understanding changes, before pushing

### --sync Mode

Fetch latest and show status - ensures you have newest remote changes.

Shows:
- Same as default mode
- Plus: Runs git fetch first to update tracking branches
- Plus: Shows which branches were updated

Perfect for: Morning start, team collaboration, before pushing

## Output Examples

### Default Output (v2.0)

```
🚀 Vault Status (v2.0)
════════════════════════════════════════════

📦 Worktree Structure

   ├─ vault-R2025.x [PRIMARY]
   │  ├─ Branch: origin/R2025.x
   │  ├─ Status: ✓ clean
   │  └─ Last commit: abc1234
   │
   ├─ vault-R2026.x
   │  ├─ Branch: main
   │  ├─ Status: ✓ clean
   │  └─ Last commit: def5678
   │
   └─ vault-R2027.1 [CURRENT]
      ├─ Branch: lpc/PDM-49688
      ├─ Status: ⚠️  2 changes
      ├─ Unpushed: 📤 1 commit(s)
      └─ ← You are here

   .git (shared database) - 500MB

📋 Current Worktree Details

   Version: R2027.1 (from H: drive)
   Directory: vault-R2027.1
   Branch: lpc/PDM-49688

   ⚠️  Working directory has changes

⚙️  Configuration

   Config: C:\Users\yourname\.claude\vault-worktree.config.json
   Naming Rule: branch-name
   Primary Version: R2025.x
   Modified: 2025-01-12 14:30:00

📝 Summary

   📝 Uncommitted: 2 file(s)
   📤 Unpushed: 1 commit(s)

   Actions needed:
   git add . && git commit -m "..."
   git push origin lpc/PDM-49688

🎯 Next Steps

   1. See details: /vault-worktree:status --full
   2. Switch version: /vault-worktree:switch-version R2027.1
   3. Switch branch:  /vault-worktree:switch-branch PDM-xxxxx
   4. Start coding:   cd h:
```

### With Clean Status

```
📦 Worktree Structure

   ├─ vault-R2025.x [PRIMARY]
   │  ├─ Branch: origin/R2025.x
   │  ├─ Status: ✓ clean
   │  └─ Last commit: abc1234
   │
   └─ vault-R2027.1 [CURRENT]
      ├─ Branch: lpc/PDM-49688
      ├─ Status: ✓ clean
      └─ ← You are here

   .git (shared database) - 500MB

📋 Current Worktree Details

   Version: R2027.1 (from H: drive)
   Directory: vault-R2027.1
   Branch: lpc/PDM-49688

   ✅ Working directory clean

⚙️  Configuration

   Config: C:\Users\yourname\.claude\vault-worktree.config.json
   Naming Rule: branch-name
   Primary Version: R2025.x
   Modified: 2025-01-12 14:00:00

📝 Summary

   ✓ Ready to work!
   All changes committed and pushed
```

### --full Output

```
📦 Worktree Structure
[Same tree structure as above]

📋 Current Worktree Details
[Same as above]

📄 Modified Files

   M  src/class1.cs         (modified)
   M  src/class2.cs         (modified)
   ?? temp.cs               (untracked)

📤 Unpushed Commits

   * abc1234 - "Add validation logic" (10 min ago)

🔗 Remote Status

   ## lpc/PDM-49688...origin/lpc/PDM-49688 [ahead 1]

⚙️  Configuration
[Same as above]

📝 Summary
[Same as above]
```

### --sync Output

```
🔄 Syncing all versions with remote...
✓ Sync complete

📦 Worktree Structure
[Same tree structure]

   [NOTE: Now shows latest from remote]
```

## Tree View Symbols

| Symbol | Meaning |
|--------|---------|
| `├─` | Branch continues down (has more items) |
| `└─` | Last branch (no more items) |
| `│` | Vertical line (shows branch connection) |
| `[PRIMARY]` | This is the main development worktree |
| `[CURRENT]` | You are currently working here (H: mapped) |
| `← You are here` | Indicator for current worktree location |

## Status Indicators

| Indicator | Meaning |
|-----------|---------|
| ✓ clean | No uncommitted changes, no unpushed commits |
| ⚠️ # changes | Has uncommitted files (number shown) |
| 📤 # commits | Has unpushed commits (number shown) |

## When to Use Each Mode

**Quick Check (Default)**
- Verifying everything before coding
- Regular status checks during day
- After switching branches

**Detailed --full**
- Before committing code
- Understanding what changed
- Before pushing to remote
- During code review preparation

**Sync --sync**
- Morning start (get all teammates' updates)
- Before important operations
- When worried about being out of sync
- Before creating Pull Request

## What Happens Behind the Scenes

### Default Mode
1. Loads configuration from ~/.claude/vault-worktree.config.json
2. Reads all configured versions
3. Gets current H: drive mapping
4. For each version:
   - Gets git branch
   - Checks for uncommitted changes
   - Counts unpushed commits
5. Displays tree structure with indicators
6. Shows current worktree details
7. Displays configuration information

### --full Mode
1. Same as default
2. Plus: Lists modified files with git status codes
3. Plus: Shows unpushed commit messages
4. Plus: Shows remote tracking status

### --sync Mode
1. Runs `git fetch origin --prune` first
2. Then same as default
3. Tracking branches updated before display

## Common Scenarios

### Scenario 1: Daily Start
```
/vault-worktree:status --sync

→ Updates latest from remote
→ Shows all versions' status
→ Verifies your environment
→ Shows if you need to pull latest code
```

### Scenario 2: Check Before Committing
```
/vault-worktree:status --full

→ See exactly what changed
→ Verify all changes are intentional
→ Get commit messages ready
```

### Scenario 3: Quick Health Check
```
/vault-worktree:status

→ 2-second verification
→ See all versions at once
→ Ensure nothing unexpected
→ Continue coding
```

### Scenario 4: Verify Multiple Versions
```
/vault-worktree:status

→ Tree shows all worktrees
→ Can see which have changes
→ Useful before switching versions
```

## Error Handling

### Error: "Not in a Git repository"
```
❌ Not in a Git repository
   Current location: D:\some\random\path

Solution:
   Navigate to Vault root: cd D:\Works\Vault\vault
   Then: /vault-worktree:status
```

### Error: "H: drive not mapped to any version"
```
❌ H: drive not mapped to any version

Solution:
   /vault-worktree:switch-version R2027.1
   Then: /vault-worktree:status
```

### Error: "No configuration found"
```
❌ No configuration found
   Initialize worktree to create configuration:
   /vault-worktree:worktree-init

Solution:
   Run initialization first
```

### Error: "Current version not found in configuration"
```
❌ Current version not found in configuration
   Run: /vault-worktree:worktree-init to update configuration

Solution:
   The configuration is out of sync
   Re-initialize to rebuild it
```

## Tips

✅ **Start every day with:** `/vault-worktree:status --sync`
✅ **Before committing:** Use `--full` to see all changes
✅ **When unsure:** Use `--sync` to get latest info
✅ **Quick checks:** Use default (no flags)
✅ **Check tree:** See all versions and their status in one command
✅ **Easy navigation:** Tree shows which version is [PRIMARY] and [CURRENT]

## Integration with Workflow

Status is central to daily workflow:
```
1. /vault-worktree:status --sync        (morning: get updates, see all versions)
2. /vault-worktree:switch-version R2027 (if needed)
3. /vault-worktree:switch-branch PDM-xxxxx
4. [edit code]
5. /vault-worktree:status --full        (before commit: verify changes)
6. git add . && git commit
7. /vault-worktree:status               (verify ready to push)
8. git push origin
```

## Related Commands

- `/vault-worktree:switch-version` - Change versions
- `/vault-worktree:switch-branch` - Change branches
- `/vault-worktree:worktree-init` - Initialize/reset worktree structure
- `/vault-worktree:diagnose` - Full environment check

---

## Implementation Instructions

When this command is invoked, execute the following PowerShell script:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-status.ps1" [-Full] [-Sync]
```

The script handles:
- Automatic Vault root detection
- Configuration loading from ~/.claude/vault-worktree.config.json
- Current version detection from H: drive mapping
- Tree structure display with status indicators
- Git status for all versions
- Full details when --full flag used
- Remote sync when --sync flag used
- Configuration status display
- Clear status summary and next steps

## v2.0 Improvements

✨ **New in v2.0:**
- Tree view showing all worktrees at once
- [PRIMARY] marker for main development version
- [CURRENT] marker for currently mapped version
- Configuration information display
- Automatic status color coding (green/yellow/cyan)
- Shows unpushed commits per version
- Better visual organization and hierarchy
