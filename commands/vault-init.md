---
description: Initialize or reinitialize the Vault worktree multi-version structure
---

# Initialize Vault Worktree

Set up or reinitialize the complete worktree structure for multi-version Vault development.

## Usage

Ask me to initialize the worktree, for example:
- "Set up the worktree structure"
- "Initialize worktree"
- "Create version directories"

## What it does

1. Creates multi-version directory structure
2. Initializes git worktrees for each Vault version
3. Sets up H: drive mapping configuration
4. Validates environment setup
5. Creates necessary configuration files

## First-time setup

This command should be run once to establish your Vault development environment. It will:
- Create directories for Vault versions (2025, 2026, 2027, etc.)
- Initialize git worktrees for parallel development
- Set up drive mapping for seamless version switching

## Requirements

- Administrator privileges
- Git 2.7+
- PowerShell 5.0+
- Sufficient disk space for multiple versions
