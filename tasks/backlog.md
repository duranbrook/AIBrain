# Task Backlog

## Priority 1 (Do Today — 5hr focus block)

- [ ] **Interview rubric: refine promo platform question** — Base rubric done 2026-04-05; needs fine-tuning on the promotional platform problem specifically. Rubric at `docs/interview-design/coding-interview-rubric.md`. Carry over from 2026-04-05.
- [ ] **RAG deep dive: PartFinder implementation** — Architecture reference completed 2026-04-05 (`docs/learning/rag-deep-dive.md`), but PartFinder-specific RAG implementation not completed. Carry over from 2026-04-05.

## Priority 2 (This Week)

- [ ] **Configure Cowork with useful skills and connectors** — Explore available plugins, MCP connectors (Slack, Linear, GitHub, etc.), and skills to set up a productive working environment.
- [ ] **Understand the difference between Skills, Connectors, and MCP** — Learn how these three concepts relate in the Claude ecosystem. See reference notes below.
- [ ] **buildco Phase 2** — Task management API, daily briefing push notifications (mobile), brand kit generation. Continue if Joe resumes this project.

## Priority 3 (Later)

## Completed (Recent)

- [x] **buildco: full-stack AI business platform** — scaffold, auth, admin, Expo mobile app, 17 API routes, live Claude API, completed 2026-04-06
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
