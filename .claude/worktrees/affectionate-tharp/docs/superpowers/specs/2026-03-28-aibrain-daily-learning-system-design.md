# AIBrain — Daily Learning & Productivity System

## Overview

AIBrain is a centralized learning and productivity system that runs as a single scheduled Claude Code remote trigger daily at 8am. It aggregates work journals and persistent memory from all Claude Code projects, manages a Plan-Prioritize-Execute-Retrospective (PPRE) cycle, and communicates with the owner via the trigger's session in the Claude app/dashboard.

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
  docs/
    superpowers/specs/  # design specs
  triggers/
    daily-agent-prompt.md   # the prompt used by the remote trigger
  .work-journal/
    YYYY-MM-DD.md       # per-session work journal for AIBrain itself
```

## Data Sources

### Work Journals
- Scan all `.work-journal/` directories under `~/workspace/` recursively
- Read the current day's file (or most recent) from each project
- Extract: completed tasks, pending tasks, key decisions, blockers

### Claude Memory
- Scan `~/.claude/projects/*/memory/` for all project memory directories
- Read memory files, focusing on types: `feedback`, `project`, `user`
- Extract: learnings, insights, discoveries

### What Qualifies as a "Learning"
Professional breadth — not just technical:
- **Technical:** new coding patterns, debugging insights, tool discoveries, architecture decisions
- **Process:** methodology insights ("TDD saved time", "this approach failed because...")
- **Collaboration:** stakeholder preferences, project context, team dynamics
- **Tool/workflow:** CLI discoveries, integration tips, productivity hacks

### Deduplication
If the same insight appears in multiple projects' journals/memory, consolidate into one learning entry noting which projects it came from.

## Daily Cycle — Single 8am Trigger

### Phase 1: Yesterday's Retrospective
1. Scan all projects' work journals + memory for yesterday's entries
2. Extract learnings, rank by significance, select top 3
3. Write `reports/daily/YYYY-MM-DD.md` for yesterday
4. Check rollup boundaries:
   - Sunday → write `reports/weekly/YYYY-WXX.md`
   - 1st of month → write `reports/monthly/YYYY-MM.md`
   - 1st of quarter (Jan/Apr/Jul/Oct) → write `reports/quarterly/YYYY-QX.md`
   - Jan 1 → write `reports/yearly/YYYY.md`
5. Update `tasks/blocked.md` with current state

### Phase 2: Today's Plan
1. Read the owner's reply from yesterday's trigger session (if any)
2. Parse natural language for new tasks, priority changes, or instructions
3. Merge new tasks into `tasks/backlog.md`
4. Scan all work journals for pending/incomplete tasks from yesterday and this week
5. Re-prioritize everything:
   - Owner's explicit instructions take highest priority
   - Blocked items pushed down
   - Urgency and recency as tiebreakers
6. Post in the session:
   - Blocker alerts (prominent, at top)
   - Yesterday's top 3 learnings
   - Today's prioritized plan
   - "Do you have anything new to prioritize?"

### Phase 3: Execute
1. Work through tasks in priority order
2. For each task: attempt → complete or mark blocked with reason
3. Skip blocked tasks, move to next
4. Update `tasks/backlog.md` and `tasks/blocked.md` as work progresses

### Phase 4: Wrap Up
1. Git add, commit, push all changes to remote
2. Commit message: `chore(daily): YYYY-MM-DD daily cycle — X tasks completed, Y blocked`

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
- [x] Task B (source project)
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
All follow the same format:
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

Each rollup level independently re-evaluates ALL raw daily data for that period to select its top 3 learnings. Weekly does not just pick from daily top 3s — it looks at everything.

## Communication

### Channel
Remote trigger session visible in Claude app/dashboard on phone and desktop.

### Interaction Flow
1. 8am trigger runs → posts plan + learnings + blockers in session
2. Owner opens Claude app, sees the output, replies with priorities (anytime during the day)
3. Next morning's 8am run reads the reply from the previous session and incorporates it

### If No Reply
Agent proceeds with the existing backlog priorities unchanged. Notes "no new input from owner" in the session.

## Constraints

- **1 remote trigger limit** on current plan — all phases run in a single trigger
- **Must disable existing marketplace trigger** before AIBrain trigger can be created
- **No proactive push notifications** — owner must check the Claude app; however, the session appearing in recents serves as a soft notification

## Future Enhancements (Not In Scope)
- Multiple triggers if plan is upgraded (separate 8am/9am/8pm)
- Gmail/Slack integration for true push notifications
- Interactive mid-day check-ins
