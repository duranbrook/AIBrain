# PartFinder — Implementation Phases

**Created:** 2026-04-05
**Source Spec:** `interview/learning/docs/superpowers/specs/2026-04-04-platform-design.md`
**Status:** Spec approved 2026-04-04. Current Next.js codebase has significant foundation. This doc maps what's built → what needs building → suggested phase order.

---

## What's Already Built (Foundation)

Per the spec, the current Next.js codebase covers:
- Auth (NextAuth v5, credentials + Google OAuth, role-based JWT)
- Prisma schema: User, Part, Vehicle, Order, Review, Message, Cart, Watchlist, SavedSearch
- Part listing creation, AI identification (Claude vision), AI pricing, AI condition assessment
- VIN decode (NHTSA), YMM compatibility tagging
- Search with filters and pagination
- Buyer + seller dashboards, order management, messaging
- Stripe + shipping scaffolds
- Seller analytics, returns API, notifications API
- Bulk listing, price history, interchange lookup, smart search
- Seller profiles, PWA manifest, admin panel

---

## Gap Analysis vs. Full Spec

### Missing Schema Models

| Model | Needed For |
|---|---|
| `StorageLocation` on `Part` | Yard bin/shelf tracking |
| `DonorVehicle.dismantleStatus` | Harvest progress tracking |
| `Dispute` model | Explicit dispute lifecycle |
| `SellerTier` enum | New/Verified/Top Rated/Power Seller |
| `Notification.channel` | Email/push/SMS per event |
| `FeatureFlag` | Ops platform config |
| `DiscountCode` | Promotions |
| `SupportTicket` | Ops support queue |
| `FraudFlag` | Moderation signals |
| `YardLocation` | Visual yard map rows/bays |

### Not Yet Built

| Feature Area | Gap |
|---|---|
| **Mobile apps** | Expo seller app + buyer app don't exist yet (web-only) |
| **Monorepo migration** | Currently single Next.js repo; Turborepo + pnpm workspaces structure needed |
| **Biometric auth on mobile** | Expo LocalAuthentication (FaceID/fingerprint) |
| **Push notifications** | Expo Push Notification Service (APNs + FCM) |
| **Presigned S3 upload from mobile** | Direct device-to-S3, no server proxy |
| **VIN barcode scanner** | Camera-based scan on mobile |
| **QR label printing** | Part/bin QR labels, label printer or PDF export |
| **Inventory audit mode** | Scan parts on mobile to confirm stock |
| **Visual yard map** | Rows/bays view on web, vehicle positions |
| **Offline draft mode** | Capture media without internet, sync on reconnect |
| **Dispute resolution UI** | Ops dispute queue with SLA countdown, unified view |
| **Fraud detection** | Velocity checks, duplicate listing detection, AI anomaly |
| **Growth tools** | Boost listings, discount codes, flash sales, email campaigns |
| **Ops BI dashboard** | Full analytics, seller cohort analysis, conversion funnel |
| **JWT + refresh for mobile** | Cookie sessions don't work on mobile; need JWT + Expo SecureStore |
| **Stripe Connect** | Payout flow to sellers (scaffold exists, may not be functional) |
| **Return policy enforcement** | 90-day window, auto-escalation after 48 hrs |

---

## Suggested Implementation Phases

### Phase 1 — Monorepo Foundation (1 week)
**Goal:** Restructure the existing codebase into the Turborepo monorepo without breaking anything.

1. Initialize Turborepo + pnpm workspaces
2. Move current Next.js app to `apps/web/`
3. Extract `packages/types/` (shared Zod schemas and TypeScript types from existing code)
4. Extract `packages/api-client/` (typed fetch wrappers for all 3 route namespaces)
5. Move Prisma to `packages/db/`
6. Add missing schema models (see gap table above)
7. Run migrations, validate existing tests still pass

**Why first:** Everything else builds on this structure. Doing mobile before monorepo means a painful migration later.

---

### Phase 2 — Mobile Auth + Core Seller App (2-3 weeks)
**Goal:** A working Expo seller app that can list parts and manage orders.

1. `apps/seller-app/` with Expo SDK, Expo Router
2. JWT auth flow: login → access token + refresh token → Expo SecureStore
3. Biometric unlock via Expo LocalAuthentication
4. VIN barcode scanner (Expo Camera + `expo-barcode-scanner`)
5. Multi-photo capture with overlay guides
6. Direct S3 presigned URL upload from mobile
7. AI part identification from mobile photos (calls existing API)
8. Listing creation from mobile
9. Push notifications: Expo Push → APNs/FCM (new order, message, return)
10. Offline draft mode (AsyncStorage queue, sync on reconnect)

---

### Phase 3 — Mobile Buyer App (1-2 weeks)
**Goal:** A working Expo buyer app with search, purchase, and tracking.

1. `apps/buyer-app/` scaffolding
2. Shared JWT auth (same token structure as seller app)
3. VIN scan for vehicle-based search
4. My Garage (up to 5 saved vehicles)
5. Search results, part detail, photo gallery, video player
6. Cart + checkout: Stripe credit/debit, Apple Pay, Google Pay
7. Biometric payment confirmation
8. Push notifications: order status, price drop alert, message reply
9. Order tracking with carrier deep links

---

### Phase 4 — Ops Dashboard Completion (1 week)
**Goal:** Fill the gaps in the existing admin panel to reach full Ops spec.

1. Dispute queue with SLA countdown and unified resolution view
2. Fraud detection signals: velocity checks, duplicate listing detection, AI anomaly flags
3. Full BI dashboard: conversion funnel, seller cohorts, search-term gaps
4. Seller tier management UI (assign/revoke tier badges)
5. Feature flag management
6. Growth tools: discount codes, boost listings, flash sales
7. 1099-K generation pipeline (Stripe + IRS threshold check)

---

### Phase 5 — Hardening + Launch Prep (1 week)
**Goal:** Production-ready across all 5 frontends.

1. Rate limiting on all API routes (Upstash Redis or Cloudflare)
2. GDPR/CCPA: account deletion + data export endpoint
3. Sales tax nexus tracking by state (TaxJar or manual rates)
4. Performance: image CDN, API response caching, DB query optimization
5. Error monitoring (Sentry across web + both mobile apps)
6. E2E test coverage for critical flows (Playwright for web, Detox for mobile)
7. App Store + Play Store submission (requires Apple Developer account)
8. Load test seller listing creation and buyer search under concurrency

---

## Critical Path

```
Phase 1 (monorepo) → Phase 2 (seller mobile) → Phase 3 (buyer mobile) → Phase 5 (launch)
                                                → Phase 4 (ops) ---------↗
```

Phases 3 and 4 can run in parallel once Phase 2 is complete.

---

## Open Decisions

| Decision | Options | Notes |
|---|---|---|
| File storage | S3 vs. Cloudflare R2 | R2 has no egress fees; S3 has broader tooling ecosystem |
| Push infra | Expo Push Service (wraps APNs/FCM) vs. direct | Expo is simpler; go direct only if custom notification logic needed |
| Shipping API | ShipEngine (multi-carrier) vs. Shippo vs. EasyPost | ShipEngine most complete; Shippo simpler API |
| Search | Postgres full-text (current) vs. Algolia vs. Typesense | Typesense is self-hostable + cheap; Algolia better DX |
| Payments | Stripe only | No open decision; confirmed in spec |
