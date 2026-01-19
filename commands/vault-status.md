---
description: Check current Vault version, branch, and worktree status
allowed-tools: Bash(powershell:*), Bash(git:*)
---

Display the current Vault development environment status.

Execute the status script:

!`powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-status.ps1"`

The output should include:
- Current Vault version
- Current Git branch
- H: drive mapping status
- Number of uncommitted changes
- Working directory cleanliness status

Provide a summary of the current state to the user.
