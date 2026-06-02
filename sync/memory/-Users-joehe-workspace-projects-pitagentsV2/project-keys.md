---
name: project-keys
description: "API keys configured in backend/.env — Anthropic, Deepgram, Gradium all present"
metadata: 
  node_type: memory
  type: project
  originSessionId: cb7266c4-4f86-478b-887f-cc209f93ed8d
---

All three voice pipeline keys are set in `backend/.env`:
- `ANTHROPIC_API_KEY` — Claude Haiku (extraction/detection) + Sonnet (generation)
- `DEEPGRAM_API_KEY` — STT
- `GRADIUM_API_KEY` — TTS (switched from Cartesia on 2026-06-02)

**Why:** User added them on 2026-06-02 after backend foundation was merged.
**How to apply:** Backend is ready for end-to-end voice pipeline testing. Run `uvicorn app.main:app` from `backend/` to start.
