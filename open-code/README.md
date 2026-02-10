# Open Code

## Build Instructions

Use the top level `Makefile` to build this. It injects things in to the build
so the container works correctly for your user under `podman`.

```bash
make open-code
```

You can add more local tools to the container to be installed via `apt-get` by
extending the `LOCAL_TOOLS` list in the top-level `Makefile`.

## Run Instructions

### Option 1: Compose stack (Web + TUI)

This launches a short-lived init container (to ensure directory permissions) followed by two main containers — a headless web server and an interactive TUI that attaches to it. The web UI is also accessible from your browser at `http://localhost:4096`. Exiting the TUI automatically tears down the entire stack.

**Prerequisites:**

The helper script automatically builds the base and open-code images on first run. No manual `make` step is required.
If you prefer to pre-build, you can still run `make open-code`.

**Usage:**

Symlink or copy `open-code/opencode` into your `$PATH` (e.g. `~/.local/bin/`), then run from any project directory:

```bash
cd /path/to/your/project
opencode
```

Or invoke the script directly:

```bash
cd /path/to/your/project
/path/to/agent-containers/open-code/opencode
```

**Subcommands:**

| Command | Description |
|---------|-------------|
| `opencode` or `opencode up` | Launch the stack (default) |
| `opencode down` or `opencode stop` | Tear down a running stack (run from the same project dir) |
| `opencode logs` | Tail web server logs |
| `opencode status` | Show running containers |

**Custom port:**

```bash
OPENCODE_PORT=8080 opencode
```

**Running multiple projects:**

Each project directory gets its own isolated compose stack (named `opencode-<dirname>`). To run multiple projects simultaneously, use different ports:

```bash
# Terminal 1
cd ~/projects/frontend
opencode

# Terminal 2
cd ~/projects/backend
OPENCODE_PORT=4097 opencode
```

Subcommands like `down`, `logs`, and `status` are scoped to the current directory, so run them from the same project directory:

```bash
cd ~/projects/frontend
opencode status
```

**What happens:**
- Your current working directory is mounted as `/app` inside both containers
- Three host directories are bind-mounted for persistent state across runs (respects `$XDG_CONFIG_HOME`, `$XDG_STATE_HOME`, `$XDG_DATA_HOME` if set):
  - `$XDG_CONFIG_HOME/opencode` (default: `~/.config/opencode`) — user config, agents, commands, themes, plugins
  - `$XDG_STATE_HOME/opencode` (default: `~/.local/state/opencode`) — UI state, command history, model preferences
  - `$XDG_DATA_HOME/opencode` (default: `~/.local/share/opencode`) — auth tokens, sessions, LSP servers, git snapshots, logs
- The web server binds to `0.0.0.0:4096` inside the container (or `$OPENCODE_PORT`), published to the same port on the host
- `host.docker.internal` is mapped so containers can reach services on your host machine

### Option 2: Single container (standalone)

For a simpler single-container setup without the web UI:

- Create the following file, make it executable with `chmod +x` and place it in `~/.local/bin`
- There are 4 volumes — make sure the directories in your `$HOME` exist and with the correct user privilege (your `$UID`):
  1. opencode global state — UI state, command history, model preferences, recently opened files
  2. opencode global share — Auth tokens, session data, LSP servers, git snapshots for undo, logs
  3. opencode global config — User configuration: themes, keybindings, custom commands, plugins
  4. the repo you work on — mounted as current PWD when executing `opencode` in your terminal

```bash
#!/usr/bin/env bash

PROJ="$(basename "$(pwd)")"
NAME="open-code-${PROJ}"

# Respect XDG base directories
OC_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
OC_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/opencode"
OC_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/opencode"

mkdir -p "${OC_CONFIG}" "${OC_STATE}" "${OC_DATA}"

exec docker run --rm --tty --interactive \
  --name "$NAME" \
  --add-host=host.docker.internal:host-gateway \
  -v "${OC_STATE}:/home/node/.local/state/opencode" \
  -v "${OC_DATA}:/home/node/.local/share/opencode" \
  -v "${OC_CONFIG}:/home/node/.config/opencode" \
  -v "$(pwd):/app:rw" \
  open-code "$@"
```

## Customization Hooks

You can customize the container environment by adding **runtime startup hooks** that execute when the compose environment starts. Hooks can install tools, configure settings, or run initialization scripts without rebuilding the container image.

> **Note**: Hooks are a base-image feature and use the `.agent-containers` namespace (shared across all agent containers). OpenCode-specific configuration (settings, UI state, auth tokens) uses the `.opencode` namespace in XDG directories. See the [base hook documentation](../base/hooks/README.md) for complete details.

### Quick Start

**1. Create hook directory:**

```bash
# For global hooks (all projects)
mkdir -p ~/.config/agent-containers/hooks/startup

# For per-project hooks (this project only)
mkdir -p .agent-containers/hooks/startup
```

**2. Add a hook script:**

```bash
# Example: Install TypeScript tools
cat > ~/.config/agent-containers/hooks/startup/10-npm-tools.sh << 'EOF'
#!/bin/bash
set -e
echo "Installing npm packages..."
npm install -g typescript prettier eslint
echo "✓ npm packages installed"
EOF

chmod +x ~/.config/agent-containers/hooks/startup/10-npm-tools.sh
```

**3. Launch OpenCode** (hooks run automatically):

```bash
cd /path/to/your/project
opencode
```

### How It Works

- Hooks are mounted from your host filesystem (not copied into image)
- They execute before the web server and TUI start
- Global hooks run first, then per-project hooks
- Numeric prefixes control execution order (10, 20, 30...)
- Hooks run as the `node` user (can install npm, pip, download binaries)
- ✅ **No rebuild needed** - changes take effect immediately

### What Hooks Can Do

**Install tools:**
- npm/Bun packages globally
- Python packages with pip
- Rust/Cargo tools
- Download binaries to `~/.local/bin/`

**Configure environment:**
- Git settings (`git config`)
- Shell aliases
- Environment variables

**Cannot do:**
- Install system packages with apt (no root access)
- For system packages, use `LOCAL_TOOLS` in Makefile instead

### Example Hooks

**Install kubectl:**
```bash
#!/bin/bash
set -e
if command -v kubectl &> /dev/null; then exit 0; fi
curl -LO "https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kubectl"
install -m 0755 kubectl ~/.local/bin/kubectl && rm kubectl
```

**Configure git:**
```bash
#!/bin/bash
set -e
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global alias.st "status"
```

**Install Python tools:**
```bash
#!/bin/bash
set -e
pip3 install --user black pylint pytest
```

📁 **More examples**: See [`../base/examples/`](../base/examples/) directory with ready-to-use hooks.

### Hook Requirements

- Executable: `chmod +x hook-file.sh`
- Shebang: `#!/bin/bash`
- Fail-fast: `set -e`
- Naming: `NN-description.sh` (e.g., `10-tools.sh`, `20-config.sh`)

### Best Practices

1. **Check before install** (idempotency):
   ```bash
   if command -v tool &> /dev/null; then exit 0; fi
   ```

2. **Log progress**: Echo what's happening
3. **Version pin**: Specify exact versions
4. **Clean up**: Remove temporary files
5. **Use gaps in numbering**: 10, 20, 30 (easier to insert later)

### Documentation

- **Complete guide**: [`../base/hooks/README.md`](../base/hooks/README.md) - Detailed documentation with examples
- **Example library**: [`../base/examples/`](../base/examples/) - Production-ready hooks
- **Example README**: [`../base/examples/README.md`](../base/examples/README.md) - How to use examples

## References

* [Documentation](https://opencode.ai/docs)
* [Github Repo](https://github.com/anomalyco/opencode)
