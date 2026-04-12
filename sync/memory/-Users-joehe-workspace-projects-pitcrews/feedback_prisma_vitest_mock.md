---
name: Prisma CJS mock incompatibility in vitest
description: vi.mock('@prisma/client') doesn't intercept when Prisma loads as CJS within a service that has @prisma/client as a direct dependency
type: feedback
originSessionId: df0f7e2e-52d1-42fd-a173-c72fe5f9f1bf
---
`vi.mock('@prisma/client', factory)` does NOT intercept Prisma's PrismaClient when the module under test has `@prisma/client` in its direct dependencies (not devDependencies) and Prisma is loaded via CJS require() chain.

**Why:** vitest intercepts ES module `import` statements. But Prisma 5's `@prisma/client/index.js` is CJS — it does `require('.prisma/client/default')`. When the service TypeScript is compiled, the `import { PrismaClient } from '@prisma/client'` becomes a CJS `require()`. The vitest mock interceptor doesn't consistently intercept nested CJS `require()` chains. The mock factory never gets called (confirmed by missing console.log output).

**How to apply:** When a service has `@prisma/client` as a direct dep (not devDep), mock the SERVICE MODULE directly (`vi.mock('../serviceFile', factory)`) rather than trying to mock `@prisma/client`. This works reliably. Note: packages where Prisma is a devDependency (like recruiter-service) don't have this problem and `vi.mock('@prisma/client')` works fine there.

Pattern that works:
```typescript
vi.mock('../threadService', () => ({
  createThread: vi.fn().mockResolvedValue({ ... }),
  transitionThread: vi.fn().mockResolvedValue({ ... }),
}));
```
