# Create the additional code snippets for the job automation system

bulk_operations_code = '''
# Additional imports for bulk operations
import base64
from io import StringIO
import json
from datetime import datetime
from pathlib import Path

def export_table_to_csv(df, filename=None):
    """Export jobs table to CSV format"""
    if filename is None:
        filename = f"jobs_export_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
    
    csv_buffer = StringIO()
    df.to_csv(csv_buffer, index=False, encoding='utf-8')
    csv_data = csv_buffer.getvalue()
    
    return csv_data, filename

def export_table_to_json(df, filename=None):
    """Export jobs table to JSON format"""
    if filename is None:
        filename = f"jobs_export_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    
    json_data = df.to_json(orient='records', indent=2, force_ascii=False)
    
    return json_data, filename

def bulk_prepare_applications(job_ids, session):
    """Prepare applications for multiple jobs in bulk"""
    results = []
    
    for job_id in job_ids:
        try:
            job = session.execute(select(Job).where(Job.id == job_id)).scalar_one()
            
            # Auto-select CV variant
            variant, file = pick_variant(job.job_desc_snippet or f"{job.company} {job.title}")
            
            # Generate tailored content
            tailored_content = tailor(job.job_desc_snippet or f"{job.company} {job.title}", variant)
            
            # Generate email
            cover_paragraph = extract_section(tailored_content, "COVER_PARAGRAPH")
            subject, body = build_email(job.company, job.title, cover_paragraph)
            
            # Create output directory
            timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
            outdir = Path("outputs") / timestamp / f"{job.company}_{job.title}".replace(" ", "_")
            outdir.mkdir(parents=True, exist_ok=True)
            
            # Save files
            (outdir / "tailored.txt").write_text(tailored_content, encoding="utf-8")
            (outdir / "email_subject.txt").write_text(subject, encoding="utf-8")
            (outdir / "email_body.txt").write_text(body, encoding="utf-8")
            (outdir / "cv_variant.txt").write_text(f"{variant}\\n{file}", encoding="utf-8")
            
            # Update job status to PENDING
            job.status = "PENDING"
            
            results.append({
                "job_id": job_id,
                "company": job.company,
                "title": job.title,
                "variant": variant,
                "output_dir": str(outdir),
                "status": "success"
            })
            
        except Exception as e:
            results.append({
                "job_id": job_id,
                "status": "error",
                "error": str(e)
            })
    
    session.commit()
    return results
'''

greenhouse_lever_auto_submit = '''
import requests
import base64
from typing import Dict, Optional, Tuple

class JobApplicationSubmitter:
    """Handle automated job application submissions with proper safeguards"""
    
    def __init__(self):
        self.allowed_domains = {
            "greenhouse": ["greenhouse.io", "boards-api.greenhouse.io"],
            "lever": ["lever.co", "api.lever.co"]
        }
    
    def detect_platform(self, apply_url: str) -> Optional[str]:
        """Detect if URL is from supported platforms"""
        for platform, domains in self.allowed_domains.items():
            if any(domain in apply_url.lower() for domain in domains):
                return platform
        return None
    
    def submit_greenhouse_application(self, 
                                    apply_url: str, 
                                    api_key: str,
                                    candidate_data: Dict,
                                    cv_file_path: Optional[str] = None,
                                    cover_letter_text: Optional[str] = None) -> Tuple[bool, str]:
        """Submit application to Greenhouse job posting"""
        
        try:
            # Extract board_token and job_id from URL
            # Example URL: https://boards-api.greenhouse.io/v1/boards/acmeinc/jobs/4043584006
            parts = apply_url.split('/')
            board_token = parts[-3] if len(parts) >= 3 else "external"
            job_id = parts[-1]
            
            # Build API endpoint
            api_url = f"https://boards-api.greenhouse.io/v1/boards/{board_token}/jobs/{job_id}"
            
            # Prepare headers
            auth_string = base64.b64encode(f"{api_key}:".encode()).decode()
            headers = {
                "Authorization": f"Basic {auth_string}",
                "Content-Type": "application/json"
            }
            
            # Prepare payload
            payload = {
                "first_name": candidate_data.get("first_name", ""),
                "last_name": candidate_data.get("last_name", ""),
                "email": candidate_data.get("email", ""),
                "phone": candidate_data.get("phone", ""),
                "data_compliance": {"gdpr_consent_given": True}
            }
            
            # Add cover letter if provided
            if cover_letter_text:
                payload["cover_letter_text"] = cover_letter_text
            
            # For file uploads, we'd need to use multipart/form-data
            if cv_file_path:
                files = {"resume": open(cv_file_path, "rb")}
                headers.pop("Content-Type")  # Let requests set it for multipart
                response = requests.post(api_url, data=payload, files=files, headers=headers, timeout=30)
                files["resume"].close()
            else:
                response = requests.post(api_url, json=payload, headers=headers, timeout=30)
            
            if response.status_code in [200, 201]:
                return True, "Application submitted successfully"
            elif response.status_code == 429:
                return False, "Rate limited - please try again later"
            else:
                return False, f"Submission failed: {response.status_code} - {response.text}"
                
        except Exception as e:
            return False, f"Error submitting application: {str(e)}"
    
    def submit_lever_application(self, 
                               apply_url: str, 
                               api_key: str,
                               candidate_data: Dict,
                               cv_file_path: Optional[str] = None,
                               cover_letter_text: Optional[str] = None) -> Tuple[bool, str]:
        """Submit application to Lever job posting"""
        
        try:
            # Extract site and posting ID from URL
            # Example URL: https://api.lever.co/v0/postings/acmeinc/posting-id
            parts = apply_url.split('/')
            site = parts[-2] if len(parts) >= 2 else ""
            posting_id = parts[-1]
            
            # Build API endpoint with API key
            api_url = f"https://api.lever.co/v0/postings/{site}/{posting_id}?key={api_key}"
            
            # Prepare payload
            payload = {
                "name": f"{candidate_data.get('first_name', '')} {candidate_data.get('last_name', '')}".strip(),
                "email": candidate_data.get("email", ""),
                "phone": candidate_data.get("phone", "")
            }
            
            # Add cover letter if provided
            if cover_letter_text:
                payload["comments"] = cover_letter_text
            
            # Handle file uploads
            if cv_file_path:
                files = {"resume": open(cv_file_path, "rb")}
                response = requests.post(api_url, data=payload, files=files, timeout=30)
                files["resume"].close()
            else:
                response = requests.post(api_url, data=payload, timeout=30)
            
            if response.status_code in [200, 201]:
                return True, "Application submitted successfully"
            elif response.status_code == 429:
                return False, "Rate limited - please try again later"
            else:
                return False, f"Submission failed: {response.status_code} - {response.text}"
                
        except Exception as e:
            return False, f"Error submitting application: {str(e)}"
    
    def auto_submit_with_confirmation(self, 
                                    job_row: Dict, 
                                    candidate_data: Dict,
                                    output_dir: str,
                                    api_keys: Dict) -> Tuple[bool, str]:
        """Auto-submit application with proper confirmation and safeguards"""
        
        apply_url = job_row["apply_url"]
        platform = self.detect_platform(apply_url)
        
        if not platform:
            return False, "Unsupported platform - manual submission required"
        
        if platform not in api_keys:
            return False, f"No API key configured for {platform}"
        
        # Look for CV file in output directory
        output_path = Path(output_dir)
        cv_files = list(output_path.glob("cv_*.pdf")) or list(output_path.glob("cv_*.docx"))
        cv_file_path = str(cv_files[0]) if cv_files else None
        
        # Read cover letter
        cover_letter_file = output_path / "email_body.txt"
        cover_letter_text = cover_letter_file.read_text(encoding="utf-8") if cover_letter_file.exists() else None
        
        # Submit based on platform
        if platform == "greenhouse":
            return self.submit_greenhouse_application(
                apply_url, api_keys["greenhouse"], candidate_data, cv_file_path, cover_letter_text
            )
        elif platform == "lever":
            return self.submit_lever_application(
                apply_url, api_keys["lever"], candidate_data, cv_file_path, cover_letter_text
            )
        
        return False, "Unknown platform error"

# Usage in dashboard:
submitter = JobApplicationSubmitter()
'''

streamlit_ui_enhancements = '''
# Enhanced UI components for dashboard.py

# Add these to the main dashboard after the existing code:

# 4) Export functionality
st.subheader("Export & Bulk Operations")

col1, col2, col3 = st.columns(3)

with col1:
    if st.button("📥 Export CSV"):
        csv_data, filename = export_table_to_csv(edited)
        st.download_button(
            label="Download CSV",
            data=csv_data,
            file_name=filename,
            mime="text/csv",
            key="csv_download"
        )

with col2:
    if st.button("📥 Export JSON"):
        json_data, filename = export_table_to_json(edited)
        st.download_button(
            label="Download JSON", 
            data=json_data,
            file_name=filename,
            mime="application/json",
            key="json_download"
        )

with col3:
    # Bulk prepare
    not_applied_jobs = edited[edited["status"] == "NOT_APPLIED"]["id"].tolist()
    if not_applied_jobs and st.button(f"✨ Bulk Prepare ({len(not_applied_jobs)} jobs)"):
        with st.spinner("Preparing applications..."):
            with Session() as s:
                results = bulk_prepare_applications(not_applied_jobs, s)
        
        # Show results
        success_count = len([r for r in results if r["status"] == "success"])
        error_count = len([r for r in results if r["status"] == "error"])
        
        st.success(f"Prepared {success_count} applications")
        if error_count > 0:
            st.error(f"{error_count} failed")
            
        # Show details in expander
        with st.expander("View Bulk Preparation Details"):
            for result in results:
                if result["status"] == "success":
                    st.write(f"✅ **{result['company']} - {result['title']}**")
                    st.caption(f"Variant: {result['variant']} | Output: {result['output_dir']}")
                else:
                    st.write(f"❌ Job ID {result['job_id']}: {result['error']}")

# 5) Auto-submit section (with proper safeguards)
st.subheader("🚀 Auto-Submit (Beta)")

# Configuration section
with st.expander("⚙️ Configure API Keys & Settings"):
    st.warning("⚠️ **Important Legal Notice:** Auto-submission tools must be used responsibly and in compliance with platform Terms of Service. Always obtain explicit user consent before submitting applications.")
    
    greenhouse_key = st.text_input("Greenhouse API Key", type="password", help="Get from Greenhouse > Configure > Dev Center")
    lever_key = st.text_input("Lever API Key", type="password", help="Get from Lever Settings > Integrations")
    
    # Candidate data
    st.subheader("Candidate Information")
    candidate_data = {
        "first_name": st.text_input("First Name", value="Omar"),
        "last_name": st.text_input("Last Name", value="Runjanally"), 
        "email": st.text_input("Email", value="[email protected]"),
        "phone": st.text_input("Phone", value="+44 XXX XXX XXXX")
    }

# Auto-submit interface
api_keys = {"greenhouse": greenhouse_key, "lever": lever_key}
pending_jobs = edited[edited["status"] == "PENDING"]

if not pending_jobs.empty and any(api_keys.values()):
    st.write(f"**{len(pending_jobs)} jobs ready for auto-submission**")
    
    # Show preview of jobs to submit
    with st.expander("Preview Jobs for Auto-Submit"):
        for idx, row in pending_jobs.iterrows():
            platform = submitter.detect_platform(row["apply_url"])
            status_icon = "🟢" if platform in ["greenhouse", "lever"] and api_keys.get(platform) else "🟡"
            st.write(f"{status_icon} **{row['company']} - {row['title']}** ({platform or 'manual'})")
    
    # Confirmation and submission
    if st.checkbox("I confirm I want to auto-submit these applications and take full responsibility"):
        if st.button("🚀 Execute Auto-Submit", type="primary"):
            if not all(candidate_data.values()):
                st.error("Please fill in all candidate information")
            else:
                results = []
                progress_bar = st.progress(0)
                
                for idx, (_, row) in enumerate(pending_jobs.iterrows()):
                    # Find output directory for this job
                    job_outputs = list(Path("outputs").glob(f"*/*{row['company'].replace(' ', '_')}_{row['title'].replace(' ', '_')}*"))
                    output_dir = str(job_outputs[0]) if job_outputs else None
                    
                    if output_dir:
                        success, message = submitter.auto_submit_with_confirmation(
                            row.to_dict(), candidate_data, output_dir, api_keys
                        )
                        
                        results.append({
                            "job": f"{row['company']} - {row['title']}",
                            "success": success,
                            "message": message
                        })
                        
                        # Update job status in database
                        if success:
                            with Session() as s:
                                job = s.execute(select(Job).where(Job.id == row["id"])).scalar_one()
                                job.status = "SENT"
                                s.commit()
                    
                    progress_bar.progress((idx + 1) / len(pending_jobs))
                
                # Show results
                success_count = len([r for r in results if r["success"]])
                st.success(f"Successfully submitted {success_count}/{len(results)} applications")
                
                with st.expander("Submission Details"):
                    for result in results:
                        icon = "✅" if result["success"] else "❌"
                        st.write(f"{icon} **{result['job']}**: {result['message']}")
                
                st.rerun()  # Refresh to show updated statuses

else:
    if pending_jobs.empty:
        st.info("No jobs in PENDING status. Use 'Bulk Prepare' first.")
    else:
        st.info("Configure API keys above to enable auto-submission.")
'''

# Write the code snippets to a file for easy copying
with open("job_automation_enhancements.py", "w", encoding="utf-8") as f:
    f.write("# Job-O-Matic Enhancement Code\n\n")
    f.write("# =============================================================================\n")
    f.write("# BULK OPERATIONS & EXPORT FUNCTIONALITY\n") 
    f.write("# Add to src/bulk_ops.py\n")
    f.write("# =============================================================================\n\n")
    f.write(bulk_operations_code)
    f.write("\n\n")
    f.write("# =============================================================================\n")
    f.write("# AUTO-SUBMIT FUNCTIONALITY (WITH SAFEGUARDS)\n")
    f.write("# Add to src/auto_submit.py\n") 
    f.write("# =============================================================================\n\n")
    f.write(greenhouse_lever_auto_submit)
    f.write("\n\n")
    f.write("# =============================================================================\n")
    f.write("# STREAMLIT UI ENHANCEMENTS\n")
    f.write("# Add to src/ui/dashboard.py (after existing code)\n")
    f.write("# =============================================================================\n\n")
    f.write(streamlit_ui_enhancements)

print("Enhanced job automation code generated successfully!")
print("File saved as: job_automation_enhancements.py")