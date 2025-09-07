# Daily Branch Management Workflow

This document describes the automated daily branch management system for Job-O-Matic, designed to keep the main codebase clean and provide structured daily development workflows.

## 🎯 Overview

The daily branch management system provides:
- **Consistent branch naming**: `feat/YYYY-MM-DD-description`
- **Automated cleanup**: Archives old branches automatically
- **Structured workflow**: Clear start-of-day and end-of-day processes
- **Protected main branch**: Prevents accidental direct commits
- **Safety checks**: Validates branches and prevents secret commits

## 🚀 Quick Start

### Start of Day
```bash
# Full workflow: cleanup + create today's branch
./scripts/daily-branch-start.sh new-feature-name

# Or just create a branch
./scripts/daily-branch-create.sh api-improvements
```

### End of Day
```bash
# Merge current daily branch back to main
./scripts/daily-branch-merge.sh

# Or merge specific branch
./scripts/daily-branch-merge.sh feat/2024-01-15-api-fixes
```

## 📋 Daily Workflow

### 1. Start-of-Day Process

The `daily-branch-start.sh` script performs:

1. **Switch to main branch**
2. **Pull latest changes** from origin
3. **Archive old branches** (older than 7 days by default)
4. **Create new daily branch** with today's date
5. **Switch to new branch** for development

**Example:**
```bash
# Creates: feat/2024-01-15-user-authentication
./scripts/daily-branch-start.sh user-authentication

# With custom options
./scripts/daily-branch-start.sh --archive-days 3 --prefix hotfix bug-fixes
```

### 2. Development Process

Work normally on your daily branch:
```bash
# Make changes
git add .
git commit -m "Add user authentication middleware"

# Push regularly
git push origin feat/2024-01-15-user-authentication
```

### 3. End-of-Day Process

The `daily-branch-merge.sh` script performs:

1. **Check for uncommitted changes**
2. **Push current branch** to origin
3. **Switch to main and pull** latest changes
4. **Test for merge conflicts**
5. **Merge the feature branch**
6. **Push merged changes**
7. **Clean up branch** (delete if successful)

**Example:**
```bash
# Auto-detect and merge current daily branch
./scripts/daily-branch-merge.sh

# Merge specific branch with squash
./scripts/daily-branch-merge.sh --squash feat/2024-01-15-api-fixes
```

## 🛠️ Script Reference

### daily-branch-create.sh

Creates a new daily branch with consistent naming.

```bash
./scripts/daily-branch-create.sh [OPTIONS] DESCRIPTION

Options:
  -h, --help              Show help message
  -d, --date DATE         Use specific date (YYYY-MM-DD)
  -p, --prefix PREFIX     Use custom prefix (default: feat)
  -n, --dry-run          Preview without executing
  -f, --force            Force creation if branch exists

Examples:
  ./scripts/daily-branch-create.sh user-auth
  ./scripts/daily-branch-create.sh --date 2024-01-20 api-fixes
  ./scripts/daily-branch-create.sh --prefix hotfix security-patch
```

### daily-branch-start.sh

Complete start-of-day workflow with cleanup and branch creation.

```bash
./scripts/daily-branch-start.sh [OPTIONS] [DESCRIPTION]

Options:
  -h, --help              Show help message
  -p, --prefix PREFIX     Branch prefix (default: feat)
  -a, --archive-days DAYS Archive branches older than DAYS (default: 7)
  -n, --dry-run          Preview without executing
  --no-archive           Skip archiving old branches
  --no-create            Skip creating new branch

Examples:
  ./scripts/daily-branch-start.sh new-feature
  ./scripts/daily-branch-start.sh --archive-days 3 api-work
  ./scripts/daily-branch-start.sh --no-archive --dry-run
```

### daily-branch-merge.sh

End-of-day merge workflow with safety checks.

```bash
./scripts/daily-branch-merge.sh [OPTIONS] [BRANCH_NAME]

Options:
  -h, --help         Show help message
  -n, --dry-run     Preview without executing
  -f, --force       Force merge with uncommitted changes
  --squash          Use squash merge
  --no-delete       Keep branch after merge
  --auto            Auto-detect current daily branch

Examples:
  ./scripts/daily-branch-merge.sh
  ./scripts/daily-branch-merge.sh --squash --dry-run
  ./scripts/daily-branch-merge.sh feat/2024-01-15-api-fix
```

## 🔒 Branch Protection

The system includes automated branch protection via GitHub Actions:

### Protected Branch Rules (Recommended)

Configure these settings in GitHub repository settings:

1. **Require pull request reviews**
   - At least 1 review required
   - Dismiss stale reviews on new commits

2. **Require status checks**
   - Branch must be up to date before merging
   - All CI checks must pass

3. **Include administrators**
   - Apply rules to repository administrators

4. **Additional restrictions**
   - Restrict force pushes
   - Restrict deletions

### Automated Checks

The GitHub workflow automatically:
- **Validates daily branch naming** in pull requests
- **Scans for secrets** in commits and files
- **Cleans up old branches** after merges to main
- **Provides setup guidance** for branch protection

## 🔍 Branch Naming Convention

### Daily Branches
- **Format**: `{prefix}/YYYY-MM-DD-{description}`
- **Prefix options**: `feat`, `fix`, `hotfix`
- **Date format**: ISO 8601 (YYYY-MM-DD)
- **Description**: Lowercase, hyphens only

### Examples
```
feat/2024-01-15-user-authentication
feat/2024-01-15-api-improvements
fix/2024-01-15-bug-fixes
hotfix/2024-01-15-security-patch
```

### Legacy/Special Branches
- Long-running features: `feature/feature-name`
- Release branches: `release/v1.2.0`
- Hotfix branches: `hotfix/issue-description`

## ⚡ Advanced Usage

### Dry Run Mode

All scripts support `--dry-run` to preview actions:
```bash
./scripts/daily-branch-start.sh --dry-run feature-name
./scripts/daily-branch-merge.sh --dry-run --squash
```

### Custom Configuration

Modify script variables for your workflow:
```bash
# In script files, change these defaults:
MAIN_BRANCH="main"           # Target branch
DEFAULT_BRANCH_PREFIX="feat" # Default prefix
ARCHIVE_DAYS=7              # Days before archiving
```

### Integration with Git Hooks

The existing pre-commit hook prevents secret commits:
```bash
# Install/update hooks
./scripts/install-hooks.sh
```

## 🚨 Troubleshooting

### Common Issues

**Branch already exists:**
```bash
# Force checkout existing branch
./scripts/daily-branch-create.sh --force existing-description
```

**Merge conflicts:**
```bash
# Resolve manually
git merge feat/2024-01-15-feature-name
# Fix conflicts, then commit
git commit
# Re-run merge script with --no-delete
./scripts/daily-branch-merge.sh --no-delete
```

**Uncommitted changes:**
```bash
# Commit changes first
git add .
git commit -m "Work in progress"

# Or force merge
./scripts/daily-branch-merge.sh --force
```

**Old branches not cleaning up:**
```bash
# Manual cleanup
git branch -r | grep 'feat/2024-01-' | xargs -I {} git push origin --delete {}
```

### Validation

Check branch status:
```bash
# List all branches with dates
git branch -a | grep -E 'feat/[0-9]{4}-[0-9]{2}-[0-9]{2}'

# Check current branch
git branch --show-current

# Verify main is up to date
git fetch origin main
git status
```

## 📚 Integration with Development Workflow

### IDE Integration

Add these as IDE tasks or shortcuts:

**VS Code tasks.json:**
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Start Daily Branch",
      "type": "shell",
      "command": "./scripts/daily-branch-start.sh",
      "args": ["${input:branchDescription}"],
      "group": "build"
    },
    {
      "label": "End Daily Branch",
      "type": "shell",
      "command": "./scripts/daily-branch-merge.sh",
      "group": "build"
    }
  ]
}
  ],
  "inputs": [
    {
      "id": "branchDescription",
      "description": "Branch description (will be formatted automatically)",
      "default": "feature-name",
      "type": "promptString"
    }
  ]
}
```

### Team Coordination

For teams using this workflow:

1. **Agree on prefixes**: `feat`, `fix`, `hotfix`
2. **Set archive policy**: Usually 7 days
3. **Configure notifications**: GitHub Actions results
4. **Document exceptions**: When to use non-daily branches

### CI/CD Integration

The branch management integrates with existing CI:
- **Daily branches**: Run full test suite
- **Main branch**: Run tests + deployment
- **PR validation**: Check naming + scan secrets

## 🎯 Benefits

### For Individual Developers
- **Clean workspace**: Start fresh each day
- **Consistent naming**: No more random branch names
- **Automated cleanup**: No manual branch management
- **Safety checks**: Prevent common mistakes

### For Teams
- **Standardization**: Everyone follows same patterns
- **Visibility**: Clear branch history and purpose
- **Protection**: Main branch stays stable
- **Compliance**: Automated security scanning

### For Project Maintenance
- **Reduced clutter**: Automatic old branch cleanup
- **Clear history**: Date-based branch organization
- **Protected main**: Prevents accidental direct commits
- **Documentation**: Self-documenting branch names

---

## 📞 Support

If you encounter issues with the daily branch management system:

1. **Check the logs**: Scripts provide detailed output
2. **Use dry-run**: Test changes before executing
3. **Read error messages**: Scripts provide helpful guidance
4. **Check GitHub Actions**: View automated checks and cleanup
5. **Review this documentation**: Look for troubleshooting sections

For feature requests or bugs, create an issue in the repository with the `branch-management` label.