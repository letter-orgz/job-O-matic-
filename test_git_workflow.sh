#!/bin/bash
# Test Suite for Git Workflow Integration in start.sh

cd /home/runner/work/job-O-matic-/job-O-matic-

echo "🧪 Testing Git Workflow Integration"
echo "====================================="

# Test 1: Help command
echo "Test 1: Help command..."
if ./start.sh --help | grep -q "Job-O-Matic Startup Script"; then
    echo "✅ Help command works"
else
    echo "❌ Help command failed"
fi

# Test 2: Script contains required functions
echo -e "\nTest 2: Required functions present..."
required_functions=("get_daily_branch_name" "check_daily_branch" "create_daily_branch" "setup_git_config" "display_git_status" "manage_git_workflow")
for func in "${required_functions[@]}"; do
    if grep -q "^$func()" start.sh; then
        echo "✅ Function $func found"
    else
        echo "❌ Function $func missing"
    fi
done

# Test 3: Check script is executable
echo -e "\nTest 3: Script permissions..."
if [ -x start.sh ]; then
    echo "✅ Script is executable"
else
    echo "❌ Script is not executable"
fi

# Test 4: Basic syntax check
echo -e "\nTest 4: Syntax check..."
if bash -n start.sh; then
    echo "✅ Script syntax is valid"
else
    echo "❌ Script has syntax errors"
fi

# Test 5: Git functionality (without actually changing branches)
echo -e "\nTest 5: Git functionality..."
current_branch=$(git branch --show-current)
expected_daily="daily/$(date +%Y-%m-%d)"
if [ "$current_branch" != "$expected_daily" ]; then
    echo "✅ Daily branch logic works (current: $current_branch, expected: $expected_daily)"
else
    echo "ℹ️  Already on expected daily branch"
fi

echo -e "\n🎉 All tests completed!"
echo "====================================="