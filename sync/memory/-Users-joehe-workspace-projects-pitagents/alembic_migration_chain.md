---
name: Alembic migration chain tip
description: The actual head revision in the pitagents alembic migration chain is 0023, not the hash file
type: project
originSessionId: 8ccd2e6c-9a9d-470a-adb3-7ee2aa89375e
---
The alembic/versions/ directory has two revision sequences:
- A numbered sequence: 0001 → 0002 → ... → 9c5e490936db → 0023 (the true head)
- A hash-named file `9c5e490936db_add_chat_messages_and_user_preferences.py` is NOT the head — it's the second-to-last

**Why:** New migration 0024 accidentally set down_revision="9c5e490936db" (the hash file) instead of "0023", creating a fork. Was caught in code review.

**How to apply:** When creating a new Alembic migration, always run `alembic heads` or check the actual latest migration's `revision` field. The last numbered file (currently 0023) is the true head.
