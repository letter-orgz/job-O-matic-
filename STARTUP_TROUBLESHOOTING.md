# GitHub MCP Startup Guide

## Overview
The Job-O-Matic GitHub MCP (Multi-Channel Platform) startup script has been enhanced with comprehensive git workflow management and interactive features.

## Features Fixed

### ✅ Git Workflow Management
- **Daily Branch Creation**: Automatically creates `daily/YYYY-MM-DD` branches
- **Base Branch Sync**: Pulls latest changes from main/master before creating daily branches
- **Interactive Prompts**: Asks user if they want to switch to daily branch
- **Status Display**: Shows current branch, working directory status, and commit history

### ✅ Multiple Operating Modes
- **Interactive Mode**: Full prompts and user interaction (default when TTY detected)
- **Non-Interactive Mode**: Skips prompts for CI/CD environments
- **Force Interactive Mode**: `--force-interactive` flag for testing
- **Help Mode**: `--help` shows comprehensive usage information

### ✅ Enhanced Error Handling
- **Directory Validation**: Ensures script runs from correct directory
- **Python/Streamlit Checks**: Validates dependencies before startup
- **Git Repository Detection**: Handles non-git directories gracefully
- **Remote Connection**: Handles offline scenarios

### ✅ Codespace Integration
- **Billing Information**: Clear display of organization billing
- **Port Configuration**: Proper Streamlit settings for Codespaces
- **Environment Detection**: Different behavior for local vs Codespace

## Usage Examples

### Standard Startup
```bash
./start.sh
```
- Detects interactive/non-interactive mode automatically
- Shows git status and offers daily branch creation
- Starts Streamlit application

### Force Interactive Testing
```bash
./start.sh --force-interactive
```
- Forces interactive mode even in non-TTY environments
- Useful for testing workflows

### Show Help
```bash
./start.sh --help
```
- Displays comprehensive usage information
- Shows all available features and options

## Git Workflow Process

1. **Status Check**: Displays current branch and repository status
2. **Daily Branch Detection**: Checks if on today's daily branch (daily/YYYY-MM-DD)
3. **User Prompt**: If not on daily branch, asks user if they want to switch
4. **Base Branch Sync**: Pulls latest changes from main/master
5. **Branch Creation**: Creates and switches to daily branch
6. **Final Status**: Shows updated repository status

## Testing

Run the test suite to validate all functionality:
```bash
./test_git_workflow.sh
```

Tests include:
- Help command functionality
- All required functions present
- Script permissions and syntax
- Git workflow logic

## Troubleshooting

### Common Issues Resolved
- ❌ **Missing git workflow management** → ✅ **Full workflow integration**
- ❌ **No interactive mode detection** → ✅ **Automatic mode detection**
- ❌ **Basic startup only** → ✅ **Comprehensive branch management**
- ❌ **No daily branch support** → ✅ **Automatic daily branch creation**
- ❌ **Limited error handling** → ✅ **Robust error handling**

### If Issues Persist
1. Ensure you're in the repository root directory
2. Check that git is properly configured
3. Verify Python 3.11+ and pip are available
4. Run `./test_git_workflow.sh` to validate functionality
5. Use `./start.sh --help` for usage guidance

## Technical Details

The enhanced script includes:
- **6 core functions** for git workflow management
- **Interactive/non-interactive mode detection** via TTY checking
- **Comprehensive error handling** for all failure scenarios
- **Codespace-specific optimizations** for GitHub development environments
- **Full backward compatibility** with existing functionality

All enhancements maintain the original Job-O-Matic functionality while adding the missing GitHub MCP features that were referenced in the repository documentation.