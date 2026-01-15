# Vault Worktree Plugin - Project Overview

## Project Purpose
Automate Vault development workflow with fast version switching and branch management using git worktrees and Windows drive mapping. Reduces version changes from **20-40 minutes to <5 seconds**.

## Core Value Proposition
- **Speed**: Version switching in <5 seconds instead of 20-40 minutes
- **Storage Efficiency**: ~30% storage vs full clones using git worktree architecture
- **Automation**: Natural language interaction via Claude Code Skills
- **Safety**: PreToolUse hooks prevent cross-version modifications

## Tech Stack
- **Language**: PowerShell 5.0+ (primary scripting)
- **Platform**: Windows with administrator privileges
- **Version Control**: Git 2.7+
- **Framework**: Claude Code v2.x plugin system
- **Plugin System**: Skills (primary) + Commands (legacy v1.x compatibility)

## Key Technologies
- Git worktrees (shared .git database with multiple working directories)
- Windows `subst` command for H: drive mapping
- PowerShell scripts for automation and utilities
- Claude Code Skills for natural language interface
- PreToolUse hooks for validation

## Project Structure

```
vault-worktree/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest v2.1.0
├── .claude-plugin/
│   └── marketplace.json         # Marketplace configuration
├── skills/
│   └── vault-worktree.md        # Main skill for v2.x
├── commands/                    # Legacy v1.x commands
│   ├── diagnose.md
│   ├── status.md
│   ├── switch-branch.md
│   ├── switch-version.md
│   └── worktree-init.md
├── hooks/
│   ├── hooks.json               # Hook configuration
│   └── scripts/
│       └── validate-version-match.ps1
├── scripts/                     # PowerShell implementation
│   ├── cmd-diagnose.ps1
│   ├── cmd-status.ps1
│   ├── cmd-switch-branch.ps1
│   ├── cmd-switch-version.ps1
│   ├── cmd-worktree-init.ps1
│   ├── lib-vault-config.ps1     # Configuration utilities
│   └── lib-vault-utils.ps1      # Shared utilities library
├── .gitignore                   # Git ignore rules
├── LICENSE                      # MIT License
└── README.md                    # Documentation
```

## Plugin Configuration
- **Name**: vault-worktree
- **Version**: 2.1.0
- **Author**: pengcheng lu (pengcheng.lu@autodesk.com)
- **License**: MIT
- **Keywords**: vault, worktree, git, version-management, branch-switching, windows, powershell

## Core Dependencies
- PowerShell 5.0+ (Windows)
- Git 2.7+
- Administrator privileges (for H: drive mapping)
- Vault project with git repository
