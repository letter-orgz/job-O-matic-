
# =====================================================================
# DASHBOARD ENHANCEMENTS - Add these to your existing dashboard.py
# =====================================================================

# ADD THESE IMPORTS at the top of your dashboard.py file:
from ..exporter import export_jobs_csv, export_jobs_json
from ..bulk_ops import bulk_preview, bulk_approve
from ..apply.submit_greenhouse import submit_greenhouse
from ..apply.submit_lever import submit_lever

# REPLACE the CV File Viewer section in your preview panel with this:

def render_cv_file_viewer(variant, variant_file):
    """Enhanced CV file viewer with download capabilities"""
    cv_path = Path("data/cv") / variant_file

    if cv_path.exists():
        file_size = cv_path.stat().st_size
        col1, col2, col3 = st.columns([2, 1, 1])

        with col1:
            st.write(f"📄 **{variant_file}**")
            st.caption(f"Size: {file_size // 1024} KB | Variant: {variant}")

        with col2:
            # Preview button (for supported formats)
            if variant_file.endswith('.txt'):
                if st.button("👁️ Preview", key=f"preview_{variant}"):
                    with st.expander("CV Preview"):
                        try:
                            content = cv_path.read_text(encoding='utf-8')
                            st.text_area("Content", content[:2000], height=200, disabled=True)
                            if len(content) > 2000:
                                st.caption("... (truncated, use download for full content)")
                        except Exception as e:
                            st.error(f"Could not preview: {e}")
            else:
                st.info("📖 PDF/DOCX - Download to view")

        with col3:
            # Download button
            try:
                with open(cv_path, "rb") as f:
                    file_data = f.read()
                st.download_button(
                    label="📥 Download",
                    data=file_data,
                    file_name=variant_file,
                    mime="application/octet-stream",
                    key=f"cv_download_{variant}"
                )
            except Exception as e:
                st.error(f"Download error: {e}")
    else:
        st.error(f"❌ **CV file not found**: `{variant_file}`")
        st.info("💡 Ensure the CV file exists in `data/cv/` directory")

# REPLACE the preview section with this enhanced version:

st.markdown("---")
st.subheader("📋 Preview & Review")

if not edited.empty:
    col_preview1, col_preview2 = st.columns([2, 3])

    with col_preview1:
        # Job selector
        sel_id = st.selectbox("Select Job for Review", edited["id"], 
                             help="Choose a job to preview the generated application materials")

        if sel_id:
            sel_job = next(j for j in jobs if j.id == sel_id)
            st.write(f"**{sel_job.company}** — {sel_job.title}")
            st.caption(f"🔗 {sel_job.apply_url}")
            st.caption(f"📍 {sel_job.location} | Remote: {'✅' if sel_job.remote_ok else '❌'}")

            # Show CV variant selection
            variant, variant_file = pick_variant(sel_job.job_desc_snippet or f"{sel_job.company} {sel_job.title}")
            st.write(f"**Selected CV Variant**: {variant}")
            render_cv_file_viewer(variant, variant_file)

    with col_preview2:
        # Find and display preview bundle
        def _find_latest_bundle(job):
            slug = f"{job.company}_{job.title}".replace(" ", "_").replace("/", "-")
            candidates = sorted(Path("outputs").glob(f"*/*{slug}*"))
            return candidates[-1] if candidates else None

        if sel_id:
            bundle = _find_latest_bundle(sel_job)

            if bundle:
                st.success(f"📦 **Preview Bundle Found**")
                st.caption(f"📁 {bundle}")

                # Safe file reading function
                def _safe_read(file_path, max_chars=1500):
                    try:
                        if file_path.exists():
                            content = file_path.read_text(encoding="utf-8", errors="ignore")
                            if len(content) > max_chars:
                                return content[:max_chars] + "\n\n... (truncated)"
                            return content
                        return "File not found"
                    except Exception as e:
                        return f"Error reading file: {e}"

                # Tabbed preview interface
                tab1, tab2, tab3 = st.tabs(["📧 Email", "📝 Tailored Content", "ℹ️ Job Info"])

                with tab1:
                    st.markdown("**Email Subject:**")
                    subject_content = _safe_read(bundle / "email_subject.txt", 200)
                    st.code(subject_content, language="text")

                    st.markdown("**Email Body:**")
                    body_content = _safe_read(bundle / "email_body.txt", 800)
                    st.code(body_content, language="text")

                with tab2:
                    st.markdown("**Tailored Application Materials:**")
                    tailored_content = _safe_read(bundle / "tailored.txt", 1200)
                    st.code(tailored_content, language="text")

                with tab3:
                    st.markdown("**Job Information:**")
                    job_info = _safe_read(bundle / "job_info.txt", 500)
                    st.code(job_info, language="text")

                    # CV variant info
                    cv_variant_content = _safe_read(bundle / "cv_variant.txt", 200)
                    st.markdown("**CV Variant Selected:**")
                    st.code(cv_variant_content, language="text")

                # Quick action buttons for this specific job
                col_action1, col_action2 = st.columns(2)
                with col_action1:
                    if sel_job.status == "PREVIEW_READY" and st.button("✅ Approve This Job", key="approve_single"):
                        count = bulk_approve([sel_job.id])
                        if count > 0:
                            st.success("✅ Job approved!")
                            st.rerun()

                with col_action2:
                    if sel_job.status in ["PREVIEW_READY", "APPROVED"] and st.button("🔄 Regenerate Preview", key="regen_single"):
                        with st.spinner("Regenerating..."):
                            bulk_preview([sel_job.id])
                        st.success("🔄 Preview regenerated!")
                        st.rerun()

            else:
                st.info("📝 **No preview available for this job**")
                if st.button("✨ Generate Preview Now", key="gen_single"):
                    with st.spinner("Generating preview..."):
                        results = bulk_preview([sel_job.id])
                    if results and results[0].get("status") == "success":
                        st.success("✅ Preview generated!")
                        st.rerun()
                    else:
                        st.error("❌ Failed to generate preview")

# REPLACE the send modal section with this ENHANCED VERSION:

# Enhanced Send Modal with Real API Integration
if st.session_state.get("open_send_modal"):
    @st.dialog("🚀 Final Confirmation - Send Applications", width="large")
    def enhanced_send_modal():
        st.warning("**⚠️ Important:** Auto-submit only works with Greenhouse and Lever job boards. All other platforms require manual submission.")

        # Candidate Information Section
        st.subheader("👤 Candidate Information")
        col1, col2 = st.columns(2)
        with col1:
            first_name = st.text_input("First Name*", value="Omar", key="send_first")
            email = st.text_input("Email*", value="your.email@example.com", key="send_email")
        with col2:
            last_name = st.text_input("Last Name*", value="Runjanally", key="send_last") 
            phone = st.text_input("Phone", value="+44 XXX XXX XXXX", key="send_phone")

        # Validation
        if not all([first_name, last_name, email]):
            st.error("❌ Please fill in all required fields (marked with *)")
            return

        candidate_data = {
            "first_name": first_name,
            "last_name": last_name, 
            "email": email,
            "phone": phone
        }

        # API Configuration Section  
        st.subheader("🔑 API Configuration")
        col1, col2 = st.columns(2)
        with col1:
            gh_key = st.text_input("Greenhouse API Key", type="password", key="send_gh_key",
                                 help="Get from: Greenhouse > Configure > Dev Center > API Credentials")
        with col2:
            lever_key = st.text_input("Lever API Key", type="password", key="send_lever_key",
                                    help="Get from: Lever Settings > Integrations > API")

        # Job Analysis Section
        st.subheader("📋 Applications Ready for Submission")
        to_send = st.session_state.get("send_ids", [])

        if not to_send:
            st.error("❌ No jobs selected for submission")
            return

        with Session() as s:
            jobs_to_send = s.execute(select(Job).where(Job.id.in_(to_send))).scalars().all()

        # Platform analysis
        platform_stats = {"greenhouse": 0, "lever": 0, "manual": 0}
        job_analysis = []

        for job in jobs_to_send:
            url = (job.apply_url or "").lower()
            if "greenhouse.io" in url:
                platform = "greenhouse"
                icon = "🏢"
                api_ready = bool(gh_key)
                color = "🟢" if api_ready else "🔴"
            elif "lever.co" in url:
                platform = "lever"
                icon = "⚡"
                api_ready = bool(lever_key)
                color = "🟢" if api_ready else "🔴"
            else:
                platform = "manual"
                icon = "✋"
                api_ready = False
                color = "🟡"

            platform_stats[platform] += 1
            job_analysis.append({
                "job": job,
                "platform": platform,
                "icon": icon,
                "api_ready": api_ready,
                "color": color
            })

        # Display job list with status
        for analysis in job_analysis:
            job = analysis["job"]
            col1, col2, col3 = st.columns([3, 1, 1])

            with col1:
                st.write(f"{analysis['color']} {analysis['icon']} **{job.company}** - {job.title}")
            with col2:
                st.caption(f"Platform: {analysis['platform']}")
            with col3:
                if analysis['api_ready']:
                    st.success("Ready")
                elif analysis['platform'] == 'manual':
                    st.info("Manual")
                else:
                    st.error("No API Key")

        # Summary stats
        ready_count = sum(1 for a in job_analysis if a['api_ready'])
        st.info(f"📊 **Summary:** {platform_stats['greenhouse']} Greenhouse | {platform_stats['lever']} Lever | {platform_stats['manual']} Manual | **{ready_count} Ready for Auto-Submit**")

        # Final confirmation
        st.subheader("✅ Final Confirmation")

        all_reviewed = st.checkbox(f"I have reviewed all {len(jobs_to_send)} application previews and confirm they are ready to submit", key="confirm_reviewed")

        understand_manual = st.checkbox("I understand that manual platforms will need to be submitted separately", key="confirm_manual")

        # Action buttons
        col1, col2, col3 = st.columns([2, 1, 1])

        with col1:
            if st.button("🚀 Submit Applications", type="primary", 
                        disabled=not (all_reviewed and understand_manual),
                        key="execute_submit"):

                # Execute submissions
                st.subheader("🔄 Submitting Applications...")
                results = []
                progress = st.progress(0, "Starting submissions...")

                for i, analysis in enumerate(job_analysis):
                    job = analysis["job"]
                    platform = analysis["platform"]

                    progress.progress((i + 1) / len(job_analysis), f"Submitting to {job.company}...")

                    # Find bundle directory
                    slug = f"{job.company}_{job.title}".replace(" ", "_").replace("/", "-")
                    bundle_candidates = list(Path("outputs").glob(f"*/*{slug}*"))
                    bundle_dir = str(bundle_candidates[-1]) if bundle_candidates else None

                    if not bundle_dir:
                        results.append({
                            "job": f"{job.company} - {job.title}",
                            "success": False,
                            "message": "❌ Application bundle not found",
                            "platform": platform
                        })
                        continue

                    # Platform-specific submission
                    job_dict = {
                        "company": job.company,
                        "title": job.title,
                        "apply_url": job.apply_url
                    }

                    if platform == "greenhouse" and gh_key:
                        success, message = submit_greenhouse(job_dict, candidate_data, bundle_dir, gh_key)
                    elif platform == "lever" and lever_key:
                        success, message = submit_lever(job_dict, candidate_data, bundle_dir, lever_key)
                    else:
                        success, message = False, "✋ Manual submission required"

                    results.append({
                        "job": f"{job.company} - {job.title}",
                        "success": success,
                        "message": message,
                        "platform": platform
                    })

                    # Update database if successful
                    if success:
                        with Session() as update_s:
                            job_to_update = update_s.execute(select(Job).where(Job.id == job.id)).scalar_one()
                            job_to_update.status = "SENT"
                            update_s.commit()

                progress.progress(1.0, "✅ Complete!")

                # Results summary
                success_count = sum(1 for r in results if r["success"])
                manual_count = sum(1 for r in results if r["platform"] == "manual")

                st.success(f"🎉 **Submission Complete!** {success_count} applications sent successfully")

                if manual_count > 0:
                    st.info(f"ℹ️ {manual_count} applications require manual submission")

                # Detailed results
                with st.expander("📋 Detailed Results", expanded=True):
                    for result in results:
                        if result["success"]:
                            st.success(f"✅ **{result['job']}** - {result['message']}")
                        else:
                            st.error(f"❌ **{result['job']}** - {result['message']}")

                # Auto-close modal after successful submissions
                if success_count > 0:
                    st.session_state["open_send_modal"] = False
                    st.rerun()

        with col2:
            if st.button("❌ Cancel", key="cancel_send"):
                st.session_state["open_send_modal"] = False
                st.rerun()

        with col3:
            # Download summary button
            if st.button("📥 Export Summary", key="export_send"):
                summary_data = []
                for analysis in job_analysis:
                    job = analysis["job"]
                    summary_data.append({
                        "Company": job.company,
                        "Title": job.title,
                        "Platform": analysis["platform"],
                        "API Ready": "Yes" if analysis["api_ready"] else "No",
                        "URL": job.apply_url,
                        "Status": job.status
                    })

                df_summary = pd.DataFrame(summary_data)
                csv_data = df_summary.to_csv(index=False)

                st.download_button(
                    label="Download CSV",
                    data=csv_data,
                    file_name=f"submission_summary_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv",
                    mime="text/csv",
                    key="download_summary"
                )

    enhanced_send_modal()

print("🎯 DASHBOARD ENHANCEMENTS COMPLETE!")
print("✅ Enhanced CV file viewer with download capabilities")
print("✅ Tabbed preview interface for better organization") 
print("✅ Real-time platform detection and API readiness")
print("✅ Comprehensive error handling and user feedback")
print("✅ Export capabilities for submission summaries")
print("✅ Individual job actions (approve, regenerate)")
print("✅ Professional UI with proper status indicators")
