---
name: Remote trigger plan limit
description: Current Claude plan allows only 1 scheduled trigger — AIBrain shares the slot with marketplace builder
type: project
---

Current Claude plan allows 1 hourly cloud scheduled session. The "Used Car Parts Marketplace Builder" trigger (ID: `trig_01J8GyTbnX44P5vcaL3C3ijj`, env: `env_01R2y7G78np7VoDG4zozgnQV`) is currently using the slot.

**Why:** Plan limitation. AIBrain was redesigned from 3 daily triggers (8am/9am/8pm) to 1 trigger (8am) because of this.

**How to apply:** Before creating the AIBrain trigger, the marketplace trigger must be disabled. If Joe upgrades his plan, revisit the 3-trigger design (spec documents the upgrade path in SETUP.md).
