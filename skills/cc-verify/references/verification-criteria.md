# Verification Criteria

Detailed criteria for verifying each pattern category at runtime. Use this reference when assessing trace data against the knowledge base.

## System Prompt Design

| Criterion | How to check | Confirmed if |
|-----------|-------------|--------------|
| Block segmentation | Count system blocks or sections | Multiple distinct sections present |
| Content ordering | Check first block content | Stable/identity content comes first |
| Cache-friendly structure | Check if stable content is prefix | Stable content unchanged across requests |
| Size ratio | system_tokens / context_window | Below 30% of context window |

## Tool Engineering

| Criterion | How to check | Confirmed if |
|-----------|-------------|--------------|
| Descriptive tool docs | Read tool descriptions | Descriptions include usage guidance, not just parameter lists |
| Parameter schema quality | Check required/optional, types, descriptions | Parameters have descriptions and appropriate types |
| Tool count management | Count tools per request | Tool count varies by context (not always max) |
| Deferred loading | Compare tool sets across requests | Some tools appear only in relevant contexts |

## Context Management

| Criterion | How to check | Confirmed if |
|-----------|-------------|--------------|
| Message compaction | Track message count across sequential requests | Message count drops after growth (compaction triggered) |
| Context utilization | total_tokens / context_window per request | Stays below ~90%, with compaction near 80% |
| Tool result limits | Check tool_result content sizes | Large results are truncated or summarized |

## Thinking & Reasoning

| Criterion | How to check | Confirmed if |
|-----------|-------------|--------------|
| Thinking enabled | Check thinking config in requests | `thinking` or equivalent config present |
| Budget sizing | Check budget_tokens value | Budget scales with task complexity |
| Effort adaptation | Compare effort across request types | Simple tasks use lower effort |

## Message Patterns

| Criterion | How to check | Confirmed if |
|-----------|-------------|--------------|
| Context injection | Search for injected context in user messages | Dynamic context added to user messages (not just system prompt) |
| Role balance | Count messages by role | Reasonable mix of user/assistant/tool messages |
| Multi-turn structure | Analyze conversation flow | Tool calls and results properly paired |

## Model Routing

| Criterion | How to check | Confirmed if |
|-----------|-------------|--------------|
| Model selection | Check model field across requests | Appropriate model for task type |
| Token limits | Check max_tokens values | Limits match task requirements |
