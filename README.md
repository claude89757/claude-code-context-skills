# cc-context-skills

**[中文版](README_CN.md)**

A Claude Code plugin that helps you learn context engineering patterns from Claude Code and apply them to your own agent projects.

## What It Does

Claude Code is a production-grade AI coding agent with sophisticated context engineering — how it structures system prompts, manages tools, handles context windows, and orchestrates sub-agents. This plugin captures those patterns from real API traces and helps you migrate them to your own agent codebase.

## Skills

| Skill | Purpose |
|-------|---------|
| **cc-trace** | Capture Claude Code's real API requests using [claude-trace](https://www.npmjs.com/package/@mariozechner/claude-trace). Inspect system prompts, tools, thinking config, context management. Generate Pattern Reports. |
| **cc-learn** | Extract patterns from cc-trace reports into a persistent, topic-based knowledge base (`docs/cc-patterns/`). Supports incremental updates across versions. |
| **cc-apply** | Scan your agent project's code, compare against the knowledge base, and generate a Gap Report with prioritized migration suggestions. |
| **cc-verify** | Capture your project's runtime API traces and verify that migrated patterns are actually working — not just present in code. |

## Workflow

```
cc-trace  →  cc-learn  →  cc-apply  →  cc-verify
(capture)    (extract)    (analyze)    (verify)
                             ↑            |
                             └────────────┘
                           (iterate on gaps)
```

Each skill works independently. Use them together for a full learning loop, or individually as needed:

- **Just curious?** Run `cc-trace` alone to see what Claude Code sends to the API.
- **Have existing knowledge?** Skip to `cc-apply` with a knowledge base from a previous session.
- **Already migrated?** Run `cc-verify` to confirm runtime behavior matches.

## Installation

### From GitHub (recommended)

```bash
# Add the marketplace
/plugin marketplace add claude89757/claude-code-context-skills

# Install the plugin
/plugin install cc-context-skills@cc-context-skills
```

### From Local Directory

```bash
# Add a locally cloned copy as marketplace
/plugin marketplace add /path/to/cc-context-skills

# Install the plugin
/plugin install cc-context-skills@cc-context-skills
```

### Prerequisites

- Node.js 16+
- jq
- [claude-trace](https://www.npmjs.com/package/@mariozechner/claude-trace) (auto-installed by cc-trace)

## Quick Start

### 1. Capture a trace

```bash
# Run the cc-trace skill
/cc-trace
```

This captures a real API request from the latest Claude Code version and generates a Pattern Report (`cc-trace-report-YYYY-MM-DD.md`).

### 2. Build the knowledge base

```bash
/cc-learn
```

Reads the Pattern Report and organizes findings into `docs/cc-patterns/` by topic:
- `system-prompt-design.md`
- `tool-engineering.md`
- `context-management.md`
- `thinking-reasoning.md`
- `message-patterns.md`
- `model-routing.md`
- `agent-orchestration.md`

### 3. Analyze your project

```bash
/cc-apply
```

Scans your agent codebase, compares against the knowledge base, and writes `docs/cc-alignment-report.md` with:
- Alignment score
- Prioritized gaps (HIGH / MED / LOW)
- Concrete migration suggestions with file references

### 4. Verify at runtime

```bash
/cc-verify
```

Captures your project's API traces and checks whether patterns are actually present in runtime behavior.

## What You'll Learn

From a single Claude Code trace, you can discover patterns like:

- **System prompt architecture** — 3-block structure with selective cache control
- **Stable-first content ordering** — maximizes prompt cache hit rates
- **System-reminder injection** — dynamic context in user messages, not system prompt
- **Rich tool descriptions** — behavioral guides embedded in tool definitions
- **Adaptive thinking** — effort level adapts to task complexity
- **Lazy context management** — activated only when context window fills up

## Project Structure

```
.claude-plugin/
  plugin.json              # Plugin metadata
skills/
  cc-trace/                # Trace capture & pattern extraction
    SKILL.md
    scripts/               # Shell scripts for capture & analysis
    references/            # Troubleshooting & version analysis guides
  cc-learn/                # Knowledge base builder
    SKILL.md
    references/            # Pattern taxonomy
  cc-apply/                # Gap analysis & migration
    SKILL.md
    references/            # API migration strategies
  cc-verify/               # Runtime verification
    SKILL.md
    references/            # Verification criteria
```

## License

MIT
