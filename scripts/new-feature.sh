#!/usr/bin/env bash
set -euo pipefail

# Daily Development Workflow - New Feature Script
# Creates sub-branches within daily branch for specific features

echo "✨ Creating new feature branch..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository"
    echo "Please run this script from the job-O-matic root directory"
    exit 1
fi

CURRENT_BRANCH=$(git branch --show-current)
TODAY=$(date +%Y-%m-%d)

echo "🌿 Current branch: $CURRENT_BRANCH"

# Function to prompt for user input with default
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local result
    
    read -p "$prompt [$default]: " result
    echo "${result:-$default}"
}

# Function to suggest feature name based on context
suggest_feature_name() {
    local suggestions=()
    
    # Check for common development patterns
    if [ -f "app.py" ]; then
        suggestions+=("ui-enhancement" "dashboard-update" "api-integration")
    fi
    
    if [ -d "src" ]; then
        suggestions+=("core-feature" "bug-fix" "refactor")
    fi
    
    if [ -f "requirements.txt" ]; then
        suggestions+=("dependency-update" "security-fix")
    fi
    
    # Add generic suggestions
    suggestions+=("feature" "fix" "improvement" "experiment")
    
    echo "💡 Suggested feature names:"
    for i in "${!suggestions[@]}"; do
        echo "   $((i+1))) ${suggestions[$i]}"
    done
    echo ""
}

# Check for uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "⚠️  You have uncommitted changes"
    echo "📋 Current changes:"
    git status --short
    echo ""
    
    while true; do
        echo "What would you like to do?"
        echo "1) Commit changes first"
        echo "2) Stash changes and continue"
        echo "3) Continue with uncommitted changes"
        echo "4) Cancel"
        read -p "Choose option (1-4): " choice
        
        case $choice in
            1)
                git add .
                commit_msg=$(prompt_with_default "Enter commit message" "WIP: Before creating feature branch")
                git commit -m "$commit_msg"
                echo "✅ Changes committed"
                break
                ;;
            2)
                stash_msg=$(prompt_with_default "Enter stash message" "WIP: Before feature branch - $(date +%H:%M)")
                git stash push -m "$stash_msg"
                echo "✅ Changes stashed"
                break
                ;;
            3)
                echo "⚠️  Continuing with uncommitted changes..."
                break
                ;;
            4)
                echo "❌ Cancelled"
                exit 1
                ;;
            *)
                echo "❌ Invalid option. Please choose 1-4."
                ;;
        esac
    done
fi

# Check if we're on a suitable base branch
echo ""
if [[ $CURRENT_BRANCH =~ ^daily/ ]]; then
    echo "✅ You're on a daily branch - perfect for creating feature branches!"
    BASE_BRANCH="$CURRENT_BRANCH"
elif [[ $CURRENT_BRANCH =~ ^(main|master|develop)$ ]]; then
    echo "💡 You're on $CURRENT_BRANCH branch"
    echo "💭 Consider using a daily branch as base (run ./scripts/start-day.sh first)"
    read -p "Continue creating feature branch from $CURRENT_BRANCH? (y/n): " continue_choice
    if [[ ! $continue_choice =~ ^[Yy] ]]; then
        echo "❌ Cancelled"
        echo "💡 Run './scripts/start-day.sh' first to create a daily branch"
        exit 1
    fi
    BASE_BRANCH="$CURRENT_BRANCH"
else
    echo "🤔 You're on branch: $CURRENT_BRANCH"
    echo "Available branches:"
    git branch | head -10
    echo ""
    
    read -p "Use current branch as base? (y/n): " use_current
    if [[ $use_current =~ ^[Yy] ]]; then
        BASE_BRANCH="$CURRENT_BRANCH"
    else
        read -p "Enter base branch name: " BASE_BRANCH
        if ! git branch --list | grep -q "$BASE_BRANCH"; then
            echo "❌ Branch '$BASE_BRANCH' not found"
            exit 1
        fi
        git checkout "$BASE_BRANCH"
    fi
fi

# Get feature name
echo ""
suggest_feature_name

FEATURE_NAME=""
while [ -z "$FEATURE_NAME" ]; do
    read -p "Enter feature name (lowercase, use hyphens): " input_name
    
    # Clean up the input
    FEATURE_NAME=$(echo "$input_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
    
    if [ -z "$FEATURE_NAME" ]; then
        echo "❌ Please enter a valid feature name"
    elif [ ${#FEATURE_NAME} -lt 3 ]; then
        echo "❌ Feature name too short (minimum 3 characters)"
        FEATURE_NAME=""
    elif [ ${#FEATURE_NAME} -gt 50 ]; then
        echo "❌ Feature name too long (maximum 50 characters)"
        FEATURE_NAME=""
    fi
done

# Create feature branch name
if [[ $BASE_BRANCH =~ ^daily/ ]]; then
    FEATURE_BRANCH="feature/$TODAY-$FEATURE_NAME"
else
    FEATURE_BRANCH="feature/$FEATURE_NAME"
fi

# Check if branch already exists
if git branch --list | grep -q "$FEATURE_BRANCH"; then
    echo "⚠️  Branch '$FEATURE_BRANCH' already exists"
    
    while true; do
        echo "What would you like to do?"
        echo "1) Switch to existing branch"
        echo "2) Create with different name"
        echo "3) Delete existing and create new"
        echo "4) Cancel"
        read -p "Choose option (1-4): " choice
        
        case $choice in
            1)
                git checkout "$FEATURE_BRANCH"
                echo "✅ Switched to existing feature branch: $FEATURE_BRANCH"
                exit 0
                ;;
            2)
                suffix=$(prompt_with_default "Enter suffix for branch name" "v2")
                FEATURE_BRANCH="$FEATURE_BRANCH-$suffix"
                break
                ;;
            3)
                echo "⚠️  This will delete the existing branch!"
                read -p "Are you sure? (y/n): " confirm
                if [[ $confirm =~ ^[Yy] ]]; then
                    git branch -D "$FEATURE_BRANCH"
                    echo "✅ Existing branch deleted"
                    break
                else
                    echo "❌ Cancelled"
                fi
                ;;
            4)
                echo "❌ Cancelled"
                exit 1
                ;;
            *)
                echo "❌ Invalid option. Please choose 1-4."
                ;;
        esac
    done
fi

# Create and switch to feature branch
echo ""
echo "🌱 Creating feature branch: $FEATURE_BRANCH"
echo "📍 Based on: $BASE_BRANCH"

git checkout -b "$FEATURE_BRANCH" "$BASE_BRANCH"

# Create initial commit with branch info
echo "📝 Creating initial commit..."
cat > .feature-branch-info <<EOF
Feature Branch: $FEATURE_BRANCH
Base Branch: $BASE_BRANCH
Created: $(date)
Description: $FEATURE_NAME
EOF

git add .feature-branch-info
git commit -m "feat: Create feature branch for $FEATURE_NAME

- Base branch: $BASE_BRANCH
- Created: $(date +%Y-%m-%d\ %H:%M)
- Feature: $FEATURE_NAME"

echo ""
echo "✅ Feature branch created successfully!"
echo "🌿 Current branch: $(git branch --show-current)"
echo ""
echo "💡 Development tips:"
echo "   - Make small, focused commits"
echo "   - Use descriptive commit messages"
echo "   - Test your changes frequently"
echo ""
echo "🔄 When finished:"
echo "   - Use 'git checkout $BASE_BRANCH' to return to base branch"
echo "   - Use 'git merge $FEATURE_BRANCH' to merge changes"
echo "   - Use './scripts/end-day.sh' to end your development session"
echo ""
echo "🚀 Happy coding!"

# Optionally start the application
if [ -f "start.sh" ]; then
    echo ""
    read -p "🚀 Launch the application for development? (y/n): " start_choice
    if [[ $start_choice =~ ^[Yy] ]]; then
        echo "🎯 Launching Job-O-Matic..."
        ./start.sh
    fi
fi