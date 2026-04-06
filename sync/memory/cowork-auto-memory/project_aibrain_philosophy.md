---
name: AIBrain project philosophy and purpose
description: The AIBrain repo simulates a human learning loop — asking What/Why/How then Who/When/Where, cycling through Plan-Prioritize-Execute-Retrospective, and persisting learnings into memory.
type: project
---

The AIBrain repo exists to simulate the human learning process for an AI assistant. The core cycle is:

**Inquiry framework (how learning starts):**
- First tier: What, Why, How — understanding the problem and building approach
- Second tier: Who, When, Where — adding context, stakeholders, and logistics

**Learning loop (PPRE cycle):**
1. Planning — define what to do
2. Prioritization — decide what matters most
3. Execution — do the work
4. Retrospective — reflect on what was learned

This loop repeats continuously. Throughout the process, new knowledge is captured and persisted into memory — the "AI brain" that remembers learnings across sessions and projects.

**Why:** The goal is to give AI the same compounding knowledge advantage humans get from experience. Each cycle produces insights that make the next cycle more effective.

**How to apply:** When working in AIBrain, always think in terms of this loop. Tasks should flow through PPRE. New knowledge should be captured, not discarded. The repo structure maps directly to phases of this cycle.

**Folder structure:**
- `tasks/` — work items (Execution phase)
- `reports/` — outputs and findings
- `sync/` — memory/state persistence across runs
- `triggers/` — deprecated; now just a redirect to the scheduled tasks
- `logs/` — run history
- `docs/` — documentation (design spec is the single source of truth)
- `scripts/` — automation scripts (sync.sh)

**Technical setup (multi-trigger, as of 2026-03-30):**
- `aibrain-sync` at 7:50am — syncs journals & memory into repo
- `aibrain-daily-cycle` at 8:00am — morning plan (Phases 1-3)
- `aibrain-execute` at 9:00am — reads owner reply, executes tasks (Phase 2 re-run + Phase 4)
- `aibrain-evening-retro` at 8:00pm — end-of-day retrospective + wrap-up (Phase 1 + Phase 5)
- Prompts live directly in the scheduled task configurations, not in repo files
- Design spec: `docs/superpowers/specs/2026-03-28-aibrain-daily-learning-system-design.md`
- Source repo: user's private AIBrain GitHub repo
