# Example Runtime Hooks

These examples demonstrate common use cases for runtime startup hooks. Copy them to your hooks directory and customize as needed.

## How to Use

**Copy to global hooks** (apply to all projects):

```bash
mkdir -p ~/.config/opencode/hooks/startup
cp open-code/examples/10-npm-globals.sh ~/.config/opencode/hooks/startup/
chmod +x ~/.config/opencode/hooks/startup/*.sh
```

**Copy to project hooks** (apply to one project only):

```bash
mkdir -p .opencode/hooks/startup
cp /path/to/agent-containers/open-code/examples/40-kubectl.sh .opencode/hooks/startup/
chmod +x .opencode/hooks/startup/*.sh
```

## Available Examples

### `10-npm-globals.sh`
Installs common Node.js development tools globally:
- TypeScript, tsx, ts-node
- Prettier, ESLint
- Nodemon

**Use case**: JavaScript/TypeScript development

### `20-python-tools.sh`
Installs Python development and testing tools:
- Black (formatter)
- Pylint, Mypy (linters)
- Pytest, ipython

**Use case**: Python development

### `30-git-config.sh`
Configures git with user preferences:
- User name and email
- Default branch name (main)
- Useful aliases (st, co, lg)
- Color output

**Use case**: Personal git configuration that applies to all projects

## Customization

Edit the examples to match your needs:

```bash
# Change versions
KUBECTL_VERSION="v1.30.0"

# Add/remove packages
npm install -g typescript prettier eslint YOUR_PACKAGE

# Modify git config
git config --global user.name "Your Actual Name"
git config --global user.email "your.actual@email.com"
```

## Execution Order

Hooks run in numeric order:
1. Global hooks (from `~/.config/opencode/hooks/startup/`)
2. Project hooks (from `.opencode/hooks/startup/`)

Within each location, numeric prefixes control order (10, 20, 30...).

## Best Practices

1. **Keep originals**: Don't modify examples in-place, copy them first
2. **Test individually**: Run `bash -e hook.sh` to test before using
3. **Check idempotency**: Hooks should be safe to run multiple times
4. **Use specific prefix**: Leave gaps between numbers (10, 20, 30) not (1, 2, 3)
5. **Log output**: Include echo statements so you know what's happening

## See Also

- [Hooks Documentation](../../base/hooks/README.md) - Complete guide
- [OpenCode README](../README.md) - Main project documentation
