---
name: cc-trace
description: "Capture and analyze Claude Code's real API requests using claude-trace. Use when you need to see what Claude Code actually sends to the LLM — system prompts, tools, thinking config, context management. Supports version capture, comparison, and automatic pattern extraction into structured reports."
---

# CC Trace

Use `claude-trace` (`@mariozechner/claude-trace`) to capture the exact API requests Claude Code sends to the Anthropic API, then extract context engineering patterns into a structured report.

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

## Analyze Trace Data

All analysis MUST use real JSONL trace files. If no trace data is available, capture it first. **Never guess or assume patterns — extract everything from the data.**

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

## Pattern Report Generation

After capturing and inspecting trace data, generate a structured Pattern Report. This report extracts Claude Code's context engineering patterns for use by `/cc-learn`.

### Report structure

Write the report to the user's working directory as `cc-trace-report-YYYY-MM-DD.md`. Organize findings by these categories (skip categories with no findings):

1. **System Prompt Architecture** — How the system prompt is structured: block count, content segmentation, ordering, `cache_control` breakpoint placement, total size vs context window ratio
2. **Tool Design** — Tool definitions: naming conventions, parameter schemas, description style, tool count, deferred tools mechanism
3. **Context Management** — `context_management` API config, message compaction, context window utilization strategy
4. **Caching Strategy** — `cache_control` placement pattern, which blocks are marked `ephemeral`, cache hit rates from usage stats
5. **Thinking & Reasoning** — `thinking` config, `budget_tokens`, `output_config` effort levels, when thinking is enabled vs disabled
6. **Message Patterns** — `system-reminder` injection patterns, message role distribution, tool call/result patterns, multi-turn conversation structure
7. **Model Routing** — Model selection, `max_tokens` settings, any model switching across requests

### Per-pattern entry format

For each discovered pattern, include:

```markdown
### <Pattern Name>
- **CC does**: Concrete description of the observed behavior
- **Evidence**: Relevant trace data excerpt or jq output
- **Why**: Design rationale — why this pattern likely exists (inferred from the data)
- **Source**: Claude Code version and capture date
```

### Key principles

- **No hardcoded knowledge.** All findings must come from real trace data
- **Data may vary.** Claude Code's behavior changes across versions — always verify with fresh traces
- **Anthropic API format.** System prompt is in `.request.body.system[]` array, tools use `.tools[].name` (not `.tools[].function.name`)
- If capture fails, report what went wrong honestly. Do not fill gaps with assumptions.
