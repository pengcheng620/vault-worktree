---
description: Switch Git branch (supports ticket numbers like PDM-xxxxx)
argument-hint: [branch-name]
allowed-tools: Bash(powershell:*), Bash(git:*)
---

Switch the current Vault worktree to branch $1.

Execute the branch switch script:

!`powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-switch-branch.ps1" -Branch $1`

After execution:
- Confirm the branch was successfully checked out
- Show current Git status (branch name and working directory state)
- Alert if there are uncommitted changes
