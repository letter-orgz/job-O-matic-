# job-O-matic-
we gonna get this bread

## 🚀 Getting Started with Codespaces

This repository is configured with GitHub Codespaces for easy development setup.

### Option 1: Use GitHub Codespaces (Recommended)
1. Click the green "Code" button
2. Select "Codespaces" tab
3. Click "Create codespace on main"
4. Wait for the environment to set up automatically
5. Once setup is complete, run: `./src/start.sh` or `streamlit run src/app.py`
6. The application will be available on port 8501

### Option 2: Local Development
1. Clone this repository
2. Install Python 3.11+
3. Install dependencies: `pip install -r requirements.txt`
4. Run the Streamlit app: `streamlit run src/app.py`

The Codespace will automatically:
- Set up Python 3.11 environment
- Install all required dependencies
- Forward port 8501 for Streamlit
- Configure VS Code with Python extensions
- Create necessary directory structure

## 📁 Directory Structure

```
job-O-matic/
├── src/                      # Source code
│   ├── app.py                # Main Streamlit application
│   └── start.sh              # Startup script
├── data/                     # User data (partially gitignored)
│   ├── cv/                   # CV files
│   └── templates/            # Email templates
├── exports/                  # Export files (gitignored)
├── outputs/                  # Generated bundles (gitignored)
└── .devcontainer/           # Codespace configuration
```

## 🔧 Usage

1. **First time setup**: The app will create necessary directories
2. **Add CV files**: Place your CV variants in `data/cv/`
3. **Configure settings**: Use the Settings page for API keys
4. **Start applying**: Use Job Search and Applications features

## 🆘 Troubleshooting

### Common Issues

**If you encounter "No such file or directory" when running `./src/start.sh`:**
- Make sure you're in the job-O-matic root directory (where `src/app.py` exists)
- Verify the script has execute permissions: `chmod +x src/start.sh`
- The enhanced `src/start.sh` script will now automatically install missing dependencies

**If you encounter "Codespace access limited" errors:**
- Refresh the Codespace
- Check if the container built successfully
- Run `./src/start.sh` manually if the app doesn't auto-start

**If you encounter dependency issues:**
- The `src/start.sh` script will automatically install dependencies from requirements.txt
- You can also manually install: `pip3 install -r requirements.txt`
- Ensure you have Python 3.11+ installed
