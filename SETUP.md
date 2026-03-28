# AIBrain Setup Guide

## Prerequisites

1. A GitHub remote repository for AIBrain
2. Claude Pro/Max plan with remote trigger access

## Step 1: Create GitHub Remote

```bash
cd ~/workspace/interview/AIBrain
gh repo create AIBrain --private --source=. --push
```

Or if you already have a repo:
```bash
git remote add origin git@github.com:<your-username>/AIBrain.git
git push -u origin main
```

## Step 2: Disable Existing Trigger

Your plan allows 1 scheduled trigger. The "Used Car Parts Marketplace Builder" trigger is currently using that slot.

To disable it, run in Claude Code:
```
Ask Claude: "Disable the Used Car Parts Marketplace Builder trigger"
```

Or via the API, the trigger ID is: `trig_01J8GyTbnX44P5vcaL3C3ijj`

## Step 3: Create the AIBrain Trigger

Once the slot is free, ask Claude Code to create the trigger:

```
Ask Claude: "Create the AIBrain daily trigger using the prompt in triggers/daily-agent-prompt.md, scheduled at 8am daily, using the AIBrain GitHub repo as the source"
```

The trigger configuration:
- **Name:** AIBrain Daily Cycle
- **Cron:** `0 8 * * *` (8am daily, in your timezone)
- **Model:** claude-sonnet-4-6 (cost-effective for daily runs)
- **Tools:** Bash, Read, Write, Edit, Glob, Grep, WebSearch, WebFetch
- **Source:** Your AIBrain GitHub repo

## Step 4: Verify

After creation, trigger a manual test run:
```
Ask Claude: "Run the AIBrain Daily Cycle trigger now"
```

Check the Claude app/dashboard to see the output.

## Usage

- **Morning:** Open Claude app, check the AIBrain session for today's plan
- **Reply:** Type your priorities/new tasks as a reply in that session
- **Next day:** The 8am run picks up your reply and incorporates it

## Upgrading

If you upgrade to a plan with more triggers, you can split into 3 triggers:
- 8am: Morning plan (Phase 1-3)
- 9am: Read reply + execute (Phase 2 re-run + Phase 4)
- 8pm: Evening retro (Phase 1 + Phase 5)
