---
name: WorkTracking App Design Decisions
description: All architecture and design decisions made during brainstorming for the employee work tracking app
type: project
---

Employee performance tracking app — quantitative measurement across code output, meeting involvement, and investigation work.

**Architecture:** Cloud-first — Go daemon on employee laptops syncs to a central Go server + managed PostgreSQL (cloud-hosted). Server serves all dashboards.

**Decided:**
- Offline handling: local SQLite buffer + heartbeat every 5min. Server distinguishes "offline" from "daemon stopped"
- Hosting: cloud-managed (AWS/GCP/Azure) + managed PostgreSQL
- LLM analysis location: configurable per daemon — `local`, `server`, or `hybrid` mode
- Meeting transcription: platform APIs (Zoom/Teams/Meet) for MVP. Local audio capture + Whisper is a backlog item
- Code metrics: GitHub/GitLab API polling only (no local git monitoring)
- Platform: macOS only MVP, design for cross-platform later
- Access control: role-based with org hierarchy (manager_id self-reference on users table)
- Org management: manual admin dashboard MVP, data model ready for directory integration (Okta/Google/Azure AD)
- Audience: Employee sees own data + Manager sees team dashboards with org hierarchy drill-down
- Frontend: Go templates + HTMX (server-rendered, no separate build step)
- Daemon is mandatory launchd service, cannot be stopped by employee
- Measurement criteria (rubrics) are stored in DB, editable by admins, expected to evolve

**Why:** Current performance reviews are manager-biased and subjective. This app provides quantitative, long-term (6-12 month) data for fairer evaluation.

**How to apply:** Design spec is at `docs/superpowers/specs/2026-03-27-work-tracking-design.md`. All implementation should follow that spec. Next step is user spec review, then implementation planning.
