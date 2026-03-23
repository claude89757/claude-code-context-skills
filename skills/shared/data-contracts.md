# Data Contracts

This document defines the data flow paths and format conventions between the four skills: cc-trace, cc-learn, cc-apply, and cc-verify. Before modifying any path or format, ensure all related skills are updated accordingly.

## Directory Structure

```
docs/cc-context/
├── traces/                              # cc-trace output
│   └── YYYY-MM-DD-v<version>/
│       ├── trace.jsonl                  # Raw trace data
│       └── metadata.json               # Capture metadata
├── knowledge/                           # cc-learn output
│   ├── patterns/                        # Cross-version evolved summaries
│   │   └── <topic>.md                  # Created on demand per pattern-taxonomy.md
│   └── examples/                        # Per-version raw artifacts
│       └── YYYY-MM-DD-v<version>/
│           ├── system-prompt-full.md
│           ├── tool-definitions/
│           │   └── <ToolName>.json
│           ├── thinking-configs.md
│           ├── context-management.md
│           ├── system-reminders.md
│           ├── deferred-tools.md
│           ├── first-turn.json
│           └── model-routing.md
├── plans/                               # Migration plans (written by cc-learn, executed by cc-apply)
│   └── YYYY-MM-DD-migration-plan.md
└── reports/                             # Verification reports (cc-verify)
    └── YYYY-MM-DD-verification-report.md
```

## Data Flow

```
cc-trace ──→ traces/*/trace.jsonl ──→ cc-learn ──→ knowledge/patterns/*.md
                                         │              knowledge/examples/*/
                                         │
                                         └──→ plans/migration-plan.md ──→ cc-apply
                                                        │                    │
                                                        ←── ✅ marks ────────┘
                                                        │
                                                cc-verify ──→ reports/verification-report.md
                                                    │
                                                    └──→ write back to plans/ (⚠️ marks)
```

## Migration Plan Status

The migration-plan.md must include a status line near the top of the document:

| Status | Meaning | Set by |
|--------|---------|--------|
| `status: draft` | Plan draft, not yet confirmed by user | cc-learn on creation |
| `status: confirmed` | User-confirmed, ready for execution | cc-learn after user approval |
| `status: in-progress` | Migration is being executed | cc-apply on start |
| `status: completed` | All migration items executed | cc-apply on finish |
| `status: verified` | Passed runtime verification | cc-verify on success |

### Migration Item Markers

| Marker | Meaning | Set by |
|--------|---------|--------|
| (none) | Pending | cc-learn |
| ✅ | Executed | cc-apply |
| ⚠️ | Executed but failed runtime verification | cc-verify |
| ⏭️ | Skipped (blocked) | cc-apply |

## Glob Pattern Reference

| Purpose | Pattern |
|---------|---------|
| Latest trace directory | `docs/cc-context/traces/*/trace.jsonl` |
| Knowledge base patterns | `docs/cc-context/knowledge/patterns/*.md` |
| Knowledge base examples | `docs/cc-context/knowledge/examples/*/` |
| Migration plan | `docs/cc-context/plans/*-migration-plan.md` |
| Verification report | `docs/cc-context/reports/*-verification-report.md` |

## metadata.json Format

```json
{
  "version": "<claude-code-version>",
  "capture_date": "YYYY-MM-DD",
  "request_count": 0,
  "llm_request_count": 0,
  "prompt_used": "hello"
}
```

## Example Files Reference

The following files are extracted by cc-learn from raw JSONL traces into `knowledge/examples/YYYY-MM-DD-v<version>/`:

| File | Content | Source in JSONL |
|------|---------|-----------------|
| `system-prompt-full.md` | Complete system prompt text, blocks separated by `---` | `.request.body.system[]` |
| `tool-definitions/<Name>.json` | Individual tool definition with full schema | `.request.body.tools[]` |
| `thinking-configs.md` | All unique thinking/effort configs with request context | `.request.body.thinking`, `.output_config` |
| `context-management.md` | Context management configurations | `.request.body.context_management` |
| `system-reminders.md` | All `<system-reminder>` injected content | User messages containing system-reminder tags |
| `deferred-tools.md` | Deferred tools declarations | Messages containing available-deferred-tools |
| `first-turn.json` | Complete first LLM request body | First request matching `v1/messages` |
| `model-routing.md` | Per-request model + max_tokens summary | `.request.body.model`, `.max_tokens` |
