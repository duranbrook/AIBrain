---
name: pitagents SSE generator bugs (2026-04-23)
description: Three chat API bugs found during smoke test of feat/web-chat-ui; all fixed
type: project
originSessionId: 41d5a89a-e7fe-4d1e-a141-0ce61970976b
---
Three bugs found and fixed during 2026-04-23 smoke test of pitagents Sub-project 1:

1. **auth.py test user IDs were not UUIDs** — `"owner-1"` / `"tech-1"` instead of UUID strings. `uuid.UUID(sub)` in chat.py crashed. Fixed to `"00000000-0000-0000-0000-000000000001"` etc.

2. **model_dump() on Anthropic content blocks includes internal fields** — `.model_dump()` adds `parsed_output` and other SDK-internal fields. When these messages are sent back to the Claude API in multi-turn calls, it returns 400 `Extra inputs are not permitted`. Fix: explicitly build dicts with only API-accepted fields (`type`, `text` for text blocks; `type`, `id`, `name`, `input` for tool_use blocks).

3. **SSE generator: code after last yield never executes** — Message save code was after the final `yield` in the async generator. In Python, code after the last yield is skipped when the generator is abandoned (HTTP connection closes). Fix: move save to inside the loop, triggered on the `done` event before its yield.

**Why:** Classic Python async generator footgun. The SSE client closes the connection, the generator is GC'd, finalization code never runs.

**How to apply:** When writing FastAPI SSE generators, never put side effects (DB writes, notifications) after the last yield. Put them before the final yield or in a `try/finally` block.
