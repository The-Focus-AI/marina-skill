#!/bin/bash
# Verify required CLI tools are available
set -euo pipefail

errors=0

for cmd in hcloud curl jq git ssh scp; do
    if command -v "$cmd" &>/dev/null; then
        echo "OK: ${cmd}"
    else
        echo "MISSING: ${cmd}"
        errors=$((errors + 1))
    fi
done

# Check hcloud context (non-fatal)
if command -v hcloud &>/dev/null; then
    if hcloud context active &>/dev/null 2>&1; then
        echo "OK: hcloud context configured"
    else
        echo "WARNING: No active hcloud context. Run 'hcloud context create <name>' to set up."
    fi
fi

if [[ $errors -gt 0 ]]; then
    echo ""
    echo "${errors} missing tool(s). Install them before proceeding."
    exit 1
else
    echo ""
    echo "All dependencies available."
fi
