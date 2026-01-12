# Vault Worktree Plugin

Automate Vault development workflow with fast version switching and branch management. Reduce version changes from **20-40 minutes to <5 seconds**.

## Problem

Switching between Vault versions manually takes 20-40 minutes per change. This plugin reduces it to seconds using git worktrees and Windows drive mapping.

## 📥 Installation

### **Option 1: From GitHub Marketplace (Recommended)**

```bash
# Step 1: Add the marketplace
/plugin marketplace add pengcheng620/vault-worktree

# Step 2: Verify the marketplace was added
/plugin marketplace list

# Step 3: Install the plugin
/plugin install vault-worktree@pengcheng620/vault-worktree

# Step 4: Restart Claude Code to activate
```

### **Option 2: From Local Directory**

```bash
# Step 1: Clone the repository
cd ~/.claude/plugins
git clone https://github.com/pengcheng620/vault-worktree

# Step 2: Restart Claude Code
```

### **Option 3: From Git URL**

```bash
# Step 1: Add GitHub repository as marketplace
/plugin marketplace add https://github.com/pengcheng620/vault-worktree

# Step 2: Install from marketplace
/plugin install vault-worktree@pengcheng620/vault-worktree
```

### **Troubleshooting Installation**

If you get "Marketplace not found" error:

```bash
# Try using the full GitHub URL
/plugin marketplace add https://github.com/pengcheng620/vault-worktree

# Or add from local path
/plugin marketplace add /path/to/vault-worktree

# Verify installation
/plugin list
```

## Features & Usage

### 🚀 Quick Commands

Simply ask Claude to perform these operations:

- **"Switch to Vault 2027"** → Automatically maps version, checks for uncommitted changes
- **"Change branch to PDM-49688"** → Switches git branches in current version
- **"What's my current status?"** → Shows version, branch, uncommitted changes
- **"Initialize the worktree"** → Sets up multi-version structure
- **"Diagnose my setup"** → Validates environment and identifies issues

### 📋 Available Operations

| Operation | Command | Purpose |
|-----------|---------|---------|
| **Switch Version** | `switch-version 2027` | Map H: drive to specific version |
| **Switch Branch** | `switch-branch PDM-49688` | Change git branches |
| **Check Status** | `status` | View worktree/git status |
| **Run Diagnostics** | `diagnose` | Validate environment |
| **Initialize** | `worktree-init` | Setup worktree structure |

### 💡 Typical Workflow

```
1. "Check my vault status"
   ✅ Shows: Version 2026, branch: main, clean

2. "Switch to vault 2027"
   ✅ Switches and maps H: drive

3. "Change to branch PDM-12345"
   ✅ Updates git branch

4. "What's my status now?"
   ✅ Shows: Version 2027, branch: PDM-12345, clean
```

## Requirements

- Windows with PowerShell 5.0+
- Git 2.7+
- Vault project with git repository
- Administrator privileges (for H: drive mapping)

## ⚡ Getting Started (5 Minutes)

### After Installation

1. **Restart Claude Code**
   ```bash
   # Close and reopen Claude Code
   ```

2. **Test the Skill**
   - Ask Claude: **"Show me my vault status"**
   - Claude should output your current version and branch

3. **Try a Version Switch**
   - Ask Claude: **"Switch to Vault 2027"**
   - The H: drive should now point to vault-2027

4. **Verify Success**
   - Ask Claude: **"What vault version am I on?"**
   - Should show the switched version

### Example Conversation

```
You:    "Switch to Vault 2027"
Claude: ✅ Switched to vault-2027 worktree
        Branch: main
        Status: working directory clean

You:    "Change branch to PDM-49688"
Claude: ✅ Switched to branch PDM-49688

You:    "Show me the status"
Claude: ✅ Current Status:
        Version: vault-2027
        Branch: PDM-49688
        Uncommitted: 0 files
```

## 🏗️ Architecture

### How It Works

- **Auto-Detection:** Finds Vault root directory automatically from any subdirectory
- **Git Worktrees:** Uses shared `.git` database with multiple working directories per version
- **H: Drive Mapping:** Maps selected version to H: drive via Windows `subst` command for quick access
- **Protective Hooks:** PreToolUse hooks warn if editing files outside current version context
- **Dynamic Paths:** No configuration needed - adapts to any team directory structure

### Performance Characteristics

| Operation | Time | Storage |
|-----------|------|---------|
| Version switch | <5 seconds | N/A |
| Branch switch | <2 seconds | N/A |
| Full initialization | <30 seconds | ~30% vs full clones |

### Design Rationale

Uses git worktree architecture rather than full clones:
- **Shared .git**: Single git database, multiple working directories = minimal storage
- **Speed**: <5 seconds per version switch
- **Space**: ~30% storage vs full clones
- **Safety**: PreToolUse validation prevents cross-version modifications

## 🤔 Why Skills Instead of Slash Commands?

This plugin uses **Skills** as the primary interface for Claude Code v2.x compatibility. Here's why:

| Aspect | Skills | Slash Commands |
|--------|--------|-----------------|
| **v2.x Support** | ✅ Fully working | ⚠️ Known bugs (Issue #9518) |
| **Natural Language** | ✅ Claude understands intent | ❌ Requires exact syntax |
| **Auto-Discovery** | ✅ Reliable | ❌ Inconsistent in local plugins |
| **Development Speed** | ✅ Faster iteration | ❌ Requires UI registration |
| **User Experience** | ✅ Conversational | ❌ Mechanical |

**Result:** You get a more natural experience where you can say "Switch to Vault 2027" and Claude automatically runs the right script.

---

## 🐛 Troubleshooting

### Version switch not working?
```bash
# 1. Check diagnostics
/ask: Run vault-worktree diagnose

# 2. Verify PowerShell
$PSVersionTable.PSVersion

# 3. Check git
git --version

# 4. Verify admin privileges
# (Required for H: drive mapping)
```

### H: drive not mapped?
```bash
# Check current mapping
subst h:

# Manual mapping (if needed)
subst h: "D:\path\to\vault\version"
```

### Uncommitted changes blocking switch?
```bash
# Check status
/ask: Show vault-worktree status

# Commit or stash changes
git commit -am "message"
# or
git stash
```

### Permission denied errors?
- Ensure PowerShell running with administrator privileges
- Required for: H: drive mapping, worktree initialization

## 📦 Project Structure

```
vault-worktree/
├── .claude-plugin/
│   └── plugin.json              # Plugin configuration
├── skills/
│   └── vault-worktree.md        # Main skill for v2.x compatibility
├── commands/                    # Legacy commands (v1.x compatibility)
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
│   └── lib-vault-utils.ps1      # Shared utilities
├── plugin-manifest.json         # Marketplace metadata
└── README.md
```

## 📚 Technical Details

### Skills Integration

The plugin includes `skills/vault-worktree.md` which teaches Claude about available operations:

```markdown
# When Claude understands user intent like:
- "Switch to Vault 2027"
- "Change branch to PDM-xxxxx"

# Claude will:
1. Recognize the request matches vault-worktree skill
2. Call the appropriate PowerShell script
3. Return results to user
```

### Marketplace Configuration

The `.claude-plugin/marketplace.json` enables:
- Plugin discovery in Claude Code
- Marketplace registration via `/plugin marketplace add pengcheng620/vault-worktree`
- Automatic plugin installation
- Version management

### Hook Validation

`hooks/hooks.json` configures PreToolUse validation:
- Detects when trying to edit files in wrong Vault version
- Warns user before proceeding
- Prevents accidental cross-version changes

---

## 🤝 Contributing

Issues and pull requests welcome! Please:
1. Test on Windows with PowerShell 5.0+
2. Include git worktree validation steps
3. Test with multiple Vault versions
4. Ensure `.claude-plugin/marketplace.json` is valid JSON

### Development Workflow

```bash
# 1. Clone locally
git clone https://github.com/pengcheng620/vault-worktree.git

# 2. Test locally
/plugin marketplace add ./vault-worktree
/plugin install vault-worktree

# 3. Make changes and test

# 4. Push to GitHub
git push origin main

# 5. Test GitHub installation
/plugin marketplace add pengcheng620/vault-worktree
/plugin install vault-worktree@pengcheng620/vault-worktree
```

## 📄 License

MIT - See LICENSE file

## 👤 Author

pengcheng lu

---

## 🔗 Resources

- [Claude Code Documentation](https://code.claude.com/docs)
- [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)
- [Windows Subst Command](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/subst)
