---
name: cc-trace
description: "Capture and store Claude Code's real API requests using claude-trace. Use when you need to see what Claude Code actually sends to the LLM — system prompts, tools, thinking config, context management. Supports version capture and comparison. Raw trace data is saved to the project for later analysis by /cc-learn."
---

# CC Trace

Use `claude-trace` (`@mariozechner/claude-trace`) to capture the exact API requests Claude Code sends to the Anthropic API, then store raw trace data to the project directory. This skill only captures and stores — pattern analysis is done by `/cc-learn`.

> **Native Binary vs npm.** Since Claude Code v2.x, the system `claude` binary is a compiled native executable. `claude-trace` works by monkey-patching Node.js `fetch`, so it cannot intercept native binaries. All scripts use `npm install @anthropic-ai/claude-code@<version>` and pass `--claude-path` to `claude-trace`.

All `scripts/` paths below are relative to this skill's directory.

## Prerequisites Check

Run before any capture or analysis:

```bash
bash scripts/prerequisites-check.sh
```

For troubleshooting, see [references/troubleshooting.md](references/troubleshooting.md).

## Capture Trace Data

### Capture latest version

```bash
bash scripts/capture-trace.sh
```

### Capture a specific version

```bash
bash scripts/analyze-version.sh <version>
```

### Compare two versions

```bash
bash scripts/analyze-version.sh <v1>
bash scripts/analyze-version.sh <v2>
bash scripts/compare-versions.sh <v1> <v2>
```

See [references/version-analysis.md](references/version-analysis.md) for details.

## 快速预览 Trace 数据（可选）

All analysis MUST use real JSONL trace files. If no trace data is available, capture it first.

### Filter LLM requests

Trace files contain all HTTP traffic. Always filter first:

```bash
LLM='select(.request.url | test("v1/messages"))'
```

### Request overview

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

### Deep inspection commands

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

# Message count per request (shows growth across turns)
jq -c "$LLM | (.request.body.messages | length)" FILE.jsonl

# system-reminder tags in user messages
jq -r "$LLM | [.request.body.messages[] | if .content | type == \"array\" then [.content[] | select(.type == \"text\") | .text] | join(\"\") else .content // \"\" end] | join(\"\\n\")" FILE.jsonl | grep -A5 'system-reminder'

# Deferred tools declaration
jq -r "$LLM | .request.body.messages[] | if .content | type == \"string\" then . else .content[]? end | select(.text? // . | tostring | test(\"available-deferred-tools\"))" FILE.jsonl | head -10

# All request URLs (shows non-LLM traffic)
jq -c '{method: .request.method, url: .request.url}' FILE.jsonl
```

### Generate HTML report (optional)

```bash
claude-trace --generate-html FILE.jsonl
```

## 保存原始数据

抓取完成后，脚本会自动将 trace 数据保存到用户工作目录：

### 存储结构

```
docs/cc-context/traces/
└── YYYY-MM-DD-v<version>/
    ├── trace.jsonl      # 原始 trace 数据
    └── metadata.json    # 抓取元信息
```

### metadata.json 格式

```json
{
  "version": "<claude-code-version>",
  "capture_date": "YYYY-MM-DD",
  "request_count": <total-requests>,
  "llm_request_count": <llm-requests>,
  "prompt_used": "hello"
}
```

### 完成后

抓取和保存完成后，运行 `/cc-learn` 对原始 trace 数据进行模式提取和分析。
