---
name: cc-learn
description: "Extract and accumulate context engineering knowledge from Claude Code traces. Reads cc-trace Pattern Reports, organizes findings into a persistent knowledge base by topic (system prompts, tools, context management, caching, etc.), and supports incremental updates as new traces are captured."
---

# CC Learn

Extract context engineering patterns from cc-trace reports and organize them into a persistent, topic-based knowledge base. The knowledge base is project-agnostic — it describes what Claude Code does and why, not how to apply it to any specific project.

## Input

Read a cc-trace Pattern Report. Accepted sources (in priority order):

1. A `cc-trace-report-*.md` file in the current working directory (use Glob to find the latest)
2. A file path provided by the user
3. Raw trace analysis output pasted by the user

If no input is found, tell the user to run `/cc-trace` first.

## Knowledge Base Location

The knowledge base lives in `docs/docs/cc-patterns/` in the current working directory. Create the directory if it does not exist.

## Knowledge Base Structure

Organize findings into these topic files. Create only files for which patterns have been discovered:

| File | Topic |
|------|-------|
| `system-prompt-design.md` | System prompt layering, block organization, content segmentation, cache_control placement |
| `tool-engineering.md` | Tool definitions, naming conventions, parameter schemas, deferred tools, progressive disclosure |
| `context-management.md` | Context compression, message trimming, context_management API, window utilization |
| `agent-orchestration.md` | Subagent patterns, Agent tool design, parallel dispatch, task delegation |
| `thinking-reasoning.md` | Thinking config, budget_tokens, effort control, output_config |
| `message-patterns.md` | system-reminder injection, role management, tool call patterns, multi-turn structure |
| `model-routing.md` | Model selection logic, max_tokens settings, model switching |

Each file starts with a level-1 heading matching the topic name, followed by pattern entries.

## Pattern Entry Format

Each entry preserves the fields from the cc-trace report and adds migration context:

```markdown
### <Pattern Name>

- **CC does**: Concrete description of what Claude Code does
- **Evidence**: Key data excerpt from the trace (keep concise)
- **Why**: Design rationale — why this pattern exists
- **When useful**: Scenarios where this pattern applies
- **Migration notes**: Key considerations when applying to other agent systems
- **Source**: CC version, trace date

---
```

The `CC does`, `Evidence`, `Why`, and `Source` fields come directly from the cc-trace report. Add `When useful` and `Migration notes` based on analysis.

## Workflow

### Step 1: Read input

Read the Pattern Report and extract all pattern entries.

### Step 2: Load existing knowledge base

Use Glob to check if `docs/cc-patterns/*.md` files exist. If they do, read them to understand what's already been captured.

### Step 3: Classify and merge

For each pattern from the report:

1. Classify it into the appropriate topic file using [references/pattern-taxonomy.md](references/pattern-taxonomy.md)
2. Check if an equivalent pattern already exists in the knowledge base:
   - **New pattern**: Append to the topic file
   - **Updated pattern** (same pattern, new evidence or version): Update the existing entry — merge evidence, update version
   - **Unchanged**: Skip

### Step 4: Write knowledge base

Write new or updated topic files to `docs/cc-patterns/`. Preserve existing patterns that were not updated.

### Step 5: Output summary

Report to the user:

```
CC Learn complete!
  New patterns:     X
  Updated patterns: Y
  Unchanged:        Z
  Topics touched:   [list of updated files]
  Knowledge base:   docs/cc-patterns/
```

Suggest next step: "Run `/cc-apply` to analyze how these patterns apply to your agent project."

## Incremental Updates

The knowledge base is designed for incremental growth:

- New traces add new patterns or update existing ones
- Patterns are never deleted automatically — only the user can remove them
- Each pattern tracks its source version, so outdated patterns can be identified when CC behavior changes
- If a new trace contradicts an existing pattern, flag the conflict to the user and ask how to resolve it
