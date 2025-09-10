# job-O-matic-
we gonna get this bread

## 🎯 Live Application: Omar's Job Radar

**🌐 [Access the live Job Radar application here](https://letter-orgz.github.io/job-O-matic-)** *(Available once GitHub Pages is configured)*

The Job Radar is a comprehensive job search and application management tool that runs entirely in your browser. Features include:
- 📊 Job data import (JSON, file upload, GitHub, Perplexity search)
- 🔍 Advanced filtering and search capabilities  
- 📈 Job statistics and tracking
- 📋 Application management with notes and cover letters
- 📥 Export functionality (CSV, JSON)
- 💾 Save/load application state

## ⚠️ Important: Codespace Billing Notice

**🚨 Current Issue: User v4mpire77 is being charged personally instead of organization billing.**

**If you are being charged personally for Codespaces from this repository:**
- 📖 **Immediate fix**: See [.github/BILLING_RESOLUTION_GUIDE.md](.github/BILLING_RESOLUTION_GUIDE.md)
- 📖 **Detailed guide**: [.github/CODESPACES_BILLING.md](.github/CODESPACES_BILLING.md)
- 🛑 **Stop creating Codespaces** until billing is properly configured
- 📧 **Contact**: @letter-orgz/admins for organization setup

## 🚀 Getting Started with Codespaces

This repository is configured with GitHub Codespaces for easy development setup.

### Option 1: Use GitHub Codespaces (Recommended)
1. Click the green "Code" button
2. Select "Codespaces" tab
3. **IMPORTANT**: Before clicking "Create codespace", verify that billing shows "letter-orgz" not your personal account
4. Click "Create codespace on main"
5. Wait for the environment to set up automatically
6. Once setup is complete, run: `./start.sh` or `streamlit run app.py`
7. The application will be available on port 8501

**💡 Billing Tip**: If you see your personal account name in the billing section, STOP and see [Billing Resolution Guide](.github/BILLING_RESOLUTION_GUIDE.md) before proceeding.

### Option 2: Local Development
1. Clone this repository
2. Install Python 3.11+
3. Install dependencies: `pip install -r requirements.txt`
4. Run the Streamlit app: `streamlit run app.py`

The Codespace will automatically:
- Set up Python 3.11 environment
- Install all required dependencies
- Forward port 8501 for Streamlit
- Configure VS Code with Python extensions
- Create necessary directory structure
- Display billing attribution information

## 📁 Directory Structure

```
job-O-matic/
├── app.py                    # Main Streamlit application
├── start.sh                  # Startup script
├── data/                     # User data (gitignored)
│   ├── cv/                   # CV files
│   └── templates/            # Email templates
├── src/                      # Source code
├── exports/                  # Export files (gitignored)
├── outputs/                  # Generated bundles (gitignored)
└── .devcontainer/           # Codespace configuration
```

## 🔧 Usage

1. **First time setup**: The app will create necessary directories
2. **Add CV files**: Place your CV variants in `data/cv/`
3. **Configure settings**: Use the Settings page for API keys
4. **Start applying**: Use Job Search and Applications features

## 🔌 GitHub Apps & Integrations

### ChatGPT Codex Connector
For AI-powered code suggestions and automated assistance:
- **Setup Guide**: [CHATGPT_CODEX_CONNECTOR_SETUP.md](CHATGPT_CODEX_CONNECTOR_SETUP.md)
- **Installation**: [GitHub App Installation](https://github.com/apps/chatgpt-codex-connector/installations/select_target)
- **Requirements**: Admin access to repository or organization

## 🔍 PR Merge Readiness Checker

Check which pull requests are ready to be merged:

```bash
# Quick check with GitHub CLI
./scripts/check-prs.sh

# Detailed analysis with Python
python3 scripts/check-pr-merge-readiness.py

# Or use the shell wrapper
./scripts/check-pr-readiness.sh
```

See [docs/PR_MERGE_CHECKER.md](docs/PR_MERGE_CHECKER.md) for detailed usage instructions.

## 🆘 Troubleshooting

### Common Issues

**If you encounter "No such file or directory" when running `./start.sh`:**
- Make sure you're in the job-O-matic root directory (where `app.py` exists)
- Verify the script has execute permissions: `chmod +x start.sh`
- The enhanced start.sh script will now automatically install missing dependencies

**If you encounter "Codespace access limited" errors:**
- Refresh the Codespace
- Check if the container built successfully
- Run `./start.sh` manually if the app doesn't auto-start

**If you encounter dependency issues:**
- The start.sh script will automatically install dependencies from requirements.txt
- You can also manually install: `pip3 install -r requirements.txt`
- Ensure you have Python 3.11+ installed
