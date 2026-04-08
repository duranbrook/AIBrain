---
name: BuildCo architecture decisions
description: Key architectural choices in the BuildCo platform and why they were made
type: project
---

## Auth architecture

**Web:** JWT stored in httpOnly cookie, created by Server Actions (`src/app/actions/auth.ts`). Session decoded via `jose` in `src/lib/session.ts`. Route protection via `src/proxy.ts`.

**Mobile:** Same JWT issued via REST endpoints (`/api/auth/signup`, `/api/auth/login`). Stored in iOS Keychain / Expo SecureStore. Sent as `Authorization: Bearer <token>`. `getSession()` accepts optional bearer token param — works for both web (cookie) and mobile (header).

**Why:** Avoids NextAuth complexity; keeps auth self-contained; one JWT secret works for both platforms.

**Admin bootstrap:** `POST /api/admin/promote` allows first call without auth (when adminCount === 0). Subsequent calls require existing admin session.

## CEO Agent onboarding

CEO Agent chat (`/api/onboard/chat`) embeds `<json>` structured extraction at the end of each response. The client accumulates fields across turns. When all required fields are collected, the "Launch" button appears and `POST /api/onboard` creates the Business + spawns the team.

Required fields: `businessName`, `businessType`, `industry`, `description`, `targetAudience`, `stateOfFormation`.

## Company Memory

Every 10 messages in a conversation, `summarizeConversation()` runs and stores a `MemorySummary` row. CEO Agent gets all flagged summaries injected into its system prompt on every call via `buildCeoContext()`.

## SSE streaming

`/api/chat` returns a `ReadableStream` with `data: {"text": "..."}` chunks and `data: [DONE]` terminator. The iOS app uses `URLSession.bytes` → `AsyncThrowingStream`. The web app uses `EventSource`-style fetch reading.

## Employee configs

All 35 roles defined in `src/lib/employee-configs.ts`. Each has a `buildSystemPrompt(ctx: BusinessContext)` function that injects the company context. The Business Context Object is collected once at onboarding and injected into every employee's system prompt.

## Mobile app (SwiftUI)

Project generated via `xcodegen` from `project.yml`. To regenerate after changes:
```bash
cd /Users/joehe/workspace/buildco-ios && xcodegen generate
```

Tests require `--uitesting` launch argument to clear Keychain. The `DashboardUITests` and `ChatUITests` seed accounts via direct API calls (no UI flow needed) for speed.
