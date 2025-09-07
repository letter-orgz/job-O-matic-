#!/usr/bin/env bash
set -euo pipefail

# Daily Development Workflow - Start Day Script
# Creates a daily branch, pulls updates, and sets up development environment

echo "🌅 Starting new development day..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository"
    echo "Please run this script from the job-O-matic root directory"
    exit 1
fi

# Get current date for branch naming
TODAY=$(date +%Y-%m-%d)
CURRENT_BRANCH=$(git branch --show-current)

echo "📅 Today's date: $TODAY"
echo "🌿 Current branch: $CURRENT_BRANCH"

# Function to prompt for user input with default
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local result
    
    read -p "$prompt [$default]: " result
    echo "${result:-$default}"
}

# Function to backup current work
backup_current_work() {
    local backup_branch="backup-$(date +%Y%m%d-%H%M%S)-$CURRENT_BRANCH"
    echo "💾 Creating backup branch: $backup_branch"
    git branch "$backup_branch"
    echo "✅ Backup created successfully"
}

# Check for uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "⚠️  You have uncommitted changes"
    echo "📋 Current changes:"
    git status --short
    echo ""
    
    while true; do
        echo "What would you like to do?"
        echo "1) Commit changes and continue"
        echo "2) Stash changes and continue"
        echo "3) Create backup branch and continue"
        echo "4) Cancel and handle manually"
        read -p "Choose option (1-4): " choice
        
        case $choice in
            1)
                echo "📝 Committing changes..."
                git add .
                commit_msg=$(prompt_with_default "Enter commit message" "WIP: End of day commit")
                git commit -m "$commit_msg"
                break
                ;;
            2)
                echo "📦 Stashing changes..."
                stash_msg=$(prompt_with_default "Enter stash message" "WIP: Start of day stash")
                git stash push -m "$stash_msg"
                echo "✅ Changes stashed"
                break
                ;;
            3)
                backup_current_work
                git add .
                git commit -m "WIP: Backup before start-day"
                break
                ;;
            4)
                echo "❌ Cancelled. Please handle your changes manually and run again."
                exit 1
                ;;
            *)
                echo "❌ Invalid option. Please choose 1-4."
                ;;
        esac
    done
fi

# Pull latest changes from remote
echo ""
echo "🔄 Updating from remote..."
if git remote | grep -q origin; then
    # Check if we can reach remote
    if git ls-remote origin &>/dev/null; then
        # Determine the main branch (main or master)
        MAIN_BRANCH="main"
        if git ls-remote --heads origin master | grep -q master; then
            if ! git ls-remote --heads origin main | grep -q main; then
                MAIN_BRANCH="master"
            fi
        fi
        
        echo "📡 Fetching from origin..."
        git fetch origin
        
        # If we're on main/master, pull directly
        if [ "$CURRENT_BRANCH" = "$MAIN_BRANCH" ]; then
            echo "🔄 Pulling latest changes..."
            git pull origin "$MAIN_BRANCH"
        else
            echo "🔄 Updating $MAIN_BRANCH branch..."
            git fetch origin "$MAIN_BRANCH:$MAIN_BRANCH" 2>/dev/null || true
        fi
    else
        echo "⚠️  Cannot reach remote origin. Working offline."
    fi
else
    echo "⚠️  No remote origin configured. Working with local repository only."
fi

# Create daily branch
BRANCH_PREFIX=$(prompt_with_default "Enter branch prefix" "daily")
DAILY_BRANCH="$BRANCH_PREFIX/$TODAY"

# Check if daily branch already exists
if git branch --list | grep -q "$DAILY_BRANCH"; then
    echo "🌿 Daily branch '$DAILY_BRANCH' already exists"
    read -p "Switch to existing branch? (y/n): " switch_choice
    if [[ $switch_choice =~ ^[Yy] ]]; then
        git checkout "$DAILY_BRANCH"
        echo "✅ Switched to existing daily branch: $DAILY_BRANCH"
    else
        echo "ℹ️  Staying on current branch: $CURRENT_BRANCH"
    fi
else
    echo "🌱 Creating new daily branch: $DAILY_BRANCH"
    
    # Ask which branch to base the daily branch on
    BASE_BRANCH=$(prompt_with_default "Base daily branch on" "$MAIN_BRANCH")
    
    # Verify base branch exists
    if git branch --list | grep -q "$BASE_BRANCH" || git branch -r --list | grep -q "origin/$BASE_BRANCH"; then
        git checkout -b "$DAILY_BRANCH" "$BASE_BRANCH"
        echo "✅ Created and switched to daily branch: $DAILY_BRANCH"
    else
        echo "❌ Base branch '$BASE_BRANCH' not found"
        echo "Available branches:"
        git branch -a
        exit 1
    fi
fi

# Run startup script if it exists and user wants it
if [ -f "start.sh" ]; then
    echo ""
    read -p "🚀 Run start.sh to launch the application? (y/n): " start_choice
    if [[ $start_choice =~ ^[Yy] ]]; then
        echo "🎯 Launching Job-O-Matic..."
        ./start.sh
    fi
fi

echo ""
echo "✅ Day setup complete!"
echo "🌿 Current branch: $(git branch --show-current)"
echo "📁 Working directory: $(pwd)"
echo ""
echo "💡 Next steps:"
echo "   - Use './scripts/new-feature.sh' to create feature branches"
echo "   - Use './scripts/end-day.sh' when you're done for the day"
echo "   - Use './scripts/cleanup-branches.sh' to clean up old branches"
echo ""
echo "🎉 Happy coding!"