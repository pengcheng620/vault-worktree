---
description: Switch Git branch (supports ticket numbers like PDM-xxxxx)
---

# Switch Git Branch

Change to a different Git branch within the current Vault version.

## Usage

Ask me to switch branches, for example:
- "Switch to branch PDM-49688"
- "Check out feature/auth-improvements"
- "Change to main branch"

## What happens

1. Verify branch exists in current worktree
2. Stash any uncommitted changes (optional)
3. Check out the target branch
4. Display confirmation with current status

## Support

Supports:
- Feature branches (feature/*, bugfix/*)
- Ticket numbers (PDM-*, JIRA-*)
- Standard branches (main, master, develop)
