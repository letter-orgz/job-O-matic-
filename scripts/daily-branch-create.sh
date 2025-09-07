#!/usr/bin/env bash
set -euo pipefail

# Daily Branch Creation Script for Job-O-Matic
# Creates daily feature branches with consistent naming: feat/YYYY-MM-DD-description

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MAIN_BRANCH="main"
DEFAULT_BRANCH_PREFIX="feat"

# Help message
show_help() {
    cat << EOF
Daily Branch Creation Script

USAGE:
    $0 [OPTIONS] [DESCRIPTION]

OPTIONS:
    -h, --help          Show this help message
    -d, --date DATE     Use specific date (YYYY-MM-DD format)
    -p, --prefix PREFIX Use custom prefix (default: feat)
    -n, --dry-run       Show what would be done without executing
    -f, --force         Force creation even if branch exists

EXAMPLES:
    $0 user-authentication           # Creates: feat/2024-01-15-user-authentication
    $0 --date 2024-01-20 api-fixes  # Creates: feat/2024-01-20-api-fixes
    $0 --prefix hotfix bug-fix       # Creates: hotfix/2024-01-15-bug-fix
    $0 --dry-run new-feature         # Shows what would be created

DESCRIPTION:
    Creates a new daily branch with format: PREFIX/YYYY-MM-DD-DESCRIPTION
    Automatically switches to main branch, pulls latest changes, then creates
    and switches to the new branch.
EOF
}

# Parse command line arguments
DRY_RUN=false
FORCE=false
CUSTOM_DATE=""
BRANCH_PREFIX="$DEFAULT_BRANCH_PREFIX"
DESCRIPTION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -d|--date)
            CUSTOM_DATE="$2"
            shift 2
            ;;
        -p|--prefix)
            BRANCH_PREFIX="$2"
            shift 2
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -f|--force)
            FORCE=true
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

# Validate description
if [[ -z "$DESCRIPTION" ]]; then
    echo -e "${RED}Error: Description is required${NC}" >&2
    echo "Use --help for usage information"
    exit 1
fi

# Validate and format date
if [[ -n "$CUSTOM_DATE" ]]; then
    if ! date -d "$CUSTOM_DATE" >/dev/null 2>&1; then
        echo -e "${RED}Error: Invalid date format. Use YYYY-MM-DD${NC}" >&2
        exit 1
    fi
    BRANCH_DATE="$CUSTOM_DATE"
else
    BRANCH_DATE=$(date +%Y-%m-%d)
fi

# Clean up description (replace spaces and special chars with hyphens)
CLEAN_DESCRIPTION=$(echo "$DESCRIPTION" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')

# Generate branch name
BRANCH_NAME="${BRANCH_PREFIX}/${BRANCH_DATE}-${CLEAN_DESCRIPTION}"

# Function to execute or show command
execute_or_show() {
    local cmd="$1"
    local description="$2"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${BLUE}[DRY RUN]${NC} $description"
        echo -e "${YELLOW}Command:${NC} $cmd"
    else
        echo -e "${BLUE}→${NC} $description"
        eval "$cmd"
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

# Check if branch already exists
if git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1; then
    if [[ "$FORCE" != "true" ]]; then
        echo -e "${RED}Error: Branch '$BRANCH_NAME' already exists${NC}" >&2
        echo "Use --force to override or choose a different description"
        exit 1
    else
        echo -e "${YELLOW}Warning: Branch '$BRANCH_NAME' already exists, will force checkout${NC}"
    fi
fi

echo -e "${GREEN}Creating daily branch: $BRANCH_NAME${NC}"
echo ""

# Step 1: Switch to main branch
execute_or_show "git checkout $MAIN_BRANCH" "Switching to $MAIN_BRANCH branch"

# Step 2: Pull latest changes
execute_or_show "git pull origin $MAIN_BRANCH" "Pulling latest changes from origin/$MAIN_BRANCH"

# Step 3: Create and switch to new branch
if git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1 && [[ "$FORCE" == "true" ]]; then
    execute_or_show "git checkout $BRANCH_NAME" "Switching to existing branch $BRANCH_NAME"
else
    execute_or_show "git checkout -b $BRANCH_NAME" "Creating and switching to new branch $BRANCH_NAME"
fi

if [[ "$DRY_RUN" == "false" ]]; then
    echo ""
    echo -e "${GREEN}✅ Daily branch created successfully!${NC}"
    echo -e "${BLUE}Current branch:${NC} $(git branch --show-current)"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Start working on your feature"
    echo "2. Make commits as usual"
    echo "3. At end of day, run: scripts/daily-branch-merge.sh"
    echo ""
else
    echo ""
    echo -e "${BLUE}[DRY RUN] Would create branch: $BRANCH_NAME${NC}"
fi