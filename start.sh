#!/bin/bash
# Job-O-Matic Startup Script for Codespaces
# Enhanced with Git Workflow Management
#
# Usage:
#   ./start.sh                    # Normal startup with git workflow
#   ./start.sh --force-interactive # Force interactive mode for testing
#   ./start.sh --help             # Show this help
#
# Features:
#   - Detects if on correct daily branch (daily/YYYY-MM-DD)
#   - Auto-creates daily branch if needed
#   - Pulls latest changes from main/master
#   - Sets up git aliases and config
#   - Displays current branch status
#   - Works in both Codespaces and local development

if [ "$1" = "--help" ]; then
    echo "Job-O-Matic Startup Script with Git Workflow"
    echo ""
    echo "Usage:"
    echo "  ./start.sh                     # Normal startup with git workflow"
    echo "  ./start.sh --force-interactive # Force interactive mode"
    echo "  ./start.sh --help              # Show this help"
    echo ""
    echo "Features:"
    echo "  - Automatic daily branch management (daily/YYYY-MM-DD)"
    echo "  - Git workflow integration with main/master sync"
    echo "  - Codespace and local development support"
    echo "  - Interactive and non-interactive modes"
    echo "  - Dependency management and validation"
    echo ""
    echo "Git Workflow:"
    echo "  - Creates daily branch if not exists"
    echo "  - Pulls latest changes from main/master"
    echo "  - Sets up git configuration and aliases"
    echo "  - Shows current repository status"
    echo ""
    exit 0
fi

echo "🎯 Starting Job-O-Matic..."

# Check if we're in the right directory
if [ ! -f "app.py" ]; then
    echo "❌ Error: app.py not found in current directory"
    echo "Please make sure you're running this script from the job-O-matic root directory"
    exit 1
fi

# Function to get today's daily branch name
get_daily_branch_name() {
    echo "daily/$(date +%Y-%m-%d)"
}

# Function to check if we're on the correct daily branch
check_daily_branch() {
    local current_branch=$(git branch --show-current 2>/dev/null)
    local expected_branch=$(get_daily_branch_name)
    
    if [ "$current_branch" = "$expected_branch" ]; then
        return 0
    else
        return 1
    fi
}

# Function to create daily branch
create_daily_branch() {
    local daily_branch=$(get_daily_branch_name)
    local base_branch="main"
    
    echo "🌿 Creating daily branch: $daily_branch"
    
    # Determine the base branch (main or master)
    if git show-ref --verify --quiet refs/remotes/origin/main; then
        base_branch="origin/main"
    elif git show-ref --verify --quiet refs/remotes/origin/master; then
        base_branch="origin/master"
    else
        base_branch=$(git branch --show-current)
        echo "ℹ️  No main/master branch found, using current branch: $base_branch"
    fi
    
    # Switch to base branch and pull latest changes if it's a main branch
    if [[ "$base_branch" =~ ^(main|master|origin/main|origin/master)$ ]]; then
        echo "🔄 Switching to base branch: $base_branch"
        if git checkout "${base_branch#origin/}"; then
            echo "📥 Pulling latest changes from $base_branch..."
            if ! git pull origin "${base_branch#origin/}"; then
                echo "⚠️  Warning: Could not pull from remote (possibly offline)"
                echo "   Using local branch..."
            fi
        else
            echo "❌ Error: Could not switch to $base_branch"
            echo "   Using current branch as base"
        fi
    else
        echo "ℹ️  Using current branch as base: $base_branch"
    fi
    
    # Create and switch to daily branch
    if git checkout -b "$daily_branch"; then
        echo "✅ Successfully created and switched to $daily_branch"
        return 0
    else
        echo "❌ Error: Could not create daily branch"
        echo "   Continuing with current branch: $(git branch --show-current)"
        return 1
    fi
}

# Function to setup git configuration
setup_git_config() {
    # Set up useful git aliases if they don't exist
    git config --global alias.st status 2>/dev/null || true
    git config --global alias.co checkout 2>/dev/null || true
    git config --global alias.br branch 2>/dev/null || true
    git config --global alias.lg "log --oneline --graph --decorate" 2>/dev/null || true
    
    # Set default branch behavior
    git config --global init.defaultBranch main 2>/dev/null || true
    git config --global pull.rebase false 2>/dev/null || true
}

# Function to display git status information
display_git_status() {
    echo ""
    echo "📊 Git Repository Status"
    echo "======================="
    echo "🌿 Current branch: $(git branch --show-current 2>/dev/null || echo 'Unknown')"
    echo "📁 Repository: $(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo 'Unknown')"
    
    # Check working directory status
    if git diff --quiet && git diff --cached --quiet; then
        echo "✅ Working directory clean"
    else
        echo "📝 Working directory has changes:"
        git status --porcelain | head -10
        if [ $(git status --porcelain | wc -l) -gt 10 ]; then
            echo "... and more (use 'git status' for full list)"
        fi
    fi
    
    # Show last commit
    echo "📌 Last commit: $(git log -1 --pretty=format:'%h - %s (%cr)' 2>/dev/null || echo 'No commits found')"
    
    # Check if ahead/behind remote
    if git remote | grep -q origin; then
        local status=$(git status --porcelain=v1 --branch | head -1)
        if echo "$status" | grep -q "ahead"; then
            echo "⬆️  Ahead of remote (unpushed commits)"
        elif echo "$status" | grep -q "behind"; then
            echo "⬇️  Behind remote (need to pull)"
        fi
    fi
    
    echo "====================="
    echo ""
}

# Function to manage daily branch workflow
manage_git_workflow() {
    echo ""
    echo "🔧 Git Workflow Management"
    echo "=========================="
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "❌ Error: Not in a git repository"
        echo "   Git workflow management skipped"
        return 1
    fi
    
    # Setup git configuration
    setup_git_config
    
    # Display current status
    display_git_status
    
    # Check if we're on the correct daily branch
    if ! check_daily_branch; then
        echo ""
        echo "❓ Would you like to switch to today's daily branch? (y/N)"
        read -r response
        case "$response" in
            [yY]|[yY][eE][sS])
                if create_daily_branch; then
                    echo "✅ Successfully set up daily branch workflow"
                else
                    echo "⚠️  Continuing with current branch"
                fi
                ;;
            *)
                echo "ℹ️  Staying on current branch: $(git branch --show-current)"
                ;;
        esac
    else
        echo "✅ Already on today's daily branch: $(get_daily_branch_name)"
    fi
    
    # Final status display
    display_git_status
}

# Detect if running in interactive mode
if [ -t 0 ] && [ -t 1 ] && [ "$1" != "--force-interactive" ]; then
    # Interactive terminal detected
    manage_git_workflow
elif [ "$1" = "--force-interactive" ]; then
    echo "🔧 Forcing interactive mode for testing..."
    manage_git_workflow
else
    echo "🤖 Non-interactive mode detected, skipping git workflow prompts"
    if git rev-parse --git-dir >/dev/null 2>&1; then
        setup_git_config
        display_git_status
    fi
fi

# Display billing information if in Codespace
if [ "$CODESPACES" = "true" ]; then
    echo ""
    echo "💳 Codespace Billing Information:"
    echo "  Repository: letter-orgz/job-O-matic-"
    echo "  This Codespace should be billed to letter-orgz organization"
    echo ""
    echo "🚨 BILLING ISSUE WARNING:"
    echo "  If you are v4mpire77: Check .github/BILLING_RESOLUTION_GUIDE.md"
    echo "  If you see personal charges: run ./check-billing.sh"
    echo ""
fi

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: python3 not found"
    echo "Please install Python 3.11+ and try again"
    exit 1
fi

# Check if streamlit is installed
if ! command -v streamlit &> /dev/null; then
    echo "⚠️  Warning: streamlit not found in PATH"
    echo "📦 Installing dependencies from requirements.txt..."
    
    if [ -f "requirements.txt" ]; then
        if pip3 install -r requirements.txt; then
            echo "✅ Dependencies installed successfully"
        else
            echo "❌ Error: Failed to install dependencies"
            echo "Please run: pip3 install -r requirements.txt"
            exit 1
        fi
    else
        echo "❌ Error: requirements.txt not found"
        echo "Please install streamlit manually: pip3 install streamlit"
        exit 1
    fi
fi

# Check if running in Codespaces
if [ "$CODESPACES" = "true" ]; then
    echo "📡 Running in GitHub Codespaces"
    # Start Streamlit with Codespace-friendly settings
    streamlit run app.py --server.headless true --server.port 8501 --server.address 0.0.0.0
else
    echo "💻 Running locally"
    # Start Streamlit normally
    streamlit run app.py
fi