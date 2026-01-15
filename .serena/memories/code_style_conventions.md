# Code Style and Conventions

## PowerShell Standards
- **Comment style**: Multiline comments using `<# #>` for function documentation
- **Function naming**: PascalCase with verb-noun pattern (e.g., `Get-VaultRoot`, `Set-HMapping`)
- **Variable naming**: Either $camelCase or $CONSTANT_CASE for configuration
- **Error handling**: Try-catch blocks with silent failures where appropriate
- **Output**: Color-coded messages using predefined $Colors hashtable
  - Success = Green
  - Warning = Yellow
  - Error = Red
  - Info = Cyan
  - Default = White

## File Organization
- **Scripts**: All .ps1 files in `scripts/` directory
- **Libraries**: Prefix with `lib-` (e.g., `lib-vault-utils.ps1`)
- **Commands**: Prefix with `cmd-` (e.g., `cmd-status.ps1`)
- **Configuration**: In `lib-vault-config.ps1`

## Markdown Documentation
- **YAML Frontmatter**: For skills and commands (Claude Code v2.x format)
- **Headers**: Markdown headers with icons for sections
- **Code blocks**: Triple backticks with language specification

## Architecture Patterns
- **Utility Library**: `lib-vault-utils.ps1` provides reusable functions
- **Core Functions**:
  - Vault detection: `Find-VaultRoot`, `Test-VaultRoot`
  - Version management: `Get-AvailableVersions`, `Get-CurrentVersion`, `Test-Version`
  - H: mapping: `Get-HMapping`, `Set-HMapping`
  - Git operations: `Get-CurrentBranch`, `Get-Branches`, `Get-GitStatus`
  - Validation: `Test-HasUncommittedChanges`, `Get-UncommittedChangeCount`
  - Output formatting: `Write-Header`, `Write-Success`, `Write-Error-Custom`

## Naming Conventions
- **Functions**: Verb-Noun PascalCase (PowerShell standard)
- **Parameters**: PascalCase with [Parameter] attributes
- **Variables**: camelCase for local, $CONSTANT_CASE for config
- **Constants**: Prefixed with $_ or defined in hashtables

## Documentation Comments
- **Format**: PowerShell comment-based help with `<# #>`
- **Sections**: SYNOPSIS, DESCRIPTION, PARAMETER, RETURNS
- **Example**: Included in complex functions

## Code Organization
- **Sections**: Separated with `# ═══════════════════════════════════════════════════`
- **Logic grouping**: Related functions grouped under themed sections
- **Module exports**: `Export-ModuleMember` at end of utility files

## Error Handling Philosophy
- **Silent failures**: Non-critical operations fail silently (e.g., `subst` errors)
- **User feedback**: Important failures show error messages to user
- **Try-catch**: Used for all system operations (git, filesystem, subst)
- **Exit codes**: Checked where important (e.g., `$LASTEXITCODE`)

## Version Detection Strategy
- **Format**: `vault-2025`, `vault-2026`, `vault-2027`, etc.
- **Extraction**: Regex pattern `vault-(\d+[.\w]*)$`
- **Validation**: Directory existence check with `Test-Path`

## Git Integration
- **Detection**: Via `Find-VaultRoot` looking for `.git/` directory
- **Operations**: All git commands use absolute paths and error redirection
- **Branch handling**: Supports local and remote branches with deduplication
- **Status reporting**: Comprehensive status object with branch, changes, and commits
