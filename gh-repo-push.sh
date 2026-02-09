#!/bin/bash
set -euo pipefail

REPO_NAME=$(basename "$PWD")
FINAL_REPO_NAME=$(gum input --value="$REPO_NAME" --prompt="Repository name: ")

gh repo create $FINAL_REPO_NAME --private --source=. --remote=upstream