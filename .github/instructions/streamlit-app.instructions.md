---
applyTo: "app.py"
---

# Streamlit App Instructions for Job-O-Matic

This file is the main entry point for the Streamlit application. Follow these guidelines when modifying:

## Streamlit Best Practices

1. **Page Configuration** - Keep the existing page config at the top
2. **Session State** - Use `st.session_state` for maintaining state across reruns
3. **Sidebar Navigation** - Maintain the current sidebar structure for consistency
4. **Error Handling** - Always use try-catch blocks around Streamlit operations

## UI Components Standards

1. **Progress Indicators** - Use `st.progress()` for long-running operations
2. **User Feedback** - Provide clear success/error messages with `st.success()`, `st.error()`, `st.warning()`
3. **Input Validation** - Validate user inputs before processing
4. **Confirmation Dialogs** - Require explicit user confirmation for destructive operations

## Layout Patterns

1. **Wide Layout** - Use the configured wide layout for better space utilization
2. **Columns** - Use `st.columns()` for side-by-side content where appropriate
3. **Expandable Sections** - Use `st.expander()` for detailed information
4. **Tabs** - Use `st.tabs()` for organizing related content

## Data Display

1. **Tables** - Use `st.dataframe()` with proper column configuration
2. **Charts** - Use Streamlit's built-in charting for data visualization
3. **File Downloads** - Implement download buttons for exports
4. **File Uploads** - Validate uploaded files before processing

## Performance Optimization

1. **Caching** - Use `@st.cache_data` for expensive computations
2. **Lazy Loading** - Load data only when needed
3. **State Management** - Minimize unnecessary reruns with proper state management
4. **Memory Management** - Clear large objects from session state when not needed

## Security in UI

1. **Input Sanitization** - Sanitize all user inputs displayed in the UI
2. **File Upload Security** - Validate file types and sizes
3. **XSS Prevention** - Be careful with user-generated content display
4. **Session Management** - Clear sensitive data from session state appropriately

## Integration with Backend

1. **Database Operations** - Keep database logic in separate modules, import as needed
2. **API Calls** - Handle API responses gracefully with user feedback
3. **File Operations** - Provide clear feedback for file operations (save, load, export)
4. **Error Propagation** - Display backend errors in user-friendly format

## Accessibility

1. **Clear Labels** - Use descriptive labels for all interactive elements
2. **Progress Feedback** - Provide feedback for long-running operations
3. **Error Messages** - Make error messages clear and actionable
4. **Navigation** - Ensure consistent navigation patterns

Example pattern for new page functions:
```python
def show_new_feature():
    """Display new feature page with proper error handling."""
    st.header("New Feature")
    
    try:
        # Check prerequisites
        if not prerequisite_check():
            st.warning("⚠️ Prerequisites not met. Please configure settings first.")
            return
        
        # Main feature UI
        with st.form("new_feature_form"):
            user_input = st.text_input("Enter value:")
            submitted = st.form_submit_button("Submit")
            
            if submitted and user_input:
                with st.spinner("Processing..."):
                    success, result = process_feature(user_input)
                    
                if success:
                    st.success("✅ Operation completed successfully!")
                    st.write(result)
                else:
                    st.error(f"❌ Operation failed: {result}")
                    
    except Exception as e:
        st.error(f"❌ Unexpected error: {e}")
        logger.exception("Error in new feature page")
```

## Debugging and Logging

1. **Debug Information** - Use `st.write()` or `st.json()` for debugging data structures
2. **Exception Logging** - Log exceptions properly while showing user-friendly messages
3. **State Inspection** - Add debug sections to inspect session state when needed
4. **Performance Monitoring** - Monitor page load times and user interactions