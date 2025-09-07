---
applyTo: "src/apply/**/*.py"
---

# Job Application Submission Instructions

Files in the `src/apply/` directory handle job application submissions to various platforms. Follow these critical guidelines:

## Legal and Ethical Requirements

1. **Human Oversight** - NEVER submit applications without explicit human approval
2. **Rate Limiting** - ALWAYS implement minimum 5-second delays between API calls
3. **Platform Compliance** - Respect each platform's Terms of Service
4. **Data Accuracy** - Ensure all submitted data is accurate and user-verified

## API Integration Patterns

1. **Authentication** - Use proper API key authentication for each platform
2. **Error Handling** - Implement comprehensive error handling and user feedback
3. **Response Validation** - Validate API responses before marking submissions as successful
4. **Logging** - Log all submission attempts with outcomes for audit trails

## Required Function Signature Pattern

All submission functions should follow this pattern:

```python
def submit_to_platform(job_row: Dict, candidate_data: Dict, bundle_dir: str, api_key: str) -> Tuple[bool, str]:
    """
    Submit application to job platform with rate limiting and error handling.
    
    Args:
        job_row: Dictionary containing job information from database
        candidate_data: Dictionary with candidate information and preferences
        bundle_dir: Path to directory containing CV and cover letter files
        api_key: Platform-specific API key for authentication
    
    Returns:
        Tuple of (success: bool, message: str)
    """
    # CRITICAL: Rate limiting - minimum 5 seconds
    time.sleep(5)
    
    try:
        # Implementation here
        pass
    except Exception as e:
        return False, f"Submission failed: {e}"
```

## Platform-Specific Guidelines

### Greenhouse API
- Use Basic authentication with API key as username
- Convert job board URLs to API endpoints when needed
- Handle file uploads as multipart/form-data
- Validate required fields before submission

### Lever API
- Use token-based authentication in headers
- Parse company and posting ID from job URLs
- Handle different URL formats (jobs.lever.co vs company.lever.co)
- Include proper Content-Type headers

## File Handling

1. **File Validation** - Always verify files exist before attempting upload
2. **File Types** - Support PDF, DOC, and DOCX formats
3. **File Size** - Check file size limits for each platform
4. **Error Recovery** - Handle file read errors gracefully

## Security Considerations

1. **API Key Protection** - Never log or expose API keys in error messages
2. **Input Sanitization** - Sanitize all user inputs before API submission
3. **SSL/TLS** - Use HTTPS for all API communications
4. **Error Information** - Don't expose sensitive details in error messages

## Status Tracking

Update job status appropriately:
- Before submission: Status should be "APPROVED"
- On success: Update to "SENT" with timestamp
- On failure: Keep as "APPROVED" with error message
- Include submission timestamp and response details

## Testing and Validation

1. **Dry Run Mode** - Implement dry run capability for testing
2. **Mock Responses** - Test with mock API responses
3. **Error Scenarios** - Test various error conditions
4. **Rate Limit Testing** - Verify rate limiting works correctly

## Example Implementation Template

```python
import time
import requests
import base64
from pathlib import Path
from typing import Dict, Tuple

def submit_to_example_platform(job_row: Dict, candidate_data: Dict, bundle_dir: str, api_key: str) -> Tuple[bool, str]:
    """Submit application to example platform."""
    
    # MANDATORY rate limiting
    time.sleep(5)
    
    try:
        # Validate inputs
        if not api_key:
            return False, "API key is required"
        
        cv_path = Path(bundle_dir) / "cv.pdf"
        if not cv_path.exists():
            return False, "CV file not found"
        
        # Prepare API request
        headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        }
        
        payload = {
            "first_name": candidate_data["first_name"],
            "last_name": candidate_data["last_name"],
            "email": candidate_data["email"],
            "phone": candidate_data.get("phone", ""),
            "job_id": extract_job_id(job_row["apply_url"])
        }
        
        # Make API call with timeout
        response = requests.post(
            f"https://api.example.com/applications",
            json=payload,
            headers=headers,
            timeout=30
        )
        
        response.raise_for_status()
        return True, f"Application submitted successfully: {response.json().get('id', 'N/A')}"
        
    except requests.exceptions.RequestException as e:
        return False, f"Network error: {e}"
    except Exception as e:
        return False, f"Submission failed: {e}"
```

## Monitoring and Compliance

1. **Audit Logs** - Log all submission attempts with timestamps
2. **Success Rates** - Track success/failure rates by platform
3. **Error Analysis** - Monitor common error patterns
4. **Compliance Checks** - Regular reviews of submission patterns and rates