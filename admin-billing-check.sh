#!/bin/bash

# Organization Admin Billing Setup Verification Script
# Run this after configuring organization Codespaces settings

echo "🏢 Letter-orgz Organization Codespace Billing Verification"
echo "========================================================="
echo ""

echo "🔍 Checking repository configuration..."
echo ""

# Check if this is the correct repository
if [[ "$(basename "$(pwd)")" == "job-O-matic-" ]]; then
    echo "✅ Running in correct repository: job-O-matic-"
else
    echo "❌ Warning: Not in job-O-matic- repository"
    echo "   Current directory: $(pwd)"
fi

echo ""
echo "📋 Admin Checklist - Verify these settings:"
echo ""

echo "1. Organization Codespaces Billing:"
echo "   → https://github.com/organizations/letter-orgz/settings/billing"
echo "   ☐ Codespaces spending limit set (minimum $10/month)"
echo "   ☐ Organization billing enabled"
echo ""

echo "2. Organization Codespaces Policies:"
echo "   → https://github.com/organizations/letter-orgz/settings/codespaces"
echo "   ☐ 'Allow for organization repositories' enabled"
echo "   ☐ Billing set to organization account"
echo "   ☐ Machine types configured (2-core minimum)"
echo ""

echo "3. User Access Verification:"
echo "   → https://github.com/orgs/letter-orgz/people"
echo "   ☐ v4mpire77 is organization member"
echo "   ☐ v4mpire77 has repository access"
echo ""

echo "4. Repository Settings:"
echo "   → https://github.com/letter-orgz/job-O-matic-/settings"
echo "   ☐ Codespaces enabled for repository"
echo "   ☐ Organization members have access"
echo ""

echo "📧 Next Steps for v4mpire77:"
echo "   1. Delete any existing personal-billed Codespaces"
echo "   2. Follow: .github/BILLING_RESOLUTION_GUIDE.md"
echo "   3. Verify billing shows 'letter-orgz' before creating new Codespace"
echo "   4. Run ./check-billing.sh in new Codespace"
echo ""

echo "⚠️  Important Notes:"
echo "   • Changes may take 5-10 minutes to take effect"
echo "   • Organization billing charges may take 24-48 hours to appear"
echo "   • User must see 'Billed to letter-orgz' before creating Codespace"
echo ""

echo "📞 If issues persist:"
echo "   • Double-check all settings above"
echo "   • Contact GitHub Support if org settings appear correct"
echo "   • Update the billing issue with resolution status"
echo ""

echo "========================================================="
echo "✅ Configuration verification complete"
echo "📝 Share this output with v4mpire77 when settings are ready"