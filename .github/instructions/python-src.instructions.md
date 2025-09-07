---
applyTo: "src/**/*.py"
---

# Python Code Instructions for Job-O-Matic

When working with Python files in the `src/` directory, follow these guidelines:

## Code Style and Formatting

1. **Use Black formatter** - All Python code must be formatted with Black before committing
2. **Follow PEP 8** - Use descriptive variable names, proper spacing, and docstrings
3. **Type hints** - Include type hints for function parameters and return values where helpful
4. **Docstrings** - Use Google-style docstrings for all public functions and classes

## Database Operations

1. **Use context managers** - Always use `with Session() as s:` for database operations
2. **Explicit commits** - Always call `s.commit()` explicitly after database changes
3. **Error handling** - Wrap database operations in try-catch blocks
4. **Model imports** - Import models from `src.models` consistently

Example database pattern:
```python
from src.db import Session
from src.models import Job

def update_job_status(job_id: int, new_status: str) -> bool:
    """Update job status with proper error handling."""
    try:
        with Session() as s:
            job = s.query(Job).filter(Job.id == job_id).first()
            if job:
                job.status = new_status
                s.add(job)
                s.commit()
                return True
            return False
    except Exception as e:
        logger.error(f"Failed to update job {job_id}: {e}")
        return False
```

## API Integration

1. **Rate limiting** - Always implement rate limiting for external APIs (max 0.2 req/sec)
2. **Error handling** - Use comprehensive try-catch for network requests
3. **Timeouts** - Set reasonable timeouts for all HTTP requests
4. **Retries** - Implement exponential backoff for transient failures

Example API call pattern:
```python
import time
import requests
from typing import Dict, Tuple

def api_call_with_rate_limit(url: str, data: Dict) -> Tuple[bool, str]:
    """Make API call with built-in rate limiting."""
    time.sleep(5)  # Rate limiting
    
    try:
        response = requests.post(url, json=data, timeout=30)
        response.raise_for_status()
        return True, response.text
    except requests.exceptions.RequestException as e:
        return False, f"API call failed: {e}"
```

## File Operations

1. **Path handling** - Use `pathlib.Path` for all file operations
2. **Encoding** - Always specify UTF-8 encoding for text files
3. **Error handling** - Check file existence before operations
4. **Cleanup** - Close file handles properly or use context managers

## Security Best Practices

1. **Input validation** - Validate all user inputs and file uploads
2. **Path traversal** - Prevent directory traversal attacks in file operations
3. **API keys** - Never hardcode API keys, use environment variables
4. **Sanitization** - Sanitize user data before database storage

## Testing Considerations

1. **Testable functions** - Write functions that can be easily unit tested
2. **Mock external calls** - Mock API calls and file operations in tests
3. **Edge cases** - Handle empty inputs, missing files, network failures
4. **Logging** - Add appropriate logging for debugging and monitoring