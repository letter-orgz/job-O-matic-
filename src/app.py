#!/usr/bin/env python3
"""
Job-O-Matic: Automated Job Application System
Main Streamlit Application Entry Point
"""

import streamlit as st
import pandas as pd
from pathlib import Path
from datetime import datetime

# Local modules
from src.opportunities import load_opportunities, add_opportunity
from src.gamification import (
    get_engine,
    init_db,
    record_application,
    available_boost_cards,
    activate_boost,
    active_boost,
    get_state,
    get_earned_badges,
    Badge,
)
from sqlmodel import Session, select

# Configure Streamlit page
st.set_page_config(
    page_title="Job-O-Matic Dashboard",
    page_icon="🎯",
    layout="wide",
    initial_sidebar_state="expanded"
)

ENGINE = get_engine(Path("data/gamification.db"))
init_db(ENGINE)

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
        ["Dashboard", "Job Search", "Applications", "Settings", "Help"]
    )
    
    # Main content based on page selection
    if page == "Dashboard":
        show_dashboard()
    elif page == "Job Search":
        show_job_search()
    elif page == "Applications":
        show_applications()
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

    with Session(ENGINE) as session:
        state = get_state(session)
        boost = active_boost(session)
        badges = get_earned_badges(session)
        badge_lookup = {b.id: b for b in session.exec(select(Badge))}

    col1, col2, col3, col4 = st.columns(4)
    with col1:
        st.metric("Total XP", state.xp)
    with col2:
        st.metric("Current Streak", state.streak)
    with col3:
        st.metric("Badges", len(badges))
    with col4:
        boost_name = boost.type.replace("_", " ").title() if boost else "None"
        st.metric("Active Boost", boost_name)

    if boost:
        st.info(f"Boost active until {boost.expires_at:%Y-%m-%d %H:%M}")
    else:
        with Session(ENGINE) as session:
            cards = available_boost_cards(session)
        if cards and st.button("Activate Double XP (24h)"):
            activate_boost(ENGINE, cards[0].id)
            st.experimental_rerun()

    if badges:
        st.subheader("🏅 Badges")
        cols = st.columns(len(badges))
        for col, earned in zip(cols, badges):
            badge = badge_lookup.get(earned.badge_id)
            col.image(earned.image_path, caption=badge.name if badge else "Badge")

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

    st.subheader("Add New Opportunity")

    # A form keeps the interface tidy and only saves when explicitly submitted.
    with st.form("opportunity_form"):
        title = st.text_input("Position Title")
        organisation = st.text_input("Organisation")
        opportunity_type = st.selectbox(
            "Opportunity Type",
            [
                "Internship",
                "Clerkship",
                "Research",
                "Court Shadowing",
                "Networking",
            ],
        )

        st.markdown("### Required Documents")
        transcript = st.checkbox("Transcript")
        references = st.checkbox("References")
        writing_sample = st.checkbox("Writing Sample")
        bar_status = st.text_input("Bar Status")
        effort = st.selectbox("Effort Level", ["Low", "Medium", "High"])

        submitted = st.form_submit_button("Save Opportunity")

    if submitted:
        opportunity = {
            "title": title,
            "organisation": organisation,
            "opportunity_type": opportunity_type,
            "transcript": transcript,
            "references": references,
            "writing_sample": writing_sample,
            "bar_status": bar_status,
            "date_added": datetime.now().isoformat(),
            "effort": effort.lower(),
        }
        add_opportunity(opportunity)
        earned = record_application(ENGINE, effort.lower())
        st.success("Opportunity saved")
        for badge in earned:
            st.success(f"Unlocked badge!")
            st.image(badge.image_path)

    # Display existing opportunities for quick reference.
    opportunities = load_opportunities()
    if opportunities:
        st.subheader("Tracked Opportunities")
        st.dataframe(pd.DataFrame(opportunities))
    else:
        st.info("No opportunities tracked yet.")

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
        ("config_template.env", "Environment configuration template")
    ]
    
    for doc_file, description in docs:
        if Path(doc_file).exists():
            st.write(f"📄 **{doc_file}**: {description}")
        else:
            st.write(f"📄 **{doc_file}**: {description} *(not found)*")

if __name__ == "__main__":
    main()
