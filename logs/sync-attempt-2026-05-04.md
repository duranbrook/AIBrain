# AIBrain Sync — Scheduled Task Attempt

**Run at:** 2026-05-04 02:36 EDT (Cowork scheduled task `aibrain-sync`)
**Result:** Blocked. No files synced. No push. See "What you need to do" below.

## Root cause: stale git lock files

`logs/sync.log` and `logs/sync-error.log` show the local cron has been failing for at least the last few runs with:

```
fatal: cannot lock ref 'HEAD': Unable to create '/Users/joehe/workspace/interview/AIBrain/.git/HEAD.lock': File exists.
fatal: Unable to create '/Users/joehe/workspace/interview/AIBrain/.git/index.lock': File exists.
```

The current state of `.git/`:

- `.git/index.lock`        (0 bytes, mtime 2026-05-04 00:10)
- `.git/packed-refs.lock`  (0 bytes, mtime 2026-05-04 06:36 — this one is mine, see below)
- `.git/REBASE_HEAD.lock`  (0 bytes, mtime 2026-05-04 06:36 — this one is mine)

The `index.lock` from 00:10 is the original culprit — likely left from a crashed or interrupted git operation around midnight. Every cron run since then has bailed out instead of committing/pushing.

## What this scheduled task could and couldn't do

The Cowork sandbox this task runs in has narrow filesystem access:

- It CAN see the AIBrain repo (mounted at the workspace path).
- It CANNOT see `~/workspace/` (other projects' `.work-journal/` dirs).
- It CANNOT see `~/.claude/projects/` (memory dirs).
- It has no GitHub credentials, so it can't `git push`.
- It cannot `rm` files inside `.git/` (mount permission).

So even though I can READ the existing `sync/` contents and run `git status`, I cannot reproduce the actual sync (read source → write target → push).

## Source-side delta (what tomorrow's sync should pick up)

Files newer than what's currently in `sync/journals/`:

| Source | Already in sync? |
|---|---|
| `projects/pitagents/.work-journal/2026-05-03.md` | NO — needs sync |
| `projects/pitagents/.work-journal/2026-05-04.md` | NO — needs sync |
| `projects/pitagents/.work-journal/2026-04-27..05-02.md` | already there, but mtime may be newer (script syncs by mtime ≤ 7d) |
| `interview/AIBrain/.work-journal/2026-05-01.md` | already there (latest AIBrain entry) |
| All other projects | no new dated files |

Memory files: 7 project dirs under `~/.claude/projects/`, all already represented in `sync/memory/`. Won't know which (if any) have changed without reading them.

## Local repo state

```
On branch main
Your branch is ahead of 'origin/main' by 9 commits.
```

The 9 unpushed commits cover:
- `chore(sync)` 2026-05-01 and 2026-05-03
- `chore(plan)` and `chore(retro)` for 05-01 / 05-02 / 05-03

These are real work that needs to reach the remote.

## What you need to do

1. Clear the stale lock files:

   ```bash
   cd ~/workspace/interview/AIBrain
   rm -f .git/index.lock .git/HEAD.lock .git/packed-refs.lock .git/REBASE_HEAD.lock
   ```

2. Run the sync manually (it will pick up 05-03 and 05-04 plus any modified entries):

   ```bash
   bash scripts/sync.sh
   ```

3. Confirm the push succeeded — the 9 backlogged commits + today's new sync commit should all reach `origin/main`.

4. Optional: harden the script so future stale locks don't silently break sync — e.g. detect and remove `.git/index.lock` if it's older than N minutes, or run `git gc --prune=now` on a weekly schedule.

## Why this Cowork trigger can't replace the cron

The cron runs locally with full filesystem and credential access. This Cowork-scheduled task runs in a sandbox with neither. It's useful as a watchdog (it found the lock-file issue tonight) but it can't be the primary sync mechanism. Keep the launchd/cron job as the source of truth and treat this trigger as a status check.
