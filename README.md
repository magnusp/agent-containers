# agent-containers

[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/magnusp/agent-containers/badge)](https://api.securityscorecards.dev/projects/github.com/magnusp/agent-containers)

Containerised [OpenCode](https://opencode.ai/) with a Docker Compose stack that
pairs a headless web server with an interactive TUI. Your current working
directory is mounted into the container so the agent can work on any local
project while running in a sandboxed environment.

Configuration is persisted on the host via XDG bind-mounts, so API credentials
and session data survive between runs.

## Prerequisites

You'll need [Docker](https://www.docker.com/) (preferably running rootless) or
[podman](https://podman.io/) installed on your system.

## Building

```bash
# Build base + open-code images
make all

# Build just the base image
make base

# Build only open-code (builds base if needed)
make open-code
```

### Architecture

The project uses a multi-stage build with a common base image (`agent-base`)
that contains shared dependencies. The open-code image extends it:

```
agent-base
└── open-code
```

### Cleaning

```bash
# Remove images but preserve build cache
make clean
```

## Running

See [`open-code/README.md`](open-code/README.md) for full details.

**Quick start:** symlink `open-code/opencode` into your `$PATH`, then:

```bash
cd /path/to/your/project
opencode
```

The helper script auto-builds images on first run, starts the web server +
TUI, and tears everything down when you exit.
