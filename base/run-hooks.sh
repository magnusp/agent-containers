#!/bin/bash
# Hook execution wrapper for OpenCode build-time hooks
# Executes shell scripts in numeric order with fail-fast error handling

set -e  # Exit immediately on error
set -u  # Exit on undefined variables
set -o pipefail  # Fail on pipe errors

# Usage: run-hooks.sh <hook_directory> [hook_type]
# Example: run-hooks.sh /hooks/privileged "PRIVILEGED"

HOOK_DIR="${1:-}"
HOOK_TYPE="${2:-HOOK}"

if [ -z "$HOOK_DIR" ]; then
    echo "Usage: $0 <hook_directory> [hook_type]" >&2
    exit 1
fi

# If directory doesn't exist or is empty, exit successfully (not an error)
if [ ! -d "$HOOK_DIR" ]; then
    echo "[${HOOK_TYPE}] No hooks directory found at: $HOOK_DIR (skipping)"
    exit 0
fi

# Find all .sh files matching the numeric prefix pattern: NN-*.sh
# Sort them numerically by prefix (00-99)
HOOKS=$(find "$HOOK_DIR" -maxdepth 1 -type f -name '[0-9][0-9]-*.sh' 2>/dev/null | sort -V || true)

if [ -z "$HOOKS" ]; then
    echo "[${HOOK_TYPE}] No hooks found in: $HOOK_DIR (skipping)"
    exit 0
fi

# Count hooks for progress reporting
HOOK_COUNT=$(echo "$HOOKS" | wc -l)
CURRENT=0

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[${HOOK_TYPE}] Executing $HOOK_COUNT hook(s) from: $HOOK_DIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Execute each hook in order
while IFS= read -r hook; do
    CURRENT=$((CURRENT + 1))
    HOOK_NAME=$(basename "$hook")
    
    echo ""
    echo "[$HOOK_TYPE:$CURRENT/$HOOK_COUNT] Executing: $HOOK_NAME"
    echo "────────────────────────────────────────────────────────────"
    
    # Check if hook is executable
    if [ ! -x "$hook" ]; then
        echo "ERROR: Hook is not executable: $hook" >&2
        echo "Fix: chmod +x $hook" >&2
        exit 1
    fi
    
    # Execute hook with bash in strict mode
    # The hook inherits our 'set -e' so any error will propagate
    START_TIME=$(date +%s)
    
    if ! /bin/bash -e "$hook"; then
        echo "" >&2
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
        echo "ERROR: Hook failed: $HOOK_NAME" >&2
        echo "Location: $hook" >&2
        echo "Type: $HOOK_TYPE" >&2
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
        exit 1
    fi
    
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    
    echo "────────────────────────────────────────────────────────────"
    echo "[$HOOK_TYPE:$CURRENT/$HOOK_COUNT] ✓ Completed: $HOOK_NAME (${DURATION}s)"
done <<< "$HOOKS"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[${HOOK_TYPE}] All hooks completed successfully ($HOOK_COUNT/$HOOK_COUNT)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

exit 0
