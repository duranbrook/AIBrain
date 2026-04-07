# PartFinder — RAG Implementation Spec

**Created:** 2026-04-07
**Depends On:** `docs/learning/rag-deep-dive.md` (architecture reference), `docs/car-parts/implementation-phases.md` (feature roadmap)
**Status:** Ready to implement. Fits in Phase 4 (Ops) or as standalone enhancement to Phase 2+.

---

## Overview

PartFinder has four distinct RAG use cases, each with different corpus characteristics, retrieval requirements, and risk profiles. This document specifies the full stack for each: what to index, how to chunk, which models to use, Prisma schema additions, and the API route design.

**Stack baseline:**
- Database: PostgreSQL via Prisma (already deployed)
- Vector extension: `pgvector` (avoids separate infra)
- Embedding model: `text-embedding-3-small` (OpenAI — easiest integration; swap to `voyage-3` for production quality)
- LLM: Claude `claude-haiku-4-5-20251001` for high-volume queries, `claude-sonnet-4-6` for dispute/research
- Orchestration: direct implementation (no LangChain)

---

## Use Case 1 — Parts Compatibility Search

**Problem:** Keyword search fails for natural language queries. A buyer searching "front bumper 2015 Camry XSE" won't match a listing titled "OEM Fascia Assembly 52119-06500 — fits 2015–2017 Camry SE/XSE/XLE."

**Solution:** Semantic search over part listing embeddings, pre-filtered by YMM (year/make/model) metadata.

### What to Index

Each `Part` record produces one embedding document:

```
{title} — {description} — {condition}: {conditionNotes}
Part number: {oem}, {aftermarket}
Fits: {year} {make} {model} {submodel}, {year} {make} {model} {submodel}, ...
Category: {category} / {subcategory}
```

Metadata stored alongside the vector (for pre-filtering, NOT embedding):
- `partId` (FK)
- `sellerId`
- `yearMin`, `yearMax`, `make`, `model` (from Vehicle compatibility records)
- `condition` enum
- `priceUsd` (integer cents)
- `status` (ACTIVE, SOLD, RESERVED)

### Chunking

One embedding per part listing. No chunking needed — listings are short (<500 tokens). Re-embed on any update to title, description, conditionNotes, or compatibility.

### Prisma Schema Addition

```prisma
model PartEmbedding {
  id        String   @id @default(cuid())
  partId    String   @unique
  part      Part     @relation(fields: [partId], references: [id], onDelete: Cascade)
  embedding Unsupported("vector(1536)")
  updatedAt DateTime @updatedAt

  @@index([partId])
}
```

Raw SQL for pgvector index (run as migration):
```sql
CREATE INDEX part_embedding_hnsw_idx
  ON "PartEmbedding"
  USING hnsw (embedding vector_cosine_ops)
  WITH (m = 16, ef_construction = 64);
```

### Ingestion Pipeline

```typescript
// packages/rag/src/ingest-parts.ts

import { openai } from './embedding-client'
import { prisma } from '@partfinder/db'

export async function ingestPart(partId: string) {
  const part = await prisma.part.findUniqueOrThrow({
    where: { id: partId },
    include: {
      vehicles: { include: { vehicle: true } },
      seller: { select: { id: true } },
    },
  })

  const vehicleLines = part.vehicles
    .map(v => `${v.vehicle.year} ${v.vehicle.make} ${v.vehicle.model} ${v.vehicle.submodel ?? ''}`.trim())
    .join(', ')

  const document = [
    `${part.title} — ${part.description ?? ''}`,
    `Condition: ${part.condition}${part.conditionNotes ? ` — ${part.conditionNotes}` : ''}`,
    part.oemNumber ? `OEM: ${part.oemNumber}` : '',
    part.aftermarketNumber ? `Aftermarket: ${part.aftermarketNumber}` : '',
    vehicleLines ? `Fits: ${vehicleLines}` : '',
    `Category: ${part.category}${part.subcategory ? ` / ${part.subcategory}` : ''}`,
  ]
    .filter(Boolean)
    .join('\n')

  const response = await openai.embeddings.create({
    model: 'text-embedding-3-small',
    input: document,
  })
  const vector = response.data[0].embedding

  await prisma.$executeRaw`
    INSERT INTO "PartEmbedding" (id, "partId", embedding, "updatedAt")
    VALUES (gen_random_uuid(), ${partId}, ${JSON.stringify(vector)}::vector, now())
    ON CONFLICT ("partId") DO UPDATE
      SET embedding = EXCLUDED.embedding,
          "updatedAt" = now()
  `
}

// Batch ingestion for backfill
export async function ingestAllParts(batchSize = 100) {
  let cursor: string | undefined
  let processed = 0

  while (true) {
    const parts = await prisma.part.findMany({
      where: { status: 'ACTIVE' },
      select: { id: true },
      take: batchSize,
      skip: cursor ? 1 : 0,
      cursor: cursor ? { id: cursor } : undefined,
      orderBy: { id: 'asc' },
    })

    if (parts.length === 0) break

    await Promise.all(parts.map(p => ingestPart(p.id)))
    processed += parts.length
    cursor = parts[parts.length - 1].id
    console.log(`Ingested ${processed} parts`)
  }
}
```

### Retrieval + Query API

```typescript
// apps/web/app/api/search/semantic/route.ts

import { openai } from '@partfinder/rag/embedding-client'
import { prisma } from '@partfinder/db'
import { z } from 'zod'

const SearchSchema = z.object({
  query: z.string().min(3).max(200),
  year: z.number().int().min(1900).max(2030).optional(),
  make: z.string().optional(),
  model: z.string().optional(),
  condition: z.enum(['NEW', 'OEM_USED', 'AFTERMARKET', 'CORE']).optional(),
  maxPrice: z.number().positive().optional(),
  limit: z.number().int().min(1).max(50).default(20),
})

export async function POST(req: Request) {
  const body = await req.json()
  const params = SearchSchema.parse(body)

  // 1. Embed the query
  const { data } = await openai.embeddings.create({
    model: 'text-embedding-3-small',
    input: params.query,
  })
  const queryVector = JSON.stringify(data[0].embedding)

  // 2. Build filter conditions (applied in SQL, not post-retrieval)
  // Pre-filter by YMM + condition before ANN search for precision
  const yearFilter = params.year
    ? `AND v.year = ${params.year}`
    : ''
  const makeFilter = params.make
    ? `AND v.make ILIKE '${params.make.replace(/'/g, "''")}'`
    : ''
  const modelFilter = params.model
    ? `AND v.model ILIKE '${params.model.replace(/'/g, "''")}'`
    : ''
  const conditionFilter = params.condition
    ? `AND p.condition = '${params.condition}'`
    : ''
  const priceFilter = params.maxPrice
    ? `AND p.price <= ${Math.round(params.maxPrice * 100)}`
    : ''

  // 3. Hybrid: cosine similarity (dense) + full-text rank (sparse), merged via RRF
  const results = await prisma.$queryRawUnsafe<Array<{
    id: string; title: string; price: number; condition: string;
    similarity: number; rrf_score: number;
  }>>(
    `
    WITH dense AS (
      SELECT pe."partId",
             1 - (pe.embedding <=> '${queryVector}'::vector) AS similarity,
             ROW_NUMBER() OVER (ORDER BY pe.embedding <=> '${queryVector}'::vector) AS rank
      FROM "PartEmbedding" pe
      JOIN "Part" p ON p.id = pe."partId"
      LEFT JOIN "_PartToVehicle" pv ON pv."A" = p.id
      LEFT JOIN "Vehicle" v ON v.id = pv."B"
      WHERE p.status = 'ACTIVE'
        ${yearFilter} ${makeFilter} ${modelFilter}
        ${conditionFilter} ${priceFilter}
      LIMIT 40
    ),
    sparse AS (
      SELECT p.id AS "partId",
             ts_rank(to_tsvector('english', p.title || ' ' || COALESCE(p.description, '')),
                     plainto_tsquery('english', $1)) AS rank_score,
             ROW_NUMBER() OVER (ORDER BY ts_rank(
               to_tsvector('english', p.title || ' ' || COALESCE(p.description, '')),
               plainto_tsquery('english', $1)) DESC) AS rank
      FROM "Part" p
      LEFT JOIN "_PartToVehicle" pv ON pv."A" = p.id
      LEFT JOIN "Vehicle" v ON v.id = pv."B"
      WHERE p.status = 'ACTIVE'
        AND to_tsvector('english', p.title || ' ' || COALESCE(p.description, ''))
            @@ plainto_tsquery('english', $1)
        ${yearFilter} ${makeFilter} ${modelFilter}
        ${conditionFilter} ${priceFilter}
      LIMIT 40
    ),
    rrf AS (
      SELECT
        COALESCE(d."partId", s."partId") AS "partId",
        COALESCE(1.0 / (60 + d.rank), 0) + COALESCE(1.0 / (60 + s.rank), 0) AS rrf_score,
        COALESCE(d.similarity, 0) AS similarity
      FROM dense d
      FULL OUTER JOIN sparse s ON s."partId" = d."partId"
    )
    SELECT p.id, p.title, p.price, p.condition, r.similarity, r.rrf_score
    FROM rrf r
    JOIN "Part" p ON p.id = r."partId"
    ORDER BY r.rrf_score DESC
    LIMIT $2
    `,
    params.query,
    params.limit
  )

  return Response.json({ results })
}
```

### Hook: Re-embed on Part Update

```typescript
// In the Part update API route, after successful Prisma update:
import { ingestPart } from '@partfinder/rag'

// Fire-and-forget; don't block the response
ingestPart(partId).catch(err => console.error('RAG re-embed failed:', err))
```

---

## Use Case 2 — Seller Knowledge Base

**Problem:** Sellers ask repetitive support questions: "How do I set up payouts?", "What's the return window?", "How do I handle a dispute?"

**Solution:** Standard RAG over help docs and policy documents. Small corpus, high precision needed.

### What to Index

- `docs/seller-help/` — onboarding, payout setup, listing best practices
- `docs/policies/` — return policy, dispute process, fee schedule, prohibited items
- FAQ entries (stored in DB as `SupportArticle` records)

Chunking: **Document-structure-aware** — split on Markdown `##` headers. Each chunk = one section. Include the document title + section header as prefix in the stored chunk for context.

```
[PartFinder Seller Guide — Payouts]
To set up your payout account, navigate to Settings > Payouts...
```

### Prisma Schema

```prisma
model KnowledgeChunk {
  id         String   @id @default(cuid())
  sourceFile String   // e.g. "docs/policies/returns.md"
  section    String   // e.g. "Return Window"
  body       String   // raw chunk text
  embedding  Unsupported("vector(1536)")
  updatedAt  DateTime @updatedAt

  @@index([sourceFile])
}
```

### API Route

```typescript
// POST /api/seller/support/ask
// Body: { question: string }
// Auth: seller session required

import Anthropic from '@anthropic-ai/sdk'
import { openai } from '@partfinder/rag/embedding-client'
import { prisma } from '@partfinder/db'

const claude = new Anthropic()

export async function POST(req: Request) {
  const { question } = await req.json()

  // 1. Embed question
  const { data } = await openai.embeddings.create({
    model: 'text-embedding-3-small',
    input: question,
  })
  const qv = JSON.stringify(data[0].embedding)

  // 2. Retrieve top-5 chunks
  const chunks = await prisma.$queryRawUnsafe<Array<{
    section: string; sourceFile: string; body: string; similarity: number
  }>>(
    `SELECT section, "sourceFile", body,
            1 - (embedding <=> '${qv}'::vector) AS similarity
     FROM "KnowledgeChunk"
     ORDER BY embedding <=> '${qv}'::vector
     LIMIT 5`
  )

  if (chunks.length === 0) {
    return Response.json({ answer: "I couldn't find relevant information. Please contact support@partfinder.com." })
  }

  // 3. Generate answer
  const context = chunks
    .map(c => `[${c.section}]\n${c.body}`)
    .join('\n\n---\n\n')

  const message = await claude.messages.create({
    model: 'claude-haiku-4-5-20251001',
    max_tokens: 512,
    system: `You are a PartFinder seller support assistant. Answer the seller's question using ONLY the provided help documentation. If the answer is not in the documentation, say "I don't have that information — please contact support@partfinder.com." Be concise and actionable.`,
    messages: [
      {
        role: 'user',
        content: `Documentation:\n\n${context}\n\n---\n\nSeller question: ${question}`,
      },
    ],
  })

  const answer = message.content[0].type === 'text' ? message.content[0].text : ''
  const sources = [...new Set(chunks.map(c => c.section))]

  return Response.json({ answer, sources })
}
```

---

## Use Case 3 — Buyer Research Assistant

**Problem:** Buyers don't know if a price is fair. "Is $85 reasonable for a used alternator for a 2012 Civic?"

**Solution:** RAG over historical sold transaction data. Retrieve comparable sales, synthesize into a natural language price assessment.

### What to Index

Each completed `Order` produces one document upon fulfillment:

```
[Sold] {partTitle} — {condition}
Price: ${price}
Vehicle: {year} {make} {model}
Part category: {category}
OEM: {oemNumber}
Sold: {fulfilledAt ISO date}
```

Metadata for filtering: `category`, `make`, `model`, `yearMin`, `yearMax`, `condition`, `priceUsd`, `soldAt` timestamp.

### Prisma Schema

```prisma
model SoldListingEmbedding {
  id        String   @id @default(cuid())
  orderId   String   @unique
  order     Order    @relation(fields: [orderId], references: [id])
  embedding Unsupported("vector(1536)")
  priceUsd  Int      // denormalized for range queries
  soldAt    DateTime // denormalized for recency filtering
  make      String?
  model     String?
  year      Int?
  category  String?
  condition String?
  updatedAt DateTime @updatedAt
}
```

### API Route

```typescript
// POST /api/parts/price-check
// Body: { query: string, partId?: string }
// Auth: buyer session (or public with rate limiting)

export async function POST(req: Request) {
  const { query, partId } = await req.json()

  // If partId provided, enrich the query with the actual listing details
  let enrichedQuery = query
  if (partId) {
    const part = await prisma.part.findUnique({
      where: { id: partId },
      include: { vehicles: { include: { vehicle: true } } },
    })
    if (part) {
      const vehicle = part.vehicles[0]?.vehicle
      enrichedQuery = `${part.title} ${part.condition} ${vehicle ? `${vehicle.year} ${vehicle.make} ${vehicle.model}` : ''}`
    }
  }

  // Embed + retrieve comparable sales (last 6 months weighted)
  const { data } = await openai.embeddings.create({
    model: 'text-embedding-3-small',
    input: enrichedQuery,
  })
  const qv = JSON.stringify(data[0].embedding)
  const sixMonthsAgo = new Date(Date.now() - 180 * 24 * 60 * 60 * 1000).toISOString()

  const comparables = await prisma.$queryRawUnsafe<Array<{
    orderId: string; priceUsd: number; condition: string;
    make: string; model: string; year: number; soldAt: string; similarity: number
  }>>(
    `SELECT "orderId", "priceUsd", condition, make, model, year,
            "soldAt", 1 - (embedding <=> '${qv}'::vector) AS similarity
     FROM "SoldListingEmbedding"
     WHERE "soldAt" > '${sixMonthsAgo}'
     ORDER BY embedding <=> '${qv}'::vector
     LIMIT 10`
  )

  if (comparables.length === 0) {
    return Response.json({ assessment: "Not enough comparable sales data yet for this part." })
  }

  const prices = comparables.map(c => c.priceUsd / 100)
  const avg = prices.reduce((a, b) => a + b, 0) / prices.length
  const min = Math.min(...prices)
  const max = Math.max(...prices)

  const salesSummary = comparables
    .map(c => `$${(c.priceUsd / 100).toFixed(2)} — ${c.condition}, ${c.year ?? '?'} ${c.make ?? '?'} ${c.model ?? '?'} (sold ${new Date(c.soldAt).toLocaleDateString()})`)
    .join('\n')

  const message = await claude.messages.create({
    model: 'claude-haiku-4-5-20251001',
    max_tokens: 300,
    system: `You are a fair pricing advisor for used auto parts. Given recent comparable sales, give a concise, honest price assessment. Include whether the listing is a good deal, fair, or overpriced. Be specific with numbers.`,
    messages: [{
      role: 'user',
      content: `Buyer is asking about: "${query}"\n\nRecent comparable sales (${comparables.length} results):\n${salesSummary}\n\nAverage: $${avg.toFixed(2)} | Range: $${min.toFixed(2)} – $${max.toFixed(2)}\n\nProvide a brief price assessment (2-3 sentences).`,
    }],
  })

  const assessment = message.content[0].type === 'text' ? message.content[0].text : ''
  return Response.json({ assessment, stats: { avg, min, max, sampleSize: comparables.length } })
}
```

---

## Use Case 4 — AI Dispute Resolution

**Problem:** Ops team spends significant time on buyer/seller disputes. Each dispute requires reading context, checking policy, and finding similar past cases.

**Solution:** RAG over past dispute outcomes + policy documents. Claude reads the current dispute and recommends a resolution path based on precedent and policy.

### What to Index

**Corpus A: Past dispute outcomes** (one document per closed dispute):
```
[Dispute Outcome — {category}]
Filed: {createdAt} | Closed: {resolvedAt} | Outcome: {outcome}
Buyer claim: {buyerClaim}
Seller response: {sellerResponse}
Resolution: {resolutionNotes}
Policy applied: {policyReference}
```

**Corpus B: Policy docs** (same as Use Case 2 knowledge base, filtered to policy sections).

### Prisma Schema

```prisma
model Dispute {
  id               String        @id @default(cuid())
  orderId          String        @unique
  order            Order         @relation(fields: [orderId], references: [id])
  buyerClaim       String        @db.Text
  sellerResponse   String?       @db.Text
  status           DisputeStatus @default(OPEN)
  outcome          DisputeOutcome?
  resolutionNotes  String?       @db.Text
  policyReference  String?
  opsAssigneeId    String?
  slaDeadline      DateTime
  createdAt        DateTime      @default(now())
  resolvedAt       DateTime?
  embedding        Unsupported("vector(1536)")?
}

enum DisputeStatus { OPEN UNDER_REVIEW AWAITING_SELLER AWAITING_BUYER ESCALATED CLOSED }
enum DisputeOutcome { BUYER_REFUNDED SELLER_FAVORABLE SPLIT ESCALATED_TO_PAYMENT }
```

### API Route

```typescript
// POST /api/ops/disputes/:id/recommend
// Auth: ops admin role required

export async function POST(req: Request, { params }: { params: { id: string } }) {
  const dispute = await prisma.dispute.findUniqueOrThrow({
    where: { id: params.id },
    include: { order: { include: { part: true, buyer: true, seller: true } } },
  })

  const queryText = `${dispute.buyerClaim} ${dispute.sellerResponse ?? ''}`
  const { data } = await openai.embeddings.create({
    model: 'text-embedding-3-small',
    input: queryText,
  })
  const qv = JSON.stringify(data[0].embedding)

  // Retrieve similar past disputes
  const similarDisputes = await prisma.$queryRawUnsafe<Array<{
    id: string; buyerClaim: string; sellerResponse: string;
    outcome: string; resolutionNotes: string; similarity: number
  }>>(
    `SELECT id, "buyerClaim", "sellerResponse", outcome::text,
            "resolutionNotes", 1 - (embedding <=> '${qv}'::vector) AS similarity
     FROM "Dispute"
     WHERE status = 'CLOSED' AND id != '${params.id}'
     ORDER BY embedding <=> '${qv}'::vector
     LIMIT 5`
  )

  // Also retrieve relevant policy chunks
  const policyChunks = await prisma.$queryRawUnsafe<Array<{
    section: string; body: string; similarity: number
  }>>(
    `SELECT section, body, 1 - (embedding <=> '${qv}'::vector) AS similarity
     FROM "KnowledgeChunk"
     WHERE "sourceFile" LIKE '%policies%'
     ORDER BY embedding <=> '${qv}'::vector
     LIMIT 3`
  )

  const precedentContext = similarDisputes.length > 0
    ? similarDisputes.map(d =>
        `Past case (${d.outcome}): Buyer claimed: "${d.buyerClaim.slice(0, 200)}" → Resolution: ${d.resolutionNotes?.slice(0, 200) ?? 'N/A'}`
      ).join('\n\n')
    : 'No similar past disputes found.'

  const policyContext = policyChunks.map(c => `[${c.section}]\n${c.body}`).join('\n\n---\n\n')

  const message = await claude.messages.create({
    model: 'claude-sonnet-4-6',
    max_tokens: 600,
    system: `You are a dispute resolution advisor for PartFinder, an auto parts marketplace.
Given a dispute and relevant precedents + policies, recommend a clear resolution path.
Format your response as:
1. Recommended outcome (one of: BUYER_REFUNDED, SELLER_FAVORABLE, SPLIT, ESCALATED_TO_PAYMENT)
2. Reasoning (2-3 sentences citing specific precedent or policy)
3. Next action for the ops team (one concrete step)`,
    messages: [{
      role: 'user',
      content: `## Current Dispute

Order: ${dispute.order.id}
Part: ${dispute.order.part.title} — $${(dispute.order.part.price / 100).toFixed(2)}
Buyer claim: ${dispute.buyerClaim}
Seller response: ${dispute.sellerResponse ?? '(no response yet)'}

## Relevant Policies
${policyContext}

## Similar Past Disputes
${precedentContext}

Provide your resolution recommendation.`,
    }],
  })

  const recommendation = message.content[0].type === 'text' ? message.content[0].text : ''
  return Response.json({ recommendation, similarCases: similarDisputes.length })
}
```

---

## Implementation Order

This maps to the Phase 4 (Ops Dashboard) work in `implementation-phases.md`, but Use Case 1 (parts search) can ship earlier as a Phase 2 enhancement since it improves core buyer experience.

| Priority | Use Case | Effort | Impact |
|---|---|---|---|
| 1 | Parts compatibility search | 2 days | High — core buyer experience |
| 2 | Seller knowledge base | 1 day | Medium — reduces support volume |
| 3 | Dispute resolution | 2 days | High — reduces ops burden |
| 4 | Buyer price research | 1 day | Medium — requires sales history to build up |

**Prerequisite:** `pgvector` must be enabled in the Postgres instance:
```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

---

## Migration Plan

1. Add `pgvector` extension to Postgres
2. Add schema models above via `prisma migrate dev`
3. Create HNSW indexes via raw SQL migration
4. Run backfill ingestion for existing parts (`ingestAllParts()`)
5. Add webhook hooks to re-embed on Part create/update
6. Deploy `POST /api/search/semantic` and integrate into the existing search UI as a "Smart Search" toggle
7. Deploy seller support bot (Use Case 2) as a chat widget in seller dashboard
8. Enable dispute recommendations for ops team (Use Case 4) — internal tool, no buyer-facing UI needed

---

## Known Trade-offs

| Decision | Rationale |
|---|---|
| pgvector over Pinecone | Already on Postgres; avoids ops overhead for a marketplace at this scale. Revisit at 10M+ embeddings. |
| `text-embedding-3-small` over `voyage-3` | Lower cost; easier OpenAI integration. Swap to `voyage-3` for production if retrieval quality is insufficient. |
| Inline SQL over ORM | Prisma doesn't support vector operations natively. Raw SQL is required for the ANN search expressions. |
| Haiku for high-volume, Sonnet for disputes | Cost/quality tradeoff. Support bot at $0.25/1M input tokens vs dispute analysis at $3/1M. |
| No LangChain/LlamaIndex | Direct implementation is simpler, easier to debug, and avoids framework churn. |
