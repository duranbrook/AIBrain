---
name: Anthropic Harness Design Blog Post
description: Key patterns from Anthropic's multi-agent harness for long-running app development — GAN-inspired generator/evaluator, sprint contracts, evaluator tuning
type: reference
---

## Source
Anthropic Engineering Blog: "Harness design for long-running application development" (March 2026)
- https://www.anthropic.com/engineering/harness-design-long-running-apps
- Companion: https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents

## Key Architecture: GAN-Inspired Multi-Agent System

**Three agents:**
1. **Planner** — converts 1-4 sentence prompts into full product specs; ambitious about scope; avoids granular technical detail upfront
2. **Generator** — implements one feature at a time; self-evaluates before QA handoff; uses git
3. **Evaluator** — uses Playwright MCP to interact like a real user; grades against criteria with hard thresholds; failure triggers detailed feedback

**Critical insight:** Separating generator from evaluator is key. Claude is a poor self-QA agent — "identifies legitimate issues, then talks itself into deciding they weren't a big deal."

## Sprint Contract Pattern
1. Generator proposes scope + success verification method
2. Evaluator reviews to ensure the right thing is being built
3. Iterate until agreement on "done"
4. Generator builds against contract
5. Evaluator tests against contract terms

## Frontend Design: Four Grading Criteria
1. **Design Quality** — coherent whole vs collection of parts
2. **Originality** — custom decisions vs template patterns
3. **Craft** — typography, spacing, color harmony, contrast
4. **Functionality** — usability independent of aesthetics
Weight design quality and originality over craft/functionality (Claude already good at technical fundamentals).

## Key Failure Modes
- **Context Window Degradation** — mitigate with compaction or context resets
- **Self-Evaluation Bias** — agents confidently praise own mediocre work
- **Prompt Wording Steering** — criteria phrasing steers generator in unexpected ways (e.g., "museum quality" caused visual convergence)

## Harness Simplification Principle
"Every component encodes an assumption about what the model can't do. Stress-test those assumptions."
- Remove one component at a time
- Review impact on final result
- Re-examine with each new model release
- Strip away non-load-bearing pieces

## Results
- Retro Game Maker: 6hrs/$200 (harness) vs 20min/$9 (solo) — dramatically better quality
- DAW: ~4hrs/$125 — working browser DAW with arrangement view, mixer, transport
- Frontend design: 5-15 iterations, up to 4 hours per generation

## Tech Stack
React, Vite, FastAPI, SQLite/PostgreSQL, Playwright MCP, Claude Agent SDK
