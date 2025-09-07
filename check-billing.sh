#!/bin/bash

# Codespace Billing Check Script
# This script helps users understand their Codespace billing attribution

echo "🔍 GitHub Codespace Billing Check"
echo "=================================="
echo ""

# Check if running in Codespace
if [ "$CODESPACES" = "true" ]; then
    echo "✅ Currently running in a GitHub Codespace"
    echo ""
    echo "📋 Codespace Information:"
    echo "  Repository: ${GITHUB_REPOSITORY:-letter-orgz/job-O-matic-}"
    echo "  Codespace Name: ${CODESPACE_NAME:-Unknown}"
    echo "  Organization: ${GITHUB_ORG:-letter-orgz}"
    echo ""
    
    if [ "$GITHUB_ORG" = "letter-orgz" ]; then
        echo "✅ This should be billed to the letter-orgz organization"
    else
        echo "⚠️  Warning: Organization not detected properly"
    fi
    
    echo ""
    echo "🔍 To verify billing:"
    echo "  1. Go to https://github.com/settings/billing"
    echo "  2. Check 'Codespaces' section"
    echo "  3. Look for this Codespace under organization billing"
    echo ""
    echo "❓ If you see charges on your personal account:"
    echo "  📖 Read: .github/CODESPACES_BILLING.md"
    echo "  📧 Contact: @letter-orgz/admins"
    
else
    echo "ℹ️  Not currently running in a Codespace"
    echo ""
    echo "📋 When creating a Codespace:"
    echo "  1. Go to: https://github.com/letter-orgz/job-O-matic-"
    echo "  2. Click 'Code' > 'Codespaces'"
    echo "  3. ⚠️  BEFORE clicking 'Create codespace':"
    echo "     - Check billing attribution shows 'letter-orgz'"
    echo "     - If it shows your username, see billing guide"
    echo ""
    echo "📖 For detailed instructions:"
    echo "  Read: .github/CODESPACES_BILLING.md"
fi

echo ""
echo "🏢 Organization Repository: letter-orgz/job-O-matic-"
echo "📞 Support: Create issue or contact @letter-orgz/admins"
echo "=================================="