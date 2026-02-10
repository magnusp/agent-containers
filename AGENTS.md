# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## Build Commands
- `make all` - Build all containers (base + open-code)
- `make open-code` - Build the OpenCode container
- `make base` - Build the base image only
- `make clean` - Remove Docker images

## Run Commands
- OpenCode (compose stack): `cd /path/to/project && opencode` (via the helper script in `open-code/opencode`)
- OpenCode (standalone): `docker run -it --rm -v $(pwd):/app:rw open-code`

## Code Style Guidelines
- Docker-based project with a containerised OpenCode agent
- Uses a multi-stage build: `agent-base` → `open-code`
- Docker Compose stack pairs a headless web server with an interactive TUI
- Use explicit mounting of configuration files with appropriate permissions (700/600)
- Keep API keys and credentials in mounted configuration files, never in code
- Host bind-mounts respect XDG Base Directory spec (`$XDG_CONFIG_HOME`, `$XDG_STATE_HOME`, `$XDG_DATA_HOME`)
- Bash commands should use `$(pwd)` for current directory mounting
- Prioritise security for configuration files containing API keys

## Customization Hooks System
- Runtime startup hooks execute when compose environment starts (before web/TUI launch)
- Hook system is part of the base image and available to all agent containers
- Base documentation uses `.agent-containers` namespace (generic default)
- Applications choose their own namespace: OpenCode uses `.opencode` for branding consistency
- Hook locations (using OpenCode as example):
  - **Global**: `~/.config/opencode/hooks/startup/` (applies to all projects)
  - **Per-project**: `.opencode/hooks/startup/` (project-specific, can be version-controlled)
- Hook execution: Applications pass their chosen paths to `run-hooks.sh` (fully parameterized)
- Execution order: Global hooks run first, then per-project hooks
- Naming: Use numeric prefix pattern `NN-description.sh` (e.g., `10-npm-tools.sh`, `20-config.sh`)
- Requirements: Executable (`chmod +x`), shebang (`#!/bin/bash`), fail-fast (`set -e`)
- Runs as node user: Can install npm/pip/cargo packages, download binaries, configure git
- Cannot install system packages (no root) - use `LOCAL_TOOLS` in Makefile for apt packages
- No rebuild needed: Hooks run from mounted filesystem, changes take effect immediately
- Documentation: See `base/hooks/README.md` for detailed guide (uses `.agent-containers` paths)
- Examples: See `base/examples/` for production-ready hook scripts
