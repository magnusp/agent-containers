#!/bin/bash
# Example: Install common npm packages globally
# Runtime hook - executes when compose environment starts

set -e  # Exit on error

echo "Installing npm global packages..."

# Install TypeScript and related tools
npm install -g \
  typescript \
  tsx \
  ts-node \
  @types/node \
  prettier \
  eslint \
  nodemon

# Verify installation
tsc --version

echo "✓ npm global packages installed"
