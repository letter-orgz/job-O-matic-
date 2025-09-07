# PR Merge Readiness Checker

This tool helps you quickly identify which pull requests in the repository are ready to be merged and which ones need attention.

## Quick Start

### Option 1: GitHub CLI (Recommended)
```bash
# Install GitHub CLI if not already installed
# macOS: brew install gh
# Ubuntu/Debian: sudo apt install gh
# Windows: winget install GitHub.cli

# Authenticate (one-time setup)
gh auth login

# Run the checker
./scripts/check-prs.sh
```

### Option 2: Python Script with Token
```bash
# Set your GitHub token (get from https://github.com/settings/tokens)
export GITHUB_TOKEN=your_token_here

# Run the Python checker
python3 scripts/check-pr-merge-readiness.py
```

### Option 3: Simple Shell Script
```bash
# Basic version without authentication
./scripts/check-pr-readiness.sh
```

## What it Checks

The PR merge readiness checker analyzes each open pull request for:

- **Draft Status**: PRs marked as draft are not ready
- **Merge Conflicts**: PRs with merge conflicts need resolution  
- **Review Status**: PRs need approved reviews
- **CI/Check Status**: All automated checks must pass
- **Branch Protection**: Compliance with any branch protection rules

## Output Format

### ✅ Ready to Merge
PRs that have:
- ✅ Not marked as draft
- ✅ No merge conflicts
- ✅ Approved reviews
- ✅ Passing CI checks

### ⚠️ Needs Attention
PRs that have blocking factors like:
- 📝 Marked as draft
- ⚠️ Has merge conflicts
- 👥 Needs review approval
- 🔴 Failing CI checks
- 🔄 Changes requested

## Report Files

The Python version saves detailed JSON reports to the `reports/` directory with:
- Complete PR analysis data
- Timestamp information
- Summary statistics
- Blocking factors for each PR

## Integration with Job-O-Matic

You can add this check to your daily workflow:

1. **Morning Check**: Run before starting development work
2. **Before Releases**: Verify which PRs can be safely merged
3. **Team Reviews**: Use reports to prioritize review efforts
4. **CI Integration**: Automate checks as part of your workflow

## Examples

### Command Line Usage
```bash
# Check current repository
./scripts/check-prs.sh

# Check specific repository
python3 scripts/check-pr-merge-readiness.py owner repo-name

# With custom token
python3 scripts/check-pr-merge-readiness.py owner repo-name your-token
```

### Sample Output
```
🔍 Job-O-Matic PR Merge Readiness Check
Repository: letter-orgz/job-O-matic-
================================================================

✅ Ready to Merge (2 PRs)
#22: Implement Automated Branch Cleanup System
   Author: Copilot
   Status: Ready to merge! 🎉

⚠️ Needs Attention (8 PRs)
#26: can we check what pr's can be merged in ?
   Author: Copilot
   Blocking: Draft, Needs Review

#25: Repository Governance and Standards
   Author: Copilot  
   Blocking: Draft, Checks Pending

📊 SUMMARY: 2 ready, 8 need attention, 10 total
```

## Troubleshooting

### API Rate Limits
- **Issue**: 403 Forbidden errors
- **Solution**: Use GitHub token or GitHub CLI authentication

### Missing Dependencies
- **Issue**: Python modules not found
- **Solution**: Run `pip install requests` or use the shell version

### Authentication Issues
- **Issue**: Cannot access repository
- **Solution**: Run `gh auth login` or set `GITHUB_TOKEN`

## Advanced Usage

### Automation
Add to your shell profile for easy access:
```bash
alias check-prs='cd /path/to/job-O-matic && ./scripts/check-prs.sh'
```

### CI Integration
Use in GitHub Actions workflow:
```yaml
- name: Check PR Readiness
  run: |
    export GITHUB_TOKEN=${{ secrets.GITHUB_TOKEN }}
    python3 scripts/check-pr-merge-readiness.py
```

### Custom Filtering
Modify the scripts to add custom criteria like:
- Minimum review count requirements
- Specific reviewer requirements
- Age-based prioritization
- Label-based filtering

## Contributing

To improve the PR checker:
1. Add new blocking factor detection
2. Enhance report formatting
3. Add integrations with other tools
4. Improve error handling and user experience

The checker is designed to be easily extensible and can be customized for different repository workflows and requirements.