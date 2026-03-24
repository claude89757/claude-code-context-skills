---
name: cc-trace
description: "Capture and store Claude Code's real API requests using claude-trace. Use when you need to see what Claude Code actually sends to the LLM — system prompts, tools, thinking config, context management. Supports version capture and comparison. Raw trace data is saved to the project for later analysis by /cc-learn."
---

# CC Trace

Use `claude-trace` (`@mariozechner/claude-trace`) to capture the exact API requests Claude Code sends to the Anthropic API, then store raw trace data to the project directory. This skill only captures and stores — pattern extraction and example curation are done by `/cc-learn`.

> **Native binary vs npm.** Since Claude Code v2.x, the system `claude` binary is a compiled native executable. `claude-trace` works by monkey-patching Node.js `fetch`, so it cannot intercept native binaries. All scripts use `npm install @anthropic-ai/claude-code@<version>` and pass `--claude-path` to `claude-trace`.

All `scripts/` paths below are relative to this skill's directory.

For data path and format conventions, see [../../data-contracts.md](../../data-contracts.md).

<OUTPUT-BOUNDARY>
This skill ONLY writes to `docs/cc-context/traces/` and `docs/cc-context/knowledge/examples/`.
It does NOT write to `docs/cc-context/plans/` or `docs/cc-context/reports/`.
It does NOT modify project source code.
</OUTPUT-BOUNDARY>

## Prerequisites Check

Run before any capture:

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

## Storage Structure

After capture, scripts automatically save trace data and extracted artifacts:

```
docs/cc-context/
├── traces/
│   └── YYYY-MM-DD-v<version>/
│       ├── trace.jsonl      # Raw trace data
│       └── metadata.json    # Capture metadata
└── knowledge/examples/
    └── YYYY-MM-DD-v<version>/
        └── cc-system-prompt.md   # Extracted system prompt (auto-generated)
```

### metadata.json Format

```json
{
  "version": "<claude-code-version>",
  "capture_date": "YYYY-MM-DD",
  "request_count": 0,
  "llm_request_count": 0,
  "prompt_used": "hello"
}
```

## Extract System Prompt (Standalone)

Re-extract from an existing trace file (useful for historical traces):

```bash
bash scripts/extract-system-prompt.sh <trace.jsonl> <version> [project_dir]
```

Output: `docs/cc-context/knowledge/examples/YYYY-MM-DD-v<version>/cc-system-prompt.md` — clean markdown with frontmatter (version, capture_date, char_count), no block markers.

## Quick Check (Optional)

After capture, you can use jq to quickly verify data integrity. See [references/trace-inspection.md](references/trace-inspection.md) for commands.

## Next Step

After capture and storage are complete, run `/cc-learn` to extract patterns and raw examples from the trace data.
