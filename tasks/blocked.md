# Blocked Items

| Task | Blocked Since | Reason | Needed to Unblock |
|------|--------------|--------|-------------------|
| pitagents: Confirm Railway deploy state for `a504cf3` + `6307b71` | 2026-04-26 | Sandbox has no Railway credentials. `a504cf3` (report-generation pipeline, 2026-04-26) and `6307b71` (Twilio resilience + InspectScreen, 2026-04-27) may or may not have shipped with the 2026-04-30 14:00 `railway up --service backend` (which definitely shipped the PATCH /reports/{id}/estimate change set and was verified live). Until confirmed, prod may still return HTTP 500 on `POST /vehicles/{id}/messages` when Twilio is flaky. | From Joe's laptop: `git log origin/main..main -- backend/` plus `railway logs --service backend \| head` to confirm running commit SHA. If older commits not deployed, run `railway up --service backend` once more. |
| pitagents: iOS Simulator deep-navigation calibration for report estimate flow | 2026-04-30 | Sandbox cannot run Xcode. 2026-04-30 sim run cleared the cliclick regression for the upper flow (login → customer detail confirmed via screenshot), but deep navigation to the report-with-estimate edit screen "needed coordinate calibration for secondary display." | Joe either runs the estimate-edit flow manually on the sim, recalibrates tap coordinates, or switches the driver to `xcrun simctl io <UDID> input` + accessibility identifiers (more reproducible across rebuilds). |
| pitagents: User-validate multi-step voice chain + clean up debug logs | 2026-04-30 | 2026-04-30 final session shipped 3 commits with debug `console.log` statements deliberately left in. Sandbox cannot run a browser session against `pitagents.vercel.app` to validate the `[voice] chain-check` output. | Joe runs PTT with "go to reports and find the Honda Civic", pastes browser console output. On confirm: sandbox cleans up debug logs. On failure: paste output for diagnosis. |
| pitagents: Android E2E on simulator/device for 2026-04-30 voice + estimate-edit features | 2026-04-30 | "No AVDs configured on this machine — not tested in simulator." Gradle build verified during feature implementation, but the voice + estimate-edit surface area was not exercised on Android. | AVD configured (or a connected device — Pixel 10a from 2026-04-27 is a known-good baseline). |
| pitagents: Monitor real inspection results for per-finding photo matching quality | 2026-04-27 | Sandbox cannot observe production; verifying photo-to-finding matching needs eyes on actual generated PDFs from real inspections. | Joe shares 1–2 recent inspection PDFs (or the underlying `findings.photo_url` rows). Alternatively, a P2 task to add `logger.info` per-render counters gives the same signal from logs. |
| buildco Phase 2 kickoff | 2026-04-26 | Soft-blocked. Hard prerequisite was "E2E mobile smoke test passes." Substantially de-risked: Android Pixel 10a 2026-04-27 (5 PASS / 2 FAIL — both fails fixed in `6307b71`); iOS sim 2026-04-30 confirmed login + nav; web estimate-edit surface tested live. The original gate is approximately satisfied for the surface area BuildCo cares about. | Either iOS deep-navigation also clears, or Joe accepts ~80% confidence from the partial mobile smoke and greenlights buildco Phase 2 in parallel. |

## Recently Unblocked (2026-05-01)

- **pitagents: iOS Simulator validation (upper flow)** — 2026-04-30 sim run confirmed the app launches past login + tab bar renders + automated tapping reaches customer detail via screenshot. The cliclick regression from 2026-04-27 has a working path again on iPhone 16 sim. *Effective state:* upper-flow validation is no longer blocked; only deep-flow estimate-edit calibration remains (now its own line above).
- **pitagents: Push backend commits to Railway (mostly)** — 2026-04-30 14:00 deploy confirmed PATCH /reports/{id}/estimate live in prod. *Effective state:* the pipeline works; whether the older `a504cf3` + `6307b71` rode along is the only outstanding unknown (now framed as a confirm-task above, not a block).
- **pitagents: Reconcile InspectScreen spec vs. implementation** — 2026-05-01 verified by execute run (read-only QA). Both platforms implement the 2-step flow. No blocker remained.
- **pitagents: `RecordingActivity.BASE_URL` Railway URL fix** — 2026-05-01 by execute run. Commit `8b02e2b` on `pitagents/main` (sandbox-local — local cron will sync to GitHub).

## Stalled (Soft) — Not Technically Blocked

*None as of 2026-05-01 evening. car-parts top-6 chains shipped 2026-04-25; per-location enrichment is a P2 with a clear next step (Google Places API investigation).*

## Watch — Potential Blockers for W18 / W19 P1

- **iOS sim deep-flow tap calibration is fragile** — Upper flow worked on 2026-04-30; deep navigation didn't. Pattern matches the 2026-04-26 → 2026-04-27 cliclick regression: pixel-driven taps + per-build coord recalibration is recurring fragility. Strongly suggests committing to `xcrun simctl io input` + accessibility identifiers instead.
- **Shipped ≠ smoke-tested (4th instance budget)** — 2026-04-30 shipped a substantial voice + reports + estimate stack to `pitagents.vercel.app` with deploy-time fixes (Vercel framework misconfig, lightningcss linux build) discovered only at deploy time. The voice chain bug surfaced after deploy too. Budget for more runtime-only bugs in the multi-step chain user-test and Android E2E.
- **AIBrain daily-cycle scheduler missing morning runs (3 days)** — No `chore(plan)` commits since 2026-04-28; daily reports for 04-29 / 04-30 / 05-01 weren't written. Sync + execute fired today (00:15 + 00:20) but plan didn't. Filed as a P3 backlog item; if the gap continues, escalates to P2.

## Friction (Self-inflicted — not owner-blocking)

- **Sandbox cloud runs cannot unlink files in `.git/`** — Every scheduled-task run leaves `.lock.stale.*` residue (the fuse mount allows file creation but blocks delete). Morning-plan workaround is `mv .git/index.lock .git/index.lock.stale.<ts>`. Tracked in P3 backlog. Recurring every day this week.
- **Sandbox cannot push to origin** — No GitHub credentials inside the scheduled sandbox; every `git push` from a triggered run fails with `fatal: could not read Username for 'https://github.com'`. Local cron has been catching up. Tracked as part of the same P3 cleanup.
- **Sandbox cannot push to other repos either** — `pitagents/main` commit `8b02e2b` from 2026-05-01 also sits sandbox-local awaiting local cron sync. Same root cause.
