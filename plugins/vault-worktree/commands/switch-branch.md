---
description: Quickly switch to a different branch within current Vault version
argument-hint: <branch-name> [--pull]
allowed-tools: Bash
---

# Switch Branch

Switch to a different Git branch within the current version. This is a quick alternative to `git checkout`.

## Usage

```
/vault-worktree:switch-branch PDM-49690
/vault-worktree:switch-branch PDM-49690 --pull
/vault-worktree:switch-branch lpc/PDM-49700-1
```

## Arguments

- `<branch-name>`: Target branch name (can use short form like "PDM-49690" or full form "lpc/PDM-49690-1")
- `--pull`: Optional flag to run git pull after switching to get latest code

## What This Command Does

1. **Validates** current worktree has .git directory
2. **Auto-detects** available branches (looks for matching branch in lpc/ prefix)
3. **Warns** if uncommitted changes exist in current branch
4. **Switches** to target branch using `git checkout`
5. **Optionally pulls** latest code if `--pull` flag is used
6. **Confirms** successful switch with branch info

## Output Example

```
✅ Switched to branch: lpc/PDM-49690-2
   Version: vault-2027
   Status: working directory clean

   💡 Tips:
      Use /vault-worktree:status to see detailed changes
      Commit before switching again
```

## What Happens

1. Checks git repository integrity in current H: mapped directory
2. Lists available branches with pattern matching
3. If partial name provided (e.g., "PDM-49690"), finds matching "lpc/PDM-49690-x"
4. Checks for uncommitted changes and warns if found
5. Executes: `git checkout <branch-name>`
6. If `--pull` flag: executes `git pull origin <branch-name>`
7. Shows confirmation with current branch and status

## Common Scenarios

### Quick Branch Switch (Typical)
```
/vault-worktree:switch-branch PDM-49690
→ Switches to lpc/PDM-49690-x (finds matching branch)
```

### Switch and Get Latest Code
```
/vault-worktree:switch-branch PDM-49690 --pull
→ Switches to branch
→ Pulls latest from remote
→ Ready to work
```

### Full Branch Name
```
/vault-worktree:switch-branch lpc/PDM-49700-1
→ Switches to exact branch name
```

## Error Handling

**If branch doesn't exist:**
```
❌ Branch "PDM-99999" not found
   Available branches:
   - lpc/PDM-49688-1 (current)
   - lpc/PDM-49690-2
   - lpc/PDM-49700-1
   - R2027.1

   💡 Use /vault-worktree:switch-branch <branch-name>
```

**If uncommitted changes exist:**
```
⚠️  WARNING: Uncommitted changes in lpc/PDM-49688-1
    Files modified:
    - src/file1.cs
    - src/file2.cs

    ⚠️  Cannot switch without committing or stashing changes

    💡 Options:
       1. git add . && git commit -m "..."
       2. git stash (temporarily save work)
       3. /vault-worktree:status (see details)
```

## Tips

✅ **Use short names:** `PDM-49690` instead of `lpc/PDM-49690-2`
✅ **Commit before switching:** Avoid losing work
✅ **Use --pull when:** Getting latest code from teammates
✅ **Check status after:** Use `/vault-worktree:status` to verify

## Related Commands

- `/vault-worktree:switch-version` - Switch to different version
- `/vault-worktree:status` - View current branch and changes
- `/vault-worktree:status --full` - Detailed git information

## Integration with Workflow

Typical development workflow:
```
1. /vault-worktree:switch-version 2027 --sync
2. /vault-worktree:switch-branch PDM-49688 --pull
3. [Edit code]
4. git add . && git commit -m "Fix feature"
5. git push origin lpc/PDM-49688-1
6. [Create PR on GitHub/GitLab]
```

---

## Implementation Instructions

When this command is invoked, execute the following PowerShell script:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-switch-branch.ps1" -BranchName <branch-name> [-Pull]
```

The script handles all branch switching logic including:
- Automatic Vault root detection and H: mapping detection
- Branch name pattern matching (supports short names like "PDM-49690")
- Uncommitted change detection and warnings
- Git checkout execution
- Optional git pull to get latest code
- Confirmation and status reporting

Parameters are passed directly from the command invocation to the PowerShell script.
