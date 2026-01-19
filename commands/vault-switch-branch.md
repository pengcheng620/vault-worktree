---
description: Switch Git branch (supports ticket numbers like PDM-xxxxx)
argument-hint: "[branch-name]"
allowed-tools: Bash(powershell:*), Bash(git:*)
---

When the user requests to switch Git branches:

1. Execute the branch switch script with the branch name:

!`powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-switch-branch.ps1" -Branch $1`

2. Analyze the output to determine success/failure

3. Provide the user with:
   - ✅ Confirmation of successful branch switch with current branch name
   - ✅ Show working directory status (clean, or list uncommitted changes)
   - ❌ Error message if branch doesn't exist or switch failed
   - ⚠️ Warning if uncommitted changes exist and may be affected

4. Suggest next steps (e.g., "You can now start working on your changes")
