#!/usr/bin/env python3
"""
Job-O-Matic Main Application
Entry point for the job automation system
"""

try:
    import streamlit as st
except ImportError:
    print("Streamlit not available. Install with: pip install streamlit")
    print("For now, running in test mode...")
    import sys
    sys.exit(1)

import sqlite3
import pandas as pd
import json
import time
from pathlib import Path
from datetime import datetime

# Configure Streamlit page
st.set_page_config(
    page_title="Job-O-Matic",
    page_icon="🤖",
    layout="wide",
    initial_sidebar_state="expanded"
)

def init_database():
    """Initialize the database with required tables"""
    db_path = Path('db/app.db')
    db_path.parent.mkdir(exist_ok=True)
    
    conn = sqlite3.connect(str(db_path))
    cursor = conn.cursor()
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS jobs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            company TEXT NOT NULL,
            title TEXT NOT NULL,
            apply_url TEXT,
            job_desc_snippet TEXT,
            status TEXT DEFAULT 'NOT_APPLIED',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    conn.commit()
    conn.close()

def get_jobs_dataframe():
    """Get jobs as pandas DataFrame"""
    db_path = Path('db/app.db')
    if not db_path.exists():
        return pd.DataFrame(columns=['id', 'company', 'title', 'apply_url', 'status'])
    
    conn = sqlite3.connect(str(db_path))
    df = pd.read_sql_query('SELECT * FROM jobs ORDER BY created_at DESC', conn)
    conn.close()
    return df

def add_test_jobs():
    """Add some test jobs for demonstration"""
    db_path = Path('db/app.db')
    conn = sqlite3.connect(str(db_path))
    cursor = conn.cursor()
    
    test_jobs = [
        ('TechCorp', 'Senior Python Developer', 'https://techcorp.com/jobs/python-dev', 'Python, FastAPI, PostgreSQL'),
        ('DataFlow Inc', 'Data Scientist', 'https://dataflow.com/careers/data-scientist', 'Machine Learning, Python, SQL'),
        ('WebSolutions', 'Full Stack Developer', 'https://websolutions.com/apply/fullstack', 'React, Node.js, MongoDB'),
        ('AI Innovations', 'Machine Learning Engineer', 'https://ai-innovations.com/jobs/ml-engineer', 'TensorFlow, Python, MLOps'),
        ('CloudTech', 'DevOps Engineer', 'https://cloudtech.com/careers/devops', 'AWS, Docker, Kubernetes')
    ]
    
    for company, title, url, desc in test_jobs:
        cursor.execute('''
            INSERT OR IGNORE INTO jobs (company, title, apply_url, job_desc_snippet)
            VALUES (?, ?, ?, ?)
        ''', (company, title, url, desc))
    
    conn.commit()
    conn.close()

def export_jobs_csv(df):
    """Export jobs to CSV"""
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    filename = f'jobs_export_{timestamp}.csv'
    csv_data = df.to_csv(index=False, encoding='utf-8')
    return csv_data, filename

def export_jobs_json(df):
    """Export jobs to JSON"""
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    filename = f'jobs_export_{timestamp}.json'
    json_data = df.to_json(orient='records', indent=2)
    return json_data, filename

def bulk_prepare_jobs(job_ids):
    """Simulate bulk preparation of job applications"""
    results = []
    for i, job_id in enumerate(job_ids):
        # Simulate processing time
        time.sleep(0.1)
        
        # Create output directory
        timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        output_dir = Path('outputs') / timestamp / f'job_{job_id}'
        output_dir.mkdir(parents=True, exist_ok=True)
        
        # Create mock output files
        (output_dir / 'tailored_cv.txt').write_text(f'Tailored CV for job {job_id}')
        (output_dir / 'cover_letter.txt').write_text(f'Cover letter for job {job_id}')
        (output_dir / 'email_subject.txt').write_text(f'Application for position at job {job_id}')
        
        results.append({
            'job_id': job_id,
            'status': 'success',
            'output_dir': str(output_dir)
        })
        
        # Update job status
        db_path = Path('db/app.db')
        conn = sqlite3.connect(str(db_path))
        cursor = conn.cursor()
        cursor.execute('UPDATE jobs SET status = ? WHERE id = ?', ('PENDING', job_id))
        conn.commit()
        conn.close()
    
    return results

def main():
    """Main application"""
    st.title("🤖 Job-O-Matic")
    st.markdown("**Automated Job Application System**")
    
    # Initialize database
    init_database()
    
    # Sidebar
    with st.sidebar:
        st.header("Navigation")
        tab = st.selectbox("Choose section:", [
            "Dashboard", 
            "Job Management", 
            "Bulk Operations", 
            "Export Data", 
            "Settings"
        ])
        
        if st.button("Add Test Jobs"):
            add_test_jobs()
            st.success("Test jobs added!")
            st.rerun()
    
    # Main content
    if tab == "Dashboard":
        st.header("📊 Dashboard")
        
        df = get_jobs_dataframe()
        
        if len(df) == 0:
            st.info("No jobs found. Use the sidebar to add test jobs.")
            return
        
        # Stats
        col1, col2, col3, col4 = st.columns(4)
        with col1:
            st.metric("Total Jobs", len(df))
        with col2:
            st.metric("Not Applied", len(df[df['status'] == 'NOT_APPLIED']))
        with col3:
            st.metric("Pending", len(df[df['status'] == 'PENDING']))
        with col4:
            st.metric("Sent", len(df[df['status'] == 'SENT']))
        
        # Jobs table
        st.subheader("Jobs Overview")
        st.dataframe(df, use_container_width=True)
    
    elif tab == "Job Management":
        st.header("🔧 Job Management")
        
        df = get_jobs_dataframe()
        
        if len(df) == 0:
            st.info("No jobs found. Use the sidebar to add test jobs.")
            return
        
        # Job selection
        selected_job = st.selectbox("Select a job:", df['id'].tolist(), format_func=lambda x: f"Job {x}: {df[df['id']==x]['company'].iloc[0]} - {df[df['id']==x]['title'].iloc[0]}")
        
        if selected_job:
            job_data = df[df['id'] == selected_job].iloc[0]
            
            col1, col2 = st.columns([2, 1])
            
            with col1:
                st.subheader(f"{job_data['company']} - {job_data['title']}")
                st.write(f"**URL:** {job_data['apply_url']}")
                st.write(f"**Description:** {job_data['job_desc_snippet']}")
                st.write(f"**Status:** {job_data['status']}")
            
            with col2:
                new_status = st.selectbox("Update Status:", 
                    ['NOT_APPLIED', 'PENDING', 'SENT', 'REJECTED', 'INTERVIEW'])
                
                if st.button("Update Status"):
                    db_path = Path('db/app.db')
                    conn = sqlite3.connect(str(db_path))
                    cursor = conn.cursor()
                    cursor.execute('UPDATE jobs SET status = ? WHERE id = ?', (new_status, selected_job))
                    conn.commit()
                    conn.close()
                    st.success(f"Status updated to {new_status}")
                    st.rerun()
    
    elif tab == "Bulk Operations":
        st.header("⚡ Bulk Operations")
        
        df = get_jobs_dataframe()
        
        if len(df) == 0:
            st.info("No jobs found. Use the sidebar to add test jobs.")
            return
        
        # Filter jobs for bulk operations
        not_applied_jobs = df[df['status'] == 'NOT_APPLIED']
        
        if len(not_applied_jobs) == 0:
            st.info("No jobs with 'NOT_APPLIED' status available for bulk processing.")
            return
        
        st.subheader("Select Jobs for Bulk Processing")
        
        # Multi-select for jobs
        selected_jobs = st.multiselect(
            "Choose jobs to process:",
            not_applied_jobs['id'].tolist(),
            format_func=lambda x: f"Job {x}: {not_applied_jobs[not_applied_jobs['id']==x]['company'].iloc[0]} - {not_applied_jobs[not_applied_jobs['id']==x]['title'].iloc[0]}"
        )
        
        if selected_jobs:
            st.write(f"Selected {len(selected_jobs)} jobs for processing")
            
            if st.button("🚀 Process Selected Jobs", type="primary"):
                progress_bar = st.progress(0)
                status_text = st.empty()
                
                results = []
                for i, job_id in enumerate(selected_jobs):
                    status_text.text(f"Processing job {job_id}...")
                    progress_bar.progress((i + 1) / len(selected_jobs))
                    
                    # Simulate processing
                    result = bulk_prepare_jobs([job_id])[0]
                    results.append(result)
                
                status_text.text("Processing complete!")
                
                # Show results
                st.success(f"Successfully processed {len(results)} jobs!")
                
                for result in results:
                    with st.expander(f"Job {result['job_id']} - {result['status']}"):
                        st.write(f"Output directory: {result['output_dir']}")
                
                st.rerun()
    
    elif tab == "Export Data":
        st.header("📥 Export Data")
        
        df = get_jobs_dataframe()
        
        if len(df) == 0:
            st.info("No jobs found. Use the sidebar to add test jobs.")
            return
        
        st.subheader("Export Options")
        
        col1, col2 = st.columns(2)
        
        with col1:
            if st.button("📄 Export as CSV"):
                csv_data, filename = export_jobs_csv(df)
                st.download_button(
                    label="📥 Download CSV",
                    data=csv_data,
                    file_name=filename,
                    mime="text/csv"
                )
        
        with col2:
            if st.button("📋 Export as JSON"):
                json_data, filename = export_jobs_json(df)
                st.download_button(
                    label="📥 Download JSON",
                    data=json_data,
                    file_name=filename,
                    mime="application/json"
                )
        
        # Preview data
        st.subheader("Data Preview")
        st.dataframe(df, use_container_width=True)
    
    elif tab == "Settings":
        st.header("⚙️ Settings")
        
        st.subheader("System Information")
        
        # Directory info
        required_dirs = ['data/cv', 'src/ui', 'src/apply', 'exports', 'outputs', 'db']
        for dir_path in required_dirs:
            path = Path(dir_path)
            if path.exists():
                st.success(f"✓ {dir_path}")
            else:
                st.error(f"✗ {dir_path}")
        
        # CV files
        cv_dir = Path('data/cv')
        cv_files = list(cv_dir.glob('*.*'))
        st.write(f"CV files available: {len(cv_files)}")
        
        # Database info
        db_path = Path('db/app.db')
        if db_path.exists():
            st.success(f"✓ Database: {db_path} ({db_path.stat().st_size} bytes)")
        else:
            st.error("✗ Database not found")
        
        st.subheader("Configuration")
        st.info("Configuration options would go here (API keys, settings, etc.)")

if __name__ == "__main__":
    main()