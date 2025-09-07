# Branch Cleanup System Documentation

## Overview

The automated branch cleanup system helps maintain a clean repository by automatically removing stale branches while preserving important ones. It includes comprehensive safety features and notifications.

## Features

### 🗓️ Scheduled Cleanup
- **When**: Every Monday at 2:00 AM UTC
- **What**: Automatically scans and cleans up old branches
- **Notification**: Creates a GitHub issue with cleanup report

### 🛡️ Branch Protection
The following branches are **never** deleted:
- `main`
- `develop` 
- `master`
- `staging`
- `production`

### 🧹 Cleanup Rules

#### Merged Feature Branches
- **Condition**: Branch has been merged into main/develop/master AND is older than retention period
- **Default Retention**: 7 days
- **Configurable**: Yes, via workflow inputs

#### Daily/Temporary Branches  
- **Pattern**: Branches starting with `daily-`, `temp-`, or `tmp-`
- **Condition**: Older than daily retention period
- **Default Retention**: 7 days
- **Configurable**: Yes, via workflow inputs

## Usage

### Automatic Mode
The workflow runs automatically every Monday. No action required.

### Manual Execution
1. Go to **Actions** tab in GitHub
2. Select "**Automated Branch Cleanup**" workflow
3. Click "**Run workflow**"
4. Configure options:
   - **Dry Run**: Test mode (recommended first time)
   - **Retention Days**: Days to keep merged branches
   - **Daily Branch Retention**: Days to keep daily branches

### Configuration Options

| Parameter | Description | Default | Example |
|-----------|-------------|---------|---------|
| `dry_run` | Test mode - no actual deletions | `true` | `false` |
| `retention_days` | Days to retain merged branches | `7` | `14` |
| `daily_branch_retention` | Days to retain daily branches | `7` | `3` |

## Safety Features

### 🧪 Dry Run Mode
- **Default**: Enabled for safety
- **What it does**: Shows what would be deleted without actually deleting
- **How to use**: Run with dry_run=true to preview changes

### 📊 Detailed Reporting
Every cleanup generates:
- **Action Summary**: In the workflow run
- **GitHub Issue**: Comprehensive report with all actions taken
- **Branch Analysis**: Shows protected, kept, and deleted branches

### 🔒 Multiple Protection Layers
1. **Branch Name Protection**: Hardcoded protection for critical branches
2. **Age Verification**: Only deletes branches older than retention period  
3. **Merge Verification**: Only deletes already-merged feature branches
4. **Manual Override**: Can be stopped/configured manually

## Examples

### Example 1: First Time Setup
```bash
# 1. Run in dry-run mode to see what would happen
Go to Actions > Automated Branch Cleanup > Run workflow
- dry_run: true
- retention_days: 7
- daily_branch_retention: 7

# 2. Review the generated issue report
# 3. If satisfied, run again with dry_run: false
```

### Example 2: Custom Retention
```bash
# Keep merged branches for 14 days, daily branches for 3 days
Go to Actions > Automated Branch Cleanup > Run workflow
- dry_run: false
- retention_days: 14
- daily_branch_retention: 3
```

### Example 3: Emergency Cleanup
```bash
# Quick cleanup of very old branches only
Go to Actions > Automated Branch Cleanup > Run workflow
- dry_run: false
- retention_days: 30
- daily_branch_retention: 30
```

## Notifications

### Cleanup Reports
Each cleanup creates a GitHub issue with:
- 📊 **Summary**: Number of branches processed
- 🔀 **Merged Branches**: List of deleted merged branches
- 📅 **Daily Branches**: List of deleted daily/temp branches
- ❌ **Failed Deletions**: Any branches that couldn't be deleted
- 🛡️ **Protected Branches**: Reminder of what's protected

### Issue Labels
Reports are tagged with:
- `automation`
- `maintenance` 
- `branch-cleanup`

## Troubleshooting

### Common Issues

#### "Branch not found" errors
- **Cause**: Branch was already deleted manually
- **Solution**: No action needed, this is normal

#### "Permission denied" errors
- **Cause**: Protected branch or insufficient permissions
- **Solution**: Check branch protection rules in repository settings

#### Workflow not running automatically
- **Cause**: Repository might be inactive or workflow disabled
- **Solution**: Run manually once to reactivate, or check Actions settings

### Manual Intervention

If branches can't be deleted automatically:
1. Check the cleanup report issue for details
2. Manually review branch protection rules
3. Delete problematic branches manually if safe
4. Re-run the workflow

## Best Practices

### For Development Teams
1. **Start with dry-run**: Always test first
2. **Review reports**: Check cleanup issues weekly
3. **Adjust retention**: Tune periods based on your workflow
4. **Use naming conventions**: Prefix temp branches with `daily-`, `temp-`, or `tmp-`

### Branch Naming
- ✅ `feature/user-authentication`
- ✅ `daily-2024-01-15-experiments`
- ✅ `temp-bug-fix`
- ✅ `tmp-testing-api`
- ❌ `johns-branch` (unclear purpose)
- ❌ `test` (too generic)

## Customization

### Adding More Protected Branches
Edit `.github/workflows/branch-cleanup.yml`:
```yaml
env:
  PROTECTED_BRANCHES: "main,develop,master,staging,production,release,hotfix"
```

### Changing Schedule
Edit the cron expression:
```yaml
on:
  schedule:
    # Run every day at 3 AM UTC instead of weekly
    - cron: '0 3 * * *'
```

### Custom Branch Patterns
Modify the regex in the workflow:
```bash
# Current: daily|temp|tmp
# Example: daily|temp|tmp|experimental|sandbox
elif [[ "$local_branch" =~ ^(daily|temp|tmp|experimental|sandbox)-.*$ ]]
```

## Security

- **Permissions**: Workflow requires `contents: write` to delete branches
- **Token**: Uses standard `GITHUB_TOKEN` (no additional setup needed)
- **Scope**: Only affects the repository where it's installed
- **Audit**: All actions are logged in workflow runs and issues

---

*This documentation covers the automated branch cleanup system. For questions or issues, create a GitHub issue with the `branch-cleanup` label.*