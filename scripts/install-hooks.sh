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
SH

chmod +x .git/hooks/pre-commit
echo "✅ pre-commit installed at .git/hooks/pre-commit"
