#!/usr/bin/env bash
set -euo pipefail

# Daily Development Workflow - End Day Script
# Merges/archives work, cleanup, and prepares for next day

echo "🌅 Ending development day..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository"
    echo "Please run this script from the job-O-matic root directory"
    exit 1
fi

CURRENT_BRANCH=$(git branch --show-current)
TODAY=$(date +%Y-%m-%d)

echo "🌿 Current branch: $CURRENT_BRANCH"
echo "📅 Today's date: $TODAY"

# Function to prompt for user input with default
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local result
    
    read -p "$prompt [$default]: " result
    echo "${result:-$default}"
}

# Check if we're on a daily branch
if [[ $CURRENT_BRANCH =~ ^(daily|feature)/.*$ ]]; then
    echo "📋 You're on a development branch: $CURRENT_BRANCH"
else
    echo "⚠️  You're on branch: $CURRENT_BRANCH"
    read -p "This doesn't look like a daily/feature branch. Continue anyway? (y/n): " continue_choice
    if [[ ! $continue_choice =~ ^[Yy] ]]; then
        echo "❌ Cancelled"
        exit 1
    fi
fi

# Check for uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo ""
    echo "📝 You have uncommitted changes:"
    git status --short
    echo ""
    
    while true; do
        echo "What would you like to do with these changes?"
        echo "1) Commit them now"
        echo "2) Stash them for later"
        echo "3) Discard them (⚠️  DESTRUCTIVE)"
        echo "4) Cancel and handle manually"
        read -p "Choose option (1-4): " choice
        
        case $choice in
            1)
                git add .
                commit_msg=$(prompt_with_default "Enter commit message" "End of day commit - $(date +%H:%M)")
                git commit -m "$commit_msg"
                echo "✅ Changes committed"
                break
                ;;
            2)
                stash_msg=$(prompt_with_default "Enter stash message" "End of day stash - $(date +%H:%M)")
                git stash push -m "$stash_msg"
                echo "✅ Changes stashed"
                break
                ;;
            3)
                echo "⚠️  This will permanently discard all uncommitted changes!"
                read -p "Are you absolutely sure? Type 'yes' to confirm: " confirm
                if [ "$confirm" = "yes" ]; then
                    git reset --hard
                    git clean -fd
                    echo "✅ Changes discarded"
                    break
                else
                    echo "❌ Cancelled discard operation"
                fi
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

# Determine main branch
MAIN_BRANCH="main"
if git branch --list | grep -q "master" && ! git branch --list | grep -q "main"; then
    MAIN_BRANCH="master"
fi

echo ""
echo "🔄 End of day workflow options:"
echo "1) Merge branch to $MAIN_BRANCH and delete"
echo "2) Keep branch for tomorrow (push to remote)"
echo "3) Archive branch (rename with archive prefix)"
echo "4) Just cleanup and switch to $MAIN_BRANCH"

while true; do
    read -p "Choose option (1-4): " workflow_choice
    
    case $workflow_choice in
        1)
            echo "🔄 Merging to $MAIN_BRANCH..."
            
            # Switch to main branch
            git checkout "$MAIN_BRANCH"
            
            # Update main branch from remote if possible
            if git remote | grep -q origin && git ls-remote origin &>/dev/null; then
                echo "📡 Updating $MAIN_BRANCH from remote..."
                git pull origin "$MAIN_BRANCH" || echo "⚠️  Could not pull from remote"
            fi
            
            # Check if branch can be merged cleanly
            if git merge --no-commit --no-ff "$CURRENT_BRANCH" &>/dev/null; then
                git merge --abort
                echo "✅ Clean merge possible"
                git merge "$CURRENT_BRANCH"
                
                # Push to remote if available
                if git remote | grep -q origin && git ls-remote origin &>/dev/null; then
                    echo "📡 Pushing merged changes to remote..."
                    git push origin "$MAIN_BRANCH" || echo "⚠️  Could not push to remote"
                fi
                
                # Delete the branch
                git branch -d "$CURRENT_BRANCH"
                echo "✅ Branch merged and deleted: $CURRENT_BRANCH"
            else
                echo "⚠️  Merge conflicts detected!"
                echo "❌ Please resolve conflicts manually:"
                echo "   1. git checkout $MAIN_BRANCH"
                echo "   2. git merge $CURRENT_BRANCH"
                echo "   3. Resolve conflicts"
                echo "   4. git commit"
                exit 1
            fi
            break
            ;;
        2)
            echo "💾 Keeping branch for tomorrow..."
            
            # Push to remote if available
            if git remote | grep -q origin && git ls-remote origin &>/dev/null; then
                echo "📡 Pushing branch to remote..."
                git push -u origin "$CURRENT_BRANCH" || echo "⚠️  Could not push to remote"
            fi
            
            # Switch to main branch
            git checkout "$MAIN_BRANCH"
            echo "✅ Branch preserved: $CURRENT_BRANCH"
            break
            ;;
        3)
            echo "📦 Archiving branch..."
            
            archive_branch="archive/$(date +%Y%m%d)-$CURRENT_BRANCH"
            git branch -m "$CURRENT_BRANCH" "$archive_branch"
            
            # Push to remote if available
            if git remote | grep -q origin && git ls-remote origin &>/dev/null; then
                echo "📡 Pushing archived branch to remote..."
                git push origin "$archive_branch" || echo "⚠️  Could not push to remote"
                # Delete old branch from remote if it existed
                git push origin --delete "$CURRENT_BRANCH" 2>/dev/null || true
            fi
            
            # Switch to main branch
            git checkout "$MAIN_BRANCH"
            echo "✅ Branch archived as: $archive_branch"
            break
            ;;
        4)
            echo "🧹 Just switching to $MAIN_BRANCH..."
            git checkout "$MAIN_BRANCH"
            
            # Update main branch from remote if possible
            if git remote | grep -q origin && git ls-remote origin &>/dev/null; then
                echo "📡 Updating $MAIN_BRANCH from remote..."
                git pull origin "$MAIN_BRANCH" || echo "⚠️  Could not pull from remote"
            fi
            
            echo "✅ Switched to $MAIN_BRANCH"
            break
            ;;
        *)
            echo "❌ Invalid option. Please choose 1-4."
            ;;
    esac
done

# Cleanup suggestions
echo ""
echo "🧹 Cleanup suggestions:"

# Check for old daily branches
old_branches=$(git branch | grep -E "(daily|feature)/" | grep -v "$(date +%Y-%m-%d)" | head -5)
if [ -n "$old_branches" ]; then
    echo "📅 Found some old development branches:"
    echo "$old_branches"
    echo "💡 Use './scripts/cleanup-branches.sh' to clean them up"
fi

# Check for stashes
stash_count=$(git stash list | wc -l)
if [ "$stash_count" -gt 0 ]; then
    echo "📦 You have $stash_count stashed changes"
    echo "💡 Review with 'git stash list' and apply with 'git stash pop'"
fi

echo ""
echo "✅ End of day complete!"
echo "🌿 Current branch: $(git branch --show-current)"
echo ""
echo "💡 Tomorrow:"
echo "   - Use './scripts/start-day.sh' to begin a new day"
echo "   - Your work is safely preserved"
echo ""
echo "🌙 Good night!"