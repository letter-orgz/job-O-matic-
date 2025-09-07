# Load environment variables from .env if present
import os

try:
    from dotenv import load_dotenv

    load_dotenv()
except ImportError:
    pass  # dotenv not installed, skip
# import requests  # Uncomment when implementing real API calls
try:
    import requests

    _REQUESTS_AVAILABLE = True
except Exception:
    requests = None
    _REQUESTS_AVAILABLE = False

API_KEY = os.getenv("PERPLEXITY_API_KEY", "")
ENABLED = os.getenv("ENABLE_PERPLEXITY", "false").lower() in ("1", "true", "yes")
PERPLEXITY_API_URL = os.getenv(
    "PERPLEXITY_API_URL", ""
)  # set to real endpoint when available


def build_perplexity_prompt(profile: dict, filters: dict, limit: int = 30) -> str:
    """Build a prompt string including profile and filter fields for Perplexity.

    profile: {name, skills:[], experience_level, work_authorization}
    filters: {titles:[], location, remote:bool, salary_min, salary_max, exclude_companies:[], nice_to_have:[]}
    """
    titles = ", ".join(filters.get("titles", ["Software Engineer"]))
    skills_must = ", ".join(profile.get("skills", [])) or ""
    skills_pref = ", ".join(filters.get("nice_to_have", [])) or ""
    location = filters.get("location", "remote")
    remote_clause = (
        "remote allowed" if filters.get("remote", True) else f"in {location}"
    )
    auth = profile.get("work_authorization", "open to sponsorship")
    exclude = ""
    if filters.get("exclude_companies"):
        exclude = " Exclude companies: " + ", ".join(filters["exclude_companies"]) + "."
    salary_clause = ""
    if filters.get("salary_min") or filters.get("salary_max"):
        salary_clause = f" Salary range: {filters.get('salary_min','-')} to {filters.get('salary_max','-')}."
    prompt = (
        f"Find up to {limit} active job postings for {titles} ({profile.get('experience_level','mid')}). "
        f"Location: {remote_clause}. "
        f"Must-have skills: {skills_must}. "
        f"Preferred skills: {skills_pref}. "
        f"Work authorization: {auth}.{salary_clause}{exclude} "
        "Filter out staffing agencies and contract-only roles. Prioritize full-time roles. "
        "Return results as a JSON array of objects with keys: company, title, location, apply_url, description_snippet, posted_date, seniority, salary_estimate."
    )
    return prompt


def build_omar_prompt(
    roles_extra=None,
    window_days=14,
    max_items=20,
    include_random_online=True,
) -> str:
    roles = [
        "legal assistant",
        "paralegal",
        "legal researcher",
        "contract analyst",
        "compliance analyst",
        "regulatory analyst",
        "privacy",
        "GDPR",
        "legal ops",
        "policy officer",
        "legal technologist",
        "public sector legal",
    ]
    if roles_extra:
        roles.extend(roles_extra)

    random_block = (
        "• Also OK: (“research assistant” OR “online tutor law/government” OR “transcription” "
        "OR “content moderator” OR “legal content writer”)"
        if include_random_online
        else ""
    )

    return f"""
You are a job-search meta-agent. Find CURRENT openings that match this candidate, then return a structured list.

CANDIDATE
• Name: Omar
• Education: LLB complete; LLM finishes in ~2 months
• Location: Ilford, London (UK citizen; no sponsorship needed)
• Preferences: Remote or hybrid (London area OK), start ASAP; open to part-time/contract/freelance/temp-to-perm
• Seniority: Graduate / Entry / Junior
• Core strengths: legal research & writing, GDPR/privacy basics, contract analysis, compliance support, document review, AI-aware legal-tech
{random_block}

MUST FILTERS
• Geography: UK-eligible OR fully remote open to UK residents
• Level: graduate/entry/junior/assistant/analyst/associate
• Exclude: roles requiring solicitor qualification/pupillage/PQE; unpaid internships; MLM/crypto/commission-only; closed/expired

BOOST (prefer)
• Titles/keywords: ({' OR '.join(f'"{r}"' for r in roles)})
• Sources to check: Civil Service Jobs, Law Gazette Jobs, LinkedIn, Indeed UK, Otta, university boards
• Recency: posted within the last {window_days} days
• Deduplicate identical listings; prefer the direct company link.

RETURN FORMAT (JSON only)
{{
  "jobs": [{{ ... up to {max_items} items as specified ... }}],
  "meta": {{
    "query_terms_used": [...],
    "boards_touched": [...],
    "search_window_days": {window_days},
    "notes": "any assumptions/exclusions"
  }}
}}
Output ONLY the JSON.
""".strip()


def search_perplexity(prompt, dry_run=True):
    """
    Search Perplexity API with the given prompt.
    If dry_run is True or ENABLE_PERPLEXITY is not set, do not call the API.
    """
    if dry_run or not ENABLED or not API_KEY or API_KEY in ("DISABLED", "INVALID"):
        print("[DRY RUN] Would call Perplexity API with prompt:")
        print(prompt)
        # Optionally, load from sample_jobs.json for testing
        return []

    # Real API call (only when enabled and dry_run is False)
    if not PERPLEXITY_API_URL:
        print(
            "[NOT IMPLEMENTED] No PERPLEXITY_API_URL set; cannot perform real API call."
        )
        return []

    if not _REQUESTS_AVAILABLE:
        print(
            "Requests package not available in this environment; install 'requests' to enable live calls."
        )
        return []

    # Perform the HTTP request and return parsed JSON
    try:
        import requests as _requests

        headers = {
            "Authorization": f"Bearer {API_KEY}",
            "Content-Type": "application/json",
        }
        payload = {"query": prompt, "format": "json"}
        resp = _requests.post(
            PERPLEXITY_API_URL, headers=headers, json=payload, timeout=30
        )
        resp.raise_for_status()
        return resp.json()
    except Exception as e:
        # Catch broad exceptions here but keep the message concise for debugging.
        print("Error during Perplexity API call:", e)
        return []


def normalize_perplexity_results(raw_results) -> list:
    """Normalize raw Perplexity results (list or dict) into internal job dicts.

    Expected to return a list of dicts with keys: id, title, company, location, platform, apply_url, description, posted_date, status
    """
    jobs = []
    if not raw_results:
        return jobs
    # If raw_results is a dict with 'results' key, try to extract
    items = (
        raw_results
        if isinstance(raw_results, list)
        else raw_results.get("results") or raw_results
    )
    if not isinstance(items, list):
        return jobs
    for idx, it in enumerate(items, start=1):
        # Try common fields, fall back to safe names
        company = it.get("company") or it.get("employer") or ""
        title = it.get("title") or it.get("job_title") or ""
        location = it.get("location") or it.get("place") or ""
        apply_url = it.get("apply_url") or it.get("url") or it.get("link") or ""
        description = it.get("description_snippet") or it.get("description") or ""
        posted_date = it.get("posted_date") or it.get("date") or ""
        jobs.append(
            {
                "id": idx,
                "title": title,
                "company": company,
                "location": location,
                "platform": it.get("platform", "perplexity"),
                "apply_url": apply_url,
                "description": description,
                "posted_date": posted_date,
                "status": "NOT_APPLIED",
            }
        )
    return jobs


def save_jobs_to_file(jobs: list, out_path: str = "data/imports/sample_jobs.json"):
    """Save normalized jobs to a JSON file (creates parent dir if needed)."""
    from pathlib import Path

    p = Path(out_path)
    p.parent.mkdir(parents=True, exist_ok=True)
    import json

    p.write_text(json.dumps(jobs, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"Saved {len(jobs)} jobs to {p}")


def insert_jobs_into_db(jobs: list):
    """Insert or update jobs into the local database using src.models.Job"""
    try:
        from src.db import get_session
        from src.models import Job
    except Exception:
        print("DB helpers not available; ensure src/db.py and src/models.py exist.")
        return 0

    inserted = 0
    sess = get_session()
    try:
        for j in jobs:
            # try to find existing by apply_url
            existing = None
            if j.get("apply_url"):
                existing = (
                    sess.query(Job)
                    .filter(Job.apply_url == j.get("apply_url"))
                    .one_or_none()
                )
            if existing:
                # update fields
                existing.title = j.get("title") or existing.title
                existing.company = j.get("company") or existing.company
                existing.location = j.get("location") or existing.location
                existing.description = j.get("description") or existing.description
                existing.posted_date = j.get("posted_date") or existing.posted_date
            else:
                nj = Job(
                    title=j.get("title") or "",
                    company=j.get("company") or "",
                    location=j.get("location") or "",
                    apply_url=j.get("apply_url") or "",
                    description=j.get("description") or "",
                    posted_date=j.get("posted_date") or "",
                    status=j.get("status") or "NOT_APPLIED",
                )
                sess.add(nj)
                inserted += 1
        sess.commit()
    except Exception as e:
        print("Error inserting jobs into DB:", e)
        sess.rollback()
    finally:
        sess.close()

    return inserted


if __name__ == "__main__":
    # Example usage: dry run
    prompt = build_omar_prompt()
    search_perplexity(prompt, dry_run=True)
