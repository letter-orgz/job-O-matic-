#!/usr/bin/env bash
set -euo pipefail

# 🌿 Job-O-Matic Feature Branch Creator
# Create sub-branches for specific features within your daily work

echo "🌿 Job-O-Matic Feature Branch Creator"

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

show_help() {
    cat << EOF
🌿 Job-O-Matic Feature Branch Creator

USAGE:
    $0 <feature-name> [OPTIONS]

ARGUMENTS:
    feature-name               Name of the feature (will be sanitized)

OPTIONS:
    --from=BRANCH             Create branch from specific branch (default: current)
    --prefix=PREFIX           Custom prefix (default: feature/)
    --help                    Show this help message

EXAMPLES:
    $0 fix-cv-upload          Creates: feature/fix-cv-upload
    $0 "Add job filters"      Creates: feature/add-job-filters
    $0 hotfix --prefix=fix/   Creates: fix/hotfix
    $0 ui-update --from=main  Creates feature branch from main instead of current

NAMING:
    - Feature names are automatically sanitized (spaces become dashes, etc.)
    - Common prefixes: feature/, fix/, hotfix/, experiment/
    - Branch will be: prefix/sanitized-feature-name

EOF
}

# Default values
FEATURE_NAME=""
FROM_BRANCH=""
PREFIX="feature/"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --from=*)
            FROM_BRANCH="${1#*=}"
            shift
            ;;
        --prefix=*)
            PREFIX="${1#*=}"
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        -*)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
        *)
            if [ -z "$FEATURE_NAME" ]; then
                FEATURE_NAME="$1"
            else
                log_error "Multiple feature names provided. Use quotes for names with spaces."
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if feature name was provided
if [ -z "$FEATURE_NAME" ]; then
    log_error "Feature name is required"
    echo "Usage: $0 <feature-name>"
    echo "Use --help for more information"
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    log_error "Not in a git repository"
    exit 1
fi

# Sanitize feature name
SANITIZED_NAME=$(echo "$FEATURE_NAME" | \
    tr '[:upper:]' '[:lower:]' | \
    sed 's/[^a-z0-9]/-/g' | \
    sed 's/--*/-/g' | \
    sed 's/^-\|-$//g')

# Create full branch name
BRANCH_NAME="${PREFIX}${SANITIZED_NAME}"

log_info "Feature: $FEATURE_NAME"
log_info "Branch name: $BRANCH_NAME"

# Determine source branch
if [ -z "$FROM_BRANCH" ]; then
    FROM_BRANCH=$(git branch --show-current)
    log_info "Creating from current branch: $FROM_BRANCH"
else
    log_info "Creating from specified branch: $FROM_BRANCH"
    
    # Check if the from branch exists
    if ! git show-ref --verify --quiet "refs/heads/$FROM_BRANCH"; then
        log_error "Source branch '$FROM_BRANCH' does not exist"
        exit 1
    fi
fi

# Check if branch already exists
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    log_warning "Branch '$BRANCH_NAME' already exists"
    read -p "Do you want to switch to it? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        git checkout "$BRANCH_NAME"
        log_success "Switched to existing branch: $BRANCH_NAME"
    fi
    exit 0
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD 2>/dev/null; then
    log_warning "You have uncommitted changes in your working directory"
    git status --short
    echo ""
    read -p "Do you want to stash these changes before creating the branch? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        STASH_NAME="Feature branch stash: $FEATURE_NAME ($(date))"
        git stash push -m "$STASH_NAME"
        log_success "Changes stashed: $STASH_NAME"
    else
        log_info "Continuing with uncommitted changes..."
    fi
fi

# Create and switch to the new branch
log_info "Creating feature branch..."
git checkout -b "$BRANCH_NAME" "$FROM_BRANCH"

log_success "Created and switched to feature branch: $BRANCH_NAME"

# Show current status
echo ""
echo "🎯 Feature Branch Ready!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌿 Branch: $BRANCH_NAME"
echo "📦 Feature: $FEATURE_NAME"
echo "🔗 Based on: $FROM_BRANCH"
echo "📁 Working directory: $(pwd)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 Next steps:"
echo "   📝 Make your changes"
echo "   📦 Commit regularly: git add . && git commit -m 'Your message'"
echo "   🔄 Merge back: git checkout $FROM_BRANCH && git merge $BRANCH_NAME"
echo "   🧹 Cleanup: git branch -d $BRANCH_NAME (after merging)"
echo ""

# Optional: Open editor or IDE
if command -v code >/dev/null 2>&1; then
    read -p "Would you like to open VS Code for this feature? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        code .
    fi
fi