# Task Backlog

## Priority 1 (Do Today — 5hr focus block)

- [x] **Interview design: coding interview for hiring** — Completed 2026-04-05. Output: `docs/interview-design/coding-interview-rubric.md` — two-stage format (take-home + live), full scoring rubric, problem bank, calibration notes.
- [x] **Car-parts platform design** — Completed 2026-04-05. Spec already existed at `interview/learning/docs/superpowers/specs/2026-04-04-platform-design.md`. Output: `docs/car-parts/implementation-phases.md` — gap analysis, 5-phase plan, critical path, open decisions.
- [x] **RAG system implementation deep dive** — Completed 2026-04-05. Output: `docs/learning/rag-deep-dive.md` — architecture overview, chunking strategies, retrieval methods, advanced patterns, evaluation framework, PartFinder application map.
- [-] **Set up Apple Developer account** — BLOCKED. Requires manual browser enrollment at developer.apple.com. See blocked.md.

## Priority 2 (This Week)

- [ ] **zhengyi-he-onsite: verify and merge 7 remaining agent branches** — Check branch status for BL-002, BL-004, BL-006, BL-017, BL-018, BL-019, BL-020 (dispatched as background agents 2026-03-31). BLOCKED — see blocked.md.
- [ ] **Configure Cowork with useful skills and connectors** — Explore available plugins, MCP connectors (Slack, Linear, GitHub, etc.), and skills to set up a productive working environment.
- [ ] **Understand the difference between Skills, Connectors, and MCP** — Learn how these three concepts relate in the Claude ecosystem. See reference notes below.

## Priority 3 (Later)

## Completed (Recent)

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
