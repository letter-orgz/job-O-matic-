#!/usr/bin/env bash
set -euo pipefail

# Start-of-Day Branch Management Script for Job-O-Matic
# Performs daily cleanup: switches to main, pulls changes, creates daily branch, archives old branches

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MAIN_BRANCH="main"
DEFAULT_BRANCH_PREFIX="feat"
ARCHIVE_DAYS=7  # Archive branches older than this many days

# Help message
show_help() {
    cat << EOF
Start-of-Day Branch Management Script

USAGE:
    $0 [OPTIONS] [DESCRIPTION]

OPTIONS:
    -h, --help              Show this help message
    -p, --prefix PREFIX     Use custom prefix for new branch (default: feat)
    -a, --archive-days DAYS Archive branches older than DAYS (default: 7)
    -n, --dry-run           Show what would be done without executing
    --no-archive            Skip archiving old branches
    --no-create             Skip creating new daily branch

EXAMPLES:
    $0 user-auth-fixes              # Full start-of-day workflow
    $0 --dry-run new-feature        # Preview what would happen
    $0 --no-archive api-work        # Skip archiving, just create branch
    $0 --archive-days 3 hotfix      # Archive branches older than 3 days

DESCRIPTION:
    Performs complete start-of-day workflow:
    1. Switch to main branch
    2. Pull latest changes
    3. Archive old daily branches (optional)
    4. Create new daily branch with today's date
    5. Switch to new branch

    This script combines cleanup and setup for a fresh start each day.
EOF
}

# Parse command line arguments
DRY_RUN=false
BRANCH_PREFIX="$DEFAULT_BRANCH_PREFIX"
DESCRIPTION=""
SKIP_ARCHIVE=false
SKIP_CREATE=false
CUSTOM_ARCHIVE_DAYS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -p|--prefix)
            BRANCH_PREFIX="$2"
            shift 2
            ;;
        -a|--archive-days)
            CUSTOM_ARCHIVE_DAYS="$2"
            shift 2
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        --no-archive)
            SKIP_ARCHIVE=true
            shift
            ;;
        --no-create)
            SKIP_CREATE=true
            shift
            ;;
        -*|--*)
            echo -e "${RED}Error: Unknown option $1${NC}" >&2
            echo "Use --help for usage information"
            exit 1
            ;;
        *)
            if [[ -z "$DESCRIPTION" ]]; then
                DESCRIPTION="$1"
            else
                echo -e "${RED}Error: Multiple descriptions provided${NC}" >&2
                echo "Use --help for usage information"
                exit 1
            fi
            shift
            ;;
    esac
done

# Set archive days
if [[ -n "$CUSTOM_ARCHIVE_DAYS" ]]; then
    if ! [[ "$CUSTOM_ARCHIVE_DAYS" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Error: Archive days must be a number${NC}" >&2
        exit 1
    fi
    ARCHIVE_DAYS="$CUSTOM_ARCHIVE_DAYS"
fi

# Function to execute or show command
execute_or_show() {
    local cmd="$1"
    local description="$2"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${BLUE}[DRY RUN]${NC} $description"
        echo -e "${YELLOW}Command:${NC} $cmd"
    else
        echo -e "${BLUE}→${NC} $description"
        if ! eval "$cmd"; then
            echo -e "${RED}Error: Failed to execute: $cmd${NC}" >&2
            return 1
        fi
    fi
}

# Function to show or list items
show_or_list() {
    local items="$1"
    local description="$2"
    local count=$(echo -n "$items" | grep -c '^' || echo "0")
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${BLUE}[DRY RUN]${NC} $description (found $count items)"
        if [[ $count -gt 0 ]]; then
            echo "$items" | sed 's/^/  - /'
        fi
    else
        echo -e "${BLUE}→${NC} $description (found $count items)"
        if [[ $count -gt 0 ]]; then
            echo "$items" | sed 's/^/  - /'
        fi
    fi
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}" >&2
    exit 1
fi

# Check if main branch exists
if ! git rev-parse --verify "$MAIN_BRANCH" >/dev/null 2>&1; then
    echo -e "${RED}Error: Main branch '$MAIN_BRANCH' does not exist${NC}" >&2
    exit 1
fi

echo -e "${GREEN}🌅 Starting daily branch management workflow${NC}"
echo ""

# Step 1: Switch to main branch
execute_or_show "git checkout $MAIN_BRANCH" "Switching to $MAIN_BRANCH branch"

# Step 2: Pull latest changes
execute_or_show "git pull origin $MAIN_BRANCH" "Pulling latest changes from origin/$MAIN_BRANCH"

# Step 3: Archive old branches (if not skipped)
if [[ "$SKIP_ARCHIVE" != "true" ]]; then
    echo ""
    echo -e "${YELLOW}📦 Archiving old daily branches...${NC}"
    
    # Find old daily branches (feat/YYYY-MM-DD-* pattern older than ARCHIVE_DAYS)
    CUTOFF_DATE=$(date -d "$ARCHIVE_DAYS days ago" +%Y-%m-%d)
    
    # Get all daily branches matching pattern
    OLD_BRANCHES=$(git branch -a | grep -E "^\s*(remotes/origin/)?$BRANCH_PREFIX/[0-9]{4}-[0-9]{2}-[0-9]{2}-" | sed 's/^\s*\(remotes\/origin\/\)\?//' | sort -u || echo "")
    
    BRANCHES_TO_ARCHIVE=""
    if [[ -n "$OLD_BRANCHES" ]]; then
        while IFS= read -r branch; do
            # Extract date from branch name
            branch_date=$(echo "$branch" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)
            if [[ -n "$branch_date" && "$branch_date" < "$CUTOFF_DATE" ]]; then
                BRANCHES_TO_ARCHIVE="${BRANCHES_TO_ARCHIVE}${branch}\n"
            fi
        done <<< "$OLD_BRANCHES"
    fi
    
    if [[ -n "$BRANCHES_TO_ARCHIVE" ]]; then
        BRANCHES_TO_ARCHIVE=$(echo -e "$BRANCHES_TO_ARCHIVE" | grep -v '^$')
        show_or_list "$BRANCHES_TO_ARCHIVE" "Found old branches to archive (older than $CUTOFF_DATE)"
        
        # Archive each branch
        while IFS= read -r branch; do
            if [[ -n "$branch" ]]; then
                # Check if branch exists locally
                if git rev-parse --verify "$branch" >/dev/null 2>&1; then
                    execute_or_show "git branch -D $branch" "Deleting local branch: $branch"
                fi
                
                # Check if branch exists on remote
                if git ls-remote --heads origin "$branch" | grep -q "$branch"; then
                    execute_or_show "git push origin --delete $branch" "Deleting remote branch: $branch"
                fi
            fi
        done <<< "$BRANCHES_TO_ARCHIVE"
    else
        echo -e "${BLUE}→${NC} No old branches found to archive"
    fi
fi

# Step 4: Create new daily branch (if not skipped and description provided)
if [[ "$SKIP_CREATE" != "true" && -n "$DESCRIPTION" ]]; then
    echo ""
    echo -e "${YELLOW}🌱 Creating today's daily branch...${NC}"
    
    TODAY=$(date +%Y-%m-%d)
    CLEAN_DESCRIPTION=$(echo "$DESCRIPTION" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
    NEW_BRANCH="${BRANCH_PREFIX}/${TODAY}-${CLEAN_DESCRIPTION}"
    
    # Check if branch already exists
    if git rev-parse --verify "$NEW_BRANCH" >/dev/null 2>&1; then
        echo -e "${YELLOW}Warning: Branch '$NEW_BRANCH' already exists${NC}"
        execute_or_show "git checkout $NEW_BRANCH" "Switching to existing branch: $NEW_BRANCH"
    else
        execute_or_show "git checkout -b $NEW_BRANCH" "Creating and switching to new branch: $NEW_BRANCH"
    fi
elif [[ "$SKIP_CREATE" != "true" ]]; then
    echo ""
    echo -e "${YELLOW}ℹ️  No description provided, skipping branch creation${NC}"
    echo "To create a daily branch, run: scripts/daily-branch-create.sh <description>"
fi

# Summary
if [[ "$DRY_RUN" == "false" ]]; then
    echo ""
    echo -e "${GREEN}✅ Start-of-day workflow completed!${NC}"
    echo -e "${BLUE}Current branch:${NC} $(git branch --show-current)"
    
    if [[ "$SKIP_CREATE" != "true" && -n "$DESCRIPTION" ]]; then
        echo ""
        echo -e "${YELLOW}📋 Next steps:${NC}"
        echo "1. Start working on your feature"
        echo "2. Make commits as usual"
        echo "3. At end of day, run: scripts/daily-branch-merge.sh"
    fi
else
    echo ""
    echo -e "${BLUE}[DRY RUN] Start-of-day workflow preview completed${NC}"
fi