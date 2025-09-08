# Git Workflow and Development Process

This document outlines the git workflow and development process for the Job-O-Matic project.

## 🌟 Overview

We follow a **GitHub Flow** approach with additional governance for the main branch. This ensures code quality while maintaining development velocity.

## 🏗️ Repository Structure

### Branch Protection
The `main` branch is protected with the following rules:
- **Direct pushes blocked**: All changes must go through pull requests
- **PR reviews required**: At least one approval from organization admins
- **Status checks required**: All checks must pass before merge
- **Auto-delete head branches**: Feature branches are automatically cleaned up after merge

### Branch Types

#### `main` Branch
- **Protected**: Cannot be pushed to directly
- **Stable**: Always in a deployable state
- **Source of truth**: All feature branches start from here
- **Deployment**: Production deployments come from this branch

#### Feature Branches
- **Naming**: `feature/description` or `feature/issue-123-description`
- **Lifespan**: Short-lived, deleted after merge
- **Purpose**: Development of new features
- **Source**: Branched from `main`
- **Target**: Merged back to `main`

#### Bug Fix Branches
- **Naming**: `fix/description` or `fix/issue-123-description`
- **Lifespan**: Short-lived, deleted after merge
- **Purpose**: Bug fixes and patches
- **Source**: Branched from `main`
- **Target**: Merged back to `main`

#### Hotfix Branches
- **Naming**: `hotfix/critical-issue`
- **Lifespan**: Very short-lived
- **Purpose**: Critical production fixes
- **Source**: Branched from `main`
- **Target**: Merged back to `main` with expedited review

## 🔄 Development Workflow

### 1. Starting New Work

```bash
# Ensure you're on main and up to date
git checkout main
git pull origin main

# Create and switch to feature branch
git checkout -b feature/your-feature-name

# Push branch to remote
git push -u origin feature/your-feature-name
```

### 2. Development Process

```bash
# Make your changes
# Edit files, add features, fix bugs

# Stage and commit changes
git add .
git commit -m "feat: add new feature description"

# Push changes regularly
git push origin feature/your-feature-name
```

### 3. Keeping Branch Updated

```bash
# Fetch latest changes from main
git fetch origin main

# Rebase your feature branch (preferred)
git rebase origin/main

# Or merge if rebase is complex
git merge origin/main

# Push updated branch
git push origin feature/your-feature-name --force-with-lease
```

### 4. Creating Pull Request

1. **Push final changes** to your feature branch
2. **Create PR** on GitHub from your branch to `main`
3. **Fill out PR template** with required information
4. **Request review** from @letter-orgz/admins
5. **Address feedback** and make necessary changes
6. **Wait for approval** and status checks to pass
7. **Merge** using the "Squash and merge" option (preferred)

### 5. Post-Merge Cleanup

```bash
# Switch back to main
git checkout main

# Pull the merged changes
git pull origin main

# Delete local feature branch
git branch -d feature/your-feature-name

# Remote branch is auto-deleted by GitHub
```

## 🔍 Code Review Process

### Review Requirements
- **Minimum reviewers**: 1 organization admin
- **Review criteria**: 
  - Code quality and style
  - Security considerations
  - Compliance with guidelines
  - Testing coverage
  - Documentation updates

### Review Timeline
- **Standard PRs**: 1-2 business days
- **Hotfixes**: Within hours (expedited)
- **Large features**: May require multiple review rounds

### Status Checks
Before merge, all PRs must pass:
- [ ] Code formatting (Black)
- [ ] Security scanning (pre-commit hooks)
- [ ] Manual testing completed
- [ ] Documentation updated
- [ ] Admin approval received

## 🚨 Emergency Procedures

### Hotfix Process
For critical production issues:

1. **Create hotfix branch** immediately from `main`
2. **Implement minimal fix** addressing only the critical issue
3. **Test thoroughly** but quickly
4. **Create PR** with "HOTFIX" label
5. **Request expedited review** from available admins
6. **Merge immediately** after approval
7. **Monitor deployment** for any issues

### Rollback Process
If issues are detected after merge:

1. **Identify problematic commit**
2. **Create revert PR**:
   ```bash
   git checkout main
   git pull origin main
   git revert <commit-hash>
   git push origin main
   ```
3. **Follow expedited review** process
4. **Investigate root cause** and plan proper fix

## 🔒 Security Considerations

### Sensitive Data Protection
- **Pre-commit hooks** scan for secrets and sensitive files
- **Environment variables** used for configuration
- **API keys** never committed to repository
- **Personal data** excluded from version control

### Compliance Checks
- **GDPR compliance** reviewed in all data-handling changes
- **Platform ToS** compliance verified for API integrations
- **Rate limiting** enforced in all automated processes
- **Audit trails** maintained for all user actions

## 📋 Commit Message Guidelines

### Format
```
type(scope): description

[optional body]

[optional footer]
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Formatting, missing semicolons, etc.
- `refactor`: Code restructuring without feature changes
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples
```bash
feat: add bulk job application processing
fix: resolve CV parsing error for Word documents
docs: update API documentation for new endpoints
chore: update dependencies to latest versions
```

## 🛠️ Development Tools

### Required Tools
- **Git**: Version control
- **Black**: Code formatting
- **Pre-commit hooks**: Security scanning
- **GitHub CLI** (optional): Command-line GitHub operations

### IDE Setup
Recommended settings for consistent development:
- **Line length**: 88 characters (Black default)
- **Tab size**: 4 spaces
- **Trim whitespace**: On save
- **Insert final newline**: Enabled

## 📊 Metrics and Monitoring

### Development Metrics
- **PR merge time**: Target 1-2 days
- **Review participation**: All admins participate
- **Hotfix frequency**: Monitor for quality issues
- **Branch lifecycle**: Feature branches < 1 week

### Quality Metrics
- **Test coverage**: Monitor and improve
- **Security scan results**: Zero high-severity issues
- **Compliance violations**: Zero tolerance
- **User feedback**: Address promptly

## 🆘 Troubleshooting Common Issues

### Merge Conflicts
```bash
# Update your branch
git fetch origin main
git rebase origin/main

# Resolve conflicts in your editor
# Edit conflicted files, remove conflict markers

# Continue rebase
git add .
git rebase --continue

# Push updated branch
git push origin feature/your-branch --force-with-lease
```

### Failed Status Checks
1. **Check error details** in GitHub PR interface
2. **Fix issues locally**:
   ```bash
   # Format code
   black .
   
   # Run security checks
   ./scripts/install-hooks.sh
   git commit --amend --no-edit
   ```
3. **Push fixes** and wait for checks to re-run

### Access Issues
- **Not a member**: Contact @letter-orgz/admins for organization access
- **Permission denied**: Ensure you're authenticated with GitHub
- **Billing concerns**: See [Codespace Billing Guide](.github/CODESPACES_BILLING.md)

## 📚 Additional Resources

- [GitHub Flow Documentation](https://guides.github.com/introduction/flow/)
- [Contributing Guidelines](CONTRIBUTING.md)
- [Security Best Practices](compliance_best_practices.md)
- [Implementation Guide](implementation-guide.md)

---

**Questions?** Create an issue or contact @letter-orgz/admins for assistance with the development workflow.