# job-O-matic-
we gonna get this bread

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

## 🌿 Daily Branch Management

This repository includes an automated daily branch management system to keep the main codebase clean and provide structured development workflows.

### Quick Start
```bash
# Start of day - full workflow
./scripts/branch-mgmt.sh start feature-name

# End of day - merge completed work
./scripts/branch-mgmt.sh merge

# Check current status
./scripts/branch-mgmt.sh status
```

### Features
- **Consistent naming**: Creates branches like `feat/2025-09-07-feature-name`
- **Automated cleanup**: Archives old branches automatically
- **Safety checks**: Prevents uncommitted changes and secret commits
- **Protected main**: Enforces clean merge practices

📖 **Full documentation**: [docs/BRANCH_MANAGEMENT.md](docs/BRANCH_MANAGEMENT.md)

## 📁 Directory Structure

```
job-O-matic/
├── app.py                    # Main Streamlit application
├── start.sh                  # Startup script
├── scripts/                  # Branch management scripts
│   ├── branch-mgmt.sh        # Main CLI for branch management
│   ├── daily-branch-*.sh     # Individual workflow scripts
│   └── install-hooks.sh      # Git hooks installer
├── docs/                     # Documentation
│   └── BRANCH_MANAGEMENT.md  # Branch workflow guide
├── data/                     # User data (gitignored)
│   ├── cv/                   # CV files
│   └── templates/            # Email templates
├── src/                      # Source code
├── exports/                  # Export files (gitignored)
├── outputs/                  # Generated bundles (gitignored)
└── .devcontainer/           # Codespace configuration
```

## 🔧 Usage

### Application Usage
1. **First time setup**: The app will create necessary directories
2. **Add CV files**: Place your CV variants in `data/cv/`
3. **Configure settings**: Use the Settings page for API keys
4. **Start applying**: Use Job Search and Applications features

### Development Workflow
1. **Start of day**: `./scripts/branch-mgmt.sh start feature-description`
2. **Work normally**: Make commits, push changes as usual
3. **End of day**: `./scripts/branch-mgmt.sh merge`
4. **Check status**: `./scripts/branch-mgmt.sh status` anytime

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
