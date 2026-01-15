# Environment Setup and Requirements

## System Requirements
- **OS**: Windows (Windows 10 or later)
- **PowerShell**: 5.0 or higher (check with `$PSVersionTable.PSVersion`)
- **Git**: 2.7 or later (check with `git --version`)
- **Administrator Privileges**: Required for H: drive mapping via `subst` command

## Windows Environment Variables
- Git should be in PATH for `git` commands to work
- PowerShell execution policy: Set to `RemoteSigned` for local script execution
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

## Working Directory
- Current working directory: `D:\Works\AI\CluadeCodePlugin\vault-worktree`
- Git repository: Initialized and clean
- Main branch: `master`

## Claude Code Setup
- **Context**: Desktop application
- **Modes**: Interactive, Editing
- **Project**: vault-worktree (active)
- **Available Projects**: FMPanel, ai-toolbox, plm-core, plmsinglepage, vault, vault-worktree

## File Permissions
- All `.ps1` scripts should be readable and executable
- `.claude-plugin/` directory contains plugin manifest
- `.serena/` directory for Serena session storage

## Development Tools Available
- **Serena MCP Server**: For semantic code understanding
- **File Operations**: Read, write, edit, rename symbols
- **Symbol Operations**: Find, reference, rename across codebase
- **Memory Management**: For session persistence and task tracking

## Git Configuration
```
Current branch: master
Main branch: master
Repository status: clean
```

## Quick Environment Check
```powershell
# PowerShell version
$PSVersionTable.PSVersion

# Git version
git --version

# Administrator status
[bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match \"S-1-5-32-544\")

# Current directory
Get-Location

# Vault root (from any subdirectory)
# Run lib-vault-utils to get Find-VaultRoot
```

## Marketplace Configuration Path
- Local marketplace: `.\.claude-plugin\marketplace.json`
- Plugin manifest: `.\.claude-plugin\plugin.json`
- Both files should be valid JSON
