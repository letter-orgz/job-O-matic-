#!/bin/bash
# Simple PR Merge Readiness Checker using GitHub CLI
# Provides basic information about PR readiness

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Job-O-Matic PR Merge Readiness Check${NC}"
echo -e "${CYAN}Repository: letter-orgz/job-O-matic-${NC}"
echo -e "${CYAN}Time: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo "================================================================"

# Check if GitHub CLI is available
if command -v gh &> /dev/null; then
    echo -e "${GREEN}✅ Using GitHub CLI for comprehensive PR analysis${NC}"
    echo ""
    
    # Get all open PRs with detailed info
    echo -e "${YELLOW}📋 Open Pull Requests Analysis:${NC}"
    echo ""
    
    # Check if we can access the repo
    if gh repo view letter-orgz/job-O-matic- --json name >/dev/null 2>&1; then
        # Get PR list with status information
        prs=$(gh pr list --repo letter-orgz/job-O-matic- --json number,title,author,isDraft,mergeable,reviewDecision,statusCheckRollupState,updatedAt --limit 50)
        
        if [ "$prs" = "[]" ]; then
            echo -e "${GREEN}✅ No open pull requests found.${NC}"
        else
            echo "$prs" | jq -r '
            def colorize(condition; color): if condition then color else "" end;
            def reset: "\u001b[0m";
            def green: "\u001b[0;32m";
            def red: "\u001b[0;31m";
            def yellow: "\u001b[1;33m";
            def blue: "\u001b[0;34m";
            
            sort_by(.updatedAt) | reverse | .[] |
            
            # Determine readiness
            (.isDraft == false and .mergeable == "MERGEABLE" and .reviewDecision == "APPROVED" and (.statusCheckRollupState == "SUCCESS" or .statusCheckRollupState == null)) as $ready |
            
            # Build blocking factors
            ([] + 
             (if .isDraft then ["Draft"] else [] end) +
             (if .mergeable == "CONFLICTING" then ["Conflicts"] else [] end) +
             (if .reviewDecision == "CHANGES_REQUESTED" then ["Changes Requested"] else [] end) +
             (if .reviewDecision == null or .reviewDecision == "REVIEW_REQUIRED" then ["Needs Review"] else [] end) +
             (if .statusCheckRollupState == "FAILURE" then ["Checks Failed"] else [] end) +
             (if .statusCheckRollupState == "PENDING" then ["Checks Pending"] else [] end)
            ) as $blocking |
            
            # Output format
            if $ready then
              "\(green)✅ PR #\(.number): \(.title)\(reset)"
            else
              "\(yellow)⚠️  PR #\(.number): \(.title)\(reset)"
            end,
            "   Author: \(.author.login)",
            "   Updated: \(.updatedAt)",
            if ($blocking | length) > 0 then
              "   Blocking: \($blocking | join(", "))"
            else
              "   Status: Ready to merge! 🎉"
            end,
            ""
            '
        fi
        
        # Summary
        echo "================================================================"
        ready_count=$(echo "$prs" | jq '[.[] | select(.isDraft == false and .mergeable == "MERGEABLE" and .reviewDecision == "APPROVED" and (.statusCheckRollupState == "SUCCESS" or .statusCheckRollupState == null))] | length')
        total_count=$(echo "$prs" | jq 'length')
        needs_attention=$((total_count - ready_count))
        
        echo -e "${BLUE}📊 SUMMARY:${NC}"
        echo -e "   ${GREEN}Ready to merge: $ready_count${NC}"
        echo -e "   ${YELLOW}Needs attention: $needs_attention${NC}"
        echo -e "   ${CYAN}Total open: $total_count${NC}"
        
    else
        echo -e "${RED}❌ Cannot access repository. Please check authentication with 'gh auth status'${NC}"
    fi
    
else
    echo -e "${YELLOW}⚠️  GitHub CLI not found. Showing basic information...${NC}"
    echo ""
    echo "To get detailed PR analysis, please install GitHub CLI:"
    echo "  - macOS: brew install gh"
    echo "  - Ubuntu/Debian: sudo apt install gh"
    echo "  - Windows: winget install GitHub.cli"
    echo ""
    echo "Then authenticate with: gh auth login"
    echo ""
    echo -e "${BLUE}💡 Alternative: Use the web interface at:${NC}"
    echo "   https://github.com/letter-orgz/job-O-matic-/pulls"
    echo ""
    echo -e "${BLUE}💡 Or use the Python script with a GitHub token:${NC}"
    echo "   export GITHUB_TOKEN=your_token_here"
    echo "   python3 scripts/check-pr-merge-readiness.py"
fi

echo ""
echo -e "${GREEN}✅ PR readiness check complete!${NC}"

# Suggest next actions
echo ""
echo -e "${BLUE}💡 Suggested Actions:${NC}"
echo "   1. Review PRs marked as ready to merge"
echo "   2. Address blocking factors for PRs needing attention"
echo "   3. Consider setting up branch protection rules"
echo "   4. Run this check regularly as part of your workflow"