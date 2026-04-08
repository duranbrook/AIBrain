---
name: Next.js 16 breaking changes and conventions
description: Critical Next.js 16 gotchas discovered during BuildCo development — middleware renamed, Prisma 7 patterns, Zod v4
type: feedback
---

Always read `node_modules/next/dist/docs/` before writing Next.js code. Next.js 16 has breaking changes from training data.

**Why:** These caused real build failures. The AGENTS.md in the business repo explicitly warns about this.

**How to apply:** Before writing any Next.js code in `/workspace/business`, check the docs directory first.

## middleware → proxy (CRITICAL)

- File: `src/middleware.ts` → `src/proxy.ts`
- Export: `export function middleware` → `export function proxy`
- The old name still works but logs a deprecation warning and shows as broken in build output
- `config.matcher` stays the same

## Prisma 7 breaking changes

- No `url` in `schema.prisma` datasource block — it lives in `prisma.config.ts`:
  ```ts
  datasource: { url: process.env["DATABASE_URL"] }
  ```
- Constructor requires adapter: `new PrismaClient({ adapter: new PrismaPg({ connectionString }) })`
- No `index.ts` generated — must create `src/generated/prisma/index.ts` manually:
  ```ts
  export * from "./client";
  export * from "./enums";
  export * from "./models";
  ```

## Zod v4 breaking change

- `.errors` → `.issues` on ZodError objects

## TypeScript + tsc

- `npx tsc` is broken (bin misconfigured). Use: `node node_modules/typescript/bin/tsc --noEmit`
- Next.js dev server still works fine — it uses its own TypeScript pipeline

## Next.js dev binary

- `npx next` may break. Use: `node node_modules/next/dist/bin/next dev`
