#!/bin/bash
# Job-O-Matic Startup Script for Codespaces

echo "🎯 Starting Job-O-Matic..."

# Check if running in Codespaces
if [ "$CODESPACES" = "true" ]; then
    echo "📡 Running in GitHub Codespaces"
    # Start Streamlit with Codespace-friendly settings
    streamlit run app.py --server.headless true --server.port 8501 --server.address 0.0.0.0
else
    echo "💻 Running locally"
    # Start Streamlit normally
    streamlit run app.py
fi