---
name: PitAgents Architecture
description: Core architecture decisions — LangGraph ReAct agents, Qdrant vector store, SSE streaming, parts catalog
type: project
originSessionId: 13aacedf-d3b6-4738-a815-08d28479106c
---
Chat agents use LangGraph StateGraph (stream_mode="custom") with StreamWriter for token streaming. Factory in `src/agents/graph_factory.py`. Two agents: Assistant (VIN + quotes) and Tom (analytics).

DB session injected via `config["configurable"]["db"]` — not passed as tool arg. Quote tool `create_quote(db, session_id)` has db first, unlike others.

SSE events: token, tool_start, tool_end, done. Client receives `done` BEFORE DB save (save in nested try/except so DB failure doesn't drop the event).

**Why:** import from `langgraph.types` not `langchain_core` for RunnableConfig + StreamWriter — avoids undeclared transitive dependency.

Planned enterprise upgrade (brainstorming in progress):
- Qdrant vector store for semantic parts search + feedback bank + few-shot RAG
- Intent classifier node (Claude Haiku cheap model)
- Per-message thumbs up/down feedback
- BMW ETK parts dataset (~$50-200) as seed data
