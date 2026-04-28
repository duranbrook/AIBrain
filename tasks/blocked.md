# Blocked Items

| Task | Blocked Since | Reason | Needed to Unblock |
|------|--------------|--------|-------------------|
| pitagents: Push backend `a504cf3` + `6307b71` to Railway | 2026-04-26 | Sandbox has no Railway credentials. `a504cf3` (report-generation pipeline, 2026-04-26) and `6307b71` (Twilio resilience + InspectScreen, 2026-04-27) sit on local `pitagents/main` undeployed. Pixel 10a smoke yesterday hit HTTP 500 on message send because Railway still runs pre-`6307b71` code. | Joe explicitly authorizes the deploy and runs `railway up` (or whatever deploy command) from his laptop. |
| pitagents: iOS Simulator validation | 2026-04-26 | Sandbox cannot run Xcode. Yesterday's iOS sim attempt confirmed the app launches past login + tab bar renders, but `cliclick` mouse moves stopped registering as iOS taps after 2026-04-27 (worked 2026-04-26 with formula `macOS_y = 79.4 + iOS_point_y × 1.078`). | Joe either tests manually on a physical iPhone, or switches the driver to `xcrun simctl io <UDID> input` + accessibility identifiers (more reproducible across rebuilds). |
| pitagents: Monitor real inspection results for per-finding photo matching quality | 2026-04-27 | Sandbox cannot observe production; verifying photo-to-finding matching needs eyes on actual generated PDFs from real inspections. | Joe shares 1–2 recent inspection PDFs (or the underlying `findings.photo_url` rows). Alternatively, the W18 P2 task to add a `logger.info` recording matched/unassigned counts per render gives the same signal from logs. |
| buildco Phase 2 kickoff | 2026-04-26 | Hard prerequisite was "E2E mobile smoke test passes." Yesterday's Pixel 10a run *substantially de-risked* this — Android side smoked + 2 bugs found + fixed. iOS smoke still pending due to sim-tap issue. | Either iOS smoke also clears (via path above), or Joe accepts ~80% confidence from the Android run and greenlights buildco Phase 2 in parallel. |

## Recently Unblocked (2026-04-27)

- **pitagents: Mobile validation on Android (physical Pixel 10a)** — Joe ran `./gradlew installDebug` on a connected Pixel 10a yesterday and executed 7 Gherkin scenarios. 5 PASS, 2 FAIL (Twilio HTTP 500, InspectScreen feature divergence). Both fails fixed in commit `6307b71`; awaiting Railway deploy + device reconnect to re-smoke. Effective state: Android smoke substantially complete; the *device validation* sub-task is no longer blocked, only the re-smoke after deploy.

## Stalled (Soft) — Not Technically Blocked

*None as of 2026-04-28 morning. car-parts top-6 chains shipped 2026-04-25; per-location enrichment is now a P2 with a clear next step (Google Places API investigation).*

## Watch — Potential Blockers for W18 P1

- **iOS simulator tap injection regressed on 2026-04-27** — cliclick worked on 2026-04-26 with the y-coordinate offset formula but stopped registering the next day. If `xcrun simctl io input` doesn't pan out either, iOS smoke is effectively gated on a physical device.
- **Quote-Agent precedent: shipped ≠ smoke-tested (now 3rd instance)** — Confirmed again on 2026-04-27: 45 unit tests + 3 P0 static-review fixes did not catch the backend Twilio HTTP 500 or the InspectScreen feature-vs-test-plan divergence — the Pixel 10a smoke surfaced both. Budget for *more* runtime-only bugs to surface in the iOS smoke.

## Friction (Self-inflicted — not owner-blocking)

- **Sandbox cloud runs cannot unlink files in `.git/`** — Every scheduled-task run leaves `.lock.stale.*` residue (the fuse mount allows file creation but blocks delete). The morning plan workaround is `mv .git/index.lock .git/index.lock.stale.<ts>`. Tracked in P3 backlog. Recurring every day this week.
- **Sandbox cannot push to origin** — No GitHub credentials inside the scheduled sandbox; every `git push` from a triggered run fails with `fatal: could not read Username for 'https://github.com'`. Local cron has been catching up. Tracked as part of the same P3 cleanup.
