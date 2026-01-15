# Task Completion Checklist

## Code Changes
- [ ] All changes follow PowerShell conventions (PascalCase functions, Try-catch error handling)
- [ ] Functions use proper comment-based help with SYNOPSIS, PARAMETER, RETURNS
- [ ] Color-coded output uses predefined $Colors hashtable
- [ ] Error messages are user-friendly with emoji indicators (✅, ❌, ⚠️)
- [ ] No console output errors or warnings
- [ ] Scripts handle edge cases and validate inputs
- [ ] Exit codes checked where important (subst, git commands)
- [ ] Silent failures appropriate; critical errors reported to user

## PowerShell Validation
```powershell
# Run before marking complete:
Test-Path ./scripts/*.ps1
# Should return $true for all files

# Check syntax (if modified)
Get-Content ./scripts/cmd-status.ps1
```

## Plugin Configuration
- [ ] `plugin.json` is valid JSON with correct structure
- [ ] `marketplace.json` is valid JSON (if created)
- [ ] Version number updated in plugin.json if feature added
- [ ] All required fields present (name, version, description, author, license)
- [ ] Commands/skills paths point to correct directories

## Git Repository
- [ ] Changes committed with descriptive message
- [ ] Commit follows pattern: `<type>: <description>` (e.g., `feat: add new command`)
- [ ] No uncommitted changes remain
- [ ] Branch is clean and ready to merge

## Testing Requirements
- [ ] Features work in Claude Code Skills interface
- [ ] Skills/commands respond to natural language appropriately
- [ ] H: drive mapping functions correctly
- [ ] Version switching without uncommitted changes works
- [ ] Branch switching functions as expected
- [ ] Diagnostic commands report accurate status
- [ ] Error handling works (e.g., blocks switching with uncommitted changes)
- [ ] Administrator privilege checks pass (for H: mapping)

## Documentation
- [ ] README.md updated with new features (if any)
- [ ] Help text in skills/commands is clear and accurate
- [ ] Installation instructions remain valid
- [ ] Troubleshooting section covers new issues (if any)
- [ ] Code comments explain complex logic
- [ ] Markdown links validate without 404s

## Marketplace Preparation
- [ ] `.claude-plugin/marketplace.json` valid and complete
- [ ] Plugin can be installed via `/plugin marketplace add` command
- [ ] Plugin can be installed via `/plugin install` command
- [ ] Plugin auto-discovers from marketplace

## Final Validation
```powershell
# Windows admin terminal checks:
1. PowerShell version >= 5.0: $PSVersionTable.PSVersion
2. Git installed: git --version
3. Admin privileges: [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match \"S-1-5-32-544\")
4. Scripts executable: Test-Path ./scripts/*.ps1 -ErrorAction SilentlyContinue
5. JSON valid: Get-Content ./.claude-plugin/plugin.json | ConvertFrom-Json
```

## Documentation Artifacts
- [ ] CHANGELOG or version notes added (if significant changes)
- [ ] Code style conventions documented
- [ ] Architecture decisions explained in README
- [ ] Examples provided for new features
- [ ] Troubleshooting guide updated

## Before Final Commit
1. Run all validation checks above
2. Test Skills/commands in Claude Code
3. Verify marketplace.json is present and valid
4. Ensure no sensitive information in commits
5. Check .gitignore doesn't exclude necessary files
6. Verify plugin.json version number is correct
