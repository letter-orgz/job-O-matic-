#!/usr/bin/env bash
set -euo pipefail

# 🎯 Job-O-Matic Daily Development Setup Script
# This script sets up a clean development environment for each day's work

echo "🌅 Starting Job-O-Matic Daily Setup..."

# Configuration
DEFAULT_MAIN_BRANCH="main"
DATE_FORMAT=$(date +"%Y-%m-%d")
DAILY_BRANCH="daily/${DATE_FORMAT}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    log_error "Not in a git repository. Please run this script from the job-O-matic root directory."
    exit 1
fi

# Get the main branch name (could be 'main' or 'master')
MAIN_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "$DEFAULT_MAIN_BRANCH")

log_info "Using main branch: $MAIN_BRANCH"

# Check if we have any uncommitted changes
if ! git diff-index --quiet HEAD 2>/dev/null; then
    log_warning "You have uncommitted changes in your working directory."
    echo "Current status:"
    git status --short
    echo ""
    read -p "Do you want to stash these changes? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git stash push -m "Daily setup stash $(date)"
        log_success "Changes stashed successfully"
    else
        log_warning "Continuing with uncommitted changes..."
    fi
fi

# Switch to main branch and update
log_info "Switching to $MAIN_BRANCH branch and updating..."
git checkout "$MAIN_BRANCH" 2>/dev/null || {
    log_warning "$MAIN_BRANCH branch not found locally. Fetching from origin..."
    git fetch origin
    git checkout -b "$MAIN_BRANCH" "origin/$MAIN_BRANCH" 2>/dev/null || {
        log_error "Could not create or switch to $MAIN_BRANCH branch"
        exit 1
    }
}

# Pull latest changes
git pull origin "$MAIN_BRANCH" || {
    log_warning "Could not pull latest changes. Continuing anyway..."
}

# Check if today's branch already exists
if git show-ref --verify --quiet "refs/heads/$DAILY_BRANCH"; then
    log_warning "Today's branch '$DAILY_BRANCH' already exists."
    read -p "Do you want to switch to it? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        git checkout "$DAILY_BRANCH"
        log_success "Switched to existing daily branch: $DAILY_BRANCH"
    fi
else
    # Create today's branch
    log_info "Creating today's branch: $DAILY_BRANCH"
    git checkout -b "$DAILY_BRANCH"
    log_success "Created and switched to daily branch: $DAILY_BRANCH"
fi

# Optional: Clean up old daily branches (older than 7 days)
log_info "Checking for old daily branches to clean up..."
OLD_BRANCHES=$(git for-each-ref --format='%(refname:short)' refs/heads/daily/ | grep -E 'daily/[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -20 || true)

if [ -n "$OLD_BRANCHES" ]; then
    echo "Found old daily branches:"
    echo "$OLD_BRANCHES"
    echo ""
    read -p "Would you like to clean up old daily branches (older than 7 days)? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./scripts/branch-cleanup.sh --daily-only --older-than=7
    fi
fi

# Ensure required directories exist
log_info "Ensuring required directories exist..."
mkdir -p data/cv data/templates exports outputs
log_success "Directories created/verified"

# Install/update dependencies if needed
if [ -f "requirements.txt" ]; then
    log_info "Checking Python dependencies..."
    if command -v pip &> /dev/null; then
        pip install -r requirements.txt --quiet
        log_success "Dependencies up to date"
    else
        log_warning "pip not found. Skipping dependency check."
    fi
fi

# Show current status
echo ""
echo "🎯 Daily Setup Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📅 Date: $(date)"
echo "🌿 Current branch: $(git branch --show-current)"
echo "📁 Working directory: $(pwd)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 Quick commands:"
echo "   🚀 Start app: ./start.sh"
echo "   🌿 New feature: ./scripts/new-feature.sh <feature-name>"
echo "   🧹 Cleanup: ./scripts/branch-cleanup.sh"
echo "   📊 Status: git status"
echo ""

# Optional: Auto-start the application
read -p "Would you like to start the Job-O-Matic application now? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    log_info "Starting Job-O-Matic application..."
    if [ -f "./start.sh" ]; then
        ./start.sh
    else
        streamlit run app.py
    fi
fi