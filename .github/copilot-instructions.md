# Job-O-Matic Development Instructions

**ALWAYS follow these instructions first and only search for additional context if the information here is incomplete or found to be in error.**

## System Overview
Job-O-Matic is a Python-based job application automation system that helps users:
- Search and manage job opportunities
- Tailor CVs using AI (Perplexity API)
- Generate personalized applications
- Export data for tracking
- Bulk process applications with human oversight
- Submit applications to supported platforms (Greenhouse, Lever)

## Working Effectively

### Bootstrap and Setup
Run these commands in order to set up the development environment:

```bash
# 1. Install Python dependencies
pip install streamlit>=1.28.0 requests>=2.31.0 python-dotenv>=1.0.0 pyyaml>=6.0 sqlalchemy>=2.0.0 python-docx>=0.8.11 pandas>=2.0.0 urllib3>=2.0.0 certifi>=2023.0.0
# NOTE: Installation may take 5-10 minutes due to dependencies. NEVER CANCEL. Set timeout to 15+ minutes.

# 2. Test core functionality (takes ~10 seconds)
python3 test_app.py

# 3. Run the main application
streamlit run app.py --server.port 8501
# NOTE: Streamlit startup takes 30-60 seconds. NEVER CANCEL. Set timeout to 120+ seconds.
```

### Directory Structure Requirements
The system expects this exact directory structure:

```
job-o-matic/
├── .github/
│   └── copilot-instructions.md      # ← This file
├── app.py                           # ← Main Streamlit application
├── test_app.py                      # ← Environment test script
├── data/cv/                         # ← CV files storage
├── src/
│   ├── ui/                          # ← UI components
│   ├── apply/                       # ← Application submission modules
│   │   ├── __init__.py
│   │   ├── submit_greenhouse.py
│   │   └── submit_lever.py
│   ├── bulk_ops.py                  # ← Bulk operations
│   └── exporter.py                  # ← Export functionality
├── db/                              # ← SQLite database files
├── exports/                         # ← Generated export files
├── outputs/                         # ← Generated application bundles
├── requirements.txt                 # ← Python dependencies
├── config_template.env              # ← Configuration template
└── compliance_best_practices.md     # ← Legal/compliance guide
```

**CRITICAL**: Always create missing directories before running the application. Use `mkdir -p` to create the full path.

### Testing and Validation

#### Environment Test (REQUIRED before any changes)
```bash
python3 test_app.py
# Expected time: 10-15 seconds. NEVER CANCEL. Set timeout to 60+ seconds.
# This validates: directories, database, CV files, exports, core modules
```

#### Database Operations Test
```bash
# Test database creation and basic operations
python3 -c "
import sqlite3
from pathlib import Path
Path('db').mkdir(exist_ok=True)
conn = sqlite3.connect('db/app.db')
cursor = conn.cursor()
cursor.execute('CREATE TABLE IF NOT EXISTS jobs (id INTEGER PRIMARY KEY, company TEXT, title TEXT)')
cursor.execute('INSERT INTO jobs (company, title) VALUES (?, ?)', ('Test Co', 'Test Role'))
conn.commit()
print('Database test: PASSED')
conn.close()
"
```

#### Streamlit Application Test
```bash
# Test that the application starts without errors
timeout 120 streamlit run app.py --server.headless true --server.port 8502 &
# Wait for startup (30-60 seconds typical)
sleep 60
# Test if port is responding
curl -f http://localhost:8502 >/dev/null 2>&1 && echo "Streamlit: RUNNING" || echo "Streamlit: FAILED"
# Kill the test instance
pkill -f "streamlit run app.py"
# NEVER CANCEL during startup - Streamlit needs time to initialize all dependencies
```

## Critical Timing and Timeout Information

### Command Timeouts (NEVER CANCEL these operations)
- **Dependency Installation**: 15+ minutes (network dependent)
- **Streamlit Startup**: 2+ minutes first time, 30-60 seconds subsequent
- **Database Operations**: 10-30 seconds for large datasets
- **CV Processing**: 5-15 seconds per file
- **Export Operations**: 10-60 seconds depending on data size
- **Bulk Processing**: 1-5 seconds per job + I/O time

### Performance Expectations
- Environment test: ~10 seconds
- Database init: ~5 seconds
- Single job processing: ~2 seconds
- Bulk operation (10 jobs): ~20-30 seconds
- Export (100 jobs): ~10 seconds
- Application startup: 30-60 seconds

## Core Functionality

### Database Operations
The system uses SQLite with this schema:
```sql
CREATE TABLE jobs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    company TEXT NOT NULL,
    title TEXT NOT NULL,
    apply_url TEXT,
    job_desc_snippet TEXT,
    status TEXT DEFAULT 'NOT_APPLIED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Always validate database connectivity before making changes that involve data operations.**

### CV File Management
- CV files stored in `data/cv/`
- Supported formats: .docx, .pdf, .txt
- Naming convention: `{variant_name}_cv.{ext}`
- Always check file existence before processing
- Current variants: Business, Legal, Communications, Mediation

### Status Flow
```
NOT_APPLIED → PENDING → SENT → [REJECTED|INTERVIEW]
```

**Always preserve this status flow in any changes to prevent data corruption.**

## Validation Scenarios

### After Making Changes - MANDATORY Tests

#### 1. Full Application Workflow Test
```bash
# Start the application
streamlit run app.py &
sleep 60  # Wait for startup

# Test scenario: Add job → Process → Export
# 1. Navigate to Dashboard
# 2. Add test jobs via sidebar
# 3. Go to Job Management → update a job status
# 4. Go to Bulk Operations → select and process jobs
# 5. Go to Export Data → export CSV and JSON
# 6. Verify files are created in exports/

# Always test this complete flow after UI changes
```

#### 2. Database Integrity Test
```bash
# After any database-related changes
python3 -c "
import sqlite3
import pandas as pd
conn = sqlite3.connect('db/app.db')
df = pd.read_sql('SELECT * FROM jobs', conn)
print(f'Jobs in database: {len(df)}')
print('Status distribution:')
print(df['status'].value_counts())
conn.close()
"
```

#### 3. File System Test
```bash
# After any file operation changes
python3 -c "
from pathlib import Path
dirs = ['data/cv', 'exports', 'outputs', 'db']
for d in dirs:
    path = Path(d)
    files = list(path.glob('*.*')) if path.exists() else []
    print(f'{d}: {len(files)} files')
"
```

## Common Development Tasks

### Adding New Features
1. **Always run environment test first**: `python3 test_app.py`
2. **Test database connectivity**: Verify `db/app.db` is accessible
3. **Check CV files availability**: Ensure `data/cv/` has test files
4. **Implement with error handling**: All functions must handle missing files/network issues
5. **Test the complete user workflow**: From adding jobs to exporting results
6. **Run timing tests**: Measure operation duration for timeout recommendations

### Debugging Failed Operations
1. **Check logs**: Streamlit logs appear in terminal
2. **Verify file paths**: Use absolute paths, check file existence
3. **Test database**: Run SQLite commands directly to verify data
4. **Check network**: API calls may fail due to connectivity
5. **Validate input data**: Ensure data formats match expectations

### Before Committing Changes
**MANDATORY validation steps:**
```bash
# 1. Environment test
python3 test_app.py

# 2. Application startup test
timeout 120 streamlit run app.py --server.headless true --server.port 8503 &
sleep 60
curl -f http://localhost:8503 >/dev/null && echo "PASS" || echo "FAIL"
pkill -f "streamlit.*8503"

# 3. Database integrity check
python3 -c "import sqlite3; conn = sqlite3.connect('db/app.db'); print('DB Status:', 'OK' if conn.execute('SELECT COUNT(*) FROM jobs').fetchone()[0] >= 0 else 'ERROR'); conn.close()"
```

## API and External Dependencies

### Perplexity API (CV Tailoring)
- **Rate Limit**: 10 requests/minute (6 seconds between calls)
- **Timeout**: 30 seconds per request
- **Error Handling**: Graceful fallback to generic CV content

### Job Platform APIs
- **Greenhouse**: Official API, requires authentication
- **Lever**: API key authentication, strict rate limits
- **Rate Limiting**: 0.2 requests/second (5 seconds between calls)
- **NEVER** attempt to bypass rate limits or use unofficial methods

### Installation Dependencies
If `pip install` fails due to network issues:
```bash
# Alternative: Try with increased timeout
pip install --timeout 300 streamlit requests python-dotenv

# Alternative: Install from wheel files if available
# Check if there are wheel files in the repository first
```

## Compliance and Safety

### CRITICAL Safety Rules
1. **Human Oversight Required**: Never auto-submit without explicit user confirmation
2. **Rate Limiting Mandatory**: Always implement delays between API calls
3. **Data Protection**: Handle personal data (CVs, emails) securely
4. **Platform Compliance**: Respect job platform Terms of Service
5. **Error Reporting**: Log all operations for audit trails

### Testing Data Privacy
- Use test/mock data for development
- Never commit real CV files or personal information
- Sanitize logs before sharing

## Project-Specific Details

### Key Files and Their Purpose
- `app.py`: Main Streamlit application entry point
- `test_app.py`: Environment validation and testing
- `job_automation_enhancements.py`: Legacy enhancement code (reference only)
- `config_template.env`: Configuration template (copy to `.env`)
- `compliance_best_practices.md`: Legal and ethical guidelines

### Expected URLs and Endpoints
- **Local Development**: http://localhost:8501 (Streamlit default)
- **Database**: SQLite file at `db/app.db`
- **Exports**: Files saved to `exports/` directory
- **Application Bundles**: Generated in `outputs/` directory

### Environment Variables (Optional)
```bash
# Copy config_template.env to .env and configure:
PERPLEXITY_API_KEY=your_key_here
GREENHOUSE_API_KEY=your_key_here
LEVER_API_KEY=your_key_here
CANDIDATE_EMAIL=your_email@example.com
```

## Troubleshooting Common Issues

### "Streamlit not found"
```bash
pip install streamlit
# If that fails: pip install --user streamlit
# Typical install time: 5-10 minutes
```

### "Database locked" errors
```bash
# Check for hanging connections
lsof db/app.db
# Kill processes if needed, restart application
```

### "CV files not found"
```bash
# Ensure CV files exist in data/cv/
ls -la data/cv/
# Copy from raw cv files if needed
cp "raw cv files"/* data/cv/
```

### Application won't start
```bash
# Check Python version (requires 3.8+)
python3 --version
# Check dependencies
python3 -c "import streamlit, pandas, sqlite3; print('Dependencies OK')"
# Check file permissions
ls -la app.py  # Should be readable
```

## Performance Optimization

### For Large Datasets (>1000 jobs)
- Use database pagination: `LIMIT 100 OFFSET {page * 100}`
- Implement background processing for bulk operations
- Add progress indicators for long-running operations

### Memory Management
- Process CV files one at a time to avoid memory issues
- Clear large variables after processing
- Use generators for large dataset iterations

---

**Remember: Always test the complete user workflow after making any changes. The system is designed for job seekers who need reliable, compliant automation - stability and accuracy are more important than speed.**