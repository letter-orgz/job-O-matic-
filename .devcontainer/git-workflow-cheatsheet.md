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
