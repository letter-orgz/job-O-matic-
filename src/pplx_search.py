
# Load environment variables from .env if present
import os
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass  # dotenv not installed, skip
# import requests  # Uncomment when implementing real API calls

API_KEY = os.getenv("PERPLEXITY_API_KEY", "")
ENABLED = os.getenv("ENABLE_PERPLEXITY", "false").lower() in ("1", "true", "yes")

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
    # Uncomment and implement real API call here
    # headers = {"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"}
    # payload = {"query": prompt, "format": "json"}
    # resp = requests.post(PERPLEXITY_API_URL, headers=headers, json=payload, timeout=30)
    # resp.raise_for_status()
    # return resp.json()
    print("[NOT IMPLEMENTED] Real API call would happen here.")
    return []

if __name__ == "__main__":
    # Example usage: dry run
    search_perplexity("Find remote Python jobs in Europe.")