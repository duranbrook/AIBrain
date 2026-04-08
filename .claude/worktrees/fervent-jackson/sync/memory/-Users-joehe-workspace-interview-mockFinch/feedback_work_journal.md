---
name: Work journal preference
description: User wants a persistent work journal so Claude can resume across sessions and they can review past work
type: feedback
---

Always maintain the work journal in `.work-journal/` at session end.

**Why:** User wants continuity across Claude sessions — both for their own reference and so Claude can pick up context without re-explaining.

**How to apply:** At session start, read the latest `.work-journal/` entry and briefly summarize it. At session end, write a new entry following the template in CLAUDE.md. During the session, update the journal if the user asks to wrap up.
