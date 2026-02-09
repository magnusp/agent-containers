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

This launches two containers — a headless web server and an interactive TUI that attaches to it. The web UI is also accessible from your browser at `http://localhost:4096`. Exiting the TUI automatically tears down the entire stack.

**Prerequisites:**

```bash
# Build the image (one-time)
make open-code
```

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
| `opencode down` | Tear down a running stack (run from the same project dir) |
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
- Three host directories are bind-mounted for persistent state across runs:
  - `~/.config/opencode` — user config, agents, commands, themes, plugins
  - `~/.local/state/opencode` — UI state, command history, model preferences
  - `~/.local/share/opencode` — auth tokens, sessions, LSP servers, git snapshots, logs
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

exec docker run --rm --tty --interactive \
  --name "$NAME" \
  --add-host=host.docker.internal:host-gateway \
  -v "$HOME/.local/state/opencode:/home/node/.local/state/opencode" \
  -v "$HOME/.local/share/opencode:/home/node/.local/share/opencode" \
  -v "$HOME/.config/opencode:/home/node/.config/opencode" \
  -v "$(pwd):/app:rw" \
  open-code "$@"
```

## References

* [Documentation](https://opencode.ai/docs)
* [Github Repo](https://github.com/sst/opencode)
