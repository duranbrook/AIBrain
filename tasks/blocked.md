# Blocked Items

| Task | Blocked Since | Reason | Needed to Unblock |
|------|--------------|--------|-------------------|
| pitagents: Mobile validation on simulator/emulator | 2026-04-26 | Sandbox cloud env has no Xcode + Android Studio; cannot run iOS Simulator or Android Emulator. Static code review (delivered today) is the best the sandbox can do; live smoke test must run on Joe's laptop. | Joe runs the simulator + emulator locally against the deployed backend (Railway). Code review at `pitagents/docs/mobile-code-review-2026-04-26.md` lists 3 P0 fixes that should land *before* the smoke test or it will trip on them immediately. |
| buildco Phase 2 kickoff | 2026-04-26 | Hard prerequisite is "E2E mobile smoke test passes" for pitagents — that prerequisite is itself blocked above. | Mobile smoke test passes on Joe's laptop, or the prerequisite is dropped from buildco Phase 2 scope. |

## Stalled (Soft) — Not Technically Blocked

*None as of 2026-04-26 morning. car-parts top-6 chains shipped on Saturday; per-location enrichment is now a P2 with a clear next step (Google Places API investigation), not a stall.*

## Watch — Potential Blockers for Today's P1

- **No local mobile dev environment in the sandbox** — Mobile validation needs Xcode (iOS sim) and Android Studio (emulator). The scheduled-task sandbox cannot run either; this work must run on the local laptop. Code review can proceed in the sandbox via static review.
- **Quote-Agent precedent: shipped ≠ smoke-tested** — Quote Agent had 4 runtime bugs surface only after smoke test, despite 45 unit tests passing. Expect similar runtime-only bugs in mobile when first run on simulator/emulator. Budget for it in today's plan.

## Friction (Self-inflicted — not owner-blocking)

- **Sandbox cloud runs cannot unlink files in `.git/`** — Every scheduled-task run leaves `.lock.stale.*` residue (the fuse mount allows file creation but blocks delete). The morning plan workaround is `mv .git/index.lock .git/index.lock.stale.<ts>`. Tracked in P3 backlog. Recurring every day this week.
- **Sandbox cannot push to origin** — No GitHub credentials inside the scheduled sandbox; every `git push` from a triggered run fails with `fatal: could not read Username for 'https://github.com'`. Local cron has been catching up. Tracked as part of the same P3 cleanup.
