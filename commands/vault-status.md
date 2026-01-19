---
description: Check current Vault version, branch, and worktree status
allowed-tools: Bash(powershell:*), Bash(git:*)
---

When the user asks about Vault or worktree status:

1. Execute the status script:

!`powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-status.ps1"`

2. Parse the output to extract key information:
   - Current Vault version (from H: drive mapping)
   - Current Git branch
   - Working directory status (clean or uncommitted changes)
   - Number of uncommitted files
   - Number of unpushed commits (if any)

3. Present the information to the user in a clear format:
   - ✅ If clean: "You're on [version] / [branch] with a clean working directory"
   - ⚠️ If uncommitted: "You have [N] uncommitted changes on [version] / [branch]"
   - 📤 If unpushed: "You have [N] unpushed commits - consider running 'git push'"

4. Suggest next steps based on status
