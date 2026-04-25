# Blocked Items

| Task | Blocked Since | Reason | Needed to Unblock |
|------|--------------|--------|-------------------|

*No hard blockers (external dependencies) as of 2026-04-25 morning plan.*

## Stalled (Soft) — Not Technically Blocked

- **car-parts: Contact enrichment (top-10 chains)** — 14 days zero progress as of 2026-04-25 morning. P1 today with a 30-min time-box; if no movement by end of weekend (Sun 2026-04-26), demote to P3 and stop carrying.

## Watch — Potential Blockers for Today's P1

- **OpenRouter `sk-or-v1` key vs OpenAI embeddings client** — Yesterday Joe added an `sk-or-v1`-prefixed key to `.worktrees/enterprise-ai/backend/.env`. The OpenAI Python embeddings client points at `api.openai.com` by default and OpenRouter is a different endpoint, so embeddings calls during seed/ingest may fail without `OPENAI_BASE_URL=https://openrouter.ai/api/v1` (or a true OpenAI key). Will turn into a real blocker for the enterprise-AI validation step if it surfaces. Source: pitagents journal 2026-04-25 Session 00:00.

## Friction (Self-inflicted — not owner-blocking)

- **Sandbox cloud runs cannot unlink files in `.git/`** — Every scheduled-task run leaves `.lock.stale.*` residue; the 2af7213 sync left an `index.lock` that blocked the Apr 24 morning plan's initial `git checkout`. The Apr 24 evening retro hit the same `unable to unlink .git/index.lock: Operation not permitted` warning during `git status`. Workaround: `mv .git/index.lock .git/index.lock.stale.<ts>`. Tracked in P3 backlog.
