---
name: Homepage/Login/Demo feature progress
description: Current build state for the marketing homepage, Google OAuth login, and /demo request page — awaiting manual Google Cloud Console setup
type: project
originSessionId: 183eb143-251c-4199-b511-0fa5ad00629c
---
All code for the homepage/login/demo feature is complete on branch `feat/ios-technician-chat`. 16 backend tests pass, TypeScript compiles cleanly.

**What was built (10 commits):**
- `POST /auth/google` — Google OAuth login with email_verified check, two-step user lookup, google_id linking
- `POST /demo/request` — public endpoint, stores demo requests with EmailStr validation
- Alembic migration 0026 — google_id on users, hashed_password nullable, demo_requests table
- `/` → full marketing homepage (8 sections: nav, hero, metrics, product cards, Why, testimonial, pricing, footer)
- `/dashboard` → existing dashboard (moved from `/`)
- `/login` → two-panel layout with Google OAuth (GSI JS SDK) + email/password fallback
- `/demo` → two-panel demo request form with success confirmation state

**Pending manual step (Task 9):** User needs to create Google OAuth Client ID and set env vars, then report back to continue.

**Why:** Google OAuth won't work without a real client ID. Email/password login continues to work unchanged.

**How to apply:** When user says they've completed the manual steps, resume by testing the full Google OAuth flow end-to-end, then merge the branch into main.
