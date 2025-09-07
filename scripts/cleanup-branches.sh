#!/usr/bin/env bash
set -euo pipefail

# Daily Development Workflow - Cleanup Branches Script
# Manual cleanup utility for old and merged branches

echo "🧹 Branch Cleanup Utility"

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository"
    echo "Please run this script from the job-O-matic root directory"
    exit 1
fi

CURRENT_BRANCH=$(git branch --show-current)

echo "🌿 Current branch: $CURRENT_BRANCH"
echo ""

# Function to prompt for user input with default
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local result
    
    read -p "$prompt [$default]: " result
    echo "${result:-$default}"
}

# Function to show branch info
show_branch_info() {
    local branch="$1"
    local last_commit=$(git log -1 --format="%ar" "$branch" 2>/dev/null || echo "unknown")
    local last_message=$(git log -1 --format="%s" "$branch" 2>/dev/null || echo "unknown")
    echo "   📅 Last commit: $last_commit"
    echo "   💬 Last message: $last_message"
}

# Function to check if branch is merged
is_merged() {
    local branch="$1"
    local target="${2:-main}"
    
    # Check against main or master
    if git branch --merged "$target" | grep -q "$branch"; then
        return 0
    fi
    
    # If main doesn't exist, try master
    if [ "$target" = "main" ] && git branch --list | grep -q "master"; then
        if git branch --merged "master" | grep -q "$branch"; then
            return 0
        fi
    fi
    
    return 1
}

# Function to safe delete branch
safe_delete_branch() {
    local branch="$1"
    local force="${2:-false}"
    
    if [ "$branch" = "$CURRENT_BRANCH" ]; then
        echo "❌ Cannot delete current branch: $branch"
        return 1
    fi
    
    if [ "$force" = "true" ]; then
        git branch -D "$branch"
        echo "✅ Force deleted: $branch"
    else
        git branch -d "$branch" 2>/dev/null && echo "✅ Safely deleted: $branch" || {
            echo "⚠️  Cannot safely delete $branch (may have unmerged changes)"
            read -p "Force delete anyway? (y/n): " force_choice
            if [[ $force_choice =~ ^[Yy] ]]; then
                git branch -D "$branch"
                echo "✅ Force deleted: $branch"
            else
                echo "❌ Skipped: $branch"
                return 1
            fi
        }
    fi
}

# Get list of branches
echo "📋 Analyzing branches..."
all_branches=($(git branch | grep -v '^\*' | sed 's/^[[:space:]]*//' | sort))

if [ ${#all_branches[@]} -eq 0 ]; then
    echo "ℹ️  No other branches found to clean up"
    exit 0
fi

# Categorize branches
daily_branches=()
feature_branches=()
archive_branches=()
merged_branches=()
old_branches=()
other_branches=()

TODAY=$(date +%Y-%m-%d)
WEEK_AGO=$(date -d '7 days ago' +%Y-%m-%d)
MONTH_AGO=$(date -d '30 days ago' +%Y-%m-%d)

for branch in "${all_branches[@]}"; do
    # Skip main/master/develop
    if [[ $branch =~ ^(main|master|develop)$ ]]; then
        continue
    fi
    
    # Categorize by name pattern
    if [[ $branch =~ ^daily/ ]]; then
        daily_branches+=("$branch")
    elif [[ $branch =~ ^feature/ ]]; then
        feature_branches+=("$branch")
    elif [[ $branch =~ ^archive/ ]]; then
        archive_branches+=("$branch")
    else
        other_branches+=("$branch")
    fi
    
    # Check if merged
    if is_merged "$branch"; then
        merged_branches+=("$branch")
    fi
    
    # Check if old (approximate based on name for daily branches)
    if [[ $branch =~ ^daily/([0-9]{4}-[0-9]{2}-[0-9]{2}) ]]; then
        branch_date="${BASH_REMATCH[1]}"
        if [[ "$branch_date" < "$WEEK_AGO" ]]; then
            old_branches+=("$branch")
        fi
    fi
done

# Show cleanup menu
while true; do
    echo ""
    echo "🧹 Cleanup Options:"
    echo "1) Quick cleanup (merged + old branches)"
    echo "2) Review daily branches (${#daily_branches[@]} found)"
    echo "3) Review feature branches (${#feature_branches[@]} found)"
    echo "4) Review merged branches (${#merged_branches[@]} found)"
    echo "5) Review archive branches (${#archive_branches[@]} found)"
    echo "6) Review all other branches (${#other_branches[@]} found)"
    echo "7) Custom branch selection"
    echo "8) Remote cleanup (clean tracking branches)"
    echo "9) Show branch statistics"
    echo "0) Exit"
    
    read -p "Choose option (0-9): " choice
    
    case $choice in
        1)
            echo ""
            echo "🚀 Quick Cleanup Mode"
            echo "This will delete:"
            echo "  - Merged branches that are safe to delete"
            echo "  - Daily branches older than 7 days"
            
            cleanup_list=()
            for branch in "${merged_branches[@]}"; do
                if [[ ! $branch =~ ^(main|master|develop)$ ]]; then
                    cleanup_list+=("$branch")
                fi
            done
            
            for branch in "${old_branches[@]}"; do
                cleanup_list+=("$branch")
            done
            
            # Remove duplicates
            cleanup_list=($(printf '%s\n' "${cleanup_list[@]}" | sort -u))
            
            if [ ${#cleanup_list[@]} -eq 0 ]; then
                echo "ℹ️  No branches to clean up"
                continue
            fi
            
            echo ""
            echo "📋 Branches to delete (${#cleanup_list[@]}):"
            for branch in "${cleanup_list[@]}"; do
                echo "  🗑️  $branch"
                show_branch_info "$branch"
            done
            
            echo ""
            read -p "Delete these ${#cleanup_list[@]} branches? (y/n): " confirm
            if [[ $confirm =~ ^[Yy] ]]; then
                for branch in "${cleanup_list[@]}"; do
                    safe_delete_branch "$branch"
                done
                echo "✅ Quick cleanup complete!"
            else
                echo "❌ Quick cleanup cancelled"
            fi
            ;;
            
        2)
            if [ ${#daily_branches[@]} -eq 0 ]; then
                echo "ℹ️  No daily branches found"
                continue
            fi
            
            echo ""
            echo "📅 Daily Branches:"
            for i in "${!daily_branches[@]}"; do
                branch="${daily_branches[$i]}"
                echo "$((i+1))) $branch"
                show_branch_info "$branch"
                if [[ " ${old_branches[*]} " =~ " $branch " ]]; then
                    echo "   ⚠️  This branch is older than 7 days"
                fi
                if [[ " ${merged_branches[*]} " =~ " $branch " ]]; then
                    echo "   ✅ This branch is merged"
                fi
                echo ""
            done
            
            read -p "Enter branch numbers to delete (e.g., 1,3,5) or 'all' or 'none': " selection
            
            if [ "$selection" = "all" ]; then
                for branch in "${daily_branches[@]}"; do
                    safe_delete_branch "$branch"
                done
            elif [ "$selection" != "none" ]; then
                IFS=',' read -ra indices <<< "$selection"
                for index in "${indices[@]}"; do
                    index=$(echo "$index" | tr -d ' ')
                    if [[ "$index" =~ ^[0-9]+$ ]] && [ "$index" -ge 1 ] && [ "$index" -le ${#daily_branches[@]} ]; then
                        branch="${daily_branches[$((index-1))]}"
                        safe_delete_branch "$branch"
                    fi
                done
            fi
            ;;
            
        3)
            if [ ${#feature_branches[@]} -eq 0 ]; then
                echo "ℹ️  No feature branches found"
                continue
            fi
            
            echo ""
            echo "✨ Feature Branches:"
            for i in "${!feature_branches[@]}"; do
                branch="${feature_branches[$i]}"
                echo "$((i+1))) $branch"
                show_branch_info "$branch"
                if [[ " ${merged_branches[*]} " =~ " $branch " ]]; then
                    echo "   ✅ This branch is merged"
                fi
                echo ""
            done
            
            read -p "Enter branch numbers to delete (e.g., 1,3,5) or 'merged' or 'none': " selection
            
            if [ "$selection" = "merged" ]; then
                for branch in "${feature_branches[@]}"; do
                    if [[ " ${merged_branches[*]} " =~ " $branch " ]]; then
                        safe_delete_branch "$branch"
                    fi
                done
            elif [ "$selection" != "none" ]; then
                IFS=',' read -ra indices <<< "$selection"
                for index in "${indices[@]}"; do
                    index=$(echo "$index" | tr -d ' ')
                    if [[ "$index" =~ ^[0-9]+$ ]] && [ "$index" -ge 1 ] && [ "$index" -le ${#feature_branches[@]} ]; then
                        branch="${feature_branches[$((index-1))]}"
                        safe_delete_branch "$branch"
                    fi
                done
            fi
            ;;
            
        4)
            if [ ${#merged_branches[@]} -eq 0 ]; then
                echo "ℹ️  No merged branches found"
                continue
            fi
            
            echo ""
            echo "✅ Merged Branches:"
            for branch in "${merged_branches[@]}"; do
                echo "  🔀 $branch"
                show_branch_info "$branch"
            done
            
            echo ""
            read -p "Delete all merged branches? (y/n): " confirm
            if [[ $confirm =~ ^[Yy] ]]; then
                for branch in "${merged_branches[@]}"; do
                    safe_delete_branch "$branch"
                done
            fi
            ;;
            
        5)
            if [ ${#archive_branches[@]} -eq 0 ]; then
                echo "ℹ️  No archive branches found"
                continue
            fi
            
            echo ""
            echo "📦 Archive Branches:"
            for i in "${!archive_branches[@]}"; do
                branch="${archive_branches[$i]}"
                echo "$((i+1))) $branch"
                show_branch_info "$branch"
                echo ""
            done
            
            echo "⚠️  Archive branches are usually kept for historical reference"
            read -p "Enter branch numbers to delete (e.g., 1,3,5) or 'none': " selection
            
            if [ "$selection" != "none" ]; then
                IFS=',' read -ra indices <<< "$selection"
                for index in "${indices[@]}"; do
                    index=$(echo "$index" | tr -d ' ')
                    if [[ "$index" =~ ^[0-9]+$ ]] && [ "$index" -ge 1 ] && [ "$index" -le ${#archive_branches[@]} ]; then
                        branch="${archive_branches[$((index-1))]}"
                        safe_delete_branch "$branch" "true"
                    fi
                done
            fi
            ;;
            
        6)
            if [ ${#other_branches[@]} -eq 0 ]; then
                echo "ℹ️  No other branches found"
                continue
            fi
            
            echo ""
            echo "🤔 Other Branches:"
            for i in "${!other_branches[@]}"; do
                branch="${other_branches[$i]}"
                echo "$((i+1))) $branch"
                show_branch_info "$branch"
                if [[ " ${merged_branches[*]} " =~ " $branch " ]]; then
                    echo "   ✅ This branch is merged"
                fi
                echo ""
            done
            
            read -p "Enter branch numbers to delete (e.g., 1,3,5) or 'none': " selection
            
            if [ "$selection" != "none" ]; then
                IFS=',' read -ra indices <<< "$selection"
                for index in "${indices[@]}"; do
                    index=$(echo "$index" | tr -d ' ')
                    if [[ "$index" =~ ^[0-9]+$ ]] && [ "$index" -ge 1 ] && [ "$index" -le ${#other_branches[@]} ]; then
                        branch="${other_branches[$((index-1))]}"
                        safe_delete_branch "$branch"
                    fi
                done
            fi
            ;;
            
        7)
            echo ""
            echo "🎯 Custom Branch Selection"
            echo "Available branches:"
            for i in "${!all_branches[@]}"; do
                branch="${all_branches[$i]}"
                echo "$((i+1))) $branch"
                if [[ " ${merged_branches[*]} " =~ " $branch " ]]; then
                    echo "   ✅ Merged"
                fi
                if [[ " ${old_branches[*]} " =~ " $branch " ]]; then
                    echo "   📅 Old"
                fi
            done
            
            echo ""
            read -p "Enter branch numbers to delete (e.g., 1,3,5): " selection
            
            IFS=',' read -ra indices <<< "$selection"
            for index in "${indices[@]}"; do
                index=$(echo "$index" | tr -d ' ')
                if [[ "$index" =~ ^[0-9]+$ ]] && [ "$index" -ge 1 ] && [ "$index" -le ${#all_branches[@]} ]; then
                    branch="${all_branches[$((index-1))]}"
                    safe_delete_branch "$branch"
                fi
            done
            ;;
            
        8)
            echo ""
            echo "🌐 Remote Cleanup"
            
            if git remote | grep -q origin; then
                echo "📡 Fetching from origin..."
                git fetch origin --prune
                
                echo "🧹 Cleaning up tracking branches for deleted remotes..."
                git remote prune origin
                
                echo "✅ Remote cleanup complete"
            else
                echo "ℹ️  No remote origin configured"
            fi
            ;;
            
        9)
            echo ""
            echo "📊 Branch Statistics"
            echo "📅 Daily branches: ${#daily_branches[@]}"
            echo "✨ Feature branches: ${#feature_branches[@]}"
            echo "📦 Archive branches: ${#archive_branches[@]}"
            echo "✅ Merged branches: ${#merged_branches[@]}"
            echo "⏰ Old branches: ${#old_branches[@]}"
            echo "🤔 Other branches: ${#other_branches[@]}"
            echo "📊 Total branches: ${#all_branches[@]}"
            echo ""
            
            if [ ${#old_branches[@]} -gt 0 ]; then
                echo "⏰ Old branches (>7 days):"
                for branch in "${old_branches[@]}"; do
                    echo "  📅 $branch"
                done
                echo ""
            fi
            
            if [ ${#merged_branches[@]} -gt 0 ]; then
                echo "✅ Merged branches:"
                for branch in "${merged_branches[@]}"; do
                    echo "  🔀 $branch"
                done
                echo ""
            fi
            ;;
            
        0)
            echo "👋 Goodbye!"
            exit 0
            ;;
            
        *)
            echo "❌ Invalid option. Please choose 0-9."
            ;;
    esac
done