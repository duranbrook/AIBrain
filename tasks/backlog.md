# Task Backlog

## Priority 1 (Do Today — 5hr focus block)

- [ ] **stlab: CMDB ingestion + data model** — Active project as of 2026-04-21. In progress: ingestion pipeline (CSV/JSON/YAML), user_groups + user_app_llm migrations, relationship gap reporting, groups tab design. Running /nuke-test-data to reset state as of 2026-04-22 morning. **Currently active.**

- [ ] **car-parts: Contact enrichment** — Enrich phone/email/website for 3,623 recyclers in `apps/web/src/data/recyclers.ts`. Strategy: major chains first (LKQ Keystone, Fenix, B&R Auto Wrecking), then batch by state with parallel web search agents. Source: car-parts journal 2026-04-11. **Carry-over day 11.** Consider demoting to P2 given stlab momentum.

## Priority 2 (This Week)

- [ ] **buildco Phase 2** — Task management API (create/assign from CEO Agent chat), daily briefing push notifications (iOS), brand kit generation via image API. Prerequisite: E2E smoke test passes. Source: business journal 2026-04-06/07.
- [ ] **Configure Cowork with useful skills and connectors** — Explore available plugins, MCP connectors (Slack, Linear, GitHub, etc.), and skills to set up a productive working environment.
- [ ] **Understand the difference between Skills, Connectors, and MCP** — Learn how these three concepts relate in the Claude ecosystem. See reference notes below.

## Priority 3 (Later)

- [ ] **Confirm sync pipeline health** — Quiet period confirmed as real inactivity (2026-04-12 → 2026-04-21). stlab journals now syncing correctly as of 2026-04-22. Monitor for continued sync health.

## Completed (Recent)

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
