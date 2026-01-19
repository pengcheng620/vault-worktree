---
name: vault-worktree
description: Automate Vault version and branch management with git worktrees
---

# Vault Worktree Management

Automated workflows for managing Vault development across multiple versions using git worktrees and drive mapping.

## Available Operations

### 1. Switch Vault Version

When a user asks to switch to a specific Vault version (2025, 2026, 2027, etc.), run:

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-switch-version.ps1" -Version <version>
```

**Examples:**
- "Switch to Vault 2027"
- "Change to vault-2026.x version"
- "I need to work on 2025"

### 2. Switch Git Branch

When a user asks to change branches (with ticket numbers like PDM-xxxxx), run:

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-switch-branch.ps1" -Branch <branch>
```

**Examples:**
- "Switch to branch PDM-49688"
- "Check out feature/auth-improvements"
- "Change to main branch"

### 3. Check Worktree Status

When a user asks for current status or wants diagnostics, run:

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-status.ps1"
```

**Examples:**
- "What version am I on?"
- "Show me the current git status"
- "Check worktree setup"

### 4. Run Diagnostics

When troubleshooting or environment issues, run:

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-diagnose.ps1"
```

**Examples:**
- "Why isn't the version switch working?"
- "Check my environment"
- "Diagnose the setup"

### 5. Initialize Worktree

When setting up or reinitializing the worktree structure, run:

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-worktree-init.ps1"
```

**Examples:**
- "Set up the worktree structure"
- "Initialize worktree"
- "Create version directories"

## How It Works

The plugin provides these capabilities:

1. **Version Switching**: Automatically maps the H: drive to the selected Vault version directory
2. **Branch Management**: Switches git branches within the current version
3. **Status Reporting**: Shows current version, branch, and uncommitted changes
4. **Environment Diagnostics**: Validates PowerShell, git, and directory structure
5. **Worktree Initialization**: Creates the multi-version worktree structure

## Requirements

- Windows with PowerShell 5.0+
- Git 2.7+
- Vault project with git repository
- Administrator privileges for H: drive mapping

## Performance

- Version switch: < 5 seconds
- Branch switch: < 2 seconds
- Full initialization: < 30 seconds

## Tips for Best Results

1. **Commit before switching**: Always commit or stash changes before switching versions
2. **Use with diagnose**: If version switch fails, run diagnostics to identify issues
3. **Check status first**: Use status command before making changes to verify current state
4. **Sync periodically**: Use `switch-version --sync` to fetch latest changes from all versions

## Integration Example

Typical workflow when working on a feature:

```
1. User: "Check my current vault status"
   → Run: cmd-status.ps1
   → Output: Current version and branch info

2. User: "Switch me to vault 2027"
   → Run: cmd-switch-version.ps1 -Version 2027
   → Output: Confirms version switch and H: drive mapping

3. User: "Change to branch PDM-12345"
   → Run: cmd-switch-branch.ps1 -Branch PDM-12345
   → Output: Confirms branch change

4. User: "What's my status now?"
   → Run: cmd-status.ps1
   → Output: Shows new version and branch
```

## Troubleshooting

If a command fails:

1. Run diagnostics: `cmd-diagnose.ps1`
2. Check PowerShell version: `$PSVersionTable.PSVersion`
3. Verify git is installed: `git --version`
4. Ensure you have admin privileges for H: drive mapping

For detailed error messages, check the script output and PowerShell logs.
