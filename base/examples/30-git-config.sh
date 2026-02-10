#!/bin/bash
# Example: Configure git with user preferences
# Runtime hook - executes when compose environment starts

set -e  # Exit on error

echo "Configuring git..."

# Set user identity (customize these!)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set default branch
git config --global init.defaultBranch main

# Pull behavior
git config --global pull.rebase false

# Editor
git config --global core.editor "vim"

# Useful aliases
git config --global alias.st "status"
git config --global alias.co "checkout"
git config --global alias.br "branch"
git config --global alias.ci "commit"
git config --global alias.lg "log --oneline --graph --decorate --all"

# Color output
git config --global color.ui auto

echo "✓ Git configured"
