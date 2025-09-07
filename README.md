# job-O-matic-
we gonna get this bread

## ⚠️ Important: Codespace Billing Notice

**🚨 Current Issue: User v4mpire77 is being charged personally instead of organization billing.**

**If you are being charged personally for Codespaces from this repository:**
- 📖 **Immediate fix**: See [.github/BILLING_RESOLUTION_GUIDE.md](.github/BILLING_RESOLUTION_GUIDE.md)
- 📖 **Detailed guide**: [.github/CODESPACES_BILLING.md](.github/CODESPACES_BILLING.md)
- 🛑 **Stop creating Codespaces** until billing is properly configured
- 📧 **Contact**: @letter-orgz/admins for organization setup

## 🚀 Getting Started with Codespaces

This repository is configured with GitHub Codespaces for easy development setup.

### Option 1: Use GitHub Codespaces (Recommended)
1. Click the green "Code" button
2. Select "Codespaces" tab
3. **IMPORTANT**: Before clicking "Create codespace", verify that billing shows "letter-orgz" not your personal account
4. Click "Create codespace on main"
5. Wait for the environment to set up automatically
6. Once setup is complete, run: `./start.sh` or `streamlit run app.py`
7. The application will be available on port 8501

**💡 Billing Tip**: If you see your personal account name in the billing section, STOP and see [Billing Resolution Guide](.github/BILLING_RESOLUTION_GUIDE.md) before proceeding.

### Option 2: Local Development
1. Clone this repository
2. Install Python 3.11+
3. Install dependencies: `pip install -r requirements.txt`
4. Run the Streamlit app: `streamlit run app.py`

The Codespace will automatically:
- Set up Python 3.11 environment
- Install all required dependencies
- Forward port 8501 for Streamlit
- Configure VS Code with Python extensions
- Create necessary directory structure
- Display billing attribution information

## 📁 Directory Structure

```
job-O-matic/
├── app.py                    # Main Streamlit application
├── start.sh                  # Startup script
├── data/                     # User data (gitignored)
│   ├── cv/                   # CV files
│   └── templates/            # Email templates
├── src/                      # Source code
├── exports/                  # Export files (gitignored)
├── outputs/                  # Generated bundles (gitignored)
└── .devcontainer/           # Codespace configuration
```

## 🔧 Usage

1. **First time setup**: The app will create necessary directories
2. **Add CV files**: Place your CV variants in `data/cv/`
3. **Configure settings**: Use the Settings page for API keys
4. **Start applying**: Use Job Search and Applications features

## 📅 Daily Development Workflow

This repository includes shell scripts for consistent daily git operations:

### Quick Start
```bash
./scripts/start-day.sh    # Begin your development day
./scripts/new-feature.sh  # Create feature branches
./scripts/end-day.sh      # End your development day
./scripts/cleanup-branches.sh  # Clean up old branches
```

### Daily Workflow Scripts

#### 🌅 Start Day (`./scripts/start-day.sh`)
- Creates daily branch with today's date (e.g., `daily/2024-01-15`)
- Pulls latest updates from remote
- Handles uncommitted changes safely
- Optionally launches the application

**Features:**
- Interactive prompts for branch naming
- Automatic backup before destructive operations
- Conflict detection and handling
- Integration with existing `start.sh`

#### ✨ New Feature (`./scripts/new-feature.sh`)
- Creates feature branches within your daily branch
- Suggests feature names based on project context
- Handles uncommitted changes gracefully
- Creates initial commit with branch metadata

**Branch naming pattern:** `feature/YYYY-MM-DD-feature-name`

#### 🌙 End Day (`./scripts/end-day.sh`)
- Multiple workflow options for ending your day:
  1. **Merge & Delete** - Merge to main and clean up
  2. **Keep for Tomorrow** - Push branch to remote
  3. **Archive** - Rename with archive prefix
  4. **Just Cleanup** - Switch to main, update from remote
- Handles uncommitted changes safely
- Automatic conflict detection before merging

#### 🧹 Cleanup Branches (`./scripts/cleanup-branches.sh`)
- Interactive branch cleanup utility
- Categories branches (daily, feature, archive, merged, old)
- Safe deletion with merge checking
- Bulk operations and custom selection
- Remote cleanup capabilities

### Workflow Examples

#### Standard Daily Flow
```bash
# Morning: Start your day
./scripts/start-day.sh

# Create features as needed
./scripts/new-feature.sh

# Evening: End your day
./scripts/end-day.sh

# Weekly: Clean up old branches
./scripts/cleanup-branches.sh
```

#### Working on Multiple Features
```bash
# Start with daily branch
./scripts/start-day.sh

# Create first feature
./scripts/new-feature.sh
# Work on feature...

# Switch back to daily and create another feature
git checkout daily/2024-01-15
./scripts/new-feature.sh
# Work on second feature...

# End day (merges daily branch with all features)
./scripts/end-day.sh
```

### Safety Features
- **Backup Creation**: Automatic backups before destructive operations
- **Conflict Detection**: Checks for merge conflicts before proceeding
- **Interactive Prompts**: Confirms all destructive actions
- **Stash Support**: Safely handles uncommitted changes
- **Remote Sync**: Automatically updates from remote when available

### Branch Naming Conventions
- **Daily branches**: `daily/YYYY-MM-DD`
- **Feature branches**: `feature/YYYY-MM-DD-feature-name`
- **Archive branches**: `archive/YYYYMMDD-original-name`
- **Backup branches**: `backup-YYYYMMDD-HHMMSS-original-name`

## 🆘 Troubleshooting

### Common Issues

**If you encounter "No such file or directory" when running `./start.sh`:**
- Make sure you're in the job-O-matic root directory (where `app.py` exists)
- Verify the script has execute permissions: `chmod +x start.sh`
- The enhanced start.sh script will now automatically install missing dependencies

**If you encounter "Codespace access limited" errors:**
- Refresh the Codespace
- Check if the container built successfully
- Run `./start.sh` manually if the app doesn't auto-start

**If you encounter dependency issues:**
- The start.sh script will automatically install dependencies from requirements.txt
- You can also manually install: `pip3 install -r requirements.txt`
- Ensure you have Python 3.11+ installed

### Daily Workflow Troubleshooting

**Script Permission Errors:**
```bash
chmod +x scripts/*.sh  # Make all scripts executable
```

**Git Repository Not Found:**
- Ensure you're in the root directory of the job-O-matic repository
- Check that `.git` directory exists

**Branch Already Exists:**
- Use the interactive options in the scripts to handle existing branches
- Or manually switch: `git checkout existing-branch-name`

**Merge Conflicts:**
- The scripts will detect conflicts and guide you through resolution
- Manual resolution: `git status` → edit files → `git add .` → `git commit`

**Remote Connection Issues:**
- Scripts work offline but some features require remote access
- Check internet connection and GitHub authentication

**Stash Issues:**
- View stashes: `git stash list`
- Apply stash: `git stash pop`
- Clear stashes: `git stash clear`

**Script Interruption:**
- If a script is interrupted, check git status: `git status`
- Clean up if needed: `git reset --hard` (⚠️ DESTRUCTIVE)
- Restart the script

### Getting Help

**Script Help:**
- Each script provides interactive guidance
- Use `Ctrl+C` to safely exit any script
- Read script prompts carefully before proceeding

**Git State Recovery:**
- Check current state: `git status`
- View recent commits: `git log --oneline -5`
- View all branches: `git branch -a`

**Emergency Recovery:**
- Create backup: `git branch backup-$(date +%s)`
- Reset to last commit: `git reset --hard HEAD`
- Reset to specific commit: `git reset --hard <commit-hash>`
