# Job-O-Matic GitHub Copilot Instructions

This is a Python-based job application automation system built with Streamlit. It helps users automate job searching, CV tailoring, and application submission while maintaining human oversight and legal compliance.

## Project Overview

Job-O-Matic is an ethical job application automation tool that:
- Searches for jobs using AI-powered search (Perplexity API)
- Stores job data in SQLite database with SQLAlchemy ORM
- Allows bulk CV tailoring and application preparation
- Provides controlled auto-submission with rate limiting
- Maintains compliance with GDPR, anti-discrimination laws, and platform ToS

## Development Workflow

### Required Before Each Commit
- Run `python -m black .` to format Python code
- Ensure all new features include human oversight mechanisms
- Test Streamlit UI changes manually with `streamlit run app.py`
- Verify database migrations work correctly

### Build and Test
- **Install dependencies**: `pip install -r requirements.txt`
- **Run application**: `streamlit run app.py`
- **Database setup**: Automatically created on first run in `db/app.db`
- **Test imports**: `python -c "import app; print('OK')"`

## Repository Structure

- `app.py`: Main Streamlit application entry point
- `src/`: Core application modules
  - `models.py`: SQLAlchemy database models (Job table)
  - `db.py`: Database connection and session management
  - `pplx_search.py`: Perplexity API integration for job search
  - `apply/`: Job application submission modules
- `data/`: User data directory (gitignored)
  - `cv/`: User CV files in various formats
  - `templates/`: Email and cover letter templates
- `exports/`: Generated export files (gitignored)
- `outputs/`: Application bundles created for each job (gitignored)
- `.github/`: GitHub configuration and workflows
- Documentation files: `compliance_best_practices.md`, `implementation-guide.md`

## Key Coding Guidelines

### 1. Human-First Design
- Always require explicit user confirmation for automated actions
- Provide preview functionality before any submission
- Include manual override options for all automated processes
- Maintain clear audit trails of all automated decisions

### 2. Compliance and Ethics
- Respect API rate limits (max 0.2 requests/second for job boards)
- Implement proper data retention policies (default 90 days)
- Include bias prevention in CV tailoring algorithms
- Ensure GDPR compliance for all data processing

### 3. Error Handling and Resilience
- Use comprehensive try-catch blocks for API calls
- Implement exponential backoff for rate-limited APIs
- Gracefully handle file system errors (missing CV files, etc.)
- Provide clear user feedback for all error conditions

### 4. Database Patterns
- Use SQLAlchemy ORM with explicit session management
- Follow the pattern: `with Session() as s:` for database operations
- Always commit transactions explicitly
- Use proper indexing for frequently queried fields

### 5. Streamlit Best Practices
- Use `st.session_state` for maintaining state across reruns
- Implement proper page navigation in sidebar
- Use progress bars for long-running operations
- Cache expensive operations with `@st.cache_data`

## Technology Stack

- **Frontend**: Streamlit (Python web framework)
- **Backend**: Python 3.11+
- **Database**: SQLite with SQLAlchemy ORM
- **APIs**: Perplexity (job search), Greenhouse/Lever (job submission)
- **File Processing**: python-docx, pandas for data handling
- **Environment**: GitHub Codespaces ready with `.devcontainer`

## Security Considerations

- Store API keys in environment variables only (never commit)
- Use HTTPS for all external API communications
- Implement proper input validation for user uploads
- Regular security audits of file upload handling
- Encrypt sensitive data at rest when possible

## Testing Approach

- Manual testing required for Streamlit UI components
- Test database operations with sample data
- Verify API integrations with rate limiting
- Check file upload/download functionality
- Validate export formats (CSV, JSON)

## Common Issues and Solutions

1. **Database locked errors**: Use proper session context managers
2. **API rate limiting**: Implement 5-second delays between requests
3. **File not found errors**: Check paths are relative to project root
4. **Streamlit caching issues**: Clear cache with `st.cache_data.clear()`

## Legal and Ethical Constraints

- Never implement bulk scraping of job boards without permission
- Always maintain human review in the application process
- Respect platform Terms of Service for Greenhouse and Lever
- Implement cooling-off periods if bulk rejections occur
- Provide clear consent mechanisms for data processing

When making changes, prioritize user safety, legal compliance, and maintainability over automation speed or convenience.