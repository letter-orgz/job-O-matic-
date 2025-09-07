# GitHub Repository Settings Configuration Guide

This document provides instructions for organization administrators to configure the GitHub repository settings to implement proper governance and branch protection.

## 🔒 Branch Protection Rules

### Main Branch Protection

Navigate to **Settings > Branches** and configure the following for the `main` branch:

#### Required Settings
- [ ] **Restrict pushes that create files**: Enabled
- [ ] **Require a pull request before merging**: ✅ **ENABLED**
  - [ ] **Require approvals**: ✅ Set to **1** minimum
  - [ ] **Dismiss stale PR approvals when new commits are pushed**: ✅ **ENABLED**
  - [ ] **Require review from code owners**: ✅ **ENABLED**
  - [ ] **Restrict reviews to users with push access**: ✅ **ENABLED**
  - [ ] **Allow specified actors to bypass required pull requests**: ❌ **DISABLED**

#### Status Checks
- [ ] **Require status checks to pass before merging**: ✅ **ENABLED**
  - [ ] **Require branches to be up to date before merging**: ✅ **ENABLED**
  - Status checks to require (add when available):
    - Code formatting (Black)
    - Security scanning
    - Manual testing confirmation

#### Additional Restrictions
- [ ] **Restrict pushes that create files**: ✅ **ENABLED**
- [ ] **Restrict pushes to matching branches**: ✅ **ENABLED**
- [ ] **Force push**: ❌ **DISABLED**
- [ ] **Allow deletions**: ❌ **DISABLED**

### Branch Protection URL
```
https://github.com/letter-orgz/job-O-matic-/settings/branches
```

## 🗑️ Automatic Branch Cleanup

### Pull Request Settings

Navigate to **Settings > General > Pull Requests**:

- [ ] **Automatically delete head branches**: ✅ **ENABLED**
- [ ] **Allow merge commits**: ✅ **ENABLED** 
- [ ] **Allow squash merging**: ✅ **ENABLED** (Recommended default)
- [ ] **Allow rebase merging**: ✅ **ENABLED**
- [ ] **Allow auto-merge**: ⚠️ **OPTIONAL** (Consider team preference)

### Cleanup URL
```
https://github.com/letter-orgz/job-O-matic-/settings
```

## 👥 Team and Access Management

### Organization Teams

Ensure the following teams exist and have appropriate access:

#### `@letter-orgz/admins`
- **Repository role**: Admin
- **Responsibilities**: 
  - Code review and approval
  - Repository configuration
  - Security oversight
  - Release management

### Access Levels
- **Admin**: @letter-orgz/admins team only
- **Write**: Selected contributors (if needed)
- **Read**: Organization members
- **None**: External collaborators (case-by-case)

## 🔐 Security Settings

### Security & Analysis

Navigate to **Settings > Security & analysis**:

#### Recommended Settings
- [ ] **Dependency graph**: ✅ **ENABLED**
- [ ] **Dependabot alerts**: ✅ **ENABLED**
- [ ] **Dependabot security updates**: ✅ **ENABLED**
- [ ] **Dependabot version updates**: ⚠️ **CONSIDER** (creates automated PRs)
- [ ] **Code scanning alerts**: ✅ **ENABLED** (when available)
- [ ] **Secret scanning alerts**: ✅ **ENABLED**

### Security URL
```
https://github.com/letter-orgz/job-O-matic-/settings/security_analysis
```

## 🏷️ Issue and PR Management

### Labels Configuration

Create the following labels for better issue management:

#### Priority Labels
- `priority: critical` (Red - #d73a4a)
- `priority: high` (Orange - #ff9500) 
- `priority: medium` (Yellow - #fbca04)
- `priority: low` (Green - #0e8a16)

#### Type Labels  
- `type: bug` (Red - #d73a4a)
- `type: feature` (Blue - #1f77b4)
- `type: documentation` (Light blue - #5dade2)
- `type: security` (Purple - #8e44ad)
- `type: maintenance` (Gray - #7f8c8d)

#### Status Labels
- `status: needs-triage` (Yellow - #fbca04)
- `status: in-progress` (Blue - #1f77b4)
- `status: blocked` (Red - #e74c3c)
- `status: ready-for-review` (Green - #27ae60)

#### Area Labels
- `area: ui` (Pink - #ff69b4)
- `area: api` (Cyan - #17a2b8)
- `area: database` (Brown - #8b4513)
- `area: deployment` (Navy - #000080)

### Labels URL
```
https://github.com/letter-orgz/job-O-matic-/labels
```

## 📊 Repository Insights

### Recommended Settings

Navigate to **Insights > Community Standards**:

Verify all community standards are met:
- [x] Description
- [x] README
- [x] Code of conduct (in CONTRIBUTING.md)
- [x] Contributing guidelines
- [x] License (if applicable)
- [x] Issue templates
- [x] Pull request template

## 🚀 GitHub Actions & Workflows

### Workflow Permissions

Navigate to **Settings > Actions > General**:

#### Workflow Permissions
- [ ] **Read repository contents permission**: ✅ **ENABLED**
- [ ] **Allow GitHub Actions to create and approve pull requests**: ❌ **DISABLED** (Security)

#### Fork Pull Request Workflows
- [ ] **Run workflows from fork pull requests**: ⚠️ **REQUIRE APPROVAL** (Security)

### Actions URL
```
https://github.com/letter-orgz/job-O-matic-/settings/actions
```

## 📱 Notifications Settings

### Default Notification Settings

Recommend team members configure:
- **Watching**: All activity for critical repositories
- **Email notifications**: Enabled for:
  - Issues and PRs you're mentioned in
  - Issues and PRs you're assigned to
  - Your own repositories

## 🔄 Codespaces Settings

### Organization Codespaces Policy

Navigate to **Organization Settings > Codespaces**:

- [ ] **Enable for organization repositories**: ✅ **ENABLED**
- [ ] **Billing**: Set to organization account
- [ ] **Spending limits**: Configure appropriate limits
- [ ] **Machine types**: Configure available types
- [ ] **Timeout**: Set reasonable limits (e.g., 30 minutes idle)

### Codespaces URL
```
https://github.com/organizations/letter-orgz/settings/codespaces
```

## 📋 Configuration Checklist

### Initial Setup (One-time)
- [ ] Main branch protection rules configured
- [ ] Automatic branch cleanup enabled
- [ ] Security settings enabled
- [ ] Team permissions configured
- [ ] Labels created and organized
- [ ] Codespaces billing configured

### Regular Maintenance (Monthly)
- [ ] Review access permissions
- [ ] Update security settings as needed
- [ ] Review and update labels
- [ ] Check Dependabot alerts
- [ ] Monitor workflow usage and permissions

### Security Review (Quarterly)
- [ ] Audit team access levels
- [ ] Review security alerts and actions
- [ ] Update branch protection rules if needed
- [ ] Review workflow permissions
- [ ] Validate compliance with organization policies

## 🆘 Troubleshooting

### Common Issues

#### Branch Protection Not Working
1. Check admin bypass settings
2. Verify team membership and permissions
3. Ensure rules are applied to correct branch patterns

#### Codespaces Billing Issues
1. Verify organization billing is configured
2. Check user permissions and team membership
3. Review spending limits and policies

#### Security Alerts Not Showing
1. Enable security features in repository settings
2. Check organization-level security policies
3. Verify admin permissions for security features

## 📞 Support

For issues with these settings:
1. **Repository issues**: Contact @letter-orgz/admins
2. **Organization settings**: Contact organization owners
3. **GitHub support**: For platform-level issues

---

**Implementation Timeline**: Complete initial setup within 1 week of repository governance implementation.