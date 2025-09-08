#!/usr/bin/env python3
"""
PR Merge Readiness Checker
Analyzes open pull requests to determine which ones are ready to be merged.
"""

import requests
import sys
import os
from datetime import datetime
from typing import List, Dict, Any
import json


class PRChecker:
    def __init__(self, repo_owner: str, repo_name: str, token: str = None):
        self.repo_owner = repo_owner
        self.repo_name = repo_name
        self.base_url = "https://api.github.com"
        self.headers = {
            "Accept": "application/vnd.github.v3+json",
            "User-Agent": "PR-Merge-Checker/1.0"
        }
        if token:
            self.headers["Authorization"] = f"token {token}"
    
    def get_open_prs(self) -> List[Dict[Any, Any]]:
        """Fetch all open pull requests"""
        url = f"{self.base_url}/repos/{self.repo_owner}/{self.repo_name}/pulls"
        params = {"state": "open", "per_page": 100}
        
        try:
            response = requests.get(url, headers=self.headers, params=params)
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            print(f"Error fetching PRs: {e}")
            return []
    
    def get_pr_status(self, pr_number: int) -> Dict[str, Any]:
        """Get the status of a specific PR"""
        url = f"{self.base_url}/repos/{self.repo_owner}/{self.repo_name}/pulls/{pr_number}"
        
        try:
            response = requests.get(url, headers=self.headers)
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            print(f"Error fetching PR #{pr_number}: {e}")
            return {}
    
    def get_pr_reviews(self, pr_number: int) -> List[Dict[Any, Any]]:
        """Get reviews for a PR"""
        url = f"{self.base_url}/repos/{self.repo_owner}/{self.repo_name}/pulls/{pr_number}/reviews"
        
        try:
            response = requests.get(url, headers=self.headers)
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            print(f"Error fetching reviews for PR #{pr_number}: {e}")
            return []
    
    def get_pr_checks(self, sha: str) -> Dict[str, Any]:
        """Get check status for a commit"""
        url = f"{self.base_url}/repos/{self.repo_owner}/{self.repo_name}/commits/{sha}/status"
        
        try:
            response = requests.get(url, headers=self.headers)
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            print(f"Error fetching checks for commit {sha}: {e}")
            return {}
    
    def check_mergeable(self, pr_data: Dict[str, Any]) -> Dict[str, Any]:
        """Check if a PR is mergeable"""
        pr_number = pr_data["number"]
        
        # Get detailed PR info
        detailed_pr = self.get_pr_status(pr_number)
        
        # Get reviews
        reviews = self.get_pr_reviews(pr_number)
        
        # Get checks
        checks = self.get_pr_checks(pr_data["head"]["sha"])
        
        # Analyze readiness
        readiness = {
            "pr_number": pr_number,
            "title": pr_data["title"],
            "author": pr_data["user"]["login"],
            "draft": pr_data["draft"],
            "mergeable": detailed_pr.get("mergeable", None),
            "mergeable_state": detailed_pr.get("mergeable_state", "unknown"),
            "checks_status": checks.get("state", "pending"),
            "review_status": self._analyze_reviews(reviews),
            "updated_at": pr_data["updated_at"],
            "can_merge": False,
            "blocking_factors": []
        }
        
        # Determine blocking factors
        if readiness["draft"]:
            readiness["blocking_factors"].append("PR is marked as draft")
        
        if readiness["mergeable"] is False:
            readiness["blocking_factors"].append("Has merge conflicts")
        
        if readiness["checks_status"] != "success":
            readiness["blocking_factors"].append(f"Checks status: {readiness['checks_status']}")
        
        if readiness["review_status"]["needs_approval"]:
            readiness["blocking_factors"].append("Needs review approval")
        
        if readiness["review_status"]["has_requested_changes"]:
            readiness["blocking_factors"].append("Has requested changes")
        
        # PR is ready if no blocking factors
        readiness["can_merge"] = len(readiness["blocking_factors"]) == 0
        
        return readiness
    
    def _analyze_reviews(self, reviews: List[Dict[Any, Any]]) -> Dict[str, Any]:
        """Analyze review status"""
        if not reviews:
            return {
                "needs_approval": True,
                "has_approval": False,
                "has_requested_changes": False,
                "review_count": 0
            }
        
        # Get latest review from each reviewer
        latest_reviews = {}
        for review in reviews:
            reviewer = review["user"]["login"]
            latest_reviews[reviewer] = review
        
        has_approval = any(r["state"] == "APPROVED" for r in latest_reviews.values())
        has_requested_changes = any(r["state"] == "CHANGES_REQUESTED" for r in latest_reviews.values())
        
        return {
            "needs_approval": not has_approval,
            "has_approval": has_approval,
            "has_requested_changes": has_requested_changes,
            "review_count": len(latest_reviews)
        }
    
    def generate_report(self) -> None:
        """Generate a comprehensive merge readiness report"""
        print("🔍 Checking PR merge readiness...")
        print(f"Repository: {self.repo_owner}/{self.repo_name}")
        print(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("=" * 60)
        
        prs = self.get_open_prs()
        
        if not prs:
            print("No open pull requests found.")
            return
        
        ready_to_merge = []
        needs_attention = []
        
        for pr in prs:
            readiness = self.check_mergeable(pr)
            
            if readiness["can_merge"]:
                ready_to_merge.append(readiness)
            else:
                needs_attention.append(readiness)
        
        # Print ready to merge PRs
        print(f"\n✅ READY TO MERGE ({len(ready_to_merge)} PRs)")
        print("-" * 40)
        if ready_to_merge:
            for pr in ready_to_merge:
                print(f"#{pr['pr_number']}: {pr['title']}")
                print(f"   Author: {pr['author']}")
                print(f"   Updated: {pr['updated_at']}")
                print()
        else:
            print("No PRs are currently ready to merge.")
        
        # Print PRs needing attention
        print(f"\n⚠️  NEEDS ATTENTION ({len(needs_attention)} PRs)")
        print("-" * 40)
        for pr in needs_attention:
            print(f"#{pr['pr_number']}: {pr['title']}")
            print(f"   Author: {pr['author']}")
            print(f"   Blocking factors:")
            for factor in pr["blocking_factors"]:
                print(f"     • {factor}")
            print()
        
        # Summary
        print("=" * 60)
        print(f"SUMMARY: {len(ready_to_merge)} ready, {len(needs_attention)} need attention")
        
        # Save detailed report to file
        report_data = {
            "timestamp": datetime.now().isoformat(),
            "repository": f"{self.repo_owner}/{self.repo_name}",
            "ready_to_merge": ready_to_merge,
            "needs_attention": needs_attention,
            "summary": {
                "total_prs": len(prs),
                "ready_count": len(ready_to_merge),
                "needs_attention_count": len(needs_attention)
            }
        }
        
        os.makedirs("reports", exist_ok=True)
        report_file = f"reports/pr-merge-readiness-{datetime.now().strftime('%Y%m%d-%H%M%S')}.json"
        with open(report_file, 'w') as f:
            json.dump(report_data, f, indent=2)
        
        print(f"Detailed report saved to: {report_file}")


def main():
    """Main function"""
    # Get repository info from environment or command line
    repo_owner = os.getenv("GITHUB_REPOSITORY_OWNER", "letter-orgz")
    repo_name = os.getenv("GITHUB_REPOSITORY_NAME", "job-O-matic-")
    github_token = os.getenv("GITHUB_TOKEN")
    
    # Allow command line override
    if len(sys.argv) >= 3:
        repo_owner = sys.argv[1]
        repo_name = sys.argv[2]
    
    if len(sys.argv) >= 4:
        github_token = sys.argv[3]
    
    # Create checker and run report
    checker = PRChecker(repo_owner, repo_name, github_token)
    checker.generate_report()


if __name__ == "__main__":
    main()