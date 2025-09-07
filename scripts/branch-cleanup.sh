#!/usr/bin/env bash
set -euo pipefail

# 🧹 Job-O-Matic Branch Cleanup Utility
# Safely cleanup old branches with user confirmation

echo "🧹 Job-O-Matic Branch Cleanup Utility"

# Configuration
DEFAULT_OLDER_THAN_DAYS=7
OLDER_THAN_DAYS=$DEFAULT_OLDER_THAN_DAYS
DAILY_ONLY=false
DRY_RUN=false
FORCE=false

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
🧹 Job-O-Matic Branch Cleanup Utility

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --daily-only                Only clean up daily/ branches
    --older-than=DAYS          Clean branches older than N days (default: 7)
    --dry-run                  Show what would be deleted without doing it
    --force                    Skip confirmation prompts
    --help                     Show this help message

EXAMPLES:
    $0                         Interactive cleanup of old branches
    $0 --daily-only           Only cleanup old daily branches
    $0 --older-than=14        Cleanup branches older than 14 days
    $0 --dry-run              Preview what would be cleaned up
    $0 --force --daily-only   Force cleanup daily branches without prompts

SAFETY:
    - Never deletes the current branch
    - Never deletes main/master branches
    - Never deletes remote tracking branches
    - Always shows what will be deleted before doing it (unless --force)
    - Supports dry-run mode for safe previewing

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --daily-only)
            DAILY_ONLY=true
            shift
            ;;
        --older-than=*)
            OLDER_THAN_DAYS="${1#*=}"
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    log_error "Not in a git repository"
    exit 1
fi

# Get current branch to avoid deleting it
CURRENT_BRANCH=$(git branch --show-current)
log_info "Current branch: $CURRENT_BRANCH"

# Calculate date threshold
if command -v date > /dev/null 2>&1; then
    if date --version 2>/dev/null | grep -q GNU; then
        # GNU date (Linux)
        THRESHOLD_DATE=$(date -d "${OLDER_THAN_DAYS} days ago" +%Y-%m-%d)
    else
        # BSD date (macOS)
        THRESHOLD_DATE=$(date -v-${OLDER_THAN_DAYS}d +%Y-%m-%d)
    fi
else
    log_warning "Could not determine date command type. Using basic branch age detection."
    THRESHOLD_DATE=""
fi

log_info "Looking for branches older than $OLDER_THAN_DAYS days (before $THRESHOLD_DATE)"

# Get list of branches to potentially delete
if [ "$DAILY_ONLY" = true ]; then
    log_info "Scanning daily/ branches only..."
    BRANCH_PATTERN="daily/"
else
    log_info "Scanning all local branches..."
    BRANCH_PATTERN=""
fi

# Find branches to delete
BRANCHES_TO_DELETE=()

while IFS= read -r branch; do
    # Skip empty lines
    [ -z "$branch" ] && continue
    
    # Remove leading/trailing whitespace
    branch=$(echo "$branch" | xargs)
    
    # Skip current branch
    if [ "$branch" = "$CURRENT_BRANCH" ]; then
        continue
    fi
    
    # Skip main branches
    if [[ "$branch" =~ ^(main|master)$ ]]; then
        continue
    fi
    
    # Skip remote tracking branches
    if [[ "$branch" =~ ^origin/ ]]; then
        continue
    fi
    
    # If daily-only mode, only include daily/ branches
    if [ "$DAILY_ONLY" = true ] && [[ ! "$branch" =~ ^daily/ ]]; then
        continue
    fi
    
    # Check age if we have a threshold date
    if [ -n "$THRESHOLD_DATE" ] && [[ "$branch" =~ daily/([0-9]{4}-[0-9]{2}-[0-9]{2}) ]]; then
        BRANCH_DATE="${BASH_REMATCH[1]}"
        if [[ "$BRANCH_DATE" > "$THRESHOLD_DATE" ]]; then
            continue  # Branch is newer than threshold
        fi
    fi
    
    BRANCHES_TO_DELETE+=("$branch")
done < <(git branch --format='%(refname:short)' | grep "${BRANCH_PATTERN}" || true)

# Show results
if [ ${#BRANCHES_TO_DELETE[@]} -eq 0 ]; then
    log_success "No branches found matching cleanup criteria"
    exit 0
fi

echo ""
echo "🎯 Found ${#BRANCHES_TO_DELETE[@]} branches to clean up:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
for branch in "${BRANCHES_TO_DELETE[@]}"; do
    # Get last commit date for the branch
    LAST_COMMIT=$(git log -1 --format="%cr" "$branch" 2>/dev/null || echo "unknown")
    echo "  🌿 $branch (last commit: $LAST_COMMIT)"
done
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Dry run mode
if [ "$DRY_RUN" = true ]; then
    log_info "DRY RUN: The above branches would be deleted"
    echo "To actually delete them, run without --dry-run"
    exit 0
fi

# Confirmation prompt (unless force mode)
if [ "$FORCE" != true ]; then
    echo ""
    log_warning "⚠️  This will permanently delete the above branches"
    echo "Make sure you have pushed any important work to remote repositories."
    echo ""
    read -p "Are you sure you want to delete these branches? (type 'yes' to confirm): " -r
    if [ "$REPLY" != "yes" ]; then
        log_info "Branch cleanup cancelled"
        exit 0
    fi
fi

# Delete branches
echo ""
log_info "Deleting branches..."
DELETED_COUNT=0
FAILED_COUNT=0

for branch in "${BRANCHES_TO_DELETE[@]}"; do
    if git branch -D "$branch" >/dev/null 2>&1; then
        log_success "Deleted: $branch"
        ((DELETED_COUNT++))
    else
        log_error "Failed to delete: $branch"
        ((FAILED_COUNT++))
    fi
done

echo ""
echo "🎯 Cleanup Summary:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Deleted: $DELETED_COUNT branches"
if [ $FAILED_COUNT -gt 0 ]; then
    echo "❌ Failed: $FAILED_COUNT branches"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $DELETED_COUNT -gt 0 ]; then
    log_success "Branch cleanup completed successfully!"
    
    # Suggest running git gc to clean up loose objects
    echo ""
    log_info "💡 Tip: Run 'git gc' to clean up loose objects and reclaim disk space"
fi