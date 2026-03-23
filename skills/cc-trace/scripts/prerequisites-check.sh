#!/usr/bin/env bash
set -euo pipefail

echo "=== CC Trace Prerequisites Check ==="
MISSING=0

# 1. node
NODE_VER=$(node --version 2>/dev/null || echo "")
if [ -n "$NODE_VER" ]; then
  echo "✓ node $NODE_VER"
else
  echo "✗ node not found"
  echo "  Install Node.js 16+ from https://nodejs.org"
  echo "  macOS:  brew install node"
  echo "  Linux:  sudo apt-get install -y nodejs npm"
  MISSING=$((MISSING + 1))
fi

# 2. jq
JQ_VER=$(jq --version 2>/dev/null || echo "")
if [ -n "$JQ_VER" ]; then
  echo "✓ jq $JQ_VER"
else
  echo "✗ jq not found"
  echo "  Install jq from https://jqlang.github.io/jq/download/"
  echo "  macOS:  brew install jq"
  echo "  Linux:  sudo apt-get install -y jq"
  MISSING=$((MISSING + 1))
fi

# 3. claude-trace
if command -v claude-trace >/dev/null 2>&1; then
  echo "✓ claude-trace installed"
elif npx --yes @mariozechner/claude-trace --help >/dev/null 2>&1; then
  echo "✓ claude-trace available via npx"
else
  echo "✗ claude-trace not found"
  echo "  Install: npm install -g @mariozechner/claude-trace"
  MISSING=$((MISSING + 1))
fi

# 4. npm registry accessibility
echo "--- npm Registry ---"
LATEST=$(npm view @anthropic-ai/claude-code version 2>/dev/null || echo "")
if [ -n "$LATEST" ]; then
  echo "✓ npm registry accessible, latest Claude Code: $LATEST"
else
  echo "⚠ npm registry not accessible. Version analysis will not work."
  echo "  Check network and npm config."
fi

# 5. Summary
echo ""
if [ "$MISSING" -gt 0 ]; then
  echo "=== $MISSING missing prerequisite(s) — install them before running capture ==="
  exit 1
else
  echo "=== All prerequisites met ==="
  echo "  To verify full pipeline, run:"
  echo "    bash scripts/capture-trace.sh"
fi
