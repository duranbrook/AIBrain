# Task Backlog

## Priority 1 (Do Today — 2026-04-24 Friday; two concurrent threads)

- [ ] **pitagents: Execute Sub-project 2 (Quote Agent)** — Plan is written at `docs/superpowers/plans/2026-04-23-quote-agent.md` (10 tasks, est. 4–6h): Quote DB model, Alembic migration, 6 agent tools, agent class, system prompt, API routes, frontend panel + sidebar entry, tests. Highest-ROI task — plan is fresh and unblocked. Source: pitagents journal 2026-04-23 + Thursday tomorrow-plan.
- [ ] **stlab: Continue relationship gap reporting + groups tab** — Ingestion pipeline validated yesterday (9 users, 3 devices, 6 apps; 3 device-user assignments; 50 ingest gaps). Next: gap reporting UI and continue groups tab implementation per `docs/plans/2026-04-20-groups-tab-design.md`. Resolve API port 8000 conflict with pitagents so E2E tests can run on the default port. Source: interview_stlab journal 2026-04-23 + Thursday tomorrow-plan.

## Priority 2 (This Week)

- [ ] **car-parts: Contact enrichment (top-10 chains validation chunk)** — Enrich phone/email/website for the 10 largest chains in `apps/web/src/data/recyclers.ts` as a validation subset before scaling to the full 3,623. Demoted from P1 on 2026-04-22 after 11 zero-progress carry-over days. Source: car-parts journal 2026-04-11.
- [ ] **buildco Phase 2** — Task management API (create/assign from CEO Agent chat), daily briefing push notifications (iOS), brand kit generation via image API. Prerequisite: E2E smoke test passes. Source: business journal 2026-04-06/07.
- [ ] **pitagents: Fix transcribe endpoint 502 (Deepgram)** — Add logging to expose the actual Deepgram error. Blocks voice-input path on chat. Small task, good to batch with Sub-project 2 work. Source: pitagents journal 2026-04-23 (Session 00:00 next steps).
- [ ] **Configure Cowork with useful skills and connectors** — Explore available plugins, MCP connectors (Slack, Linear, GitHub, etc.), and skills to set up a productive working environment.
- [ ] **Understand the difference between Skills, Connectors, and MCP** — Learn how these three concepts relate in the Claude ecosystem. See reference notes below.

## Priority 3 (Later)

- [ ] **Fix sandbox `.git` lock accumulation** — Cloud runs cannot `unlink` files inside `.git`, so every run leaves `.lock.stale.*` residue (and on Apr 24 morning the initial `git checkout` was blocked by a stale `index.lock` from the 2af7213 sync). Either gate git write-ops behind a lock cleaner, or run sync/retro only from the local cron where unlink is permitted. Source: interview_AIBrain journal 2026-04-23 "Friction notes".
- [ ] **Confirm sync pipeline health** — Overnight sync on 2026-04-23 correctly caught the pitagents 23:09 session that was missed by the prior evening retro. Monitor for continued sync health.
- [ ] **pitagents: Sub-project 3 — Mobile Chat Interface** — Queued after Sub-project 2 ships. Mirror the web chat flow on iOS + Android. Source: pitagents journal 2026-04-23.

## Completed (Recent)

- [x] **stlab: CMDB ingestion validation on freshly nuked data** — 80/80 unit tests pass (fixed Dockerfile to install dev deps); ingestion pipeline validated: 9 users, 3 devices, 6 apps; 3 device-user assignments confirmed. Completed 2026-04-23.
- [x] **pitagents: smoke test of Sub-project 1 + plan Sub-project 2 (Quote Agent)** — API smoke test passed (found+fixed 3 bugs: UUID auth IDs, model_dump extra fields, SSE save placement). Sub-project 2 plan written at `docs/superpowers/plans/2026-04-23-quote-agent.md` (10 tasks, 4–6h). Completed 2026-04-23.
- [x] **pitagents: Sub-project 1 — Web Chat UI** — All 15 tasks implemented: DB model, transcribe endpoint, upload endpoint, agent tools (VIN + shop DB), base/assistant/tom agents, chat API (SSE streaming), frontend API client, MessageBubble, VoiceButton, ImageAttach, ChatPanel, AppShell + AgentList, /chat route. 76/76 backend tests passing. Branch: `feat/web-chat-ui`. Completed 2026-04-23. Source: pitagents journal 2026-04-23.
- [x] **pitagents: initial stack bring-up + auth flow** — Full Docker Compose stack (db, redis, backend, web) up; 5 startup bugs fixed (pydantic_settings, bcrypt/passlib, pydantic[email], `/` → `/dashboard`, CORSMiddleware); `/login` + JWT + dashboard auth guard wired; creds `owner@shop.com` / `testpass` work. Completed 2026-04-22 night. Source: pitagents journal 2026-04-22.
- [x] **pitagents: repository README + quick-start guide** — Root-level README.md for new-developer onboarding. Completed 2026-04-22 AM. Source: pitagents journal 2026-04-22.
- [x] **stlab: CMDB ingestion + data model (phase 1)** — Pipeline fixes (code fence stripping, NullPool/Celery, recursive parser, `on_conflict_do_nothing` upsert dedup, model alias), 3 migrations (0003/0004/0006), docs/plans, test suite repairs (80/80 passing). Committed 4 commits to stlab/main via AIBrain execute `11a09cb`. Completed 2026-04-22.
- [x] **PitCrew: YouTube outreach expanded to 2,000 channels** — 76 BFS rounds, Cat 1–3 prioritized (Parts Resellers, Salvage/Part-Out, Car Flippers). Committed `a55fb12`. Completed 2026-04-12.
- [x] **PitCrew: Vercel build fix** — Clerk v7 prop rename + Next.js 16 `proxy.ts`. Committed `8ae0113`. Completed 2026-04-12.
- [x] **car-parts: Recycler directory page** — 3,623 recyclers loaded into `apps/web/src/data/recyclers.ts`, `/recyclers` page live, nav link added. Completed 2026-04-11.
- [x] **Interview rubric: Option B promotional platform question** — Full promo platform take-home problem added (POST /promotions, redeem, GET status, background job), with concurrency-specific rubric additions (concurrent redemption handling, validation ordering, error specificity, idempotency). Completed 2026-04-06/07.
- [x] **buildco: full-stack AI business platform** — scaffold, auth, admin, 18 API routes, live Claude API, iOS SwiftUI app with full test suite, completed 2026-04-06/07.
- [x] **RAG deep dive: PartFinder implementation** — Architecture reference + full 4-use-case spec (hybrid retrieval, model tiering, pgvector HNSW), completed 2026-04-07.
- [x] **Car-parts platform design** — gap analysis, 5-phase implementation roadmap, completed 2026-04-05
- [x] **Set up Apple Developer account** — resolved 2026-04-05
- [x] **zhengyi-he-onsite: 7 remaining agent branches** — closed out 2026-04-05
- [x] **Design and initialize AIBrain repo** — completed 2026-03-28
- [x] **mockFinch: Claude Files API integration** — all 3 endpoints validated with live Anthropic API, completed 2026-03-30
- [x] **mockFinch: Transcript intake service** — S3 + Anthropic Files upload + Claude extraction, completed 2026-03-30
- [x] **WorkTracking: All 4 phases + 8 backlog items** — full app complete (server, daemon, dashboards, LLM pipeline), completed 2026-03-28
- [x] **mockFinch: 80 E2E tests, RBAC, Temporal, analytics, admin, portal** — completed 2026-03-27

---

## Reference: Skills vs Connectors vs MCP

**MCP** — Open protocol (the plumbing) that lets Claude talk to external services. Each MCP server exposes tools.
**Connectors** — Pre-built MCP integrations with auth handled for you (e.g., Gmail, Notion, Google Calendar).
**Skills** — Prompt-based instructions that teach Claude how to do specific tasks well (e.g., make a polished .pptx).
**Plugins** — Bundles of connectors + skills in one installable package.
