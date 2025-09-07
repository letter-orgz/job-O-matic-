# AI Agent Instructions for Job-O-Matic

This document provides guidelines for AI coding agents working on the Job-O-Matic project.

## Project Context

Job-O-Matic is an ethical job application automation system built with Python and Streamlit. The system prioritizes human oversight, legal compliance, and responsible automation practices.

## Core Principles

### 1. Human-First Automation
- Never remove human approval steps
- Always maintain preview functionality
- Provide clear confirmation dialogs
- Enable easy manual overrides

### 2. Legal and Ethical Compliance
- Respect platform Terms of Service
- Implement proper rate limiting (5+ second delays)
- Maintain GDPR compliance
- Include anti-discrimination safeguards

### 3. Technical Excellence
- Use proper error handling and recovery
- Implement comprehensive logging
- Follow established code patterns
- Maintain database integrity

## Development Guidelines

### Code Changes
- **Minimal modifications**: Change only what's necessary
- **Test thoroughly**: Verify changes don't break existing functionality
- **Follow patterns**: Maintain consistency with existing code
- **Document changes**: Update relevant documentation

### Database Operations
```python
# Always use this pattern for database operations
with Session() as s:
    try:
        # Database operations here
        s.commit()
    except Exception as e:
        s.rollback()
        raise
```

### API Integration
```python
# Always include rate limiting for external APIs
import time

def api_call():
    time.sleep(5)  # Minimum 5-second delay
    try:
        # API call here
        pass
    except Exception as e:
        # Proper error handling
        pass
```

### Streamlit UI
```python
# Use proper error handling in UI components
try:
    # UI logic here
    if success:
        st.success("✅ Operation completed")
    else:
        st.error("❌ Operation failed")
except Exception as e:
    st.error(f"❌ Unexpected error: {e}")
```

## File Structure Awareness

- `app.py` - Main Streamlit application
- `src/models.py` - Database models (Job table)
- `src/db.py` - Database session management
- `src/apply/` - Job submission modules
- `data/` - User data (CVs, templates)
- `exports/` - Generated files
- `outputs/` - Application bundles

## Security Requirements

1. **API Keys**: Store in environment variables only
2. **Input Validation**: Sanitize all user inputs
3. **File Operations**: Validate file paths and types
4. **Database**: Use parameterized queries

## Testing Approach

1. **Manual Testing**: Required for Streamlit UI changes
2. **Database Testing**: Test with sample data
3. **API Testing**: Use mock responses when possible
4. **Error Testing**: Verify error handling works

## Common Patterns

### Status Management
Jobs follow this status flow:
`NOT_APPLIED` → `PREVIEW_READY` → `APPROVED` → `SENT`

### File Organization
- CVs in `data/cv/`
- Generated applications in `outputs/{company}_{title}/`
- Exports in `exports/`

### Error Handling
Always provide user-friendly error messages and log detailed errors for debugging.

## Restrictions

### What NOT to do:
- Remove human approval mechanisms
- Implement bulk scraping without rate limits
- Store sensitive data in plain text
- Remove compliance safeguards
- Break existing functionality

### What TO do:
- Enhance existing features safely
- Add new compliance checks
- Improve error handling
- Optimize performance without breaking functionality
- Add helpful documentation

## Quality Checklist

Before completing any task:

- [ ] Code follows established patterns
- [ ] Error handling is comprehensive
- [ ] Rate limiting is maintained
- [ ] Human oversight is preserved
- [ ] Database operations use proper sessions
- [ ] UI provides clear feedback
- [ ] Documentation is updated
- [ ] No sensitive data is exposed
- [ ] Existing tests still pass
- [ ] New functionality is tested

## Getting Help

When uncertain about changes:
1. Review existing similar code for patterns
2. Check compliance documentation
3. Verify changes don't impact user safety
4. Ask for clarification if requirements are unclear

Remember: The goal is to enhance the system while maintaining its ethical, legal, and technical integrity.