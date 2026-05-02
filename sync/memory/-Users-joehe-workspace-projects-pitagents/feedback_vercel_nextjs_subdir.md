---
name: Vercel subdir deployment — ignoreCommand pitfall
description: Adding vercel.json to a Next.js subdirectory breaks directory detection
type: feedback
originSessionId: c3067120-a9d4-4be0-b2c7-7c8a57e74654
---
Do NOT place `vercel.json` in the `web/` subdirectory when Vercel's root directory is configured to `web/` in the dashboard. Even with only `ignoreCommand` set, it breaks Next.js's `app/` directory detection (build fails with "Couldn't find any pages or app directory").

**Why:** Happened in this project. Adding `web/vercel.json` with just `ignoreCommand` caused every subsequent Vercel build to fail. The forced `vercel --prod --force` from the `web/` directory was the only reliable deploy path while the GitHub integration was broken.

**How to apply:**
- If Vercel's root directory is `web/`, do NOT add `vercel.json` anywhere — manage ignoreCommand via the Vercel dashboard UI instead
- When GitHub auto-deploys break (0ms build + Error state), use `cd web && vercel --prod --force` to bypass
- Deployment race conditions (two simultaneous builds) cause RSC payload / chunk mismatch → "This page couldn't load" with all 200s — fix with hard refresh or incognito
