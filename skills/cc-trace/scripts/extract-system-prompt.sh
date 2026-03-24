#!/usr/bin/env bash
# Usage: ./extract-system-prompt.sh <trace.jsonl> <version> [project_dir]
# Example: ./extract-system-prompt.sh docs/cc-context/traces/2026-03-24-v2.1.81/trace.jsonl 2.1.81
# Example: ./extract-system-prompt.sh /tmp/trace.jsonl 2.1.81 /path/to/project
#
# Extracts the system prompt from the first LLM request in a trace file
# and saves it as a clean markdown file with frontmatter.
set -euo pipefail

TRACE_FILE="${1:?Usage: $0 <trace.jsonl> <version> [project_dir]}"
VERSION="${2:?Usage: $0 <trace.jsonl> <version> [project_dir]}"
PROJECT_DIR="${3:-$(pwd)}"

if [ ! -f "$TRACE_FILE" ]; then
  echo "✗ Trace file not found: $TRACE_FILE"
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "✗ jq is required but not found"
  exit 1
fi

LLM='select(.request.url | test("v1/messages"))'
CAPTURE_DATE=$(date +%Y-%m-%d)

# Extract system prompt text from the first LLM request
# Join all system blocks with newline separators
PROMPT_TEXT=$(jq -r "[$LLM] | .[0] | [.request.body.system[]? | .text] | join(\"\\n\")" "$TRACE_FILE" 2>/dev/null)

if [ -z "$PROMPT_TEXT" ] || [ "$PROMPT_TEXT" = "null" ]; then
  echo "✗ No system prompt found in trace"
  exit 1
fi

CHAR_COUNT=${#PROMPT_TEXT}
OUT_DIR="$PROJECT_DIR/docs/cc-context/knowledge/examples/${CAPTURE_DATE}-v${VERSION}"
OUT_FILE="$OUT_DIR/cc-system-prompt.md"

mkdir -p "$OUT_DIR"

cat > "$OUT_FILE" <<EOF
---
version: "${VERSION}"
capture_date: "${CAPTURE_DATE}"
char_count: ${CHAR_COUNT}
source: "claude-trace extraction from trace.jsonl"
---

${PROMPT_TEXT}
EOF

echo "✓ System prompt extracted: ${CHAR_COUNT} chars"
echo "  File: $OUT_FILE"
