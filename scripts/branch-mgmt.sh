#!/usr/bin/env bash
set -euo pipefail

# Branch Management CLI - Convenience wrapper for daily branch management
# Provides easy access to all branch management commands

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Help message
show_help() {
    cat << EOF
${GREEN}🌿 Branch Management CLI${NC}

${CYAN}USAGE:${NC}
    $0 COMMAND [OPTIONS] [ARGS]

${CYAN}COMMANDS:${NC}
    ${YELLOW}start${NC} [description]         Start-of-day workflow with cleanup + new branch
    ${YELLOW}create${NC} [description]        Create new daily branch only
    ${YELLOW}merge${NC} [branch]              End-of-day merge workflow
    ${YELLOW}status${NC}                      Show current branch status and info
    ${YELLOW}list${NC}                        List all daily branches
    ${YELLOW}cleanup${NC}                     Manual cleanup of old branches
    ${YELLOW}help${NC}                        Show this help message

${CYAN}EXAMPLES:${NC}
    $0 start user-authentication    # Full start-of-day workflow
    $0 create api-improvements      # Just create today's branch
    $0 merge                        # Merge current daily branch
    $0 status                       # Check current status
    $0 list                         # Show all daily branches
    $0 cleanup --dry-run            # Preview cleanup actions

${CYAN}GLOBAL OPTIONS:${NC}
    -h, --help                      Show help for any command
    -n, --dry-run                   Preview actions without executing
    -v, --verbose                   Show detailed output

${CYAN}DOCUMENTATION:${NC}
    📖 Full documentation: docs/BRANCH_MANAGEMENT.md
    🔧 Script help: $0 COMMAND --help

${CYAN}QUICK REFERENCE:${NC}
    Daily branches follow format: ${YELLOW}feat/YYYY-MM-DD-description${NC}
    
    ${GREEN}Morning:${NC}  $0 start <description>
    ${GREEN}Evening:${NC}  $0 merge
    ${GREEN}Status:${NC}   $0 status
EOF
}

# Function to show current branch status
show_status() {
    echo -e "${GREEN}📊 Branch Status${NC}"
    echo ""
    
    # Current branch
    CURRENT_BRANCH=$(git branch --show-current)
    echo -e "${BLUE}Current branch:${NC} $CURRENT_BRANCH"
    
    # Check if it's a daily branch
    if [[ "$CURRENT_BRANCH" =~ ^(feat|fix|hotfix)/[0-9]{4}-[0-9]{2}-[0-9]{2}-.+ ]]; then
        BRANCH_DATE=$(echo "$CURRENT_BRANCH" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
        CURRENT_DATE=$(date +%Y-%m-%d)
        
        if [[ "$BRANCH_DATE" == "$CURRENT_DATE" ]]; then
            echo -e "${GREEN}✅ Working on today's daily branch${NC}"
        else
            DAYS_OLD=$(( ($(date -d "$CURRENT_DATE" +%s) - $(date -d "$BRANCH_DATE" +%s)) / 86400 ))
            echo -e "${YELLOW}⚠️  Working on $DAYS_OLD day(s) old branch${NC}"
        fi
    else
        echo -e "${YELLOW}ℹ️  Not on a daily branch${NC}"
    fi
    
    # Git status
    echo ""
    echo -e "${BLUE}Git status:${NC}"
    git status --porcelain | head -10 | sed 's/^/  /'
    
    if [[ $(git status --porcelain | wc -l) -gt 10 ]]; then
        echo "  ... (and $(( $(git status --porcelain | wc -l) - 10 )) more files)"
    fi
    
    if [[ -z "$(git status --porcelain)" ]]; then
        echo -e "  ${GREEN}✅ Working directory clean${NC}"
    fi
    
    # Remote status
    echo ""
    echo -e "${BLUE}Remote status:${NC}"
    
    # Check if branch exists on remote
    if git ls-remote --heads origin "$CURRENT_BRANCH" | grep -q "$CURRENT_BRANCH"; then
        # Check if local is ahead/behind
        LOCAL=$(git rev-parse @)
        REMOTE=$(git rev-parse @{u} 2>/dev/null || echo "")
        
        if [[ -n "$REMOTE" ]]; then
            if [[ "$LOCAL" == "$REMOTE" ]]; then
                echo -e "  ${GREEN}✅ Up to date with origin${NC}"
            else
                BASE=$(git merge-base @ @{u} 2>/dev/null || echo "")
                if [[ "$LOCAL" == "$BASE" ]]; then
                    echo -e "  ${YELLOW}⬇️  Behind origin (pull needed)${NC}"
                elif [[ "$REMOTE" == "$BASE" ]]; then
                    echo -e "  ${YELLOW}⬆️  Ahead of origin (push needed)${NC}"
                else
                    echo -e "  ${RED}🔀 Diverged from origin${NC}"
                fi
            fi
        else
            echo -e "  ${YELLOW}⬆️  Local branch not tracking remote${NC}"
        fi
    else
        echo -e "  ${YELLOW}📤 Branch not pushed to remote${NC}"
    fi
}

# Function to list daily branches
list_branches() {
    echo -e "${GREEN}📋 Daily Branches${NC}"
    echo ""
    
    # Get all daily branches
    ALL_BRANCHES=$(git branch -a | grep -E '(feat|fix|hotfix)/[0-9]{4}-[0-9]{2}-[0-9]{2}-' | sed 's/^\s*\(remotes\/origin\/\)\?//' | sort -u || echo "")
    
    if [[ -z "$ALL_BRANCHES" ]]; then
        echo -e "${YELLOW}No daily branches found${NC}"
        return
    fi
    
    CURRENT_BRANCH=$(git branch --show-current)
    TODAY=$(date +%Y-%m-%d)
    
    echo -e "${BLUE}Local and remote daily branches:${NC}"
    while IFS= read -r branch; do
        if [[ -n "$branch" ]]; then
            # Extract date
            BRANCH_DATE=$(echo "$branch" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
            
            # Calculate age
            DAYS_OLD=$(( ($(date -d "$TODAY" +%s) - $(date -d "$BRANCH_DATE" +%s)) / 86400 ))
            
            # Format output
            if [[ "$branch" == "$CURRENT_BRANCH" ]]; then
                PREFIX="${GREEN}→${NC}"
            else
                PREFIX=" "
            fi
            
            if [[ $DAYS_OLD -eq 0 ]]; then
                AGE_COLOR="${GREEN}"
                AGE_TEXT="today"
            elif [[ $DAYS_OLD -le 3 ]]; then
                AGE_COLOR="${YELLOW}"
                AGE_TEXT="${DAYS_OLD} day(s) old"
            else
                AGE_COLOR="${RED}"
                AGE_TEXT="${DAYS_OLD} day(s) old"
            fi
            
            echo -e "$PREFIX $branch ${AGE_COLOR}($AGE_TEXT)${NC}"
        fi
    done <<< "$ALL_BRANCHES"
}

# Function to cleanup old branches
cleanup_branches() {
    local dry_run_flag=""
    
    # Parse cleanup-specific options
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--dry-run)
                dry_run_flag="--dry-run"
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    
    echo -e "${GREEN}🧹 Cleaning up old branches${NC}"
    echo ""
    
    # Use the start script's cleanup functionality
    "$SCRIPT_DIR/daily-branch-start.sh" --no-create $dry_run_flag
}

# Parse global options
DRY_RUN=false
VERBOSE=false

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
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -*)
            echo -e "${RED}Error: Unknown global option $1${NC}" >&2
            echo "Use --help for usage information"
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

# Check for command
if [[ $# -eq 0 ]]; then
    show_help
    exit 0
fi

COMMAND="$1"
shift

# Prepare common flags
COMMON_FLAGS=""
if [[ "$DRY_RUN" == "true" ]]; then
    COMMON_FLAGS="$COMMON_FLAGS --dry-run"
fi

# Execute command
case "$COMMAND" in
    start)
        echo -e "${GREEN}🌅 Starting daily workflow...${NC}"
        echo ""
        "$SCRIPT_DIR/daily-branch-start.sh" $COMMON_FLAGS "$@"
        ;;
    
    create)
        echo -e "${GREEN}🌱 Creating daily branch...${NC}"
        echo ""
        "$SCRIPT_DIR/daily-branch-create.sh" $COMMON_FLAGS "$@"
        ;;
    
    merge)
        echo -e "${GREEN}🔄 Merging daily branch...${NC}"
        echo ""
        "$SCRIPT_DIR/daily-branch-merge.sh" $COMMON_FLAGS "$@"
        ;;
    
    status)
        show_status
        ;;
    
    list)
        list_branches
        ;;
    
    cleanup)
        cleanup_branches $COMMON_FLAGS "$@"
        ;;
    
    help)
        if [[ $# -gt 0 ]]; then
            # Show help for specific command
            case "$1" in
                start)
                    "$SCRIPT_DIR/daily-branch-start.sh" --help
                    ;;
                create)
                    "$SCRIPT_DIR/daily-branch-create.sh" --help
                    ;;
                merge)
                    "$SCRIPT_DIR/daily-branch-merge.sh" --help
                    ;;
                *)
                    echo -e "${RED}Unknown command: $1${NC}" >&2
                    show_help
                    exit 1
                    ;;
            esac
        else
            show_help
        fi
        ;;
    
    *)
        echo -e "${RED}Error: Unknown command '$COMMAND'${NC}" >&2
        echo ""
        show_help
        exit 1
        ;;
esac