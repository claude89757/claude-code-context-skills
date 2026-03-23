---
name: cc-learn
description: "Extract context engineering patterns and raw examples from Claude Code trace data, compare them against the current project's code, and collaboratively develop a detailed migration plan through interactive dialogue. Follows a brainstorming-style interaction: one question at a time, prefer multiple-choice, confirm in segments."
---

# CC Learn

Extract Claude Code's context engineering patterns and raw reference examples from trace data captured by cc-trace, compare them against the current project's implementation, and collaboratively develop a migration plan with the user through interactive dialogue.

For data path and format conventions, see [../../data-contracts.md](../../data-contracts.md).

<HARD-GATE>
Do not suggest running /cc-apply until the migration plan is confirmed by the user. Each phase's output must be confirmed by the user before proceeding to the next phase.
</HARD-GATE>

<OUTPUT-BOUNDARY>
This skill ONLY writes to `docs/cc-context/knowledge/` and `docs/cc-context/plans/`.
It NEVER writes to `docs/cc-context/traces/`, `docs/cc-context/reports/`, or any other directory.
It NEVER modifies project source code, configuration files, or any files outside `docs/cc-context/`.
All project code changes are deferred to /cc-apply.
Reading project files for analysis is allowed; writing or editing them is NOT.
</OUTPUT-BOUNDARY>

<PHASE-GATE>
You MUST wait for explicit user confirmation before crossing phase boundaries:
- Phase 1 → Phase 2: Show extraction summary, wait for user to confirm before scanning project code
- Phase 2 → Phase 3: Show project scan results and clarifying Q&A summary, wait for user to confirm before starting comparison
- Phase 3 → Phase 4: Show comparison table, wait for user to confirm before proposing directions
- Phase 4 → Phase 5: User must select a direction before plan development begins
- Phase 5 (plan written) → suggest /cc-apply: Do NOT suggest /cc-apply until the user explicitly approves the plan and you have updated status from draft to confirmed

If you find yourself writing code that would be executed by the project (not documentation), STOP. You are in the wrong skill. Tell the user to run /cc-apply.
</PHASE-GATE>

## Checklist

You must create a task for each of the following steps and complete them in order:

1. **[Phase 1] Load trace data** — Read raw JSONL from docs/cc-context/traces/
2. **[Phase 1] Extract CC patterns** — Analyze traces with jq, write pattern summaries to knowledge/patterns/
3. **[Phase 1] Extract raw examples** — Extract raw artifacts from traces to knowledge/examples/YYYY-MM-DD-v\<version\>/
4. **[Phase 2] Explore project context** — Scan the current project's agent-related code
5. **[Phase 2] Clarifying questions** — One question at a time, understand architecture intent, constraints, priorities
6. **[Phase 3] Item-by-item comparison** — CC patterns vs project status, mark each pattern's state
7. **[Phase 4] Propose 2-3 migration directions** — With trade-off analysis and recommendation
8. **[Phase 5] Present migration plan** — Show in segments, confirm each segment before continuing
9. **[Phase 5] Write plan document** — Save to docs/cc-context/plans/YYYY-MM-DD-migration-plan.md, set status to draft
10. **[Phase 5] User review** — Update status to confirmed after user approval, then suggest running /cc-apply

## Flowchart

```dot
digraph cc_learn {
    "Load trace data" [shape=box];
    "Extract CC patterns → knowledge/patterns/" [shape=box];
    "Extract raw examples → knowledge/examples/" [shape=box];
    "Explore project context" [shape=box];
    "Clarifying questions (one at a time)" [shape=box];
    "Sufficient understanding?" [shape=diamond];
    "Item-by-item comparison: CC vs project" [shape=box];
    "Propose 2-3 migration directions" [shape=box];
    "Present plan in segments" [shape=box];
    "User confirms?" [shape=diamond];
    "Write plan document (status: draft)" [shape=box];
    "User reviews document?" [shape=diamond];
    "Update status: confirmed" [shape=box];
    "Suggest running /cc-apply" [shape=doublecircle];

    "Load trace data" -> "Extract CC patterns → knowledge/patterns/";
    "Extract CC patterns → knowledge/patterns/" -> "Extract raw examples → knowledge/examples/";
    "Extract raw examples → knowledge/examples/" -> "Explore project context";
    "Explore project context" -> "Clarifying questions (one at a time)";
    "Clarifying questions (one at a time)" -> "Sufficient understanding?";
    "Sufficient understanding?" -> "Clarifying questions (one at a time)" [label="No, continue asking"];
    "Sufficient understanding?" -> "Item-by-item comparison: CC vs project" [label="Yes"];
    "Item-by-item comparison: CC vs project" -> "Propose 2-3 migration directions";
    "Propose 2-3 migration directions" -> "Present plan in segments";
    "Present plan in segments" -> "User confirms?";
    "User confirms?" -> "Present plan in segments" [label="Revise"];
    "User confirms?" -> "Write plan document (status: draft)" [label="Confirmed"];
    "Write plan document (status: draft)" -> "User reviews document?";
    "User reviews document?" -> "Write plan document (status: draft)" [label="Needs changes"];
    "User reviews document?" -> "Update status: confirmed" [label="Approved"];
    "Update status: confirmed" -> "Suggest running /cc-apply";
}
```

**The terminal state is suggesting /cc-apply.** Do not start modifying code directly. If you reach this point and the user has not confirmed the plan, do not proceed.

## Phase 1: Load, Extract Patterns, and Extract Examples

### Input Sources

Read raw data saved by cc-trace (in priority order):

1. JSONL files in `docs/cc-context/traces/` directory (use Glob to find the latest)
2. User-specified JSONL file path
3. Raw trace data pasted by the user

If no input is found, tell the user to run `/cc-trace` first.

### Analysis Commands

Use jq to extract key information from JSONL. For jq command reference, see [../cc-trace/references/trace-inspection.md](../cc-trace/references/trace-inspection.md).

Extract for each category (use the LLM filter and jq commands from the trace inspection reference):

- **System prompt architecture**: Block count, length, cache_control placement, content segmentation
- **Tool design**: Tool names, description style, parameter schemas, deferred tools
- **Context management**: context_management config, message growth trends
- **Caching strategy**: cache_control placement patterns, ephemeral markers
- **Thinking and reasoning**: thinking config, budget_tokens, effort levels
- **Message patterns**: system-reminder injection, role distribution
- **Model routing**: model selection, max_tokens settings

### Pattern Summaries → knowledge/patterns/

Write extracted pattern summaries to `docs/cc-context/knowledge/patterns/`, organized by topic. Files are created on demand — only when relevant patterns are found.

For classification reference, see [references/pattern-taxonomy.md](references/pattern-taxonomy.md).

#### Pattern Entry Format

```markdown
### <Pattern Name>

- **CC approach**: Specific description of observed behavior
- **Evidence**: See [examples/YYYY-MM-DD-v<version>/<file>](../examples/YYYY-MM-DD-v<version>/<file>)
- **Rationale**: Design reasoning
- **Source**: CC v<version>, YYYY-MM-DD

---
```

#### Incremental Updates

- New traces add new patterns or update existing ones
- Existing patterns are not automatically deleted
- Each pattern tracks its source version
- If a new trace contradicts an existing pattern, flag the conflict and ask the user

### Raw Examples → knowledge/examples/

Extract raw artifacts from the JSONL trace into `docs/cc-context/knowledge/examples/YYYY-MM-DD-v<version>/` (matching the trace's version directory name).

| Output File | Content | Source in JSONL |
|-------------|---------|-----------------|
| `system-prompt-full.md` | Complete system prompt text; all blocks separated by `---` with cache_control annotations | `.request.body.system[]` |
| `tool-definitions/<ToolName>.json` | Individual tool definition with full input_schema; one file per unique tool | `.request.body.tools[]` |
| `thinking-configs.md` | All unique thinking/effort configurations with request context | `.request.body.thinking`, `.request.body.output_config` |
| `context-management.md` | All unique context_management configurations | `.request.body.context_management` |
| `system-reminders.md` | All `<system-reminder>` injected content extracted from user messages | User messages containing system-reminder tags |
| `deferred-tools.md` | All deferred tools declarations | Messages containing available-deferred-tools |
| `first-turn.json` | Complete first LLM request body (system, messages, tools, config) | First request matching `v1/messages` |
| `model-routing.md` | Per-request summary: model, max_tokens, thinking config, effort | `.request.body.model`, `.request.body.max_tokens`, `.request.body.thinking`, `.request.body.output_config` |

### Extraction Summary

After extraction, show a summary to the user:

```
Extraction complete!
  Patterns:
    New:        X
    Updated:    Y
    Unchanged:  Z
    Location:   docs/cc-context/knowledge/patterns/
  Examples:
    Files:      N
    Location:   docs/cc-context/knowledge/examples/YYYY-MM-DD-v<version>/
```

## Phase 2: Explore and Clarify

### Scan Project Code

Use Grep and Glob to scan the current project's agent-related code. **Do not hardcode paths.**

**File patterns:**
- `**/agent/**`, `**/llm/**`, `**/ai/**`, `**/chat/**`
- `**/*prompt*`, `**/*context*`, `**/*tool*`
- `**/*completion*`, `**/*message*`

**Code patterns:**
- System prompt construction: `system`, `system_prompt`, `system_message`
- Tool/function definitions: `tools`, `functions`, `function_call`, `tool_choice`
- Context management: `context`, `token`, `truncat`, `compac`, `compress`
- LLM API calls: `messages.create`, `chat.completions`, `anthropic`, `openai`
- Agent orchestration: `agent`, `subagent`, `delegate`, `spawn`

Build a map of discovered components: file paths, functional descriptions, corresponding agent behavior aspects.

**If no agent-related code is found**, stop and tell the user:

> This project does not contain agent or LLM integration code. cc-learn is designed for projects with LLM API calls (system prompts, tool definitions, context management, etc.). If the project does have agent code, please specify the subdirectory path.

Do not generate a list of "not applicable" entries.

### Clarifying Questions

After understanding the project, clarify with the user **one question at a time**:

- LLM API format used by the project (Anthropic / OpenAI / other)
- Primary migration focus (performance? cost? quality?)
- Architectural constraints and limitations
- Priority preferences

**Rules:**
- Only one question per message
- Prefer multiple-choice questions
- Open-ended questions are acceptable but prefer multiple-choice
- Focus on: purpose, constraints, success criteria

## Phase 3: Comparative Analysis

### Item-by-item Comparison

For each pattern in the knowledge base, assess the project's current state:

| Status | Meaning |
|--------|---------|
| `implemented` | Project already has equivalent functionality |
| `partially-implemented` | Related code exists but missing key aspects |
| `missing` | Not implemented |
| `not-applicable` | Not applicable to this project's architecture |

For `partially-implemented` and `missing` patterns, record:
- **Current state**: How the project currently handles this (with file paths)
- **CC approach**: How Claude Code handles this (link to examples)
- **Gap**: What specifically is missing
- **Priority**: HIGH / MED / LOW
- **Complexity**: S / M / L

Present the comparison summary to the user and wait for confirmation before proceeding to the next phase.

## Phase 4: Direction Proposal

### Propose Migration Directions

Based on the comparison results, propose **2-3 migration directions**, each including:

- **Direction name**: Brief summary
- **Scope**: Which patterns are covered
- **Trade-offs**: Pros and cons
- **Effort estimate**: Approximate scale
- **Recommendation rationale** (if recommended)

Present the recommended direction first with rationale. Wait for the user to select a direction before proceeding to Phase 5.

## Phase 5: Plan Development and Confirmation

### Present Plan in Segments

After the user selects a direction, **present the detailed plan in segments**:

- Each segment covers one topic (e.g., system prompt, tool design, etc.)
- Ask for user confirmation after each segment
- Include specific file paths, modification points, and code examples
- Reference relevant examples from knowledge/examples/ for concrete guidance
- User can request adjustments before continuing

### Write Plan Document

After all segments are confirmed, write to `docs/cc-context/plans/YYYY-MM-DD-migration-plan.md` (date prefix for archival sorting).

**Note: Initial status must be set to `draft`. Only update to `confirmed` after user approval.**

```markdown
# CC Migration Plan

status: draft
Generated: YYYY-MM-DD
Knowledge base: docs/cc-context/knowledge/patterns/
Reference examples: docs/cc-context/knowledge/examples/
Target project: <project root>

## Overview

| Status | Count |
|--------|-------|
| Implemented | X |
| Partially implemented | Y |
| Missing | Z |
| Not applicable | W |

Alignment: X / (X + Y + Z) = XX%

## Migration Direction

<Selected direction and rationale>

## Migration Items

### 1. <Item Name>

- **CC pattern**: <pattern name>
- **Reference example**: [examples/YYYY-MM-DD-v<version>/<file>](../knowledge/examples/YYYY-MM-DD-v<version>/<file>)
- **Current status**: <partially-implemented / missing>
- **Current implementation**: <how the project currently handles this>
- **Target implementation**: <desired state after migration>
- **Affected files**: <file paths>
- **Steps**:
  1. ...
  2. ...
- **Priority**: HIGH / MED / LOW
- **Complexity**: S / M / L

### 2. ...

## Implemented Patterns

(Brief list)

## Not Applicable Patterns

(Brief list with reasons)
```

### User Review

After the document is written, prompt:

> Plan saved to `docs/cc-context/plans/YYYY-MM-DD-migration-plan.md` (current status: draft). Please review the plan.

Wait for user confirmation. If changes are needed, update the document.

**After user approval**, update `status: draft` to `status: confirmed` in the document, then prompt:

> Plan confirmed (status: confirmed). Run `/cc-apply` to start executing the migration.

## Key Principles

- **One question at a time** — Never stack questions
- **Prefer multiple-choice** — Reduce cognitive load
- **2-3 directions to compare** — Never present a single option
- **Confirm in segments** — Never output the entire plan at once
- **Hard gate** — Do not proceed to cc-apply without confirmation
- **Status-driven** — draft → confirmed state transition ensures process integrity
- **Examples as evidence** — Pattern entries link to raw examples, migration items reference concrete artifacts
- **No framework assumptions** — Analyze actual code, do not assume specific frameworks
- **API format-aware** — Support both Anthropic and OpenAI formats
- **Respect project conventions** — Follow the project's existing code style
- **Concrete and actionable** — Reference specific files, functions, and code patterns
