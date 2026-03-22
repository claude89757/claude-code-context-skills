---
name: cc-apply
description: "Apply Claude Code context engineering patterns to your agent project. Reads the cc-learn knowledge base, scans your project's agent-related code, identifies gaps and opportunities, and generates actionable migration suggestions. Works with any agent codebase — not tied to specific frameworks."
---

# CC Apply

Read the cc-learn knowledge base and analyze your agent project to identify which Claude Code patterns are applicable, which are already implemented, and which represent opportunities for improvement.

## Prerequisites

A `docs/cc-patterns/` knowledge base directory must exist (created by `/cc-learn`). Use Glob to verify:

```
docs/cc-patterns/*.md
```

If the user specifies a custom path (e.g., `/cc-apply --kb /path/to/cc-patterns`), use that instead.

If no knowledge base is found, tell the user to run `/cc-learn` first, or specify the knowledge base path.

## Workflow

### Step 1: Load knowledge base

Read all `docs/cc-patterns/*.md` files (or from the custom path). Extract every pattern entry (identified by `###` headings with the standard fields: CC does, Evidence, Why, When useful, Migration notes).

### Step 2: Discover agent code in target project

Scan the current working directory for agent-related code. Use Grep and Glob — do NOT hardcode any paths. Search for:

**File patterns:**
- `**/agent/**`, `**/llm/**`, `**/ai/**`, `**/chat/**`
- `**/*prompt*`, `**/*context*`, `**/*tool*`
- `**/*completion*`, `**/*message*`
- `**/AGENT.md`, `**/CLAUDE.md`, `**/*.prompt`

**Code patterns:**
- System prompt construction (search: `system`, `system_prompt`, `system_message`)
- Tool/function definitions (search: `tools`, `functions`, `function_call`, `tool_choice`)
- Context management (search: `context`, `token`, `truncat`, `compac`, `compress`)
- LLM API calls (search: `messages.create`, `chat.completions`, `anthropic`, `openai`)
- Agent orchestration (search: `agent`, `subagent`, `delegate`, `spawn`)

Build a map of discovered components: file paths, what each file does, and which aspect of agent behavior it handles.

**If no agent-related code is found**, stop and tell the user:

> This project does not appear to contain agent or LLM integration code. cc-apply is designed for projects that make LLM API calls (system prompts, tool definitions, context management, etc.). If this project does have agent code, try specifying the subdirectory: `/cc-apply --path src/agent/`

Do NOT generate a report full of "not applicable" entries.

### Step 3: Gap analysis

For each pattern in the knowledge base, assess the target project:

| Status | Meaning |
|--------|---------|
| `implemented` | Project has equivalent functionality |
| `partial` | Project has related code but misses key aspects |
| `missing` | Project does not implement this pattern |
| `not-applicable` | Pattern doesn't apply to this project's architecture |

For `partial` and `missing` patterns, provide:
- **Current state**: What the project does today (with file path references)
- **Suggested action**: Concrete steps to implement the pattern
- **Priority**: HIGH (core architecture) / MED (optimization) / LOW (nice-to-have)
- **Complexity**: S (hours) / M (days) / L (weeks)

### Step 4: Generate Gap Report

Write the report to `docs/cc-alignment-report.md` in the target project directory. Create the `docs/` directory if needed.

**Report format:**

```markdown
# CC Alignment Report

Generated: YYYY-MM-DD
Knowledge base: docs/cc-patterns/
Target project: <project root>

## Summary

| Status | Count |
|--------|-------|
| Implemented | X |
| Partial | Y |
| Missing | Z |
| Not applicable | W |

Alignment score: X / (X + Y + Z) = XX%

## HIGH Priority Gaps

### <Pattern Name> (from <topic file>)
- **Status**: missing / partial
- **Current state**: <what the project does today>
- **CC pattern**: <what CC does>
- **Suggested action**: <concrete migration steps>
- **Files to modify**: <relevant file paths>
- **Complexity**: S / M / L

## MED Priority Gaps

(same format)

## LOW Priority Gaps

(same format)

## Already Implemented

(brief list of implemented patterns with file references)

## Not Applicable

(brief list with reason)
```

### Step 5: Output summary

```
CC Apply complete!
  Implemented:      X patterns
  Partial:          Y patterns
  Missing:          Z patterns
  Not applicable:   W patterns
  Alignment:        XX%
  HIGH priority:    N gaps
  Report:           docs/cc-alignment-report.md
```

If there are HIGH priority gaps, suggest starting with the highest-impact, lowest-complexity item.

## Important Notes

- **No framework assumptions.** Do not assume the project uses any specific framework (LangChain, CrewAI, etc.). Analyze what's actually in the code.
- **API format awareness.** Claude Code uses Anthropic API format. Target projects may use OpenAI-compatible APIs. See [references/migration-strategies.md](references/migration-strategies.md) for translation guidance.
- **Respect project conventions.** Suggestions should follow the target project's existing code style, language, and architecture patterns.
- **Be specific.** Generic advice like "implement context management" is not useful. Point to specific files, functions, and code patterns.
