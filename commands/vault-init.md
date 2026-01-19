---
description: Initialize or reinitialize the Vault worktree multi-version structure
allowed-tools: Bash(powershell:*), Bash(git:*)
---

Set up or reinitialize the complete Vault worktree structure for multi-version development.

Execute the initialization script:

!`powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/cmd-worktree-init.ps1"`

The initialization will:
1. Create multi-version directory structure (for Vault 2025, 2026, 2027, etc.)
2. Initialize git worktrees for each Vault version
3. Set up H: drive mapping configuration
4. Validate environment setup
5. Create necessary configuration files

After execution:
- Confirm successful worktree structure creation
- Display initialized versions and locations
- Show H: drive mapping configuration
- Provide next steps for first-time setup

Note: This should typically be run once during initial setup, but can be re-run to repair a corrupted worktree configuration.
