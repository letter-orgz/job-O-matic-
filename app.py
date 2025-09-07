#!/usr/bin/env python3
"""
Job-O-Matic: Automated Job Application System
Main Streamlit Application Entry Point
"""

import streamlit as st
import pandas as pd
from pathlib import Path
from datetime import datetime
import os

# Configure Streamlit page
st.set_page_config(
    page_title="Job-O-Matic Dashboard",
    page_icon="🎯",
    layout="wide",
    initial_sidebar_state="expanded"
)

def main():
    """Main application function"""
    
    # Header
    st.title("🎯 Job-O-Matic")
    st.subheader("Automated Job Application System")
    
    # Check if this is first run
    if not Path("data").exists():
        st.warning("⚠️ First time setup detected. Creating directory structure...")
        setup_directories()
        st.success("✅ Directory structure created!")
        st.info("📝 Please add your CV files to the `data/cv/` directory and configure your settings.")
    
    # Sidebar navigation
    st.sidebar.title("Navigation")
    page = st.sidebar.selectbox(
        "Choose a page:",
        ["Dashboard", "Job Search", "Applications", "PR Status", "Settings", "Help"]
    )
    
    # Main content based on page selection
    if page == "Dashboard":
        show_dashboard()
    elif page == "Job Search":
        show_job_search()
    elif page == "Applications":
        show_applications()
    elif page == "PR Status":
        show_pr_status()
    elif page == "Settings":
        show_settings()
    elif page == "Help":
        show_help()

def setup_directories():
    """Create necessary directory structure"""
    directories = [
        "data",
        "data/cv",
        "data/templates",
        "outputs",
        "exports",
        "src",
        "src/apply"
    ]
    
    for directory in directories:
        Path(directory).mkdir(parents=True, exist_ok=True)
    
    # Create sample files if they don't exist
    readme_path = Path("data/README.md")
    if not readme_path.exists():
        readme_path.write_text("""# Job-O-Matic Data Directory

## CV Files
Place your CV variants in the `cv/` subdirectory:
- CV_Software_Engineer.pdf
- CV_Data_Scientist.docx
- CV_General.txt

## Templates
Email and cover letter templates go in `templates/`:
- email_template.txt
- cover_letter_template.txt

## Getting Started
1. Add your CV files to `cv/` directory
2. Configure your settings in the Settings page
3. Start searching for jobs and managing applications
""")

def show_dashboard():
    """Display main dashboard"""
    st.header("📊 Dashboard")
    
    # Sample metrics
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        st.metric("Total Jobs Found", "0", "0")
    
    with col2:
        st.metric("Applications Sent", "0", "0")
    
    with col3:
        st.metric("Pending Reviews", "0", "0")
    
    with col4:
        st.metric("Success Rate", "0%", "0%")
    
    # Status overview
    st.subheader("📋 Recent Activity")
    
    # Check if there are any data files
    if not any(Path("data/cv").glob("*")) if Path("data/cv").exists() else True:
        st.info("👋 Welcome to Job-O-Matic! Get started by:")
        st.markdown("""
        1. **Upload your CV files** to the `data/cv/` directory
        2. **Configure your settings** in the Settings page  
        3. **Start searching** for jobs in the Job Search page
        4. **Manage applications** in the Applications page
        """)
    else:
        st.success("✅ System is ready to use!")
        
        # Show CV files found
        cv_files = list(Path("data/cv").glob("*"))
        if cv_files:
            st.write("**CV Files Found:**")
            for cv_file in cv_files:
                st.write(f"📄 {cv_file.name}")

def show_job_search():
    """Display job search interface"""
    st.header("🔍 Job Search")
    
    st.info("🚧 Job search functionality will be implemented here.")
    st.markdown("""
    **Features to be implemented:**
    - Search jobs from multiple platforms
    - Filter by location, salary, keywords
    - Save interesting positions
    - Bulk job processing
    """)

def show_applications():
    """Display applications management"""
    st.header("📨 Applications")
    
    st.info("🚧 Application management functionality will be implemented here.")
    st.markdown("""
    **Features to be implemented:**
    - View all job applications
    - Track application status
    - Generate tailored CVs and cover letters
    - Send applications via API
    """)

def show_settings():
    """Display settings page"""
    st.header("⚙️ Settings")
    
    # API Keys section
    st.subheader("🔑 API Configuration")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.text_input("Greenhouse API Key", type="password", help="Enter your Greenhouse API key")
        st.text_input("OpenAI API Key", type="password", help="For CV tailoring and content generation")
    
    with col2:
        st.text_input("Lever API Key", type="password", help="Enter your Lever API key")
        st.text_input("Email SMTP Server", help="For sending applications via email")
    
    # Application Settings
    st.subheader("🎯 Application Settings")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.number_input("Applications per day limit", min_value=1, max_value=50, value=10)
        st.selectbox("Default CV variant", ["CV_General.pdf", "CV_Software.pdf", "CV_Data_Science.pdf"])
    
    with col2:
        st.number_input("Delay between applications (seconds)", min_value=5, max_value=300, value=30)
        st.checkbox("Require manual approval before sending", value=True)
    
    if st.button("💾 Save Settings"):
        st.success("✅ Settings saved successfully!")

def show_pr_status():
    """Display PR merge readiness status"""
    st.header("🔍 Pull Request Status")
    st.subheader("Check which PRs are ready to merge")
    
    # Information section
    st.info("📋 This page helps you monitor which pull requests are ready to be merged into the main branch.")
    
    col1, col2 = st.columns([2, 1])
    
    with col1:
        st.markdown("""
        **What we check:**
        - ✅ Draft status (PRs marked as draft are not ready)
        - 🔄 Merge conflicts (must be resolved)
        - 👥 Review approvals (required before merge)
        - 🔍 CI checks (all automated tests must pass)
        - 🛡️ Branch protection compliance
        """)
    
    with col2:
        # Quick actions
        if st.button("🔄 Check PR Status", type="primary"):
            with st.spinner("Checking PR status..."):
                check_pr_status_live()
        
        if st.button("📖 View Documentation"):
            st.markdown("See [PR Merge Checker Documentation](docs/PR_MERGE_CHECKER.md)")
    
    # Manual run options
    st.subheader("🛠️ Manual Tools")
    
    with st.expander("🖥️ Command Line Tools"):
        st.code("""
# Quick check with GitHub CLI
./scripts/check-prs.sh

# Detailed Python analysis
python3 scripts/check-pr-merge-readiness.py

# Shell wrapper
./scripts/check-pr-readiness.sh
        """, language="bash")
    
    with st.expander("📊 Latest Report"):
        show_latest_pr_report()

def check_pr_status_live():
    """Run PR status check and display results"""
    import subprocess
    import os
    
    try:
        # Try to run the PR checker script
        result = subprocess.run(
            ["python3", "scripts/check-pr-merge-readiness.py"],
            capture_output=True,
            text=True,
            timeout=30
        )
        
        if result.returncode == 0:
            st.success("✅ PR check completed successfully!")
            
            # Display output
            if result.stdout:
                st.text_area("Output:", result.stdout, height=300)
            
            # Try to show latest report
            show_latest_pr_report()
        else:
            st.error(f"❌ PR check failed with exit code {result.returncode}")
            if result.stderr:
                st.error(f"Error: {result.stderr}")
                
            # Suggest alternatives
            st.markdown("""
            **Alternative options:**
            - Use GitHub CLI: `gh pr list --repo letter-orgz/job-O-matic-`
            - Visit the web interface: https://github.com/letter-orgz/job-O-matic-/pulls
            - Set up GitHub token authentication
            """)
    
    except subprocess.TimeoutExpired:
        st.error("⏰ Check timed out. This might be due to network issues or rate limiting.")
    except FileNotFoundError:
        st.error("❌ Python script not found. Please ensure the scripts are properly installed.")
    except Exception as e:
        st.error(f"❌ Unexpected error: {str(e)}")

def show_latest_pr_report():
    """Display the latest PR report if available"""
    reports_dir = Path("reports")
    
    if not reports_dir.exists():
        st.info("📝 No reports directory found. Run a PR check to generate reports.")
        return
    
    # Find latest report file
    report_files = list(reports_dir.glob("pr-merge-readiness-*.json"))
    
    if not report_files:
        st.info("📝 No PR reports found. Run a check to generate one.")
        return
    
    # Get the most recent report
    latest_report = max(report_files, key=lambda f: f.stat().st_mtime)
    
    try:
        import json
        with open(latest_report, 'r') as f:
            report_data = json.load(f)
        
        st.success(f"📊 Latest report: {latest_report.name}")
        
        # Display summary
        summary = report_data.get("summary", {})
        
        col1, col2, col3 = st.columns(3)
        with col1:
            st.metric("Total PRs", summary.get("total_prs", 0))
        with col2:
            st.metric("Ready to Merge", summary.get("ready_count", 0), 
                     delta=None, delta_color="normal")
        with col3:
            st.metric("Need Attention", summary.get("needs_attention_count", 0),
                     delta=None, delta_color="inverse")
        
        # Show ready PRs
        ready_prs = report_data.get("ready_to_merge", [])
        if ready_prs:
            st.subheader("✅ Ready to Merge")
            for pr in ready_prs:
                st.success(f"PR #{pr['pr_number']}: {pr['title']} (by {pr['author']})")
        
        # Show PRs needing attention
        needs_attention = report_data.get("needs_attention", [])
        if needs_attention:
            st.subheader("⚠️ Needs Attention")
            for pr in needs_attention:
                with st.expander(f"PR #{pr['pr_number']}: {pr['title']}"):
                    st.write(f"**Author:** {pr['author']}")
                    st.write(f"**Updated:** {pr['updated_at']}")
                    if pr.get('blocking_factors'):
                        st.write("**Blocking factors:**")
                        for factor in pr['blocking_factors']:
                            st.write(f"• {factor}")
    
    except Exception as e:
        st.error(f"❌ Error reading report: {str(e)}")

def show_help():
    """Display help and documentation"""
    st.header("❓ Help & Documentation")
    
    st.markdown("""
    ## 🚀 Getting Started
    
    ### 1. Setup Your Environment
    - Ensure you have Python 3.11+ installed
    - Install dependencies: `pip install -r requirements.txt`
    - Run the app: `streamlit run app.py`
    
    ### 2. Configure Your Data
    - Add your CV files to `data/cv/` directory
    - Supported formats: PDF, DOCX, TXT
    - Use descriptive names like `CV_Software_Engineer.pdf`
    
    ### 3. API Setup
    - Get API keys from job platforms (Greenhouse, Lever)
    - Configure them in Settings page
    - Test connections before bulk operations
    
    ## 🔧 Troubleshooting
    
    ### Common Issues
    - **No CV files found**: Check `data/cv/` directory exists and contains files
    - **API errors**: Verify API keys are correct and have proper permissions
    - **Port conflicts**: Default port is 8501, change with `--server.port` flag
    
    ### Support
    - Check the GitHub repository for latest updates
    - Review compliance guidelines in `compliance_best_practices.md`
    - Follow implementation guide in `implementation-guide.md`
    
    ## 📖 Documentation Files
    """)
    
    # Show available documentation
    docs = [
        ("README.md", "Main project documentation"),
        ("compliance_best_practices.md", "Legal and ethical guidelines"),
        ("implementation-guide.md", "Technical implementation details"),
        ("config_template.env", "Environment configuration template"),
        ("docs/PR_MERGE_CHECKER.md", "PR merge readiness checker guide")
    ]
    
    for doc_file, description in docs:
        if Path(doc_file).exists():
            st.write(f"📄 **{doc_file}**: {description}")
        else:
            st.write(f"📄 **{doc_file}**: {description} *(not found)*")

if __name__ == "__main__":
    main()