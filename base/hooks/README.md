# Runtime Startup Hooks

Runtime hooks execute when agent container environments start up. This allows you to install tools, configure settings, or run initialization scripts dynamically without rebuilding the container image.

**Note**: This hook system is part of the `agent-base` image and is available to all containers built from it (e.g., OpenCode).

## Hook Locations

Hooks are stored in two locations and execute in this order:

1. **Global hooks**: `~/.config/agent-containers/hooks/startup/`
   - Apply to all projects
   - Ideal for user preferences and standard tooling

2. **Per-project hooks**: `.agent-containers/hooks/startup/`
   - Apply only to the current project
   - Can be version-controlled for team sharing

> **Note**: Applications built from `agent-base` (e.g., OpenCode) may choose their own namespace for branding. The hook execution mechanism remains the same, but paths are passed as parameters to the hook runner.

## Quick Start

**1. Create hook directory:**

```bash
# For global hooks (all projects)
mkdir -p ~/.config/agent-containers/hooks/startup

# For per-project hooks (this project only)
mkdir -p .agent-containers/hooks/startup
```

**2. Create a hook script:**

```bash
# Example: Install Node.js CLI tools
cat > ~/.config/agent-containers/hooks/startup/10-npm-tools.sh << 'EOF'
#!/bin/bash
set -e

echo "Installing npm global packages..."
npm install -g typescript prettier eslint
EOF

chmod +x ~/.config/agent-containers/hooks/startup/10-npm-tools.sh
```

**3. Launch your agent environment:**

Hooks will execute automatically during container startup. Refer to your specific agent's documentation for launch instructions.

## Hook Requirements

All hooks must:

1. **Be executable**: `chmod +x hook-file.sh`
2. **Have shebang**: Start with `#!/bin/bash` or `#!/bin/sh`
3. **Use `set -e`**: Exit immediately on error (fail-fast)
4. **Follow naming pattern**: `NN-description.sh` (e.g., `10-npm-tools.sh`, `20-python.sh`)

The numeric prefix (00-99) controls execution order.

## What Hooks Can Do

Hooks run as the `node` user and can:

- ✅ Install npm packages globally (`npm install -g`)
- ✅ Install Bun packages (`bun install -g`)
- ✅ Install Python packages (`pip3 install --user`)
- ✅ Install Rust/Cargo tools (`cargo install`)
- ✅ Download and install binaries to `~/.local/bin/`
- ✅ Configure git settings (`git config`)
- ✅ Set up shell aliases and environment
- ✅ Run initialization scripts
- ❌ Install system packages with apt (need root - use `LOCAL_TOOLS` in Makefile instead)

## Example Hooks

### Install TypeScript Tools

```bash
#!/bin/bash
set -e

npm install -g \
  typescript \
  tsx \
  ts-node \
  prettier \
  eslint

echo "TypeScript tools installed"
```

### Install Python Development Tools

```bash
#!/bin/bash
set -e

pip3 install --user \
  black \
  pylint \
  mypy \
  pytest

echo "Python tools installed"
```

### Install kubectl (Kubernetes CLI)

```bash
#!/bin/bash
set -e

KUBECTL_VERSION="v1.29.0"

# Check if already installed
if command -v kubectl &> /dev/null; then
  echo "kubectl already installed"
  exit 0
fi

# Download and install
mkdir -p ~/.local/bin
cd /tmp
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
install -m 0755 kubectl ~/.local/bin/kubectl
rm kubectl

kubectl version --client
echo "kubectl installed"
```

### Configure Git

```bash
#!/bin/bash
set -e

git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main
git config --global alias.st "status"
git config --global alias.co "checkout"

echo "Git configured"
```

### Install Rust Toolchain

```bash
#!/bin/bash
set -e

# Check if Rust is already installed
if command -v rustc &> /dev/null; then
  echo "Rust already installed: $(rustc --version)"
  exit 0
fi

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

# Source environment
source "$HOME/.cargo/env"

rustc --version
cargo --version
echo "Rust installed"
```

## Best Practices

1. **Check before install**: Make hooks idempotent
   ```bash
   if command -v tool &> /dev/null; then
     echo "tool already installed"
     exit 0
   fi
   ```

2. **Use numeric prefixes**: Leave gaps (10, 20, 30) for ordering
   - If hook A must run before hook B, use `10-A.sh` and `20-B.sh`

3. **Log progress**: Echo what the hook is doing
   ```bash
   echo "Installing kubectl..."
   ```

4. **Install to user directories**:
   - Binaries: `~/.local/bin/` (already in PATH)
   - npm: Automatically goes to `~/.npm-global` (in PATH)
   - pip: Use `--user` flag

5. **Version pin**: Specify exact versions for reproducibility
   ```bash
   npm install -g typescript@5.3.3
   ```

6. **Handle errors gracefully**: Use conditional checks
   ```bash
   npm install -g typescript || echo "Warning: TypeScript install failed"
   ```

## Runtime vs Build-Time

**Runtime hooks** (what you're using now):
- ✅ No image rebuild needed
- ✅ Fast iteration
- ✅ Tools can vary per project
- ✅ Easy to test and debug
- ⚠️ Runs every time environment starts (use idempotency checks)
- ⚠️ Cannot install system packages (no root access)

**Build-time** (for system packages):
- Use `LOCAL_TOOLS` in the Makefile to add apt packages
- Requires rebuilding the base image: `make base`
- Tools are baked into the image

## Troubleshooting

**Hook not executing:**
1. Check file is in correct directory: `~/.config/agent-containers/hooks/startup/` or `.agent-containers/hooks/startup/`
2. Verify executable: `chmod +x hook.sh`
3. Check filename matches pattern: `[0-9][0-9]-*.sh`
4. View logs with your container/compose stack (e.g., `docker compose logs <hooks-service>`)

**Hook fails:**
- Hooks use fail-fast behavior (`set -e`)
- If any hook fails, the environment won't start
- Check logs with your container/compose stack
- Test hook locally: `bash -e hook-file.sh`

**Tools not in PATH:**
- Ensure tools install to PATH locations:
  - `~/.local/bin/` (for binaries)
  - `~/.npm-global/bin/` (for npm)
  - `~/.cargo/bin/` (for Rust)
- Or explicitly add to bashrc in your hook

**Slow startup:**
- First run is slower (downloads, installs)
- Add idempotency checks to skip if already installed
- Consider which tools really need to be installed per-project vs globally

## File Structure

```
# Global (all projects)
~/.config/agent-containers/hooks/startup/
├── 10-npm-globals.sh      # npm packages
├── 20-python-tools.sh     # Python packages
└── 30-git-config.sh       # Git configuration

# Per-project (this project only)  
.agent-containers/hooks/startup/
├── 10-project-tools.sh    # Project-specific tools
└── 20-env-setup.sh        # Project environment
```

Execution order:
1. Global hooks (10, 20, 30...)
2. Then project hooks (10, 20, 30...)

## See Also

- [Example Hooks](../examples/) - Ready-to-use hook examples
- [AGENTS.md](../AGENTS.md) - Developer guidance for this repository
