# Create the advanced UI enhancements and real submission logic

cv_file_viewer = '''
# =====================================================================
# Enhanced UI components for dashboard.py - CV File Viewer
# =====================================================================

# Add this function to your dashboard.py after the existing code:

def render_cv_file_viewer(variant, variant_file):
    """Render CV file viewer with download/preview capabilities"""
    cv_path = Path("data/cv") / variant_file
    
    if cv_path.exists():
        col1, col2 = st.columns([3, 1])
        
        with col1:
            st.write(f"📄 **CV File**: `{variant_file}` ({cv_path.stat().st_size // 1024} KB)")
            
            # Show file preview for supported formats
            if variant_file.endswith('.pdf'):
                st.info("📖 PDF preview available for download")
            elif variant_file.endswith(('.docx', '.doc')):
                st.info("📝 Word document - use download to review")
            else:
                st.warning("⚠️ Unsupported file format for preview")
        
        with col2:
            # Download button for the CV file
            with open(cv_path, "rb") as f:
                st.download_button(
                    label="📥 Download CV",
                    data=f.read(),
                    file_name=variant_file,
                    mime="application/octet-stream",
                    key=f"cv_download_{variant}"
                )
    else:
        st.error(f"❌ CV file not found: `{variant_file}`")
        st.info("Please ensure the CV file exists in the `data/cv/` directory")

# Add this to replace the CV variant line in your preview section:
# Instead of: st.write(f"Suggested CV variant: **{variant}**  ·  file: `{variant_file}`")
# Use:
st.write(f"**Selected CV variant**: {variant}")
render_cv_file_viewer(variant, variant_file)
'''

real_submitters = '''
# =====================================================================  
# src/apply/submit_greenhouse.py - Real Greenhouse API submission
# =====================================================================
import requests
import base64
from pathlib import Path
from typing import Dict, Optional, Tuple

def submit_greenhouse(job_row: Dict, candidate_data: Dict, bundle_dir: str, api_key: str) -> Tuple[bool, str]:
    """Submit application to Greenhouse job board"""
    
    try:
        # Extract board token and job ID from URL
        # Example: https://boards-api.greenhouse.io/v1/boards/company/jobs/123456
        url_parts = job_row["apply_url"].split('/')
        
        if "boards-api.greenhouse.io" not in job_row["apply_url"]:
            # Try to convert job board URL to API URL
            if "boards.greenhouse.io" in job_row["apply_url"]:
                # Convert https://boards.greenhouse.io/company/jobs/123456 
                # to https://boards-api.greenhouse.io/v1/boards/company/jobs/123456
                api_url = job_row["apply_url"].replace("boards.greenhouse.io", "boards-api.greenhouse.io/v1/boards")
            else:
                return False, "Unable to determine Greenhouse API endpoint"
        else:
            api_url = job_row["apply_url"]
        
        # Prepare authentication
        auth_string = base64.b64encode(f"{api_key}:".encode()).decode()
        headers = {
            "Authorization": f"Basic {auth_string}",
            "User-Agent": "Job-O-Matic/1.0"
        }
        
        # Prepare form data
        form_data = {
            "first_name": candidate_data.get("first_name", ""),
            "last_name": candidate_data.get("last_name", ""), 
            "email": candidate_data.get("email", ""),
            "phone": candidate_data.get("phone", ""),
        }
        
        # Add cover letter if available
        bundle_path = Path(bundle_dir)
        cover_letter_path = bundle_path / "email_body.txt"
        if cover_letter_path.exists():
            cover_letter = cover_letter_path.read_text(encoding="utf-8")
            # Extract just the main paragraph, not the full email
            lines = cover_letter.split('\\n')
            main_content = []
            for line in lines:
                if line.strip() and not line.startswith(('Dear', 'Kind regards', 'Best regards')):
                    main_content.append(line.strip())
            if main_content:
                form_data["cover_letter_text"] = ' '.join(main_content)
        
        # Handle CV file upload
        files = {}
        cv_variant_path = bundle_path / "cv_variant.txt"
        if cv_variant_path.exists():
            variant_info = cv_variant_path.read_text(encoding="utf-8").strip().split('\\n')
            if len(variant_info) >= 2:
                cv_filename = variant_info[1]
                cv_path = Path("data/cv") / cv_filename
                if cv_path.exists():
                    files["resume"] = (cv_filename, open(cv_path, "rb"), "application/octet-stream")
        
        # Make the request
        if files:
            response = requests.post(api_url, data=form_data, files=files, headers=headers, timeout=30)
            # Close file handles
            for f in files.values():
                if hasattr(f[1], 'close'):
                    f[1].close()
        else:
            response = requests.post(api_url, data=form_data, headers=headers, timeout=30)
        
        # Handle response
        if response.status_code in [200, 201]:
            return True, "Application submitted successfully to Greenhouse"
        elif response.status_code == 429:
            return False, "Rate limited by Greenhouse - please try again later"
        elif response.status_code == 401:
            return False, "Authentication failed - check your Greenhouse API key"
        elif response.status_code == 404:
            return False, "Job posting not found or no longer accepting applications"
        else:
            return False, f"Greenhouse API error: {response.status_code} - {response.text[:200]}"
            
    except Exception as e:
        return False, f"Error submitting to Greenhouse: {str(e)}"

# =====================================================================
# src/apply/submit_lever.py - Real Lever API submission  
# =====================================================================
def submit_lever(job_row: Dict, candidate_data: Dict, bundle_dir: str, api_key: str) -> Tuple[bool, str]:
    """Submit application to Lever job board"""
    
    try:
        # Extract posting info from URL
        # Example: https://jobs.lever.co/company/posting-id
        url_parts = job_row["apply_url"].split('/')
        
        if len(url_parts) < 2:
            return False, "Invalid Lever URL format"
            
        company = url_parts[-2] if "lever.co" in job_row["apply_url"] else "unknown"
        posting_id = url_parts[-1]
        
        # Build API endpoint
        api_url = f"https://api.lever.co/v0/postings/{company}/{posting_id}?key={api_key}"
        
        # Prepare form data
        full_name = f"{candidate_data.get('first_name', '')} {candidate_data.get('last_name', '')}".strip()
        form_data = {
            "name": full_name,
            "email": candidate_data.get("email", ""),
            "phone": candidate_data.get("phone", ""),
        }
        
        # Add cover letter as comments
        bundle_path = Path(bundle_dir) 
        cover_letter_path = bundle_path / "email_body.txt"
        if cover_letter_path.exists():
            cover_letter = cover_letter_path.read_text(encoding="utf-8")
            # Extract main content
            lines = cover_letter.split('\\n')
            main_content = []
            for line in lines:
                if line.strip() and not line.startswith(('Dear', 'Kind regards', 'Best regards')):
                    main_content.append(line.strip())
            if main_content:
                form_data["comments"] = ' '.join(main_content)
        
        # Handle CV file upload
        files = {}
        cv_variant_path = bundle_path / "cv_variant.txt"
        if cv_variant_path.exists():
            variant_info = cv_variant_path.read_text(encoding="utf-8").strip().split('\\n')
            if len(variant_info) >= 2:
                cv_filename = variant_info[1]
                cv_path = Path("data/cv") / cv_filename
                if cv_path.exists():
                    files["resume"] = (cv_filename, open(cv_path, "rb"), "application/octet-stream")
        
        # Make the request
        headers = {"User-Agent": "Job-O-Matic/1.0"}
        
        if files:
            response = requests.post(api_url, data=form_data, files=files, headers=headers, timeout=30)
            # Close file handles
            for f in files.values():
                if hasattr(f[1], 'close'):
                    f[1].close()
        else:
            response = requests.post(api_url, data=form_data, headers=headers, timeout=30)
        
        # Handle response
        if response.status_code in [200, 201]:
            return True, "Application submitted successfully to Lever"
        elif response.status_code == 429:
            return False, "Rate limited by Lever - please try again later" 
        elif response.status_code == 401:
            return False, "Authentication failed - check your Lever API key"
        elif response.status_code == 404:
            return False, "Job posting not found or no longer accepting applications"
        else:
            return False, f"Lever API error: {response.status_code} - {response.text[:200]}"
            
    except Exception as e:
        return False, f"Error submitting to Lever: {str(e)}"
'''

enhanced_modal = '''
# =====================================================================
# Enhanced Send Modal with Real API Integration - Add to dashboard.py
# =====================================================================

# Add these imports at the top of dashboard.py:
# from ..apply.submit_greenhouse import submit_greenhouse  
# from ..apply.submit_lever import submit_lever

# Replace the existing send modal section with this enhanced version:

if st.session_state.get("open_send_modal"):
    @st.dialog("🚀 Final Confirmation - Send Applications")
    def send_modal():
        st.warning("**Important:** Auto-submit only works with Greenhouse and Lever job boards that support API applications. All others require manual submission.")
        
        # Candidate info form
        st.subheader("Candidate Information")
        col1, col2 = st.columns(2)
        with col1:
            first_name = st.text_input("First Name", value="Omar", key="send_first")
            email = st.text_input("Email", value="your.email@example.com", key="send_email")
        with col2:
            last_name = st.text_input("Last Name", value="Runjanally", key="send_last") 
            phone = st.text_input("Phone", value="+44 XXX XXX XXXX", key="send_phone")
        
        candidate_data = {
            "first_name": first_name,
            "last_name": last_name, 
            "email": email,
            "phone": phone
        }
        
        # API Keys
        st.subheader("API Configuration")
        col1, col2 = st.columns(2)
        with col1:
            gh_key = st.text_input("Greenhouse API Key", type="password", key="send_gh_key",
                                 help="Get from Greenhouse > Configure > Dev Center > API Credentials")
        with col2:
            lever_key = st.text_input("Lever API Key", type="password", key="send_lever_key",
                                    help="Get from Lever Settings > Integrations > API")
        
        # Show jobs to be submitted
        st.subheader("Applications to Submit")
        to_send = st.session_state.get("send_ids", [])
        
        with Session() as s:
            jobs = s.execute(select(Job).where(Job.id.in_(to_send))).scalars().all()
        
        # Platform detection and preview
        platforms_summary = {"greenhouse": 0, "lever": 0, "manual": 0}
        
        for job in jobs:
            url = (job.apply_url or "").lower()
            if "greenhouse.io" in url:
                platform = "greenhouse"
                icon = "🏢"
                api_ready = bool(gh_key)
            elif "lever.co" in url:
                platform = "lever" 
                icon = "⚡"
                api_ready = bool(lever_key)
            else:
                platform = "manual"
                icon = "✋"
                api_ready = False
            
            platforms_summary[platform] += 1
            
            status_icon = "✅" if api_ready else "⚠️"
            st.write(f"{status_icon} {icon} **{job.company}** - {job.title}")
            if not api_ready and platform != "manual":
                st.caption(f"   ⚠️ {platform.title()} API key required")
        
        # Summary
        st.info(f"**Summary:** {platforms_summary['greenhouse']} Greenhouse, {platforms_summary['lever']} Lever, {platforms_summary['manual']} Manual")
        
        # Final confirmation
        ready_count = platforms_summary['greenhouse'] * bool(gh_key) + platforms_summary['lever'] * bool(lever_key)
        
        confirm_checked = st.checkbox(f"I have reviewed all {len(jobs)} applications and confirm submission")
        
        col1, col2 = st.columns(2)
        with col1:
            if st.button("📤 Submit Applications", type="primary", disabled=not confirm_checked):
                if not all([first_name, last_name, email]):
                    st.error("Please fill in all required candidate information")
                    return
                
                # Process submissions
                results = []
                progress = st.progress(0)
                
                for i, job in enumerate(jobs):
                    progress.progress((i + 1) / len(jobs), f"Submitting {job.company}...")
                    
                    # Find bundle directory
                    slug = f"{job.company}_{job.title}".replace(" ", "_").replace("/", "-")
                    bundle_candidates = list(Path("outputs").glob(f"*/*{slug}*"))
                    bundle_dir = str(bundle_candidates[-1]) if bundle_candidates else None
                    
                    if not bundle_dir:
                        results.append({
                            "job": f"{job.company} - {job.title}",
                            "success": False,
                            "message": "Bundle directory not found"
                        })
                        continue
                    
                    # Platform-specific submission
                    url = (job.apply_url or "").lower()
                    job_dict = {
                        "company": job.company,
                        "title": job.title, 
                        "apply_url": job.apply_url
                    }
                    
                    if "greenhouse.io" in url and gh_key:
                        success, message = submit_greenhouse(job_dict, candidate_data, bundle_dir, gh_key)
                    elif "lever.co" in url and lever_key:
                        success, message = submit_lever(job_dict, candidate_data, bundle_dir, lever_key)  
                    else:
                        success, message = False, "Manual submission required"
                    
                    results.append({
                        "job": f"{job.company} - {job.title}",
                        "success": success,
                        "message": message
                    })
                    
                    # Update database status
                    if success:
                        with Session() as update_session:
                            job_to_update = update_session.execute(select(Job).where(Job.id == job.id)).scalar_one()
                            job_to_update.status = "SENT"
                            update_session.commit()
                
                progress.progress(1.0, "Complete!")
                
                # Show results
                success_count = sum(1 for r in results if r["success"])
                st.success(f"✅ Successfully submitted: {success_count}/{len(results)}")
                
                # Detailed results
                with st.expander("📋 Detailed Results"):
                    for result in results:
                        icon = "✅" if result["success"] else "❌"  
                        st.write(f"{icon} **{result['job']}**")
                        st.caption(f"   {result['message']}")
                
                # Clear modal
                if success_count > 0:
                    st.session_state["open_send_modal"] = False
                    st.rerun()
        
        with col2:
            if st.button("❌ Cancel"):
                st.session_state["open_send_modal"] = False
                st.rerun()
    
    send_modal()
'''

print("Enhanced UI components created!")
print("\\nNew capabilities:")
print("✅ CV File Viewer with download buttons")
print("✅ Real Greenhouse API integration")  
print("✅ Real Lever API integration")
print("✅ Enhanced confirmation modal")
print("\\nFiles to create/update:")
print("1. src/apply/submit_greenhouse.py")
print("2. src/apply/submit_lever.py") 
print("3. Update dashboard.py with new UI components")