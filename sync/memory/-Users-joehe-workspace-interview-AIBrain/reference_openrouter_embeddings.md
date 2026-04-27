---
name: OpenRouter as drop-in OpenAI embeddings provider
description: Use OPENAI_BASE_URL=https://openrouter.ai/api/v1 to route OpenAI Python embeddings client through OpenRouter when OpenAI quota is exhausted
type: reference
originSessionId: 3482f84c-e960-4517-82b1-d6552cdf2e41
---
When the OpenAI Python `openai` client hits 429 quota errors and you have an OpenRouter key (`sk-or-v1-...`), you can keep using the same SDK by overriding the base URL:

```bash
export OPENAI_API_KEY=sk-or-v1-...
export OPENAI_BASE_URL=https://openrouter.ai/api/v1
```

OpenRouter exposes `text-embedding-3-small` (and other OpenAI-compatible embedding models) at the same endpoint shape, so no SDK code changes are needed. Verified 2026-04-25 in pitagents while seeding the `few_shots` Qdrant collection — original OpenAI key was rate-limited, OpenRouter fallback worked transparently.

**When this is useful:**
- OpenAI key hit quota and you have an OpenRouter key handy
- You want a cheaper/different provider but don't want to refactor away from the OpenAI Python SDK
- Smoke-testing in CI where you don't want to consume production OpenAI budget

**Caveat:** OpenRouter pricing/availability for embedding models changes; check `openrouter.ai/models` before standardizing on a model name.
