#!/bin/bash
# Job-O-Matic Startup Script for Codespaces

echo "🎯 Starting Job-O-Matic..."

# Check if we're in the right directory
if [ ! -f "app.py" ]; then
    echo "❌ Error: app.py not found in current directory"
    echo "Please make sure you're running this script from the job-O-matic root directory"
    exit 1
fi

# Display billing information if in Codespace
if [ "$CODESPACES" = "true" ]; then
    echo ""
    echo "💳 Codespace Billing Information:"
    echo "  Repository: letter-orgz/job-O-matic-"
    echo "  This Codespace should be billed to letter-orgz organization"
    echo "  If you see personal charges, run: ./check-billing.sh"
    echo ""
fi

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: python3 not found"
    echo "Please install Python 3.11+ and try again"
    exit 1
fi

# Check if streamlit is installed
if ! command -v streamlit &> /dev/null; then
    echo "⚠️  Warning: streamlit not found in PATH"
    echo "📦 Installing dependencies from requirements.txt..."
    
    if [ -f "requirements.txt" ]; then
        if pip3 install -r requirements.txt; then
            echo "✅ Dependencies installed successfully"
        else
            echo "❌ Error: Failed to install dependencies"
            echo "Please run: pip3 install -r requirements.txt"
            exit 1
        fi
    else
        echo "❌ Error: requirements.txt not found"
        echo "Please install streamlit manually: pip3 install streamlit"
        exit 1
    fi
fi

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