---
name: Skip permission prompts
description: User wants all tool permissions allowed globally so Claude never prompts for permission
type: feedback
---

User wants Claude to execute tools without permission prompts. All tools are allowed in global settings.json.

**Why:** Permission prompts slow down the workflow.

**How to apply:** This is handled via settings.json permissions, not Claude behavior. If new tools need allowing, add them to the global allow list.
