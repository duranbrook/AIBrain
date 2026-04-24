# Blocked Items

| Task | Blocked Since | Reason | Needed to Unblock |
|------|--------------|--------|-------------------|

*No hard blockers (external dependencies) as of 2026-04-24 morning plan.*

## Stalled (Soft) — Not Technically Blocked

*None as of 2026-04-24 morning plan — stlab and pitagents are both actively progressing (Sub-project 2 plan ready to execute); car-parts remains P2 with a re-scoped top-10-chains validation chunk (still zero progress — consider scoping to a 30-min time-box to force motion or re-demote to P3).*

## Friction (Self-inflicted — not owner-blocking)

- **Sandbox cloud runs cannot unlink files in `.git/`** — Every scheduled-task run leaves `.lock.stale.*` residue; the 2af7213 sync left an `index.lock` that blocked the Apr 24 morning plan's initial `git checkout`. Workaround: `mv .git/index.lock .git/index.lock.stale.<ts>`. Tracked in P3 backlog.
