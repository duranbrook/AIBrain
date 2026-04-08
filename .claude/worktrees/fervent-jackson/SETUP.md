# AIBrain Setup & Usage

## Status

Setup is complete. All scheduled tasks are configured and running.

## Scheduled Tasks

| Task | Schedule | Purpose |
|------|----------|---------|
| `aibrain-sync` | 7:50am daily | Syncs work journals and Claude memory into repo |
| `aibrain-daily-cycle` | 8:00am daily | Morning retrospective, planning, daily briefing |
| `aibrain-execute` | 9:00am daily | Reads owner reply, executes prioritized tasks |
| `aibrain-evening-retro` | 8:00pm daily | End-of-day retrospective and wrap-up |

Manage these from the **Scheduled** section in the Claude app sidebar.

## Daily Usage

1. **Morning:** Open Claude app → check the `aibrain-daily-cycle` session for today's briefing
2. **Reply:** Type priorities or new tasks as a reply in the session (before 9am to catch the execute run)
3. **Evening:** Check the `aibrain-evening-retro` session for end-of-day summary
4. **Next day:** The 8am run incorporates your replies and continues the cycle

## Design Spec

Full system design: [`docs/superpowers/specs/2026-03-28-aibrain-daily-learning-system-design.md`](docs/superpowers/specs/2026-03-28-aibrain-daily-learning-system-design.md)

## Troubleshooting

- **Tasks not running?** Check they're enabled in the Scheduled section. Do a manual "Run now" to pre-approve tool permissions.
- **Sync not working?** Verify `scripts/sync.sh` can access `~/workspace/` and `~/.claude/projects/`.
- **Stale data?** The sync runs at 7:50am. If you need fresher data, trigger a manual sync run first.
