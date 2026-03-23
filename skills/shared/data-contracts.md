# Data Contracts

This document defines the data flow paths and format conventions between the four skills: cc-trace, cc-learn, cc-apply, and cc-verify. Before modifying any path or format, ensure all related skills are updated accordingly.

## Directory Structure

```
docs/cc-context/
├── traces/                              # cc-trace output
│   └── YYYY-MM-DD-v<version>/
│       ├── trace.jsonl                  # Raw trace data
│       └── metadata.json               # Capture metadata
├── patterns/                            # cc-learn output (knowledge base)
│   ├── system-prompt-design.md
│   ├── tool-engineering.md
│   ├── context-management.md
│   ├── agent-orchestration.md
│   ├── thinking-reasoning.md
│   ├── message-patterns.md
│   └── model-routing.md
├── YYYY-MM-DD-migration-plan.md         # cc-learn output → cc-apply input
└── YYYY-MM-DD-verification-report.md    # cc-verify output
```

## Data Flow

```
cc-trace ──→ traces/*/trace.jsonl ──→ cc-learn ──→ patterns/*.md
                                         │
                                         └──→ migration-plan.md ──→ cc-apply
                                                     │                  │
                                                     ←── ✅ marks ──────┘
                                                     │
                                             cc-verify ──→ verification-report.md
                                                 │
                                                 └──→ write back to migration-plan (⚠️ marks)
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
| Knowledge base files | `docs/cc-context/patterns/*.md` |
| Migration plan | `docs/cc-context/*-migration-plan.md` |
| Verification report | `docs/cc-context/*-verification-report.md` |

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
