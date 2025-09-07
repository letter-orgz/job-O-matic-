#!/usr/bin/env bash
set -euo pipefail

# ensure hooks dir
mkdir -p .git/hooks

# write/update pre-commit hook
cat > .git/hooks/pre-commit <<"SH"
#!/usr/bin/env bash
set -e

# Block committing secret-y files
if git diff --cached --name-only | grep -E '^(\.env|config\.yaml|secrets/)' -q; then
  echo "❌ Blocked: trying to commit .env/config.yaml/secrets/* — keep secrets out of git."
  exit 1
fi

# Block committing secret-looking content
if git diff --cached | grep -E 'API_KEY|SECRET_KEY|PERPLEXITY_API_KEY|BEGIN RSA PRIVATE KEY' -q; then
  echo "❌ Blocked: looks like a secret in the staged diff. Move it to .env and try again."
  exit 1
fi

# Block large files
if git diff --cached --name-only | xargs -I {} find {} -type f -size +10M 2>/dev/null | grep -q .; then
  echo "❌ Blocked: trying to commit large files (>10MB). Use Git LFS or exclude from git."
  exit 1
fi

# Encourage good commit practices for main/master branches
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
  echo "⚠️  Warning: Committing directly to $BRANCH branch. Consider using a feature branch."
  echo "   Run: git new-feature my-feature-name"
  echo "   Or: git daily-branch"
fi
SH

chmod +x .git/hooks/pre-commit
echo "✅ pre-commit installed at .git/hooks/pre-commit"

# write/update pre-push hook for additional protection
cat > .git/hooks/pre-push <<"SH"
#!/usr/bin/env bash
set -e

# Get the branch being pushed
BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Prevent pushing WIP commits to main/master
if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
  if git log --oneline -1 | grep -q "WIP:"; then
    echo "❌ Blocked: Cannot push WIP commits to $BRANCH branch."
    echo "   Use: git undo && git ci -m 'proper commit message'"
    exit 1
  fi
fi

# Check for merge conflicts markers
if git diff --check --cached; then
  echo "❌ Blocked: Found merge conflict markers or whitespace errors."
  exit 1
fi

echo "✅ Pre-push checks passed for branch: $BRANCH"
SH

chmod +x .git/hooks/pre-push
echo "✅ pre-push installed at .git/hooks/pre-push"
