---
description: Initialize or reinitialize the Vault worktree multi-version structure
allowed-tools: Bash(powershell:*), Bash(git:*)
---

When the user wants to initialize the Vault worktree structure:

1. Execute the initialization script:

!`powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-worktree-init.ps1"`

2. Parse the output to identify:
   - ✅ Successfully created worktree directories (vault-2025, vault-2026, etc.)
   - ✅ Git worktrees initialized
   - ✅ Configuration files created
   - ❌ Any failures or permission issues

3. Provide the user with:
   - Summary of initialization (successful/failed)
   - List of created versions and their paths
   - H: drive mapping status
   - ✅ Confirmation that they can now switch versions

4. Suggest next steps:
   - "Try switching to a version with: /vault-switch-version 2027"
   - "Check your status with: /vault-status"
   - Explain that they can now use version switching commands

5. Guidance for issues:
   - If permission denied: explain administrator privileges are needed
   - If git errors: run diagnostics with /vault-diagnose
   - Note: This can be re-run to repair corrupted worktree configuration
