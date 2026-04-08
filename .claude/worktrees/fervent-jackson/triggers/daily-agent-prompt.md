# DEPRECATED — Prompts have moved

This file is no longer used. The daily cycle prompts now live directly in the scheduled task configurations:

| Task ID | Schedule | Manages |
|---------|----------|---------|
| `aibrain-sync` | 7:50am | Sync journals & memory |
| `aibrain-daily-cycle` | 8:00am | Morning plan (Phases 1-3) |
| `aibrain-execute` | 9:00am | Execute tasks (Phase 2 re-run + Phase 4) |
| `aibrain-evening-retro` | 8:00pm | Evening retro (Phase 1 + Phase 5) |

Manage these from the **Scheduled** section in the Claude app sidebar.

For the full system design, see: [`docs/superpowers/specs/2026-03-28-aibrain-daily-learning-system-design.md`](../docs/superpowers/specs/2026-03-28-aibrain-daily-learning-system-design.md)
