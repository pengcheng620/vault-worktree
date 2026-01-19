---
description: Run diagnostics to troubleshoot environment and configuration issues
allowed-tools: Bash(powershell:*), Bash(git:*)
---

Run comprehensive diagnostics on the Vault development environment.

Execute the diagnostics script:

!`powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-diagnose.ps1"`

The diagnostics will check:
- PowerShell version (requires 5.0+)
- Git installation and version
- H: drive mapping configuration
- Directory structure and permissions
- Vault repository status
- Worktree configuration validity

Analyze the output and provide:
- Summary of environment health
- Any issues or misconfigurations found
- Recommended actions to resolve issues
