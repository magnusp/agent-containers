#!/bin/bash
# Example: Install Python development tools
# Runtime hook - executes when compose environment starts

set -e  # Exit on error

echo "Installing Python packages..."

# Install common Python development tools
pip3 install --user --no-warn-script-location \
  black \
  pylint \
  mypy \
  pytest \
  pytest-cov \
  ipython

# Verify installation
python3 -m black --version

echo "✓ Python packages installed"
