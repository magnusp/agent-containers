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
- Just create the following file, make it executable with `chmod +x` and place it in `~/.local/bin`
- Startup is a bit slow due to container startup time, but taking ~5s startup penalty for safety measures is not so bad.
- There are three volumes:
  1. project scoped `.opencode/auth.json` to store apikeys DO NOT COMMIT TO GIT
  2. global scoped config for theme etc at `~/.config/opencode/opencode.json`
  3. the repo you work on as current PWD when executing `opencode` in your terminal

```bash
#!/usr/bin/env bash

PROJ="$(basename "$(pwd)")"
NAME="open-code-${PROJ}"

exec docker run --rm --tty --interactive \
  --name "$NAME" \
  -v "$(pwd)/.opencode/auth.json:/home/node/.local/share/opencode/auth.json" \
  -v "$HOME/.config/opencode/opencode.json:/home/node/.config/opencode/opencode.json" \
  -v "$(pwd):/app:rw" \
  open-code "$@"
```

## References

* [Documentation](https://opencode.ai/docs)
* [Github Repo](https://github.com/sst/opencode)
