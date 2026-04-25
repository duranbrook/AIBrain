# Blocked Items

| Task | Blocked Since | Reason | Needed to Unblock |
|------|--------------|--------|-------------------|

*No hard blockers (external dependencies) as of 2026-04-24 evening retro.*

## Stalled (Soft) — Not Technically Blocked

- **car-parts: Contact enrichment (top-10 chains)** — 13 days zero progress as of 2026-04-24 evening. Promoted back to P1 for 2026-04-25 with a 30-min time-box; if no movement by end of weekend, demote to P3 and stop carrying.

## Friction (Self-inflicted — not owner-blocking)

- **Sandbox cloud runs cannot unlink files in `.git/`** — Every scheduled-task run leaves `.lock.stale.*` residue; the 2af7213 sync left an `index.lock` that blocked the Apr 24 morning plan's initial `git checkout`. The Apr 24 evening retro hit the same `unable to unlink .git/index.lock: Operation not permitted` warning during `git status`. Workaround: `mv .git/index.lock .git/index.lock.stale.<ts>`. Tracked in P3 backlog.
