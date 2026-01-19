---
name: vault-worktree
description: Teaches Claude about Vault development workflow automation using git worktrees, version management, and branch switching for Windows-based Vault projects
---

# Vault Worktree Automation Skill

This skill provides Claude with knowledge for automating Vault development workflows:

- **Version Switching**: Map Vault versions (2025, 2026, 2027, etc.) to H: drive with instant switching
- **Branch Management**: Switch Git branches by ticket number (PDM-xxxxx) or feature branches
- **Status Monitoring**: Check worktree status, uncommitted changes, and unpushed commits
- **Troubleshooting**: Diagnose PowerShell, Git, and worktree configuration issues
- **Initialization**: Set up multi-version git worktree structure with shared .git database

## How Claude Helps Users

When a user asks to perform Vault operations, Claude matches the request to the appropriate operation:

### 1. Version Switching
**User intent**: Switch to a specific Vault version (2025, 2026, 2027, etc.)

**Examples Claude recognizes**:
- "Switch me to Vault 2027"
- "Change to vault-2026.x version"
- "I need to work on the 2025 version"
- "Map the H: drive to vault-2027"

**Claude's action**: Runs `cmd-switch-version.ps1` with the version number, then verifies the H: drive mapping

---

### 2. Branch Switching
**User intent**: Switch Git branches, typically by ticket number

**Examples Claude recognizes**:
- "Switch to branch PDM-49688"
- "Check out feature/auth-improvements"
- "Change to main branch"
- "I need to work on PDM-12345"

**Claude's action**: Runs `cmd-switch-branch.ps1` with the branch name, then shows the new branch status

---

### 3. Status Checking
**User intent**: Get current Vault status, branch, and uncommitted work

**Examples Claude recognizes**:
- "What version am I on?"
- "Show me the current git status"
- "Check my worktree setup"
- "Do I have any uncommitted changes?"

**Claude's action**: Runs `cmd-status.ps1` and interprets the output for the user

---

### 4. Troubleshooting
**User intent**: Diagnose configuration or functionality issues

**Examples Claude recognizes**:
- "Why isn't the version switch working?"
- "Check my environment"
- "Diagnose what's wrong"
- "PowerShell version check"

**Claude's action**: Runs `cmd-diagnose.ps1` to validate environment and provide solutions

---

### 5. Initialization
**User intent**: Set up the git worktree structure for the first time

**Examples Claude recognizes**:
- "Set up the worktree structure"
- "Initialize worktree"
- "Create version directories"
- "First-time setup for vault"

**Claude's action**: Runs `cmd-worktree-init.ps1` and guides through initial configuration

---

## Prerequisites

- **Operating System**: Windows with PowerShell 5.0+
- **Version Control**: Git 2.7+
- **Repository**: Vault project with git repository initialized
- **Permissions**: Administrator privileges (required for H: drive mapping)

## Implementation Details

When Claude recognizes a user request matching this skill:
1. Identifies the operation type (version switch, branch switch, status, diagnose, init)
2. Extracts parameters (version number, branch name, etc.)
3. Executes the appropriate PowerShell script from `${CLAUDE_PLUGIN_ROOT}/scripts/`
4. Parses the output to extract status and results
5. Provides user-friendly feedback with actionable next steps
6. If errors occur, guides the user toward resolution
