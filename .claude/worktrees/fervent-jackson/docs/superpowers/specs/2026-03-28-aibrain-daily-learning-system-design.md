# AIBrain — Daily Learning & Productivity System

## Overview

AIBrain is a centralized learning and productivity system that runs as a set of scheduled Claude tasks throughout the day. It aggregates work journals and persistent memory from all Claude Code projects, manages a Plan-Prioritize-Execute-Retrospective (PPRE) cycle, and communicates with the owner via the task sessions in the Claude app.

## Goals

1. **Consistent learning tracking** — capture and surface professional learnings daily, with rollups at weekly/monthly/quarterly/yearly cadence (top 3 per level)
2. **PPRE productivity cycle** — structured daily workflow: plan from pending tasks, prioritize with owner input, execute in order, retrospect on outcomes
3. **Cross-project aggregation** — pull from all projects' work journals and memory, not just one
4. **Minimal friction communication** — owner sees the plan in Claude app, replies when convenient, next run picks it up

## Repo Structure

```
AIBrain/
  reports/
    daily/YYYY-MM-DD.md
    weekly/YYYY-WXX.md
    monthly/YYYY-MM.md
    quarterly/YYYY-QX.md
    yearly/YYYY.md
  tasks/
    backlog.md          # all pending tasks with priority tiers
    blocked.md          # blocked items with reasons and dates
  sync/
    journals/           # synced from ~/workspace/*/.work-journal/
    memory/             # synced from ~/.claude/projects/*/memory/
  scripts/
    sync.sh             # local sync script (runs as 7:50am scheduled task)
  docs/
    superpowers/specs/  # this design spec
  logs/                 # run history
```

## Data Sources

### Work Journals
- Synced from all `.work-journal/` directories under `~/workspace/` into `sync/journals/`
- Each subdirectory represents a project
- Extract: completed tasks, pending tasks, key decisions, blockers

### Claude Memory
- Synced from `~/.claude/projects/*/memory/` into `sync/memory/`
- Each subdirectory represents a project
- Extract: learnings, insights, discoveries (focus on `feedback`, `project`, `user` types)

### What Qualifies as a "Learning"
Professional breadth — not just technical:
- **Technical:** new coding patterns, debugging insights, tool discoveries, architecture decisions
- **Process:** methodology insights ("TDD saved time", "this approach failed because...")
- **Collaboration:** stakeholder preferences, project context, team dynamics
- **Tool/workflow:** CLI discoveries, integration tips, productivity hacks

### Deduplication
If the same insight appears in multiple projects' journals/memory, consolidate into one learning entry noting which projects it came from.

## Scheduled Tasks

The daily cycle is split across 4 scheduled tasks. Prompts live directly in the scheduled task configurations (managed via Claude's scheduled tasks UI).

| Task ID | Time | Description |
|---------|------|-------------|
| `aibrain-sync` | 7:50am | Runs `scripts/sync.sh` — copies journals & memory into repo, commits, pushes |
| `aibrain-daily-cycle` | 8:00am | Morning plan: retrospective (Phase 1), planning (Phase 2), daily briefing (Phase 3) |
| `aibrain-execute` | 9:00am | Reads owner reply, re-prioritizes (Phase 2 re-run), executes tasks (Phase 4) |
| `aibrain-evening-retro` | 8:00pm | End-of-day retrospective (Phase 1 evening), wrap-up and push (Phase 5) |

### Phase Details

**Phase 1 — Retrospective:** Scan `sync/journals/` and `sync/memory/` for recent entries. Extract top 3 learnings. Write `reports/daily/YYYY-MM-DD.md`. Check rollup boundaries (weekly on Sunday, monthly on 1st, quarterly, yearly).

**Phase 2 — Planning:** Check for owner reply. Parse new tasks/priorities. Merge into `tasks/backlog.md`. Re-prioritize: owner input > unblocked by urgency > blocked items.

**Phase 3 — Daily Briefing:** Post to session: blocked items (prominent), yesterday's top 3 learnings, today's prioritized plan, prompt for owner input.

**Phase 4 — Execute:** Work through `tasks/backlog.md` in priority order. Complete or mark blocked. Update backlog and blocked files.

**Phase 5 — Wrap Up:** Finalize daily report with end-of-day status. Git add, commit, pull --rebase, push.

## Report Formats

### Daily Report (`reports/daily/YYYY-MM-DD.md`)
```markdown
# Daily Report: YYYY-MM-DD

## Key Learnings (Top 3)
1. [Learning] — [why it matters]
2. ...
3. ...

## Executed Today
- [x] Task A (source project)
- [ ] Task C — blocked: [reason]

## Blocked Items
- Task C: [detailed reason, what's needed to unblock]

## Tomorrow's Tentative Plan
1. [Task] — priority 1
2. [Task] — priority 2
```

### Backlog (`tasks/backlog.md`)
```markdown
# Task Backlog

## Priority 1 (Do Today)
- [ ] Task description — source: [origin] — added: YYYY-MM-DD

## Priority 2 (This Week)
- [ ] ...

## Priority 3 (Later)
- [ ] ...

## Completed (Recent)
- [x] Task — completed: YYYY-MM-DD
```

### Blocked (`tasks/blocked.md`)
```markdown
# Blocked Items

| Task | Blocked Since | Reason | Needed to Unblock |
|------|--------------|--------|-------------------|
| ... | YYYY-MM-DD | ... | ... |
```

### Rollup Summaries (weekly/monthly/quarterly/yearly)
```markdown
# [Period] Summary: [identifier]

## Key Learnings (Top 3)
1. [Learning] — [why it matters]
2. ...
3. ...

## Completed This [Period]
- ...

## Carried Over / Blocked
- ...
```

Each rollup level independently re-evaluates ALL raw daily data for that period. Weekly does not pick from daily top 3s — it looks at everything.

## Communication

### Channel
Scheduled task sessions visible in Claude app on phone and desktop.

### Interaction Flow
1. **7:50am** sync runs → journals and memory pushed to repo
2. **8:00am** morning plan → posts briefing + learnings + blockers in session
3. Owner opens Claude app, sees the output, replies with priorities
4. **9:00am** execute run → reads reply, re-prioritizes, works through tasks
5. **8:00pm** evening retro → end-of-day summary, commits everything

### If No Reply
Agent proceeds with existing backlog priorities. Notes "no new input from owner" in the session.

## Rules

- NEVER force push
- NEVER delete .env or credential files
- Always pull before pushing
- If merge conflicts occur, resolve conservatively
- Top 3 learnings maximum at every level — can be fewer, never more
- Each rollup level independently re-evaluates ALL raw daily data, not summaries from below
- If no meaningful learnings for a day, say so honestly — don't fabricate
- Blocked items always appear prominently at the top of the daily briefing
