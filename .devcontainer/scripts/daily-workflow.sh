#!/usr/bin/env bash
# Daily workflow helper for Job-O-Matic development

set -euo pipefail

echo "🌅 Job-O-Matic Daily Workflow Helper"
echo ""

case "${1:-help}" in
    "start")
        echo "🚀 Starting daily development..."
        git daily-branch
        echo "✅ Switched to today's branch: $(git rev-parse --abbrev-ref HEAD)"
        ;;
    "save")
        echo "💾 Saving current work..."
        git save
        echo "✅ Work saved to current branch"
        ;;
    "push")
        echo "📤 Pushing today's work..."
        git daily-push
        echo "✅ Work pushed to remote"
        ;;
    "clean")
        echo "🧹 Cleaning old daily branches..."
        git daily-clean
        echo "✅ Old daily branches cleaned"
        ;;
    "status")
        echo "📊 Current status:"
        echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
        echo "Status: $(git status --porcelain | wc -l) files changed"
        git recent-branches | head -5
        ;;
    *)
        echo "Usage: $0 {start|save|push|clean|status}"
        echo ""
        echo "Commands:"
        echo "  start  - Create/switch to today's daily branch"
        echo "  save   - Save current work with WIP commit"
        echo "  push   - Push current branch to remote"
        echo "  clean  - Remove old daily branches"
        echo "  status - Show current branch and recent activity"
        ;;
esac
