# RAG System Implementation — Deep Dive

**Created:** 2026-04-05
**Purpose:** Architecture reference and implementation guide for Retrieval-Augmented Generation systems.

---

## What RAG Is and Why It Exists

LLMs have a fundamental limitation: their knowledge is frozen at training time. They cannot answer questions about documents they've never seen, private data, or events after their cutoff. They also hallucinate — generating plausible-sounding but incorrect information when they don't know the answer.

RAG solves both problems by inserting a retrieval step between the user's question and the LLM's answer. Instead of asking the model to recall facts from training, you fetch relevant documents at query time and include them in the prompt. The model's job shifts from "remember this" to "synthesize this."

```
Without RAG:  User question → LLM → Answer (from training memory)
With RAG:     User question → Retrieve relevant docs → LLM (question + docs) → Answer
```

---

## Core Architecture

### The Five Components

```
┌─────────────┐    ┌──────────────┐    ┌────────────────┐
│  Documents  │───▶│  Chunking    │───▶│   Embedding    │
│  (source)   │    │  (splitting) │    │   (vectorize)  │
└─────────────┘    └──────────────┘    └────────────────┘
                                                │
                                                ▼
                                        ┌──────────────┐
                                        │  Vector DB   │
                                        │  (store +    │
                                        │   index)     │
                                        └──────────────┘
                                                │
                        ┌───────────────────────┘
                        ▼
┌─────────────┐    ┌──────────────┐    ┌────────────────┐
│  User Query │───▶│  Retrieval   │───▶│  LLM + Context │──▶ Answer
└─────────────┘    │  (top-k ANN) │    │  (generation)  │
                   └──────────────┘    └────────────────┘
```

### 1. Document Ingestion

The ingestion pipeline runs once (and re-runs on updates). It takes raw source documents and prepares them for retrieval.

**Input types:** PDFs, HTML pages, Markdown files, database rows, API responses, code files, transcripts.

**Steps:**
1. **Parse** — extract clean text (strip HTML tags, handle PDF formatting, etc.)
2. **Chunk** — split into retrievable segments (see Chunking Strategies below)
3. **Embed** — run each chunk through an embedding model to get a vector
4. **Store** — upsert vectors + metadata into a vector database

---

### 2. Chunking Strategies

Chunking is the highest-leverage decision in RAG system design. Chunks that are too large bring in noisy context and eat your context window. Chunks that are too small lack the context to be useful.

#### Fixed-Size Chunking
Split by token count (e.g., 512 tokens per chunk). Simple but ignores semantic boundaries.
- **Best for:** unstructured text where you don't know the structure
- **Weakness:** can split sentences or concepts mid-thought

#### Recursive Character Splitting
Split on paragraph breaks, then sentence breaks, then character count — falling back to smaller units until the chunk is small enough. This is what LangChain's `RecursiveCharacterTextSplitter` does.
- **Best for:** general prose documents
- **Key param:** `chunk_size=512, chunk_overlap=64` (overlap preserves cross-boundary context)

#### Semantic Chunking
Use an embedding model to detect where topic shifts occur, then split at those boundaries. More expensive but produces semantically coherent chunks.
- **Best for:** long documents with clear section transitions
- **Weakness:** compute-intensive at ingestion time

#### Document-Structure-Aware Chunking
Respect the document's inherent structure: Markdown headers define chunk boundaries; HTML `<section>` tags define chunks; PDF page boundaries are respected.
- **Best for:** structured documents (spec sheets, legal docs, technical documentation)
- **Best practice:** include the section header in every chunk for context

#### Agentic / Proposition-Based Chunking
Extract atomic factual propositions from the text and store each proposition as its own chunk. Each chunk is one claim: "The boiling point of water is 100°C at standard pressure." Very high retrieval precision.
- **Best for:** knowledge bases, Q&A over dense factual content
- **Weakness:** expensive (requires an LLM pass at ingestion), loses narrative context

---

### 3. Embedding Models

Embeddings convert text to dense vectors in a high-dimensional semantic space. Texts with similar meaning have vectors that are close together (by cosine similarity or dot product).

| Model | Dimensions | Notes |
|---|---|---|
| `text-embedding-3-small` (OpenAI) | 1536 | Fast, cheap, good general performance |
| `text-embedding-3-large` (OpenAI) | 3072 | Higher quality, 5x cost |
| `voyage-3` (Voyager AI) | 1024 | SOTA on MTEB, best for code + technical text |
| `nomic-embed-text` (open source) | 768 | Self-hostable, strong performance |
| `bge-m3` (BAAI, open source) | 1024 | Multilingual, strong on long documents |

**Key principle:** The embedding model used at query time must match the model used at ingestion time. Mixing models produces nonsense similarity scores.

---

### 4. Vector Databases

| Database | Type | Best For |
|---|---|---|
| **Pinecone** | Managed cloud | Zero-ops, production-ready, scales automatically |
| **Weaviate** | Self-hosted / cloud | GraphQL API, hybrid search built-in, strong metadata filtering |
| **Qdrant** | Self-hosted / cloud | High performance, rich payload filtering, Rust-based |
| **pgvector** (Postgres extension) | Embedded in Postgres | Best for teams already on Postgres; avoid separate infra |
| **Chroma** | Local / embedded | Best for development and prototyping; not production-scale |
| **LanceDB** | Embedded / serverless | Columnar storage, zero-ops, good for edge/serverless |

**For most production systems:** Pinecone (zero-ops) or pgvector (if already on Postgres).

---

### 5. Retrieval Methods

#### Dense Retrieval (Standard)
Query text is embedded, then Approximate Nearest Neighbor (ANN) search finds the top-k most similar chunks by vector distance.
- Fast, semantic, works well for paraphrase/synonym matching
- Fails for exact keyword matching, rare terms, product codes, IDs

#### Sparse Retrieval (BM25 / TF-IDF)
Classic keyword-based retrieval. High precision for exact terms.
- Works for product SKUs, proper nouns, unique identifiers
- Fails for semantic similarity

#### Hybrid Retrieval
Runs both dense and sparse, then merges results using **Reciprocal Rank Fusion (RRF)** or a weighted score.
- Best of both worlds
- Recommended for production systems

#### Reranking
After retrieval, run a **cross-encoder** (a model that scores query-document pairs) to re-order the top-k results. Cross-encoders are more expensive than bi-encoders but produce significantly better ordering.
- Models: `cross-encoder/ms-marco-MiniLM-L-6-v2`, Cohere Rerank, `voyage-rerank-2`
- Pattern: retrieve top-20 with ANN → rerank to top-5 → pass to LLM

---

### 6. The Generation Step

The retrieved chunks are injected into the prompt as context. The LLM's job is to answer the question using only the provided context.

**Standard prompt structure:**
```
System: You are a helpful assistant. Answer questions using only the provided context.
        If the answer is not in the context, say "I don't know."

Context:
[Chunk 1 text]
---
[Chunk 2 text]
---
[Chunk 3 text]

User: [Original question]
```

**Key design choices:**
- Number of chunks (top-k): typically 3-8. More context = better coverage but higher latency + cost.
- Whether to include chunk source metadata in the prompt (document name, page number) for citation
- Whether to instruct the model to cite sources in its answer

---

## Advanced RAG Patterns

### Query Rewriting
Before retrieval, pass the raw user query through an LLM to rewrite it into a form better suited for retrieval. Handles conversational queries, typos, and under-specified questions.

```
User: "What did they say about the returns policy?"
Rewritten: "What is the product return and refund policy?"
```

### HyDE (Hypothetical Document Embeddings)
Generate a hypothetical answer to the question using the LLM, then embed that hypothetical answer and use it as the retrieval query. This works because a well-formed answer often shares more semantic space with actual answers than a sparse question does.

### Multi-Query Retrieval
Generate N variations of the query, run retrieval for each, then deduplicate and merge results. Increases recall at the cost of N× retrieval calls.

### Self-RAG
Instruct the LLM to decide whether it needs retrieval at all, and whether the retrieved chunks are actually relevant. Reduces hallucination and irrelevant context injection.

### Contextual Compression
After retrieval, ask a smaller LLM to extract only the relevant sentences from each chunk before passing to the main model. Keeps the context window tight.

### Parent Document Retrieval
Store small chunks for retrieval (high precision), but when a chunk is retrieved, return its larger "parent" document as context (more information). Solves the precision/context tradeoff.

---

## Evaluation Framework

RAG systems have two distinct failure modes: **retrieval failures** and **generation failures**. Evaluate them separately.

### Retrieval Metrics

| Metric | What It Measures |
|---|---|
| **Hit Rate** | % of questions where at least one relevant chunk is in top-k |
| **MRR** (Mean Reciprocal Rank) | How high up the first relevant chunk appears |
| **Recall@k** | % of all relevant docs retrieved in top-k |
| **Precision@k** | % of retrieved docs that are actually relevant |

**Tooling:** RAGAS, TruLens, LangSmith

### Generation Metrics

| Metric | What It Measures |
|---|---|
| **Faithfulness** | Is the answer grounded in the retrieved context? (no hallucination) |
| **Answer Relevance** | Does the answer address the question? |
| **Context Relevance** | Are the retrieved chunks actually relevant to the question? |
| **Answer Correctness** | Is the answer factually correct? (requires ground truth) |

**RAGAS** automates all four of these using LLM-as-judge evaluation.

---

## Implementation Checklist

### Minimum Viable RAG
- [ ] Document loader (PDF, Markdown, or HTML)
- [ ] Recursive character text splitter (512 tokens, 64 overlap)
- [ ] Embedding model (OpenAI `text-embedding-3-small` or `nomic-embed-text`)
- [ ] Vector store (pgvector for Postgres projects, Chroma for prototyping)
- [ ] Dense retrieval (top-5 ANN)
- [ ] Basic generation prompt with "answer only from context" instruction

### Production-Grade RAG
- [ ] Hybrid retrieval (dense + BM25 via Weaviate or Qdrant)
- [ ] Cross-encoder reranking (top-20 → rerank → top-5)
- [ ] Query rewriting (LLM rewrites raw query before retrieval)
- [ ] Source citations in generated answers
- [ ] Metadata filtering (filter by document type, date, category before ANN)
- [ ] Incremental ingestion (re-embed only changed chunks, not full re-index)
- [ ] Evaluation pipeline (RAGAS or TruLens on a golden Q&A test set)
- [ ] Latency monitoring (retrieval time, embedding time, generation time)

---

## Relevant to PartFinder

RAG is directly applicable to PartFinder for:

1. **Parts compatibility search** — natural language query → retrieve compatible part listings
   - Index: all part listings + their YMM compatibility data
   - Query: "front bumper for 2015 Camry XSE" → embed + retrieve → filter to exact vehicle
   - This replaces fragile keyword matching with semantic search

2. **Seller knowledge base** — seller support bot that answers "how do I set up payouts?"
   - Index: help docs, policy documents, FAQ
   - Standard RAG pattern; small context window, high precision needed

3. **Buyer research assistant** — "Is this a fair price for a B-grade alternator?"
   - Index: historical sold prices per part type + condition grade
   - Retrieves recent comparable sales, LLM synthesizes into natural language response

4. **AI dispute resolution** — ops agent that reads dispute context and recommends resolution
   - Index: past dispute outcomes + platform policies
   - Retrieves similar past disputes; LLM recommends based on precedent

---

## Tech Stack Recommendation (2026)

| Component | Recommendation | Rationale |
|---|---|---|
| Embedding | `voyage-3` or `text-embedding-3-small` | Voyage best quality; OpenAI easiest integration |
| Vector DB | pgvector (if on Postgres) or Qdrant | Avoid separate infra if already on Postgres |
| Retrieval | Hybrid (pgvector full-text + dense) | Better than dense-only for product/part data |
| Reranking | Cohere Rerank or `voyage-rerank-2` | Worth the latency for precision-critical queries |
| Orchestration | Direct implementation or Vercel AI SDK | LangChain adds complexity; direct is often cleaner |
| Evaluation | RAGAS | Best-in-class automated RAG evaluation |
| LLM | Claude claude-sonnet-4-6 | Best reasoning quality; `claude-haiku-4-5-20251001` for high-volume |
