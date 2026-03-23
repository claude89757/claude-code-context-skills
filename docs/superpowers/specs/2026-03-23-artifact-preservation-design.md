# Artifact Preservation & Directory Restructure Design

Generated: 2026-03-23

## Problem

The current cc-trace + cc-learn pipeline only saves abstracted pattern summaries in the knowledge base, discarding the most valuable raw artifacts: actual system prompt text, complete tool definitions, thinking configs, etc. During migration (cc-apply), users have no concrete reference material — only high-level descriptions.

Additionally, `docs/cc-context/` has a flat structure where migration plans and verification reports are loose files at the top level, which becomes disorganized as the project grows.

## Design Decisions

Decided through collaborative brainstorming:

1. **Two-layer extraction (option C)**: cc-trace captures raw JSONL; cc-learn extracts both patterns and raw examples
2. **Full artifact set (option C)**: Extract all artifact types — system prompts, tools, thinking configs, context management, first-turn messages, system-reminders, deferred tools, model routing
3. **Independent examples directory (option B)**: Curated examples live in a separate `examples/` directory, pattern files link to them
4. **cc-learn owns all extraction (option A)**: cc-trace stays pure capture (JSONL + metadata only); cc-learn handles all extraction from JSONL into knowledge/
5. **Per-version examples**: examples/ is organized by version since raw artifacts are version-specific snapshots; patterns/ remains cross-version evolved summaries
6. **Lifecycle-based directory structure**: Top-level directories map to pipeline stages

## New Directory Structure

```
docs/cc-context/
├── traces/                          # Stage 1: Raw capture (cc-trace)
│   └── YYYY-MM-DD-v<version>/
│       ├── trace.jsonl
│       └── metadata.json
│
├── knowledge/                       # Stage 2: Patterns + examples (cc-learn)
│   ├── patterns/                    # Cross-version evolved summaries
│   │   └── <topic>.md              # Created on demand per pattern-taxonomy.md
│   └── examples/                    # Per-version raw artifacts
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
│
├── plans/                           # Stage 3: Migration plans (written by cc-learn, executed by cc-apply)
│   └── YYYY-MM-DD-migration-plan.md
│
└── reports/                         # Stage 4: Verification reports (cc-verify)
    └── YYYY-MM-DD-verification-report.md
```

### Design Rationale

- **traces/** contains only raw JSONL + metadata. No extraction here — keeps cc-trace simple and fast.
- **knowledge/** is split into two concerns:
  - **patterns/**: Evolved summaries that accumulate across versions. Each pattern entry tracks its source version. Files are created on demand based on what's found in traces.
  - **examples/**: Version-stamped raw artifacts. These are snapshots of what CC actually sent, preserving the complete original content. Organized per-version so multiple captures can coexist and be compared.
- **plans/**: Migration plans move from the top level into their own directory.
- **reports/**: Verification reports move from the top level into their own directory.

## Changes by Skill

### cc-trace

No functional change. Still captures JSONL + metadata only. Path remains `docs/cc-context/traces/YYYY-MM-DD-v<version>/`.

### cc-learn

**Phase 1 expanded**: After loading JSONL and extracting patterns (existing), also extract raw examples:

1. Load JSONL from `docs/cc-context/traces/`
2. Extract pattern summaries → `docs/cc-context/knowledge/patterns/<topic>.md` (existing behavior, new path)
3. **NEW**: Extract raw artifacts → `docs/cc-context/knowledge/examples/YYYY-MM-DD-v<version>/`

**Example extraction details:**

| Output File | Source in JSONL | Extraction Method |
|-------------|-----------------|-------------------|
| `system-prompt-full.md` | `.request.body.system[]` | Concatenate all system blocks, separated by `---`, with cache_control annotations |
| `tool-definitions/<Name>.json` | `.request.body.tools[]` | One file per unique tool, full definition including input_schema |
| `thinking-configs.md` | `.request.body.thinking`, `.request.body.output_config` | All unique configs with request context |
| `context-management.md` | `.request.body.context_management` | All unique configs |
| `system-reminders.md` | system-reminder tags in user messages | Extract all `<system-reminder>` content blocks |
| `deferred-tools.md` | deferred tools declarations in messages | Extract available-deferred-tools content |
| `first-turn.json` | First LLM request | Complete request body (system, messages, tools, config) |
| `model-routing.md` | `.request.body.model`, `.request.body.max_tokens` | Per-request summary table |

**Pattern entry format updated** — evidence field links to examples:

```markdown
### <Pattern Name>

- **CC approach**: Specific description of observed behavior
- **Evidence**: See [examples/YYYY-MM-DD-v<version>/system-prompt-full.md](examples/YYYY-MM-DD-v<version>/system-prompt-full.md)
- **Rationale**: Design reasoning
- **Source**: CC v<version>, YYYY-MM-DD
```

**Knowledge base path change**: `docs/cc-context/patterns/` → `docs/cc-context/knowledge/patterns/`

**Migration plan path change**: `docs/cc-context/YYYY-MM-DD-migration-plan.md` → `docs/cc-context/plans/YYYY-MM-DD-migration-plan.md`

### cc-apply

- **Migration plan path**: `docs/cc-context/plans/*-migration-plan.md`
- **NEW**: When executing migration items, reference `docs/cc-context/knowledge/examples/` for concrete implementation guidance. The migration plan's steps can link to specific example files.

### cc-verify

- **Knowledge base path**: `docs/cc-context/knowledge/patterns/*.md`
- **Migration plan path**: `docs/cc-context/plans/*-migration-plan.md`
- **Report path**: `docs/cc-context/reports/YYYY-MM-DD-verification-report.md`

## Data Contracts Update

All paths in `shared/data-contracts.md` must be updated:

| Old Path | New Path |
|----------|----------|
| `docs/cc-context/patterns/` | `docs/cc-context/knowledge/patterns/` |
| `docs/cc-context/patterns/*.md` (glob) | `docs/cc-context/knowledge/patterns/*.md` |
| `docs/cc-context/*-migration-plan.md` | `docs/cc-context/plans/*-migration-plan.md` |
| `docs/cc-context/*-verification-report.md` | `docs/cc-context/reports/*-verification-report.md` |
| (new) | `docs/cc-context/knowledge/examples/*/` |

## Migration Plan Template Update

The migration plan template in cc-learn should encourage referencing examples:

```markdown
### 1. <Item Name>

- **CC pattern**: <pattern name>
- **Reference example**: [examples/YYYY-MM-DD-v<version>/<file>](...)
- **Current status**: <partially-implemented / missing>
- **Current implementation**: <how the project currently handles this>
- **Target implementation**: <desired state after migration>
- **Affected files**: <file paths>
- **Steps**:
  1. ...
  2. ...
- **Priority**: HIGH / MED / LOW
- **Complexity**: S / M / L
```
