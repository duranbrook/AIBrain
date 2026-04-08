---
name: BuildCo project state
description: Current state of the BuildCo AI business platform — what exists, where it lives, what's working
type: project
---

BuildCo is an AI-powered business platform ("Build a one-person business yourself") at `/Users/joehe/workspace/business`.

**Why:** Joe is building a product where Claude powers AI employees (35 roles) that run a business end-to-end.

**How to apply:** Always read the latest work journal at `.work-journal/` before starting. The platform is live and functional — don't scaffold from scratch.

## Repos

| Repo | Path | Purpose |
|---|---|---|
| Web (Next.js 16) | `/Users/joehe/workspace/business` | Main platform |
| Mobile (Expo RN) | `/Users/joehe/workspace/buildco-mobile` | React Native mirror (deprecated in favor of Swift) |
| iOS (Swift) | `/Users/joehe/workspace/buildco-ios` | Native SwiftUI app |

## Web stack
- Next.js 16 (App Router, TypeScript, Tailwind)
- Prisma 7 + PostgreSQL (`ai_business` DB, port 5432, Docker container `ai-business-postgres`)
- Claude API `claude-sonnet-4-6` — one agent per employee role
- BullMQ + Redis (background jobs)
- JWT sessions via `jose` (httpOnly cookie for web, Bearer token for mobile)
- bcryptjs for password hashing

## What's built and working (as of 2026-04-07)
- Landing page, `/signup`, `/login` with full auth
- CEO Agent onboarding chat → creates Business + spawns team
- Dashboard with 35-role employee sidebar, 1:1 streaming chat (SSE)
- Daily Briefing (AI-generated CEO summary)
- Legal intake form (3-step LLC filing flow)
- Admin dashboard at `/admin` (user table, business/employee counts)
- REST auth endpoints for mobile: `POST /api/auth/signup`, `POST /api/auth/login`
- `GET /api/users/me/businesses` for mobile keychain restore

## iOS app (SwiftUI, `/workspace/buildco-ios`)
- 6 screens: Landing, Signup, Login, Onboard, Dashboard, Chat
- Keychain token storage, Bearer auth
- XCUITest E2E suite + unit tests (BuildCoTests + BuildCoUITests targets)
- Generated with xcodegen from `project.yml`

## Dev server
- Runs at `http://localhost:3001`
- Start: `cd /Users/joehe/workspace/business && npm run dev`
- Or start in background: `node node_modules/next/dist/bin/next dev -p 3001`

## Admin access bootstrap
```bash
curl -X POST http://localhost:3001/api/admin/promote \
  -H "Content-Type: application/json" \
  -d '{"email": "your@email.com"}'
# Then sign out and back in — session needs to be refreshed for isAdmin=true
```

## Next priorities (Phase 2)
1. Task management — create/assign tasks from CEO Agent chat
2. Daily briefing push notifications (mobile)
3. Brand kit generation (AI-generated logo via image API)
