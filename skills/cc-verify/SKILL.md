---
name: cc-verify
description: "Verify that Claude Code patterns were correctly migrated to your agent project. Captures your project's runtime API traces, compares them against the cc-learn knowledge base, and reports which patterns are behaviorally confirmed, partially present, or missing at runtime. Closes the trace-learn-apply-verify loop."
---

# CC Verify

Capture your agent project's runtime API traces and compare them against the cc-learn knowledge base to verify that migrated patterns are actually working at runtime — not just present in code.

This skill closes the feedback loop: `cc-trace → cc-learn → cc-apply → cc-verify`.

For data path and format conventions, see [../shared/data-contracts.md](../shared/data-contracts.md).

## Prerequisites

1. A `docs/cc-context/knowledge/patterns/` knowledge base must exist (created by `/cc-learn`)
2. The target project must have a way to capture its API traces

## Workflow

### Step 1: Locate Knowledge Base

Use Glob to find `docs/cc-context/knowledge/patterns/*.md`. If the user specifies a custom path, use that.

If not found, tell the user to run `/cc-learn` first.

Also check for reference examples at `docs/cc-context/knowledge/examples/` — these can aid in understanding expected behavior.

### Step 2: Obtain Target Project Traces

The target project's API traces can come from multiple sources. Ask the user which applies:

**Option A — JSONL trace file (preferred)**
The user provides a JSONL file containing their project's API requests. Each line should be a JSON object with at least:
- `request.body.system` or `request.body.messages[0].role == "system"` (system prompt)
- `request.body.tools` or `request.body.functions` (tool definitions)
- `request.body.messages` (conversation messages)
- `request.body.model` (model identifier)

Both Anthropic API format and OpenAI-compatible format are supported.

**Option B — Log files or debug output**
The user points to application logs that contain API request/response data. Read and parse them.

**Option C — HTTP proxy capture**
If the project has no built-in trace output, capture API requests via an HTTP proxy:
```bash
# Approach 1: Set environment variable to route traffic through a proxy
HTTPS_PROXY=http://localhost:8080 <start project command>

# Approach 2: If the project is Node.js and uses fetch, try claude-trace
# Note: claude-trace works by monkey-patching Node.js fetch, only applicable to Node.js projects
# --claude-path is repurposed here to point to the project's entry file instead of Claude Code's cli.js
# This is an unofficial usage — prefer HTTPS_PROXY for production projects
claude-trace --claude-path <project entry file> --no-open --include-all-requests --run-with <args>
```

> **Limitations:** claude-trace was originally designed for intercepting Claude Code. When used with other Node.js projects, the following requirements must be met: (1) the project uses Node.js, (2) HTTP requests are made via Node.js built-in fetch or undici. For non-Node.js projects or projects using native HTTP clients, use the HTTPS_PROXY approach or Option A/B.

**Option D — Static code analysis (fallback)**
If no runtime traces are available, fall back to static analysis (similar to cc-apply's code inspection), but **clearly mark results as "static only — not runtime verified"**.

### Step 3: Normalize Trace Data

Convert the captured data to a common format for comparison:

```
{
  system_prompt: { blocks: [...], total_length: N },
  tools: { names: [...], count: N, definitions: [...] },
  context_management: { ... },
  thinking: { ... },
  messages: { count: N, patterns: [...] },
  model: { name: "...", max_tokens: N }
}
```

Handle API format differences:
- Anthropic: `system` is an array of blocks, tools use `input_schema`
- OpenAI: `system` is a message role, tools use `function.parameters`

### Step 4: Pattern-by-Pattern Verification

For each pattern in the knowledge base, check the trace data. Where available, compare against reference examples from `docs/cc-context/knowledge/examples/` for precise behavioral matching.

| Verification Status | Meaning |
|---------------------|---------|
| `confirmed` | Runtime behavior matches the CC pattern |
| `partially-confirmed` | Some aspects present at runtime, others missing |
| `not-observed` | Pattern not detected in traces (may need more test scenarios) |
| `diverged` | Implementation exists but behaves differently from CC pattern |
| `not-applicable` | Pattern cannot apply to this project's API/architecture |

For each pattern, assess against specific observable criteria:

**System prompt design patterns:**
- Check block count, content ordering, total size
- Verify stable content appears first
- Check if cache-friendly structure is maintained

**Tool engineering patterns:**
- Compare tool names, descriptions, parameter schemas
- Check tool count per request
- Look for deferred/conditional tool loading

**Context management patterns:**
- Track message count growth across requests
- Check for compaction/truncation evidence
- Measure system content ratio vs total context

**Thinking/reasoning patterns:**
- Verify thinking config presence and budget sizing
- Check effort level settings

**Message patterns:**
- Look for system-reminder or equivalent injection patterns
- Analyze role distribution

For detailed verification criteria, see [references/verification-criteria.md](references/verification-criteria.md).

### Step 5: Generate Verification Report

Write to `docs/cc-context/reports/YYYY-MM-DD-verification-report.md` (use today's date). Create `docs/cc-context/reports/` if needed. If a report with the same date already exists, overwrite it (the latest run is authoritative).

```markdown
# CC Verification Report

Generated: YYYY-MM-DD
Knowledge base: docs/cc-context/knowledge/patterns/
Reference examples: docs/cc-context/knowledge/examples/
Trace source: <file path or capture method>
Requests analyzed: N

## Summary

| Status | Count |
|--------|-------|
| Confirmed | X |
| Partially confirmed | Y |
| Not observed | Z |
| Diverged | W |
| Not applicable | V |

Behavioral alignment: X / (X + Y + Z + W) = XX%

## Confirmed Patterns

### <Pattern Name>
- **Expected (CC)**: <what CC does>
- **Observed**: <what your project does>
- **Evidence**: <trace data excerpt>

## Partially Confirmed / Diverged Patterns

### <Pattern Name>
- **Expected (CC)**: <what CC does>
- **Observed**: <what your project does>
- **Gap**: <what's missing or different>
- **Suggested fix**: <concrete action>
- **Evidence**: <trace data excerpt>

## Not Observed

Patterns that could not be verified — may need additional test scenarios:
- <Pattern Name>: Need to trigger <specific scenario> to verify
- ...

## Not Applicable

- <Pattern Name>: <reason>
```

### Step 6: Cross-reference with Migration Plan

Use Glob to find all `docs/cc-context/plans/*-migration-plan.md` files. Sort matches lexicographically and pick the last one (most recent date). If found, cross-reference:

- Items marked ✅ in the migration plan but **NOT** confirmed at runtime → **false positive** (cc-apply execution issue). Update the marker to ⚠️.
- Items confirmed at runtime but **NOT** in the migration plan → project already implemented these patterns independently (no action needed).

**Write back to migration plan:** For false positive items, automatically update the corresponding migration item's ✅ to ⚠️ in the migration plan, appending a reason (e.g., `⚠️ not confirmed at runtime — see verification report YYYY-MM-DD`).

If all executed items pass verification **and** the migration plan's current status is `completed`, update the status to `verified`. If the status is still `in-progress`, warn that migration has not finished and do not update the status.

Report all discrepancies with possible causes.

### Step 7: Output Summary

```
CC Verify complete!
  Requests analyzed:     N
  Confirmed:             X patterns
  Partially confirmed/Diverged: Y patterns
  Not observed:          Z patterns
  Behavioral alignment:  XX%
  Report:                docs/cc-context/reports/YYYY-MM-DD-verification-report.md
```

If there are partially-confirmed/diverged patterns, suggest: "Run `/cc-learn` to update the plan, then run `/cc-apply` to re-execute."

If many patterns are "not observed", suggest running more diverse test scenarios to generate more comprehensive trace data.

## Key Principles

- **Runtime data is essential** — Static code analysis (cc-apply) and runtime verification (cc-verify) serve different purposes. Code that looks correct may not behave correctly at runtime.
- **More traces = better verification** — A single API request may not cover all patterns. Encourage users to capture traces from diverse scenarios (simple queries, complex multi-turn tasks, tool-heavy operations).
- **Example-informed verification** — Use reference examples from knowledge/examples/ to understand exact expected behavior.
- **Format-agnostic** — Support both Anthropic and OpenAI API formats. Comparison is at the pattern level, not the API field level.
- **Close the loop** — Verification results are written back to the migration plan, ensuring the feedback loop is truly closed.
