---
name: status
description: View Vault worktree and Git status with flexible output options
argument-hint: [--full] [--sync]
allowed-tools: Bash
---

# View Status

Check your current Vault worktree and Git status. Three modes available: quick check, detailed view, or fetch and check.

## Usage

```
/vault-worktree:status              # Quick status check (default)
/vault-worktree:status --full       # Detailed Git information
/vault-worktree:status --sync       # Fetch latest then show status
```

## Arguments

- `--full`: Show detailed Git status including all changes and commits
- `--sync`: Run `git fetch` to sync all versions before showing status

## What Each Mode Does

### Default Mode (No Flags)

Quick readiness check - best for before starting development.

Shows:
- Current H: drive mapping (which version)
- Current Git branch
- Uncommitted file count
- Unpushed commit count
- Overall "Ready to work" status

Perfect for: Daily start, quick verification

### --full Mode

Detailed Git information - see exactly what changed.

Shows:
- Current H: drive mapping
- Current Git branch
- Detailed list of modified files with status
- Detailed list of unpushed commits
- Remote branch sync status
- Suggested next actions

Perfect for: Before committing, understanding changes

### --sync Mode

Fetch latest and show status - ensures you have newest remote changes.

Shows:
- Same as default mode
- But runs git fetch first for all versions
- Shows which branches were updated
- Highlights new remote commits

Perfect for: Morning start, team collaboration, before pushing

## Output Examples

### Default Output
```
📍 Current Version: vault-2027
🌿 Current Branch: lpc/PDM-49688-1
✅ Working Directory: clean

📝 Status:
   ✓ Committed and pushed
   → Ready to work!

💡 Next steps:
   /vault-worktree:switch-branch PDM-xxxxx  (to switch branches)
   git add . && git commit                   (when done coding)
```

### With Uncommitted Changes
```
📍 Current Version: vault-2027
🌿 Current Branch: lpc/PDM-49688-1
⚠️  Working Directory: has uncommitted changes

📝 Changes:
   M  src/class1.cs
   M  src/class2.cs
   ?? temp-file.txt (untracked)

📤 Unpushed Commits: 1
   * abc1234 - "Add validation logic" (10 minutes ago)

💡 Next steps:
   git add . && git commit -m "..."  (commit changes)
   git push origin lpc/PDM-49688-1   (push to remote)
```

### --full Output
```
📍 Current Version: vault-2027
🌿 Current Branch: lpc/PDM-49688-1

📝 Modified Files:
   M  src/class1.cs         (modified)
   M  src/class2.cs         (modified)
   ?? temp.cs               (untracked)

📤 Unpushed Commits: 2
   * abc1234 - "Add validation"  (10 min ago)
   * def5678 - "Fix bug"         (25 min ago)

📥 Status vs Remote:
   ✓ Remote is up to date (last pull 2 hours ago)

🔄 Other Versions Status:
   vault-2025: R2025.x (no changes)
   vault-2026: R2026.x (3 new commits from teammates)
   vault-2027: lpc/PDM-49688-1 (current - 2 unpushed)
```

### --sync Output
```
🔄 Syncing all versions with remote...
   ✓ vault-2025 synced
   ✓ vault-2026 synced (1 new commit in R2026.x)
   ✓ vault-2027 synced (2 new commits in your branch)

📍 Current Version: vault-2027
🌿 Current Branch: lpc/PDM-49688-1

📝 Status: working directory clean
📤 Unpushed: 0 commits
📥 Latest from remote: synced

✅ All up to date!
```

## When to Use Each Mode

**Quick Check (Default)**
- Verifying everything is ready before coding
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
1. Detects current H: mapping
2. Reads .git/HEAD for current branch
3. Runs `git status` to check for uncommitted changes
4. Runs `git log` to check for unpushed commits
5. Compares with remote to check sync status

### --full Mode
1. Same as default
2. Plus: detailed file-by-file changes
3. Plus: full commit messages for unpushed commits
4. Plus: status of other versions

### --sync Mode
1. Runs `git fetch --all` to update all remote tracking branches
2. Then performs default mode checks
3. Shows which branches had updates

## Common Scenarios

### Scenario 1: Daily Start
```
/vault-worktree:status --sync

→ Syncs latest from all teammates
→ Verifies your environment
→ Shows if you need to pull latest code
```

### Scenario 2: Check Before Committing
```
/vault-worktree:status --full

→ See exactly what changed
→ Verify all changes are intentional
→ Copy commit message ideas
```

### Scenario 3: Quick Health Check
```
/vault-worktree:status

→ 2-second verification
→ Ensure nothing unexpected
→ Continue coding
```

## Error Handling

**If not in Git repository:**
```
❌ Not in a Git repository
   Current H: mapping: none

   💡 Solution:
      /vault-worktree:switch-version 2027  (map a version first)
      /vault-worktree:status                (then check status)
```

**If H: not mapped:**
```
❌ H: drive not mapped

   💡 Solution:
      /vault-worktree:switch-version 2027
```

## Tips

✅ **Start every day with:** `/vault-worktree:status --sync`
✅ **Before committing:** Use `--full` to see all changes
✅ **When unsure:** Use `--sync` to get latest info
✅ **Quick checks:** Use default (no flags)

## Related Commands

- `/vault-worktree:switch-version` - Change versions
- `/vault-worktree:switch-branch` - Change branches
- `/vault-worktree:diagnose` - Full environment check

## Integration with Workflow

Status is central to daily workflow:
```
1. /vault-worktree:status --sync        (morning: get updates)
2. /vault-worktree:switch-branch PDM-xxxxx
3. [edit code]
4. /vault-worktree:status --full        (before commit: verify changes)
5. git add . && git commit
6. /vault-worktree:status               (verify ready to push)
7. git push origin
```

---

## Implementation Instructions

When this command is invoked, execute the following PowerShell script:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-status.ps1" [-Full] [-Sync]
```

The script handles all status logic including:
- Automatic Vault root detection
- Current version and branch detection
- Uncommitted and unpushed change detection
- Optional git fetch sync (--sync flag)
- Detailed file and commit information (--full flag)
- Cross-version status overview in full mode
- Helpful next steps and action suggestions

Flags are passed directly from the command invocation to the PowerShell script.
