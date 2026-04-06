---
name: Check repo structure before creating files
description: Always explore the folder structure before creating new files — place them in the appropriate existing directory rather than creating standalone files at the root or arbitrary paths.
type: feedback
---

Before creating any new file in the user's workspace (especially AIBrain), always scan the existing directory structure first to understand where the file logically belongs.

**Why:** User had a `tasks/backlog.md` file that was the correct home for todo items, but I created a redundant `TODO.md` at the repo root instead. This clutters the project and ignores the conventions already in place.

**How to apply:** Run `ls` or use Glob to understand the folder layout before writing any new file. Match the new content to an existing folder or file that serves the same purpose. Only create a new file at a new path if nothing in the current structure fits.
