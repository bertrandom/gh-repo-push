#!/bin/bash
set -euo pipefail

REPO_NAME=$(basename "$PWD")
FINAL_REPO_NAME=$(gum input --value="$REPO_NAME" --prompt="Repository name: ")

gh repo create $FINAL_REPO_NAME --private --source=. --remote=upstream
git push
REPO_URL=$(gh repo view "$FINAL_REPO_NAME" --json url --jq .url)
echo "$REPO_URL"
