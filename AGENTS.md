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