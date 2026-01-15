---
name: vault-worktree:diagnose
description: Complete environment and status diagnostics for troubleshooting Vault setup
argument-hint: [--verbose]
allowed-tools: Bash
---

# Diagnose Environment

Comprehensive diagnostics for your Vault worktree environment. Helps identify and fix issues quickly.

## Usage

```
/vault-worktree:diagnose              # Quick diagnosis
/vault-worktree:diagnose --verbose    # Detailed report
```

## Arguments

- `--verbose`: Show detailed information including all branches, full paths, and technical details

## What This Command Checks

### Core Information
- Windows version and PowerShell version
- Git installation and version
- Java/build tool status (if applicable)
- Vault project root directory

### Worktree Structure
- All vault-xxxx directories
- Directory sizes and available space
- Shared .git database status
- Each worktree's health

### Current Mapping
- H: drive mapping status
- Current version
- Current branch
- Git status for current directory

### Build Information
- Size of bin/ directory
- Size of obj/ directory
- Size of packages/ directory
- Disk space available
- Recent build artifacts

### Team Collaboration
- All branches across all versions
- Last commit dates
- Remote sync status
- Uncommitted changes in each worktree

## Output Examples

### Quick Diagnose (Default)
```
🔍 Vault Environment Diagnostics Report
════════════════════════════════════════════

✅ System Environment
   Windows: 11 Pro (Build 22631)
   PowerShell: 7.4.1
   Git: 2.47.0
   Vault Root: D:\Works\Vault\vault

✅ Worktree Structure
   vault-2025  (6.5GB) [OK]
   vault-2026  (6.8GB) [OK]
   vault-2027  (7.2GB) [OK]
   Total Size: 20.5GB
   Free Space: 250GB [OK]

✅ Current Mapping
   H: → D:\Works\Vault\vault-2027
   Branch: lpc/PDM-49688-1
   Status: Clean (no uncommitted changes)

✅ Build Status
   bin/       2.5GB
   obj/       1.2GB
   packages/  10GB
   Status: Normal

✅ Overall Status
   🎯 All systems operational
   → Ready to work!
```

### With Issues
```
[Same as above, but with warnings]

⚠️  Detected Issues
   1. vault-2026 has uncommitted changes (1 file modified)
      → Consider committing: git add . && git commit

   2. packages/ is 10GB (may slow compile)
      → Consider cleanup if build is slow

   3. Last sync was 5 hours ago
      → Consider running: /vault-worktree:status --sync
```

### --verbose Output
```
[All of above, plus:]

📊 Detailed Branch Information

   vault-2025 (R2025.x):
      R2025.x → origin/R2025.x [sync: 3 days ago]
      Branches: 5 total

   vault-2026 (R2026.x):
      R2026.x → origin/R2026.x [sync: 1 hour ago]
      lpc/PDM-49689-1 → origin/lpc/PDM-49689-1 [new: 2 commits]
      Branches: 7 total

   vault-2027 (lpc/PDM-49688-1):
      lpc/PDM-49688-1 [local, unpushed: 1 commit]
      R2027.1 → origin/R2027.1 [sync: 30 minutes ago]
      Branches: 9 total

📝 File System Details
   .git database: 500MB
   vault-2025 path: D:\Works\Vault\vault-2025
   vault-2026 path: D:\Works\Vault\vault-2026
   vault-2027 path: D:\Works\Vault\vault-2027

🔧 Git Configuration
   user.name: pengcheng lu
   user.email: pengcheng.lu@autodesk.com
   core.autocrlf: true
   submodules: 0
```

## When to Use Diagnose

**Use quick diagnose when:**
- Verifying setup is correct
- Quick health check before important work
- Sharing status with team lead
- Troubleshooting straightforward issues

**Use --verbose when:**
- Troubleshooting complex problems
- Detailed issue investigation
- Full system analysis needed
- Sharing with technical support

## Common Issues & Solutions

### Issue: "H: drive not mapped"
```
Problem:
   ❌ H: → (not mapped)

Solution:
   /vault-worktree:switch-version 2027
   This will map H: automatically
```

### Issue: "Uncommitted changes in version"
```
Problem:
   ⚠️  vault-2026 has uncommitted changes

Solution 1: If changes are yours
   cd vault-2026 (or switch to that version)
   git add . && git commit -m "..."

Solution 2: If changes are mistakes
   git checkout -- .  (discard)
   git clean -fd     (remove untracked)
```

### Issue: "packages/ directory is huge"
```
Problem:
   packages/ is 15GB (very large)

Solution:
   This is normal for large projects
   If builds are slow, consider:
   1. NuGet cache cleanup: nuget locals all -clear
   2. Or use: /vault-worktree:status --sync
```

### Issue: "Out of sync with remote"
```
Problem:
   Last sync was 8 hours ago
   Teammates pushed changes

Solution:
   /vault-worktree:status --sync
   This will fetch all updates

   Then merge/rebase as needed:
   git pull origin <branch-name>
```

## Technical Details (--verbose includes)

### What Gets Checked
1. **System Tools**
   - PowerShell version
   - Git version and configuration
   - Available disk space
   - File system accessibility

2. **Worktree Health**
   - .git integrity
   - Index file validity
   - Ref count
   - Object database size

3. **Branch Status**
   - Local vs remote comparison
   - Unpushed commits count
   - Uncommitted changes count
   - Merge conflict status

4. **Disk Usage**
   - Directory sizes
   - Fragmentation indicators
   - Free space percentage

## Tips

✅ **Run daily:** `/vault-worktree:diagnose` takes < 5 seconds
✅ **Share output:** Easy way to report issues to tech support
✅ **Use --verbose:** When weird things happen
✅ **Track changes:** Good baseline to compare later

## Related Commands

- `/vault-worktree:status` - Simpler status check
- `/vault-worktree:switch-version` - Fix mapping issues
- `/vault-worktree:worktree-init` - Recover from corruption

## Integration with Support

When reporting issues, share:
```
1. Output from: /vault-worktree:diagnose --verbose
2. What you were doing when issue happened
3. Expected vs actual behavior
4. Any error messages you saw
```

This gives support team complete picture of your environment.

---

## Implementation Instructions

When this command is invoked, execute the following PowerShell script:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-diagnose.ps1" [-Verbose]
```

The script performs comprehensive diagnostics including:
- System information (Windows version, PowerShell version, Git version)
- Vault root detection and validation
- Worktree structure analysis with size information
- Current H: drive mapping status
- Build directory analysis (bin/, obj/, packages/)
- Git configuration details
- Branch information across all versions
- Disk space availability checks
- Issue detection and remediation suggestions

The --verbose flag provides detailed information about branches, configurations, and system details.
