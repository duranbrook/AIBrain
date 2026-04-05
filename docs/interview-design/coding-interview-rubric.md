# Coding Interview Design — Hiring Rubric

**Created:** 2026-04-05
**Purpose:** Design a repeatable, fair, signal-rich coding interview process for hiring software engineers.

---

## Format Decision: Live + Take-Home (Two-Stage)

| Stage | Format | Duration | What It Tests |
|---|---|---|---|
| 1 — Async Screen | Take-home (72hr window) | ~3-4 hrs work | Real-world code quality, self-direction, communication |
| 2 — Live Technical | Pair programming session | 60-90 min | Problem-solving process, communication under pressure, adaptability |

**Why two stages:** Take-home reveals what a candidate produces when they have time and no eyes on them. Live interview reveals how they think, communicate, and handle ambiguity in real-time. Neither alone gives the full picture.

---

## Stage 1 — Take-Home Assignment

### Design Principles
- Scoped to be completable in 3-4 hrs, not 8+
- Has multiple valid approaches — tests judgment, not just knowledge
- Reveals communication style via README and code comments
- Reviewable in under 20 minutes by the interviewer

### Assignment Template

> Build a REST API with the following requirements:
>
> - A `/parts` endpoint that accepts a `make`, `model`, and `year` query param and returns a list of compatible parts
> - Results must be paginated (cursor-based preferred, offset acceptable)
> - Basic auth or API key authentication
> - At least one background job or async operation
> - A README explaining your architectural decisions, what you'd do differently with more time, and how to run locally
>
> Use any language/framework. Data can be mocked — no real database required unless you want to include one.

### Take-Home Review Rubric (Score 1-5 per category)

| Category | What to Look For | 1 (Weak) | 5 (Strong) |
|---|---|---|---|
| **Correctness** | Does it work as described? | Missing features, broken | All requirements met, handles edge cases |
| **Code Clarity** | Is it readable without explanation? | Cryptic, inconsistent naming | Self-documenting, clear intent |
| **Architectural Judgment** | Are the decisions sensible for the scope? | Over- or under-engineered | Right size for the problem |
| **Error Handling** | Does it fail gracefully? | Crashes or swallows errors silently | Explicit error paths, meaningful messages |
| **Testing** | Is there any test coverage? | None | Key paths covered, tests read like specs |
| **Communication** | Does the README explain decisions? | Empty or copy-paste boilerplate | Articulates trade-offs and what's incomplete |

**Threshold to advance:** 4+ on Correctness and Communication; average ≥ 3.5 overall.

---

## Stage 2 — Live Technical Interview

### 60-Minute Structure

| Time | Block | Goal |
|---|---|---|
| 0-5 min | Warm-up | Candidate comfort, quick take-home debrief question |
| 5-15 min | Take-home debrief | Understand their decision-making, probe a trade-off |
| 15-55 min | Live coding problem | See real-time problem solving |
| 55-60 min | Candidate questions | Evaluate curiosity and preparation |

### Take-Home Debrief Questions (pick 1-2)
- "Walk me through the design decision you're least happy with."
- "If you had a week instead of a weekend, what would you change first?"
- "Why [language/framework X]? What were the alternatives?"
- "Where are the failure modes in your current implementation?"

These questions have no right answer — they test self-awareness and articulation of trade-offs.

---

### Live Coding Problem Bank

#### Problem 1 — Rate Limiter (System Design + Implementation)
**Prompt:** Implement a function `isAllowed(userId: string): boolean` that enforces a rate limit of 10 requests per minute per user. Start simple, then discuss how to extend it.

**Signals:**
- Do they clarify requirements before coding?
- Do they ask about distributed environments vs. single process?
- Do they know what a sliding window vs. fixed window is?
- Do they handle edge cases (first request, exactly at the limit)?

**Extension questions:**
- "What if we have 10 servers? How does your solution change?"
- "How would you persist this across restarts?"
- "What's the memory complexity as users scale?"

---

#### Problem 2 — LRU Cache
**Prompt:** Implement an LRU (Least Recently Used) cache with `get(key)` and `put(key, value)` operations in O(1) time.

**Signals:**
- Do they recognize this as a HashMap + doubly-linked list problem without hints?
- Can they reason about why a singly-linked list doesn't work?
- Do they write clean, correct pointer manipulation?
- Do they test their own code before saying "done"?

---

#### Problem 3 — Flatten Nested Structure
**Prompt:** Given a deeply nested JSON object, write a function to flatten it into a single-level object with dot-notation keys.

```
Input:  { a: { b: { c: 1 }, d: 2 }, e: 3 }
Output: { "a.b.c": 1, "a.d": 2, "e": 3 }
```

**Signals:**
- Do they handle arrays vs. objects differently?
- Do they ask about circular references?
- Recursive vs. iterative solution — can they do both if asked?
- Do they handle empty objects and null values?

---

#### Problem 4 — Design a URL Shortener (System Design focus)
**Prompt:** Design the data model and API for a URL shortener like bit.ly. No coding required — whiteboard/verbal only.

**Signals:**
- Do they identify the core problem (collision avoidance in short-code generation)?
- Do they think about read/write ratio (10:1 reads in production)?
- Do they bring up caching, TTL, and analytics?
- Do they design the DB schema before jumping to infrastructure?

---

### Live Interview Scoring Rubric

| Dimension | What to Assess | 1 | 5 |
|---|---|---|---|
| **Problem Decomposition** | Did they break it down before coding? | Jumped in blindly | Systematically decomposed, asked clarifying questions |
| **Correctness Under Pressure** | Did they get to a working solution? | Stuck / solution is wrong | Working solution with good coverage |
| **Communication** | Did they narrate their thinking? | Silent; hard to follow | Clear running commentary, explains every choice |
| **Handling Unknowns** | How do they react to "what if X?" | Freezes or deflects | Thinks out loud, makes reasonable assumptions |
| **Code Quality** | Is the live code clean? | Spaghetti | Clear structure even when moving fast |
| **Curiosity** | Did they ask interesting questions at the end? | None / generic | Thoughtful, shows they researched the company |

**Hire signal:** 4+ on Problem Decomposition and Communication; no 1s anywhere.

---

## Evaluation Aggregate

| Candidate | Take-Home Score | Live Score | Decision |
|---|---|---|---|
| Strong hire | ≥ 4.0 avg | ≥ 4.0 avg | Proceed to offer |
| Hire | ≥ 3.5 avg | ≥ 3.5 avg | Proceed with calibration |
| No hire | < 3.0 on any critical dimension | — | Pass |
| Borderline | 3.0–3.5 range | — | Discuss as panel |

---

## Interviewer Calibration Notes

### Common Biases to Watch
- **Speed bias:** Fast code ≠ good code. A candidate who thinks before typing often produces cleaner work.
- **Language familiarity bias:** Don't penalize for using Python vs. Go. Signal is in the reasoning, not the syntax.
- **Confidence bias:** Quiet, methodical thinkers are often stronger than enthusiastic hand-wavers.
- **Completion bias:** A partial solution with good reasoning can be stronger than a complete solution with no self-awareness.

### After Each Interview
1. Write your notes before discussing with other interviewers.
2. Score independently, then compare.
3. Flag any gut feelings that diverge from the rubric scores — discuss them explicitly.
4. One strong dissenting "no hire" vote should be discussed, not overridden by majority.

---

## Logistics Checklist

- [ ] Send take-home with clear instructions and expected time commitment (state "3-4 hours")
- [ ] Give 72-hour window from assignment to submission
- [ ] Use a shared scoring sheet so all reviewers score before discussing
- [ ] Assign a primary interviewer to lead the live session; second interviewer observes and asks follow-up
- [ ] Send feedback within 48 hours of live interview (regardless of outcome)
- [ ] Keep a question bank log — retire any question that leaks online
