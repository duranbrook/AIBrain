---
name: React infinite loop debugging pattern
description: How to diagnose and fix React #185 (Maximum update depth exceeded) — lessons from a 2-hour debugging session
type: feedback
originSessionId: c3067120-a9d4-4be0-b2c7-7c8a57e74654
---
When a page shows "This page couldn't load" with all-200s in the Network tab, it's a JavaScript runtime error caught by React's error boundary — not an HTTP failure. HTTP status codes reflect file delivery, not code execution.

**Why:** The team spent ~2 hours chasing deployment race conditions before getting the actual console error, which pointed directly to React #185.

**How to apply:**
1. Ask for the browser Console output immediately — don't debug from the Network tab alone
2. React error #185 = "Maximum update depth exceeded" = infinite setState loop
3. Look at the stack trace: find what calls `setState`/`configure`/`publish` and trace backwards
4. Check every `useMemo` dependency for unstable references:
   - Inline object literals `{ ... }` passed as hook args → new reference every render
   - Destructuring defaults `= []` when `data` is undefined → new `[]` every render
   - Inline lambdas outside `useMemo`
5. The fix is always: stabilize the reference with `useMemo`, `useRef`, or a module-level constant
6. Use incognito to eliminate cache as a variable — if it crashes in incognito too, it's code not cache
7. Incognito also reveals 401/loading states (no auth token) which can expose secondary bugs hidden when logged in
