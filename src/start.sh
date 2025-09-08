#!/bin/bash
# Job-O-Matic Startup Script for Codespaces

echo "🎯 Starting Job-O-Matic..."

# Ensure the app entry point exists
APP_PATH="src/app.py"
if [ ! -f "$APP_PATH" ]; then
    echo "❌ Error: $APP_PATH not found"
    echo "Please make sure you're running this script from the repository root"
    exit 1
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
    streamlit run "$APP_PATH" --server.headless true --server.port 8501 --server.address 0.0.0.0
else
    echo "💻 Running locally"
    # Start Streamlit normally
    streamlit run "$APP_PATH"
fi

