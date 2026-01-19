---
description: Run diagnostics to troubleshoot environment and configuration issues
allowed-tools: Bash(powershell:*), Bash(git:*)
---

When the user reports issues or asks for environment diagnostics:

1. Execute the diagnostics script:

!`powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-diagnose.ps1"`

2. Parse the output to identify:
   - ✅ Passing checks (PowerShell, Git, H: drive, directory structure)
   - ❌ Failing checks and their root causes
   - ⚠️ Warnings or configuration issues

3. Provide the user with:
   - Summary of environment health (healthy, has issues, critical problems)
   - List of specific problems found (if any)
   - Root cause explanation for each issue
   - Step-by-step resolution instructions
   - Examples of commands to fix issues (e.g., "Run: powershell -ExecutionPolicy Bypass...")

4. If all checks pass, confirm the environment is ready for use
