#!/bin/bash
# PR Merge Readiness Checker - Shell Wrapper
# Quick script to check which PRs can be merged

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Job-O-Matic PR Merge Readiness Checker${NC}"
echo ""

# Check if GitHub token is available
if [ -z "${GITHUB_TOKEN:-}" ]; then
    echo -e "${YELLOW}⚠️  No GITHUB_TOKEN found. API rate limits will be more restrictive.${NC}"
    echo "   To get higher rate limits, set GITHUB_TOKEN environment variable."
    echo ""
fi

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 is required but not found.${NC}"
    exit 1
fi

# Check if requests module is available
if ! python3 -c "import requests" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Python 'requests' module not found. Installing...${NC}"
    pip3 install requests --user
fi

# Change to script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# Run the Python script
echo -e "${GREEN}Running PR merge readiness check...${NC}"
echo ""

python3 scripts/check-pr-merge-readiness.py

# Check if report was generated
if [ -d "reports" ] && [ "$(ls -A reports 2>/dev/null)" ]; then
    echo ""
    echo -e "${GREEN}📊 Detailed reports available in the 'reports' directory:${NC}"
    ls -la reports/pr-merge-readiness-*.json 2>/dev/null | tail -3 || true
fi

echo ""
echo -e "${BLUE}✅ PR merge readiness check complete!${NC}"