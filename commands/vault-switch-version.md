---
description: Switch to a specific Vault version (2025, 2026, 2027, etc.)
---

# Switch Vault Version

Switch the development environment to work with a specific Vault version.

## Usage

Ask me to switch to a Vault version, for example:
- "Switch to Vault 2027"
- "Change to vault-2026.x version"
- "I need to work on 2025"

## What happens

1. Verify the target version directory exists
2. Map the H: drive to the selected version
3. Update the git worktree configuration
4. Display confirmation with new version and branch info

## Requirements

- Administrator privileges for H: drive mapping
- Target version directory must exist in your worktree
