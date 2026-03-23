# Pattern Taxonomy

Classification reference for cc-learn Phase 1 (pattern extraction from trace data). Use this as a guide when classifying extracted patterns into topic files — if a pattern doesn't fit any category, create a note about it and ask the user.

## system-prompt-design.md

Patterns related to how the system prompt is constructed and organized:

- Block segmentation (how content is split into separate system blocks)
- Content ordering (what goes first/last and why)
- Cache control placement (`cache_control: {"type": "ephemeral"}` breakpoints)
- Static vs dynamic content separation
- System prompt size relative to context window
- Instruction layering (base instructions, environment, tools guidance, user preferences)

## tool-engineering.md

Patterns related to tool definitions and tool-related behavior:

- Tool naming conventions (casing, verb/noun patterns)
- Parameter schema design (required vs optional, descriptions, types)
- Tool description writing style and length
- Tool count management (how many tools per request)
- Deferred tools mechanism (lazy loading tools based on context)
- Tool grouping and categorization

## context-management.md

Patterns related to managing the context window:

- `context_management` API configuration
- Message compaction/compression strategies
- Context window utilization targets
- When and how old messages are trimmed
- Tool result truncation
- Conversation history management

## agent-orchestration.md

Patterns related to multi-agent and delegation:

- Subagent spawning (Agent tool design)
- Task delegation criteria (what gets delegated vs handled directly)
- Parallel vs sequential agent execution
- Agent isolation and context sharing
- Subagent result aggregation

## thinking-reasoning.md

Patterns related to model reasoning configuration:

- `thinking` block configuration (`type`, `budget_tokens`)
- `output_config` effort levels
- When thinking is enabled vs disabled
- Budget token sizing relative to task complexity
- Reasoning effort adaptation

## message-patterns.md

Patterns related to message structure and injection:

- `system-reminder` tag usage and placement
- User message augmentation (injecting context into user messages)
- Tool call/result message patterns
- Multi-turn conversation structure
- Role distribution (system/user/assistant balance)

## model-routing.md

Patterns related to model selection and configuration:

- Which model is used for which request type
- `max_tokens` settings and their rationale
- Model switching across conversation turns
- Relationship between model choice and thinking/effort config
