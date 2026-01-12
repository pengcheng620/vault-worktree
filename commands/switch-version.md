---
name: switch-version
description: Quickly switch to a specific Vault version worktree and optionally sync latest code
argument-hint: <version> [--sync]
allowed-tools: Bash
---

# Switch Vault Version

Switch the H: drive mapping to a specific Vault version. This command automatically detects the Vault directory structure and handles the mapping.

## Usage

```
/vault-worktree:switch-version 2027
/vault-worktree:switch-version 2026.x --sync
/vault-worktree:switch-version 2025
```

## Arguments

- `<version>`: Target version (e.g., 2025, 2026, 2026.x, 2027, 2027.1)
- `--sync`: Optional flag to run git fetch and sync all versions after switching

## What This Command Does

1. **Auto-detects** Vault root directory by traversing up to find .git/
2. **Validates** target version directory exists (vault-2025, vault-2026, vault-2027, etc.)
3. **Checks** for uncommitted changes and warns user if any exist
4. **Maps** H: drive to the target version directory using Windows `subst` command
5. **Optionally syncs** all versions with `git fetch --all` if `--sync` flag is used
6. **Confirms** successful switch with current branch information

## Output Example

```
✅ Switched to vault-2027
   Branch: R2027.1
   Status: working directory clean

   💡 Next steps:
      /vault-worktree:switch-branch PDM-xxxxx  (to switch branches)
      /vault-worktree:status                   (to verify state)
```

## What Happens

1. Discovers Vault root from current working directory
2. Lists all available versions (vault-2025, vault-2026, vault-2027, etc.)
3. Removes old H: mapping: `subst h: /d`
4. Creates new H: mapping to target version: `subst h: <vault-root>\vault-<version>`
5. Displays current git branch and status
6. If `--sync` flag: runs `git fetch origin --prune` to sync all versions

## Common Scenarios

### Switch to Different Version
```
/vault-worktree:switch-version 2026.x
→ H: now points to D:\Works\Vault\vault-2026.x
```

### Switch and Sync Latest Code
```
/vault-worktree:switch-version 2027 --sync
→ H: maps to vault-2027
→ All versions fetch latest remote changes
→ Ready to work with latest code
```

### Emergency Switch from Current Directory
Works from anywhere in your Vault project:
```
cd D:\Works\Vault\vault\Client\InventorVault
/vault-worktree:switch-version 2026
→ Auto-detects D:\Works\Vault as Vault root
→ Switches to vault-2026
```

## Error Handling

**If version doesn't exist:**
```
❌ Version "2028" not found
   Available versions: 2025, 2026, 2027.1

   💡 Use /vault-worktree:worktree-init to create missing versions
```

**If uncommitted changes exist:**
```
⚠️  WARNING: Uncommitted changes in vault-2027
    Files modified:
    - src/class1.cs
    - src/class2.cs

    ⚠️  Switch anyway? (you can commit changes with git commit)

✅ Switched to vault-2026
```

**If H: mapping fails:**
```
❌ Failed to map H: drive
   Ensure you have administrator privileges
   Or check if H: is in use by another process
```

## Tips

✅ **Use --sync when:** Switching versions and want to ensure latest code
✅ **Commit before switching:** To avoid losing work
✅ **Check branch after:** Use `/vault-worktree:switch-branch` to switch feature branches
✅ **Verify success:** Use `/vault-worktree:status` to confirm

## Integration with Other Commands

After switching version, you often want to:
1. Check status: `/vault-worktree:status`
2. Switch branch: `/vault-worktree:switch-branch PDM-xxxxx`
3. Start working on code

Typical workflow:
```
/vault-worktree:switch-version 2027 --sync
/vault-worktree:switch-branch PDM-49688
git diff   (check changes)
```

---

## Implementation Instructions

When this command is invoked, execute the following PowerShell script:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-switch-version.ps1" -Version <version> [-Sync]
```

The script handles all version switching logic including:
- Automatic Vault root detection
- Version validation
- H: drive mapping via `subst` command
- Uncommitted change warnings
- Optional git fetch sync
- Status reporting

Parameters are passed directly from the command invocation to the PowerShell script.
