# Task Backlog

## Priority 1 (Do Today)

## Priority 2 (This Week)

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
