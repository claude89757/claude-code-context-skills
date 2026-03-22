# Migration Strategies

Guidance for translating Claude Code's Anthropic API patterns to other agent frameworks and API formats.

## API Format Translation

### System Prompt

| Anthropic API | OpenAI-compatible API |
|---------------|----------------------|
| `system` is an array of `{type: "text", text: "...", cache_control: {...}}` blocks | `system` is a single string (or a system-role message) |

**Migration approach:**
- Concatenate Anthropic system blocks into a single string with clear section separators (e.g., `---` or `# Section Name`)
- Preserve the ordering — Claude Code puts stable/high-frequency content first for caching; even without API-level caching, this ordering aids readability
- If the target API supports multiple system messages (some do), map each Anthropic block to a separate system message

### Cache Control

| Anthropic | General |
|-----------|---------|
| `cache_control: {"type": "ephemeral"}` on system blocks | No direct equivalent in most APIs |

**Migration approach:**
- The purpose of cache control is to mark stable content for prompt caching. Learn the *principle*: separate stable content (instructions, tool definitions) from dynamic content (conversation state, user context)
- If the target provider supports prompt caching (e.g., OpenAI's cached prompts), structure prompts so stable prefixes remain unchanged across requests
- If no caching support: still separate stable vs dynamic content for maintainability

### Tool Definitions

| Anthropic | OpenAI |
|-----------|--------|
| `tools[].name` | `tools[].function.name` |
| `tools[].description` | `tools[].function.description` |
| `tools[].input_schema` | `tools[].function.parameters` |

**Migration approach:**
- Direct field mapping as shown above
- Anthropic's tool descriptions tend to be detailed and instructional — preserve this style regardless of API format
- Tool names follow the same conventions across both APIs

### Thinking / Reasoning

| Anthropic | OpenAI |
|-----------|--------|
| `thinking: {type: "enabled", budget_tokens: N}` | `reasoning_effort: "low"/"medium"/"high"` (model-dependent) |

**Migration approach:**
- Map thinking budget to effort levels: small budget → low, medium budget → medium, large budget → high
- If the target model doesn't support reasoning control, this pattern is not applicable

### Context Management

| Anthropic | General |
|-----------|---------|
| `context_management` API field | Custom implementation required |

**Migration approach:**
- Implement message truncation/compaction in application code
- Key strategy from CC: summarize old messages rather than dropping them entirely
- Monitor context utilization (total tokens / max context) and trigger compaction at a threshold (CC uses ~80%)

## Pattern-Level Strategies

### System Prompt Layering

CC structures its system prompt in layers:
1. Base identity and behavior instructions (stable)
2. Tool usage guidance (stable)
3. Environment info (semi-stable — changes per session)
4. User preferences and project context (dynamic)
5. System reminders injected into messages (per-turn dynamic)

**Apply to any project:**
- Separate instructions by change frequency
- Put stable content first (enables caching and reduces drift)
- Use message-level injection for per-turn context rather than rebuilding the system prompt

### Tool Progressive Disclosure

CC doesn't load all tools at once. It uses "deferred tools" to announce tool availability without sending full definitions until needed.

**Apply to any project:**
- Start with essential tools, add specialized tools based on task context
- Reduces token cost and model confusion from too many tools
- Implement as conditional tool inclusion in the request builder

### Context Window Utilization

CC actively manages its context budget:
- System prompt + tools take a predictable, bounded portion
- Message history grows until a threshold, then gets compacted
- Tool results are truncated if too large

**Apply to any project:**
- Set a token budget for system content (aim for <30% of context window)
- Implement tool result size limits
- Add conversation compaction at ~80% window utilization
- Track token usage per request for monitoring
