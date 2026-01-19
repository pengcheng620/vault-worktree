---
description: Run diagnostics to troubleshoot environment and configuration issues
---

# Vault Diagnostics

Run comprehensive diagnostics to identify environment issues and validate your setup.

## Usage

Ask me to diagnose problems, for example:
- "Why isn't the version switch working?"
- "Check my environment"
- "Diagnose the setup"

## What it checks

- PowerShell version (requires 5.0+)
- Git installation and version
- H: drive mapping configuration
- Directory structure and permissions
- Vault repository status
- Worktree configuration validity

## Troubleshooting

If you encounter issues:
1. Run this command to get detailed diagnostics
2. Check PowerShell version: `$PSVersionTable.PSVersion`
3. Verify git is installed: `git --version`
4. Ensure administrator privileges for drive mapping
