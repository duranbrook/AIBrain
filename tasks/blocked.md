# Blocked Items

| Task | Blocked Since | Reason | Needed to Unblock |
|------|--------------|--------|-------------------|

*No hard blockers (external dependencies) as of 2026-04-25 morning plan.*

## Stalled (Soft) — Not Technically Blocked

*None as of 2026-04-25 evening retro — car-parts top-6 chains enriched, mobile sub-project shipped.*

## Watch — Potential Blockers for Tomorrow's P1

- **No local mobile dev environment in the sandbox** — Mobile validation tomorrow needs Xcode (iOS sim) and Android Studio (emulator). The scheduled-task sandbox cannot run either; this work must run on the local machine.
- **Quote-Agent precedent: shipped ≠ smoke-tested** — Quote Agent had 4 runtime bugs surface only after Joe smoke-tested in the evening, despite 45 unit tests passing. Expect similar runtime-only bugs in mobile when first run on simulator/emulator.

## Friction (Self-inflicted — not owner-blocking)

- **Sandbox cloud runs cannot unlink files in `.git/`** — Every scheduled-task run leaves `.lock.stale.*` residue; the 2af7213 sync left an `index.lock` that blocked the Apr 24 morning plan's initial `git checkout`. The Apr 24 evening retro hit the same `unable to unlink .git/index.lock: Operation not permitted` warning during `git status`. Workaround: `mv .git/index.lock .git/index.lock.stale.<ts>`. Tracked in P3 backlog.
