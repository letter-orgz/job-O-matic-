# 🌅 Daily Development Workflow Guide

This guide provides a clean, organized approach to managing branches and starting development work each day in the job-O-matic repository.

## 🎯 Quick Start

### For Daily Development
```bash
# Start your day with a clean setup
./scripts/daily-setup.sh
```

This single command will:
- ✅ Switch to main branch and pull latest changes
- ✅ Create a new daily branch (`daily/2024-01-15`)
- ✅ Set up required directories
- ✅ Update dependencies
- ✅ Optionally clean up old branches
- ✅ Offer to start the application

### For Feature Development
```bash
# Create a feature branch for specific work
./scripts/new-feature.sh "fix-cv-upload"
./scripts/new-feature.sh "Add job filters"
./scripts/new-feature.sh ui-improvements --prefix=experiment/
```

### For Branch Cleanup
```bash
# Clean up old branches safely
./scripts/branch-cleanup.sh                 # Interactive cleanup
./scripts/branch-cleanup.sh --daily-only   # Only daily branches
./scripts/branch-cleanup.sh --dry-run      # Preview what would be deleted
```

## 📋 Detailed Workflow

### 1. Starting Your Day

When you begin work each day:

1. **Open Codespace/Dev Environment**
   - GitHub Codespace will auto-setup the environment
   - Or run locally: `./scripts/daily-setup.sh`

2. **Daily Setup Script Does:**
   - Checks for uncommitted work (offers to stash)
   - Switches to main branch
   - Pulls latest changes from origin
   - Creates daily branch: `daily/YYYY-MM-DD`
   - Offers to clean up old branches
   - Sets up directories and dependencies

3. **Result:** Clean daily branch ready for work

### 2. Working on Features

For each distinct piece of work within your day:

```bash
# Create feature branches as needed
./scripts/new-feature.sh "feature-name"
```

This creates branches like:
- `feature/fix-cv-upload` 
- `feature/add-job-filters`
- `feature/improve-ui`

**Feature Branch Benefits:**
- ✅ Isolate work on specific features
- ✅ Easy to switch between different tasks
- ✅ Clean commit history
- ✅ Safe to experiment

### 3. Branch Structure

Your repository will maintain this clean structure:

```
main                    # Production-ready code
├── daily/2024-01-15   # Today's main work branch
│   ├── feature/fix-cv-upload     # Sub-feature 1
│   ├── feature/add-filters       # Sub-feature 2
│   └── experiment/new-ui         # Experimental work
├── daily/2024-01-14   # Yesterday's work (cleanup candidate)
└── daily/2024-01-13   # Older work (cleanup candidate)
```

### 4. End of Day Workflow

Before ending your work session:

```bash
# 1. Commit your work
git add .
git commit -m "Feature: implement CV upload fix"

# 2. Merge completed features back to daily branch
git checkout daily/$(date +%Y-%m-%d)
git merge feature/fix-cv-upload
git branch -d feature/fix-cv-upload  # Clean up merged branch

# 3. Push your daily branch (optional, for backup)
git push origin daily/$(date +%Y-%m-%d)

# 4. If work is complete and tested, merge to main
git checkout main
git merge daily/$(date +%Y-%m-%d)
git push origin main
```

### 5. Weekly Cleanup

Run weekly cleanup to maintain repository hygiene:

```bash
# Clean up old daily branches (older than 7 days)
./scripts/branch-cleanup.sh --daily-only --older-than=7

# Or clean up all old branches
./scripts/branch-cleanup.sh --older-than=14
```

## 🛠️ Script Reference

### `daily-setup.sh`
**Purpose:** Complete daily development environment setup

**What it does:**
- Switches to main and pulls latest
- Creates daily branch with today's date
- Handles uncommitted changes safely
- Sets up directories and dependencies
- Offers branch cleanup and app startup

**Usage:**
```bash
./scripts/daily-setup.sh
```

### `new-feature.sh`
**Purpose:** Create feature/task branches within your daily work

**Options:**
- `--from=BRANCH` - Create from specific branch
- `--prefix=PREFIX` - Use custom prefix (default: `feature/`)

**Usage:**
```bash
./scripts/new-feature.sh "feature-name"
./scripts/new-feature.sh "Fix CV upload bug"
./scripts/new-feature.sh hotfix --prefix=fix/
./scripts/new-feature.sh ui-test --from=main
```

### `branch-cleanup.sh`
**Purpose:** Safe cleanup of old development branches

**Options:**
- `--daily-only` - Only clean daily/ branches
- `--older-than=N` - Clean branches older than N days
- `--dry-run` - Preview without deleting
- `--force` - Skip confirmations

**Safety Features:**
- Never deletes current branch
- Never deletes main/master
- Shows what will be deleted before doing it
- Supports dry-run mode

**Usage:**
```bash
./scripts/branch-cleanup.sh                    # Interactive
./scripts/branch-cleanup.sh --daily-only      # Daily branches only
./scripts/branch-cleanup.sh --dry-run         # Preview mode
./scripts/branch-cleanup.sh --force --older-than=14  # Automated
```

## 🔧 Devcontainer Integration

The `.devcontainer/devcontainer.json` is configured to:

1. **On Create:** Install dependencies and make scripts executable
2. **On Start:** Remind about daily setup and provide quick commands

**Codespace Quick Start:**
1. Open Codespace
2. Wait for auto-setup
3. Run: `./scripts/daily-setup.sh`
4. Start coding!

## 💡 Best Practices

### Branch Naming
- **Daily branches:** `daily/YYYY-MM-DD`
- **Feature branches:** `feature/descriptive-name`
- **Fix branches:** `fix/issue-description`
- **Experiments:** `experiment/what-youre-testing`

### Commit Messages
```bash
# Good commit messages
git commit -m "Feature: add job filtering by location"
git commit -m "Fix: resolve CV upload validation error"
git commit -m "Docs: update workflow guide"
git commit -m "Refactor: simplify email template logic"
```

### Daily Workflow
1. ✅ Start with `./scripts/daily-setup.sh`
2. ✅ Create feature branches for distinct work
3. ✅ Commit early and often
4. ✅ Merge completed features back to daily branch
5. ✅ Push daily branch for backup
6. ✅ Merge stable work to main

### Weekly Maintenance
1. ✅ Run branch cleanup weekly
2. ✅ Review and merge daily branches to main
3. ✅ Update documentation if needed
4. ✅ Push main branch changes

## 🚨 Troubleshooting

### "Script not executable"
```bash
chmod +x scripts/*.sh
```

### "Not in git repository"
Make sure you're in the job-O-matic root directory:
```bash
cd /path/to/job-O-matic
./scripts/daily-setup.sh
```

### "Branch already exists"
The scripts handle this gracefully and will ask if you want to switch to existing branches.

### "Uncommitted changes"
Scripts will detect uncommitted work and offer to stash it safely.

## 🎯 Summary

This workflow system provides:

- ✅ **Clean daily branches** - Fresh start each day
- ✅ **Feature isolation** - Separate branches for different tasks  
- ✅ **Safe cleanup** - Automated old branch removal
- ✅ **Devcontainer integration** - Works seamlessly with Codespaces
- ✅ **Safety checks** - Prevents data loss
- ✅ **Flexibility** - Supports different work styles

**Start each day with:** `./scripts/daily-setup.sh`
**Create features with:** `./scripts/new-feature.sh <name>`
**Clean up with:** `./scripts/branch-cleanup.sh`

Happy coding! 🚀