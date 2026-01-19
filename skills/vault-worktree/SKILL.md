---
name: vault-worktree
description: When Claude detects user is working with Vault development workflow, version switching, or worktree management tasks
---

# Vault Worktree Automation Skill

Automatically activate when user mentions:
- Switching Vault versions (2025, 2026, 2027, etc.)
- Changing Git branches with ticket numbers (PDM-xxxxx, feature branches)
- Checking Vault status or environment
- Troubleshooting Vault or worktree issues
- Setting up or initializing Vault worktree structure

## Automated Operations

When this skill activates, intelligently route user requests to appropriate PowerShell scripts:

### 1. Version Switching
When user asks to switch to a specific Vault version:

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-switch-version.ps1" -Version <version>
```

Examples that trigger this:
- "Switch me to Vault 2027"
- "Change to vault-2026.x version"
- "I need to work on the 2025 version"

### 2. Branch Switching
When user asks to change Git branches:

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-switch-branch.ps1" -Branch <branch>
```

Examples that trigger this:
- "Switch to branch PDM-49688"
- "Check out feature/auth-improvements"
- "Change to main branch"

### 3. Status Checking
When user asks about current status or configuration:

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-status.ps1"
```

Examples that trigger this:
- "What version am I on?"
- "Show me the current git status"
- "Check my worktree setup"

### 4. Troubleshooting
When user reports issues or asks for diagnostics:

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-diagnose.ps1"
```

Examples that trigger this:
- "Why isn't the version switch working?"
- "Check my environment"
- "Diagnose what's wrong"

### 5. Initialization
When user wants to set up the worktree structure:

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-worktree-init.ps1"
```

Examples that trigger this:
- "Set up the worktree structure"
- "Initialize worktree"
- "Create version directories"

## Environment Requirements

- Windows with PowerShell 5.0+
- Git 2.7+
- Vault project with git repository
- Administrator privileges for H: drive mapping

## Skill Behavior

1. **Detection**: Monitor for Vault-related keywords and version numbers
2. **Routing**: Direct requests to appropriate PowerShell script
3. **Execution**: Run scripts with proper environment variables
4. **Feedback**: Analyze output and provide user-friendly status updates
5. **Error Handling**: Guide troubleshooting for failed operations

## Integration with Commands

This skill powers the following user-available commands:
- `/vault-switch-version` - Manual version switching
- `/vault-switch-branch` - Manual branch switching
- `/vault-status` - Manual status checking
- `/vault-diagnose` - Manual diagnostics
- `/vault-init` - Manual worktree initialization

Users can either invoke commands directly or describe their task naturally, and this skill will automatically activate.
