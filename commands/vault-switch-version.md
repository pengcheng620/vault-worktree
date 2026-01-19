---
description: Switch to a specific Vault version (2025, 2026, 2027, etc.)
argument-hint: "[version]"
allowed-tools: Bash(powershell:*)
---

When the user requests to switch Vault versions:

1. Execute the version switch script with the specified version:

!`powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-switch-version.ps1" -Version $1`

2. Analyze the output to determine success/failure

3. Provide the user with:
   - ✅ Confirmation message if successful (include version and branch)
   - ❌ Error explanation and troubleshooting steps if it fails
   - ⚠️ Warning if there are uncommitted changes that may have been affected

4. Suggest next steps (e.g., "You can now run 'cd h:' to navigate to the version")
