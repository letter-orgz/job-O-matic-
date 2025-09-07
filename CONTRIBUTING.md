# Contributing to Job-O-Matic

Welcome to the Job-O-Matic project! We're excited to have you contribute to this job application automation tool. This guide will help you understand our development process and contribution standards.

## 🚀 Getting Started

### Prerequisites
- Python 3.11 or higher
- Git
- GitHub account with access to the letter-orgz organization

### Development Environment Setup
1. **Using GitHub Codespaces (Recommended)**
   - Click the green "Code" button on the repository
   - Select "Codespaces" tab
   - **IMPORTANT**: Verify billing shows "letter-orgz" before creating
   - Click "Create codespace on main"
   - Run `./start.sh` when setup is complete

2. **Local Development**
   ```bash
   git clone https://github.com/letter-orgz/job-O-matic-.git
   cd job-O-matic-
   pip install -r requirements.txt
   streamlit run app.py
   ```

## 🌿 Branch Naming Conventions

Use the following naming patterns for your branches:

### Feature Branches
- `feature/short-description` - New features
- `feature/issue-123-add-feature` - Features linked to specific issues

### Bug Fix Branches
- `fix/short-description` - General bug fixes
- `fix/issue-123-bug-description` - Bug fixes linked to specific issues
- `hotfix/critical-issue` - Critical production fixes

### Documentation Branches
- `docs/update-readme` - Documentation updates
- `docs/api-documentation` - API or code documentation

### Maintenance Branches
- `chore/update-dependencies` - Dependency updates
- `chore/cleanup-code` - Code cleanup and refactoring
- `ci/update-workflows` - CI/CD pipeline updates

### Examples
✅ Good branch names:
- `feature/bulk-job-application`
- `fix/issue-42-cv-parsing-error`
- `docs/contributing-guidelines`
- `chore/update-streamlit`

❌ Avoid:
- `my-changes`
- `test`
- `branch-1`
- `temp-fix`

## 📝 Pull Request Process

### Before Creating a PR
1. **Test Your Changes**
   ```bash
   # Run the application
   streamlit run app.py
   
   # Run any existing tests
   pytest
   
   # Check code formatting
   black --check .
   ```

2. **Update Documentation**
   - Update README.md if your changes affect usage
   - Update docstrings for new or modified functions
   - Add or update comments for complex logic

3. **Create Meaningful Commits**
   ```bash
   git commit -m "feat: add bulk job application feature"
   git commit -m "fix: resolve CV parsing error for Word documents"
   git commit -m "docs: update API documentation"
   ```

### PR Requirements
- [ ] Descriptive title and description
- [ ] Link to related issues using "Closes #123" or "Fixes #123"
- [ ] Tests pass (if applicable)
- [ ] Code follows project style guidelines
- [ ] Documentation updated (if needed)
- [ ] No sensitive information (API keys, credentials) committed

### PR Template
When creating a PR, include:
1. **What**: Brief description of changes
2. **Why**: Reason for the changes
3. **How**: Technical approach taken
4. **Testing**: How you tested the changes
5. **Screenshots**: For UI changes

## 🐛 Issue Reporting

### Bug Reports
Use the "Bug Report" issue template and include:
- Clear description of the problem
- Steps to reproduce
- Expected vs. actual behavior
- Environment details (OS, Python version, browser)
- Screenshots or error logs

### Feature Requests
Use the "Feature Request" issue template and include:
- Clear description of the proposed feature
- Use case and business value
- Acceptance criteria
- Any design considerations

### Security Issues
For security vulnerabilities:
- **DO NOT** create a public issue
- Contact @letter-orgz/admins directly
- Use responsible disclosure practices

## 🎨 Code Style Guidelines

### Python Code Style
- Follow PEP 8 conventions
- Use `black` for code formatting
- Maximum line length: 88 characters
- Use type hints where appropriate
- Write descriptive function and variable names

### Documentation Style
- Use clear, concise language
- Include code examples for complex features
- Keep README.md updated with new features
- Use proper Markdown formatting

### Commit Message Format
Follow conventional commit format:
```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

## 🔒 Security and Compliance

### Data Protection
- Never commit sensitive data (API keys, personal information)
- Use environment variables for configuration
- Follow GDPR/privacy guidelines for user data
- Implement proper error handling

### Platform Compliance
- Respect API rate limits (max 0.2 requests/second)
- Only support official APIs (Greenhouse, Lever)
- Include human oversight in automated processes
- Maintain audit trails for all actions

### Pre-commit Hooks
Install the pre-commit hooks to prevent committing sensitive data:
```bash
./scripts/install-hooks.sh
```

## 🧪 Testing Guidelines

### Manual Testing
1. Test new features thoroughly
2. Verify existing functionality still works
3. Test with different CV formats and job types
4. Check error handling and edge cases

### Automated Testing
- Write unit tests for new functions
- Include integration tests for API interactions
- Test with sample data, not real personal information

## 📚 Resources

### Documentation
- [Streamlit Documentation](https://docs.streamlit.io/)
- [Greenhouse API Docs](https://developers.greenhouse.io/job-board.html)
- [Lever API Docs](https://github.com/lever/postings-api)
- [GitHub Flow Guide](https://guides.github.com/introduction/flow/)

### Project-Specific
- [Implementation Guide](implementation-guide.md)
- [Compliance Best Practices](compliance_best_practices.md)
- [Codespace Billing Guide](.github/CODESPACES_BILLING.md)

## 🤝 Code of Conduct

### Our Standards
- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Respect different perspectives and experiences

### Unacceptable Behavior
- Harassment or discrimination
- Trolling or insulting comments
- Publishing private information
- Any other unprofessional conduct

## 📞 Getting Help

### Community Support
- Create an issue for bugs or feature requests
- Join discussions in existing issues
- Review and comment on pull requests

### Maintainer Contact
- For urgent issues: Contact @letter-orgz/admins
- For general questions: Create a discussion issue
- For security concerns: Direct message organization admins

## 🎉 Recognition

Contributors will be recognized in:
- Project README.md contributors section
- Release notes for significant contributions
- Special mentions for outstanding community involvement

Thank you for contributing to Job-O-Matic! Your efforts help make job searching more efficient and accessible for everyone.