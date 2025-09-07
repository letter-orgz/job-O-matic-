---
applyTo: "**/*.md"
---

# Documentation Instructions for Job-O-Matic

When working with Markdown documentation files, follow these guidelines:

## Documentation Standards

1. **Clear Structure** - Use proper heading hierarchy (H1, H2, H3)
2. **Code Examples** - Include working code examples with proper syntax highlighting
3. **User-Focused** - Write from the user's perspective with clear instructions
4. **Compliance Awareness** - Always include relevant legal and ethical considerations

## Content Guidelines

### Legal and Compliance Documentation
- Always emphasize human oversight requirements
- Include rate limiting and ToS compliance information
- Mention GDPR and anti-discrimination considerations
- Provide clear guidance on responsible usage

### Technical Documentation
- Include complete, working code examples
- Specify prerequisites and dependencies
- Provide troubleshooting information
- Include security considerations

### User Guides
- Use step-by-step instructions
- Include screenshots or examples where helpful
- Provide alternative approaches for different use cases
- Highlight important warnings and cautions

## File-Specific Guidelines

### README.md
- Keep the main project overview clear and concise
- Include quick start instructions
- Provide links to detailed documentation
- Mention key compliance and safety features

### compliance_best_practices.md
- Update with new compliance requirements
- Include specific examples of responsible usage
- Provide clear do's and don'ts
- Reference relevant laws and regulations

### implementation-guide.md
- Provide step-by-step implementation instructions
- Include code examples that can be copied directly
- Explain the rationale behind safety features
- Include testing and validation steps

## Formatting Standards

### Code Blocks
Always specify language for syntax highlighting:
```python
# Python code example
def example_function():
    return "properly formatted"
```

### Lists and Checklists
Use consistent formatting:
- Use `-` for unordered lists
- Use `1.` for ordered lists
- Use `- [ ]` for checkboxes
- Use `- [x]` for completed items

### Warnings and Alerts
Use appropriate emoji and formatting:
- ⚠️ for warnings
- ❌ for errors or things to avoid
- ✅ for success or completed items
- 🔒 for security-related content
- ⚖️ for legal/compliance content

### Links and References
- Use descriptive link text
- Include relevant external documentation
- Reference specific line numbers for code files
- Provide context for why links are relevant

## Content Maintenance

### When Updating Documentation
1. **Accuracy Check** - Ensure all instructions still work
2. **Consistency** - Maintain consistent terminology
3. **Completeness** - Don't leave incomplete information
4. **Cross-References** - Update related documentation

### Version Control
- Make incremental updates rather than large rewrites
- Explain significant changes in commit messages
- Keep historical context where relevant
- Archive outdated information rather than deleting

## Quality Checklist

Before updating documentation:

- [ ] Instructions are complete and accurate
- [ ] Code examples are tested and working
- [ ] Legal/compliance information is current
- [ ] Language is clear and user-friendly
- [ ] Links and references are valid
- [ ] Formatting is consistent
- [ ] No sensitive information is exposed
- [ ] Cross-references are updated

## Examples of Good Documentation

### Step-by-Step Instructions
```markdown
## Setting Up API Integration

1. **Obtain API Key**
   - Navigate to the platform's developer console
   - Generate a new API key with appropriate permissions
   - ⚠️ **Important**: Store this key securely

2. **Configure Environment**
   ```bash
   export PLATFORM_API_KEY="your_key_here"
   ```

3. **Test Connection**
   ```python
   from src.apply import test_connection
   success = test_connection("platform_name")
   ```
```

### Security Warning Example
```markdown
🔒 **Security Note**: Never commit API keys to version control. Always use environment variables or secure configuration files that are gitignored.
```

### Compliance Example
```markdown
⚖️ **Legal Compliance**: This feature requires explicit user consent and must respect platform rate limits. Ensure you have reviewed the compliance guidelines before implementation.
```