# Suggested Commands - Vault Worktree Plugin Development

## PowerShell Execution

### Running Scripts
```powershell
# Execute a command script
& \"./scripts/cmd-status.ps1\"

# Source library functions
. \"./scripts/lib-vault-utils.ps1\"
. \"./scripts/lib-vault-config.ps1\"

# Run diagnostic script
& \"./scripts/cmd-diagnose.ps1\"
```

### PowerShell Utilities
```powershell
# Check PowerShell version (needs 5.0+)
$PSVersionTable.PSVersion

# Import module for development
Import-Module ./scripts/lib-vault-utils.ps1

# Test script syntax
Test-Path ./scripts/cmd-status.ps1
```

## Git Operations

### Repository Status
```powershell
git status
git branch -a
git log --oneline -10
```

### Branch Management
```powershell
git checkout -b feature/your-feature
git add .
git commit -m \"message\"
git push origin feature/your-feature
```

### Testing Changes
```powershell
# Test locally before marketplace
/plugin marketplace add ./vault-worktree
/plugin install vault-worktree

# Verify marketplace configuration
Test-Json .\.claude-plugin\marketplace.json
```

## Development Workflow

### Testing New Features
```powershell
# 1. Make changes to scripts
# 2. Test locally via Claude Code
# 3. Verify all functions work
# 4. Test via Skills interface
# 5. Check marketplace.json validity
# 6. Commit and push
```

### Validation Checklist
```powershell
# Before committing
1. Test on Windows with admin privileges
2. Verify PowerShell 5.0+ compatibility
3. Check git worktree functionality
4. Test all Skills work correctly
5. Validate H: drive mapping
6. Verify marketplace.json is valid JSON
```

### Quick Testing
```powershell
# Test vault detection
. ./scripts/lib-vault-utils.ps1
Find-VaultRoot

# Test H: mapping
Get-HMapping

# Test version detection
$vaultRoot = Find-VaultRoot
Get-AvailableVersions $vaultRoot

# Test git operations
$versionPath = \"D:\\path\\to\\vault-2027\"
Get-GitStatus $versionPath
```

## Plugin Management

### Local Installation
```bash
# Add local marketplace
/plugin marketplace add ./vault-worktree

# Install plugin
/plugin install vault-worktree

# List installed plugins
/plugin list

# Uninstall if needed
/plugin uninstall vault-worktree
```

### GitHub Installation (Testing)
```bash
# Test GitHub marketplace
/plugin marketplace add https://github.com/pengcheng620/vault-worktree

# Install from GitHub
/plugin install vault-worktree@pengcheng620/vault-worktree
```

## File Operations

### Check File Permissions
```powershell
# On Windows with admin terminal
Get-Item ./scripts/*.ps1 | Get-Acl

# Set execution policy if needed
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Validate JSON Files
```powershell
# Check plugin.json
$pluginJson = Get-Content .\.claude-plugin\plugin.json | ConvertFrom-Json
$pluginJson

# Check marketplace.json
$marketplaceJson = Get-Content .\.claude-plugin\marketplace.json | ConvertFrom-Json
$marketplaceJson
```

## Troubleshooting

### PowerShell Issues
```powershell
# Check execution policy
Get-ExecutionPolicy

# Set for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Check module loading
Import-Module ./scripts/lib-vault-utils.ps1 -Verbose
```

### Git Worktree Issues
```powershell
# List all worktrees
git worktree list

# Check git configuration
git config --list

# Verify .git directory
Test-Path .\.git
```

### H: Drive Issues
```powershell
# Check current H: mapping
subst h:

# Remove H: mapping if stuck
subst h: /d

# Manual H: mapping (for testing)
subst h: \"D:\path\to\version\"
```

## Documentation

### Markdown Validation
```powershell
# Check markdown links
# Use markdown linter or manual review

# Validate YAML frontmatter in skills
# Ensure valid YAML syntax in .md files
```

### README Updates
```powershell
# After changes, update README.md with:
# - New features/operations
# - Updated troubleshooting section
# - Architecture changes (if any)
```
