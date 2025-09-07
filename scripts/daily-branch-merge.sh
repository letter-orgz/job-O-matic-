#!/usr/bin/env bash
set -euo pipefail

# End-of-Day Branch Merge Script for Job-O-Matic
# Handles merging completed work back to main branch with proper checks

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
End-of-Day Branch Merge Script

USAGE:
    $0 [OPTIONS] [BRANCH_NAME]

OPTIONS:
    -h, --help          Show this help message
    -n, --dry-run       Show what would be done without executing
    -f, --force         Force merge even with uncommitted changes
    --squash            Use squash merge instead of regular merge
    --no-delete         Don't delete branch after successful merge
    --auto              Auto-detect current daily branch for merging

EXAMPLES:
    $0                           # Merge current branch if it's a daily branch
    $0 --auto                    # Same as above, explicit auto-detection
    $0 feat/2024-01-15-api-fix   # Merge specific branch
    $0 --squash --dry-run        # Preview squash merge of current branch
    $0 --no-delete hotfix-branch # Merge but keep branch

DESCRIPTION:
    Merges completed work from a daily feature branch back to main:
    1. Checks for uncommitted changes
    2. Switches to main branch and pulls latest
    3. Merges the feature branch
    4. Pushes changes to origin
    5. Optionally deletes the merged branch

    Safety checks prevent merging incomplete work.
EOF
}

# Parse command line arguments
DRY_RUN=false
FORCE=false
SQUASH=false
NO_DELETE=false
AUTO_DETECT=true
BRANCH_NAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        --squash)
            SQUASH=true
            shift
            ;;
        --no-delete)
            NO_DELETE=true
            shift
            ;;
        --auto)
            AUTO_DETECT=true
            shift
            ;;
        -*|--*)
            echo -e "${RED}Error: Unknown option $1${NC}" >&2
            echo "Use --help for usage information"
            exit 1
            ;;
        *)
            if [[ -z "$BRANCH_NAME" ]]; then
                BRANCH_NAME="$1"
                AUTO_DETECT=false
            else
                echo -e "${RED}Error: Multiple branch names provided${NC}" >&2
                echo "Use --help for usage information"
                exit 1
            fi
            shift
            ;;
    esac
done

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

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}" >&2
    exit 1
fi

# Auto-detect branch if needed
if [[ "$AUTO_DETECT" == "true" && -z "$BRANCH_NAME" ]]; then
    CURRENT_BRANCH=$(git branch --show-current)
    
    # Check if current branch is a daily branch (feat/YYYY-MM-DD-* pattern)
    if [[ "$CURRENT_BRANCH" =~ ^$DEFAULT_BRANCH_PREFIX/[0-9]{4}-[0-9]{2}-[0-9]{2}-.+ ]]; then
        BRANCH_NAME="$CURRENT_BRANCH"
        echo -e "${BLUE}Auto-detected daily branch:${NC} $BRANCH_NAME"
    else
        echo -e "${RED}Error: Current branch '$CURRENT_BRANCH' is not a daily branch${NC}" >&2
        echo "Daily branches should match pattern: $DEFAULT_BRANCH_PREFIX/YYYY-MM-DD-description"
        echo "Use --help for usage information"
        exit 1
    fi
fi

# Validate branch name
if [[ -z "$BRANCH_NAME" ]]; then
    echo -e "${RED}Error: No branch specified${NC}" >&2
    echo "Use --help for usage information"
    exit 1
fi

# Check if branch exists
if ! git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1; then
    echo -e "${RED}Error: Branch '$BRANCH_NAME' does not exist${NC}" >&2
    exit 1
fi

# Check if main branch exists
if ! git rev-parse --verify "$MAIN_BRANCH" >/dev/null 2>&1; then
    echo -e "${RED}Error: Main branch '$MAIN_BRANCH' does not exist${NC}" >&2
    exit 1
fi

echo -e "${GREEN}🔄 Starting end-of-day merge workflow${NC}"
echo -e "${BLUE}Branch to merge:${NC} $BRANCH_NAME"
echo -e "${BLUE}Target branch:${NC} $MAIN_BRANCH"
echo ""

# Step 1: Switch to the feature branch
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" != "$BRANCH_NAME" ]]; then
    execute_or_show "git checkout $BRANCH_NAME" "Switching to feature branch: $BRANCH_NAME"
fi

# Step 2: Check for uncommitted changes
if [[ "$FORCE" != "true" ]]; then
    if ! git diff --quiet || ! git diff --cached --quiet; then
        echo -e "${RED}Error: You have uncommitted changes${NC}" >&2
        echo ""
        echo "Uncommitted changes:"
        git status --porcelain
        echo ""
        echo "Please commit or stash your changes, or use --force to proceed anyway"
        exit 1
    fi
fi

# Step 3: Push current branch to ensure remote is up to date
execute_or_show "git push origin $BRANCH_NAME" "Pushing current branch to origin"

# Step 4: Switch to main branch
execute_or_show "git checkout $MAIN_BRANCH" "Switching to $MAIN_BRANCH branch"

# Step 5: Pull latest changes
execute_or_show "git pull origin $MAIN_BRANCH" "Pulling latest changes from origin/$MAIN_BRANCH"

# Step 6: Check for conflicts before merging
if [[ "$DRY_RUN" == "false" ]]; then
    # Test merge to check for conflicts
    if ! git merge --no-commit --no-ff "$BRANCH_NAME" >/dev/null 2>&1; then
        # Abort the test merge
        git merge --abort >/dev/null 2>&1 || true
        
        echo -e "${RED}Error: Merge would result in conflicts${NC}" >&2
        echo "Please resolve conflicts manually:"
        echo "1. git merge $BRANCH_NAME"
        echo "2. Resolve conflicts"
        echo "3. git commit"
        echo "4. Re-run this script with --no-delete option"
        exit 1
    else
        # Abort the test merge
        git merge --abort >/dev/null 2>&1 || true
    fi
fi

# Step 7: Perform the actual merge
if [[ "$SQUASH" == "true" ]]; then
    execute_or_show "git merge --squash $BRANCH_NAME" "Performing squash merge of $BRANCH_NAME"
    
    # Create commit message for squash merge
    COMMIT_MSG="Merge daily branch: $BRANCH_NAME

$(git log --oneline $MAIN_BRANCH..$BRANCH_NAME | sed 's/^/- /')"
    
    if [[ "$DRY_RUN" == "false" ]]; then
        git commit -m "$COMMIT_MSG"
        echo -e "${GREEN}✅ Squash merge completed${NC}"
    else
        echo -e "${BLUE}[DRY RUN]${NC} Would create commit with message:"
        echo "$COMMIT_MSG"
    fi
else
    execute_or_show "git merge --no-ff $BRANCH_NAME" "Performing merge of $BRANCH_NAME"
fi

# Step 8: Push merged changes
execute_or_show "git push origin $MAIN_BRANCH" "Pushing merged changes to origin/$MAIN_BRANCH"

# Step 9: Delete the merged branch (if not disabled)
if [[ "$NO_DELETE" != "true" ]]; then
    execute_or_show "git branch -d $BRANCH_NAME" "Deleting local branch: $BRANCH_NAME"
    
    # Check if branch exists on remote before trying to delete
    if [[ "$DRY_RUN" == "false" ]]; then
        if git ls-remote --heads origin "$BRANCH_NAME" | grep -q "$BRANCH_NAME"; then
            execute_or_show "git push origin --delete $BRANCH_NAME" "Deleting remote branch: $BRANCH_NAME"
        fi
    else
        echo -e "${BLUE}[DRY RUN]${NC} Would delete remote branch if it exists: $BRANCH_NAME"
    fi
fi

# Summary
if [[ "$DRY_RUN" == "false" ]]; then
    echo ""
    echo -e "${GREEN}✅ End-of-day merge completed successfully!${NC}"
    echo -e "${BLUE}Current branch:${NC} $(git branch --show-current)"
    echo ""
    echo -e "${YELLOW}📋 Summary:${NC}"
    echo "- Merged: $BRANCH_NAME → $MAIN_BRANCH"
    if [[ "$SQUASH" == "true" ]]; then
        echo "- Type: Squash merge"
    else
        echo "- Type: Regular merge"
    fi
    if [[ "$NO_DELETE" != "true" ]]; then
        echo "- Cleanup: Branch deleted"
    else
        echo "- Cleanup: Branch preserved"
    fi
    echo ""
    echo -e "${YELLOW}🌅 Ready for tomorrow's workflow!${NC}"
    echo "Run: scripts/daily-branch-start.sh <description>"
else
    echo ""
    echo -e "${BLUE}[DRY RUN] End-of-day merge preview completed${NC}"
fi