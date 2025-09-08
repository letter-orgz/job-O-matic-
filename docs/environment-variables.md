# Environment Variables

| Variable | Purpose | Required | Default |
|----------|---------|----------|---------|
| `PERPLEXITY_API_KEY` | Access key for Perplexity job search API. | No | `` |
| `MODEL` | Perplexity model selection. | No | `sonar-pro` |
| `PERPLEXITY_API_URL` | Override endpoint for Perplexity API. | No | `` |
| `ENABLE_PERPLEXITY` | Toggle Perplexity integrations. | No | `false` |
| `APP_DB` | Path to application database. | No | `./db/app.db` |
| `JOB_O_MATIC_DATABASE_URL` | SQLAlchemy connection string for main app database. | No | `sqlite:///data/jobs.db` |
| `GREENHOUSE_API_KEY` | API key for Greenhouse submissions. | No | `` |
| `LEVER_API_KEY` | API key for Lever submissions. | No | `` |
| `CANDIDATE_FIRST_NAME` | Applicant first name. | Yes | `Omar` |
| `CANDIDATE_LAST_NAME` | Applicant last name. | Yes | `Runjanally` |
| `CANDIDATE_EMAIL` | Applicant contact email. | Yes | `your_email@example.com` |
| `CANDIDATE_PHONE` | Applicant contact phone. | Yes | `+44 XXX XXX XXXX` |
| `API_RATE_LIMIT` | Requests per second cap for external APIs. | No | `0.2` |
| `ENABLE_AUTO_SUBMIT` | Allow automatic job application submission. | No | `false` |
| `REQUIRE_HUMAN_CONFIRMATION` | Require manual approval before sending applications. | No | `true` |
| `DATA_RETENTION_DAYS` | Days to retain stored data. | No | `90` |
| `GITHUB_REPOSITORY_OWNER` | Owner for PR merge reports. | No | `letter-orgz` |
| `GITHUB_REPOSITORY_NAME` | Repository name for PR merge reports. | No | `job-O-matic-` |
| `GITHUB_TOKEN` | GitHub API token for PR merge checks. | No | `` |
| `STREAMLIT_HEADLESS` | Disable Streamlit server GUI when set. | No | `0` |
