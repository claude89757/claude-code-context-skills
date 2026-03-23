# Trace Inspection Commands

Optional quick-check commands to run after trace capture. These commands are also used by cc-learn during Phase 1.

> **Note:** Replace `FILE.jsonl` in all commands below with the actual trace file path, e.g., `docs/cc-context/traces/2026-03-23-v1.0.0/trace.jsonl`.

## Pre-filter

Trace files contain all HTTP traffic. Always filter for LLM requests first:

```bash
LLM='select(.request.url | test("v1/messages"))'
```

## Request Overview

```bash
jq -c "$LLM | {
  model: .request.body.model,
  max_tokens: .request.body.max_tokens,
  msgs: (.request.body.messages | length),
  tools: (.request.body.tools // [] | length),
  sys_blocks: (.request.body.system // [] | length),
  sys_len: ([.request.body.system[]? | .text | length] | add // 0),
  thinking: .request.body.thinking,
  effort: .request.body.output_config,
  ctx_mgmt: .request.body.context_management
}" FILE.jsonl
```

## Deep Inspection

```bash
# System prompt blocks (preview, length, cache control)
jq -c "$LLM | [.request.body.system[]? | {preview: (.text | .[0:80]), len: (.text | length), cache: .cache_control}]" FILE.jsonl

# Full system prompt text
jq -r "$LLM | .request.body.system[]? | .text" FILE.jsonl

# Tool names
jq -r "$LLM | .request.body.tools[]?.name" FILE.jsonl | sort -u

# Thinking and effort config
jq -c "$LLM | {thinking: .request.body.thinking, effort: .request.body.output_config}" FILE.jsonl

# Context management config
jq -c "$LLM | .request.body.context_management" FILE.jsonl

# Message count per request (observe growth across turns)
jq -c "$LLM | (.request.body.messages | length)" FILE.jsonl

# system-reminder tags in user messages
jq -r "$LLM | [.request.body.messages[] | if .content | type == \"array\" then [.content[] | select(.type == \"text\") | .text] | join(\"\") else .content // \"\" end] | join(\"\\n\")" FILE.jsonl | grep -A5 'system-reminder'

# Deferred tools declaration
jq -r "$LLM | .request.body.messages[] | if .content | type == \"string\" then . else .content[]? end | select(.text? // . | tostring | test(\"available-deferred-tools\"))" FILE.jsonl | head -10

# All request URLs (inspect non-LLM traffic)
jq -c '{method: .request.method, url: .request.url}' FILE.jsonl
```

## Generate HTML Report

```bash
claude-trace --generate-html FILE.jsonl
```
