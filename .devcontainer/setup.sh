#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Setting up Job-O-Matic git workflow..."

# Install git configuration with useful aliases
echo "📝 Setting up git configuration..."
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'

# Daily workflow aliases
git config --global alias.daily-branch '!f() { DATE=$(date +%Y-%m-%d); git checkout -b daily/$DATE 2>/dev/null || git checkout daily/$DATE; }; f'
git config --global alias.daily-push '!f() { BRANCH=$(git rev-parse --abbrev-ref HEAD); git push -u origin $BRANCH; }; f'
git config --global alias.daily-clean '!f() { git checkout main 2>/dev/null || git checkout master 2>/dev/null; git branch | grep "daily/" | head -10 | xargs -r git branch -d; }; f'

# Branch management aliases
git config --global alias.new-feature '!f() { git checkout -b feature/$1; }; f'
git config --global alias.new-fix '!f() { git checkout -b fix/$1; }; f'
git config --global alias.recent-branches 'for-each-ref --sort=-committerdate refs/heads/ --format="%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))"'

# Safety aliases
git config --global alias.save '!git add -A && git commit -m "WIP: Save current work"'
git config --global alias.undo 'reset HEAD~1 --mixed'
git config --global alias.wipe '!git add -A && git commit -qm "WIPE SAVEPOINT" && git reset HEAD~1 --hard'

echo "✅ Git aliases configured"

# Set up git hooks using existing script
echo "🪝 Installing git hooks..."
if [ -f "./scripts/install-hooks.sh" ]; then
    bash ./scripts/install-hooks.sh
else
    echo "⚠️  Git hooks script not found, skipping..."
fi

# Set up default git configuration for better workflow
echo "⚙️  Configuring git workflow settings..."
git config --global pull.rebase false
git config --global init.defaultBranch main
git config --global core.autocrlf input
git config --global core.safecrlf true

# Create helpful scripts directory if it doesn't exist
mkdir -p .devcontainer/scripts

# Create daily workflow helper script
cat > .devcontainer/scripts/daily-workflow.sh << 'EOF'
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
EOF

chmod +x .devcontainer/scripts/daily-workflow.sh

# Create git workflow cheatsheet
cat > .devcontainer/git-workflow-cheatsheet.md << 'EOF'
# Job-O-Matic Git Workflow Cheatsheet

## Daily Workflow Commands
```bash
# Start daily work (creates/switches to today's branch)
git daily-branch

# Save work in progress
git save

# Push current branch
git daily-push

# Clean old daily branches
git daily-clean

# Quick daily workflow script
./.devcontainer/scripts/daily-workflow.sh start
./.devcontainer/scripts/daily-workflow.sh save
./.devcontainer/scripts/daily-workflow.sh push
```

## Branch Management
```bash
# Create feature branch
git new-feature my-feature-name

# Create fix branch  
git new-fix my-fix-name

# See recent branches
git recent-branches
```

## Safety Commands
```bash
# Save current work without thinking about commit message
git save

# Undo last commit (keep changes)
git undo

# Wipe everything and go back to last commit
git wipe
```

## Useful Shortcuts
```bash
git co    # checkout
git br    # branch
git ci    # commit
git st    # status
```
EOF

echo "📚 Git workflow cheatsheet created at .devcontainer/git-workflow-cheatsheet.md"
echo "🎯 Daily workflow script available at .devcontainer/scripts/daily-workflow.sh"
echo ""
echo "✅ Git workflow setup complete!"
echo ""
echo "Quick start:"
echo "  git daily-branch          # Start today's work"
echo "  ./.devcontainer/scripts/daily-workflow.sh start"
echo ""
echo "📖 See .devcontainer/git-workflow-cheatsheet.md for full command reference"