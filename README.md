# cc-context-skills

**[中文版](README_CN.md)**

A Claude Code plugin that helps you learn context engineering patterns from Claude Code and apply them to your own agent projects.

## What It Does

Claude Code is a production-grade AI coding agent with sophisticated context engineering — how it structures system prompts, manages tools, handles context windows, and orchestrates sub-agents. This plugin captures those patterns from real API traces and helps you migrate them to your own agent codebase.

## Skills

| Skill | Purpose |
|-------|---------|
| **cc-trace** | Capture Claude Code's real API requests using [claude-trace](https://www.npmjs.com/package/@mariozechner/claude-trace) and store raw trace data for analysis. |
| **cc-learn** | Extract patterns and raw examples from traces, compare with your project code through collaborative dialogue, and produce a detailed migration plan (`docs/cc-context/plans/YYYY-MM-DD-migration-plan.md`). |
| **cc-apply** | Execute the migration plan step by step, modifying your project code with confirmation at each step. |
| **cc-verify** | Capture your project's runtime API traces and verify that migrated patterns are actually working — not just present in code. |

## Workflow

```
cc-trace  →  cc-learn  →  cc-apply  →  cc-verify
(capture)    (analyze     (execute)    (verify)
              + plan)        ↑            |
                             └────────────┘
                           (iterate on gaps)
```

Each skill works independently. Use them together for a full learning loop, or individually as needed:

- **Just curious?** Run `cc-trace` alone to see what Claude Code sends to the API.
- **Have existing knowledge?** Skip to `cc-learn` with a knowledge base from a previous session to plan your migration.
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

This captures a real API request from the latest Claude Code version and saves raw trace data to `docs/cc-context/traces/`.

### 2. Analyze and plan migration

```bash
/cc-learn
```

Extracts patterns and raw reference examples from traces, compares with your project code through collaborative dialogue, and generates a migration plan (`docs/cc-context/plans/YYYY-MM-DD-migration-plan.md`) with:
- Alignment score
- Prioritized gaps (HIGH / MED / LOW)
- Concrete migration steps with file references

### 3. Execute migration

```bash
/cc-apply
```

Reads the migration plan and executes changes step by step, with confirmation at each step.

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
  cc-trace/                # Trace capture & raw data storage
    SKILL.md
    scripts/               # Shell scripts for capture & analysis
    references/            # Troubleshooting & version analysis guides
  cc-learn/                # Pattern extraction + example curation + migration planning
    SKILL.md
    references/            # Pattern taxonomy
  cc-apply/                # Migration plan execution
    SKILL.md
    references/            # API migration strategies
  cc-verify/               # Runtime verification
    SKILL.md
    references/            # Verification criteria
  shared/                  # Cross-skill references
    data-contracts.md      # Inter-skill data paths & format conventions
    trace-inspection.md    # Shared jq inspection commands
```

## License

MIT
