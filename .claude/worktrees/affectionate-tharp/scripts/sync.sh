#!/bin/bash
# AIBrain Sync Script
# Copies work journals and memory from local projects into the AIBrain repo
# and pushes to remote so the cloud trigger can read them.
#
# Runs locally via cron at 7:50am EST (before the 8am trigger).

set -euo pipefail

AIBRAIN_DIR="$HOME/workspace/interview/AIBrain"
SYNC_JOURNALS="$AIBRAIN_DIR/sync/journals"
SYNC_MEMORY="$AIBRAIN_DIR/sync/memory"
WORKSPACE="$HOME/workspace"
CLAUDE_PROJECTS="$HOME/.claude/projects"

# Ensure sync directories exist
mkdir -p "$SYNC_JOURNALS" "$SYNC_MEMORY"

# --- Sync Work Journals ---
# Find all .work-journal directories and copy recent entries
find "$WORKSPACE" -type d -name ".work-journal" 2>/dev/null | while read -r journal_dir; do
    # Derive a project name from the path
    project_path="${journal_dir%/.work-journal}"
    project_name=$(echo "$project_path" | sed "s|$WORKSPACE/||" | tr '/' '_')

    # Create project subdirectory in sync
    mkdir -p "$SYNC_JOURNALS/$project_name"

    # Copy files modified in the last 7 days
    find "$journal_dir" -name "*.md" -mtime -7 2>/dev/null | while read -r file; do
        cp "$file" "$SYNC_JOURNALS/$project_name/"
    done
done

# --- Sync Claude Memory ---
# Find all project memory directories and copy their contents
if [ -d "$CLAUDE_PROJECTS" ]; then
    find "$CLAUDE_PROJECTS" -type d -name "memory" 2>/dev/null | while read -r memory_dir; do
        # Derive project name from the path
        parent_dir=$(dirname "$memory_dir")
        project_name=$(basename "$parent_dir")

        # Create project subdirectory in sync
        mkdir -p "$SYNC_MEMORY/$project_name"

        # Copy all memory files
        find "$memory_dir" -name "*.md" 2>/dev/null | while read -r file; do
            cp "$file" "$SYNC_MEMORY/$project_name/"
        done
    done
fi

# --- Push to remote ---
cd "$AIBRAIN_DIR"
git add sync/
if git diff --cached --quiet; then
    echo "No changes to sync."
else
    git commit -m "chore(sync): $(date +%Y-%m-%d) — sync journals and memory"
    git pull --rebase origin main
    git push origin main
    echo "Sync complete and pushed."
fi
