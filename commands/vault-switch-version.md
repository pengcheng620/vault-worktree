---
description: Switch to a specific Vault version (2025, 2026, 2027, etc.)
argument-hint: [version]
allowed-tools: Bash(powershell:*)
---

Switch the Vault development environment to work with version $1.

Execute the version switch script:

!`powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-switch-version.ps1" -Version $1`

After execution:
- Confirm the H: drive mapping is set to the correct version directory
- Display the new Vault version and current branch
- Alert user to commit/stash changes before switching if needed
