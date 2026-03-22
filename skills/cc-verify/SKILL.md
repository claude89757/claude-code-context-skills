---
name: cc-verify
description: "Verify that Claude Code patterns were correctly migrated to your agent project. Captures your project's runtime API traces, compares them against the cc-learn knowledge base, and reports which patterns are behaviorally confirmed, partially present, or missing at runtime. Closes the learn-apply-verify loop."
---

# CC Verify

Capture your agent project's runtime API traces and compare them against the cc-learn knowledge base to verify that migrated patterns are actually working at runtime — not just present in code.

This skill closes the feedback loop: `cc-trace → cc-learn → cc-apply → cc-verify`.

## Prerequisites

1. A `docs/cc-patterns/` knowledge base must exist (created by `/cc-learn`)
2. The target project must have a way to capture its API traces

## Workflow

### Step 1: Locate knowledge base

Use Glob to find `docs/cc-patterns/*.md`. If the user specifies a custom path, use that.

If not found, tell the user to run `/cc-learn` first.

### Step 2: Obtain target project traces

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

**Option C — Live capture (if the project uses Node.js + Anthropic API)**
Use `claude-trace` to intercept the project's API calls:
```bash
claude-trace --claude-path <path-to-project-entry> --no-open --include-all-requests --run-with <args>
```
This only works if the project uses Node.js and makes fetch-based HTTP calls.

**Option D — Code inspection fallback**
If no runtime traces are available, fall back to static analysis (similar to cc-apply) but clearly mark results as "static only — not runtime verified".

### Step 3: Normalize trace data

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
- Anthropic: `system` is array of blocks, tools use `input_schema`
- OpenAI: `system` is a message role, tools use `function.parameters`

### Step 4: Pattern-by-pattern verification

For each pattern in the knowledge base, check the trace data:

| Verification Status | Meaning |
|---------------------|---------|
| `confirmed` | Runtime behavior matches the CC pattern |
| `partial` | Some aspects present, others missing |
| `not-observed` | Pattern not detected in traces (may need more test scenarios) |
| `diverged` | Implementation exists but behaves differently from CC pattern |
| `not-applicable` | Pattern cannot apply to this project's API/architecture |

For each pattern, assess against specific observable criteria:

**System Prompt Design patterns:**
- Check block count, content ordering, total size
- Verify stable content appears first
- Check if cache-friendly structure is maintained

**Tool Engineering patterns:**
- Compare tool names, descriptions, parameter schemas
- Check tool count per request
- Look for deferred/conditional tool loading

**Context Management patterns:**
- Track message count growth across requests
- Check for compaction/truncation evidence
- Measure system content ratio vs total context

**Thinking/Reasoning patterns:**
- Verify thinking config presence and budget sizing
- Check effort level settings

**Message Patterns:**
- Look for system-reminder or equivalent injection patterns
- Analyze role distribution

### Step 5: Generate Verification Report

Write to `docs/cc-verification-report.md`. Create `docs/` if needed.

```markdown
# CC Verification Report

Generated: YYYY-MM-DD
Knowledge base: docs/cc-patterns/
Trace source: <file path or capture method>
Requests analyzed: N

## Summary

| Status | Count |
|--------|-------|
| Confirmed | X |
| Partial | Y |
| Not observed | Z |
| Diverged | W |
| Not applicable | V |

Behavioral alignment: X / (X + Y + Z + W) = XX%

## Confirmed Patterns

### <Pattern Name>
- **Expected (CC)**: <what CC does>
- **Observed**: <what your project does>
- **Evidence**: <trace data excerpt>

## Partial / Diverged Patterns

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

### Step 6: Comparison with cc-apply report

If `docs/cc-alignment-report.md` exists (from a previous `/cc-apply` run), compare:

- Patterns that cc-apply marked as `implemented` but cc-verify marks as `not-observed` or `diverged` → **false positives** in static analysis, flag these
- Patterns that cc-apply marked as `missing` but cc-verify marks as `confirmed` → unlikely but possible if implementation was added after the last cc-apply run

Report any discrepancies.

### Step 7: Output summary

```
CC Verify complete!
  Requests analyzed:     N
  Confirmed:             X patterns
  Partial/Diverged:      Y patterns
  Not observed:          Z patterns
  Behavioral alignment:  XX%
  Report:                docs/cc-verification-report.md
```

If there are partial/diverged patterns, suggest re-running `/cc-apply` to get updated migration suggestions.

If many patterns are "not observed", suggest specific test scenarios to run to generate more comprehensive traces.

## Important Notes

- **Runtime data is essential.** Static code analysis (cc-apply) and runtime verification (cc-verify) serve different purposes. Code that looks correct may not behave correctly at runtime.
- **More traces = better verification.** A single API request may not cover all patterns. Encourage users to capture traces from diverse scenarios (simple queries, complex multi-turn tasks, tool-heavy operations).
- **Format-agnostic.** Support both Anthropic and OpenAI API formats. The comparison is at the pattern level, not the API field level.
