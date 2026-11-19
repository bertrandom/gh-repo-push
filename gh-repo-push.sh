#!/usr/bin/env bash
#
# Create a private GitHub repo for the current directory, add it as the
# "upstream" remote, push the current branch, and print the repo's URL.
#
# Requires: gh (authenticated), gum

set -euo pipefail

REMOTE=upstream

die() {
  gum style --foreground 196 "✗ $*" >&2
  exit 1
}

for cmd in gh gum git; do
  command -v "$cmd" >/dev/null 2>&1 || die "'$cmd' is not installed."
done

gh auth status >/dev/null 2>&1 || die "gh is not authenticated. Run 'gh auth login' first."

repo_root=$(git rev-parse --show-toplevel 2>/dev/null) \
  || die "$(pwd) is not inside a git repository."
cd "$repo_root"

git rev-parse --verify --quiet HEAD >/dev/null \
  || die "This repository has no commits yet. Commit something first."

if git remote get-url "$REMOTE" >/dev/null 2>&1; then
  die "A '$REMOTE' remote already exists: $(git remote get-url "$REMOTE")"
fi

branch=$(git branch --show-current)
[[ -n "$branch" ]] || die "HEAD is detached. Check out a branch first."

owner=$(gh api user --jq .login 2>/dev/null) || die "Couldn't look up your GitHub username."
commits=$(git rev-list --count HEAD)

gum style \
  --border rounded --border-foreground 212 --padding "1 2" --margin "1 0" \
  "$(gum style --bold --foreground 212 "Push to a new GitHub repo")" \
  "" \
  "Directory:   $repo_root" \
  "Owner:       $owner" \
  "Branch:      $branch ($commits commit$([[ "$commits" == 1 ]] || echo s))" \
  "Visibility:  $(gum style --bold --foreground 214 PRIVATE)" \
  "Remote:      $REMOTE"

name=$(gum input --value="$(basename "$repo_root")" --prompt="Repository name: " \
  --placeholder="repo-name") || {
  gum style --faint "Cancelled."
  exit 1
}
[[ -n "$name" ]] || die "Repository name can't be empty."

gum spin --spinner dot --show-error --title "Creating private repo $owner/$name..." -- \
  gh repo create "$name" --private --source=. --remote="$REMOTE" \
  || die "Failed to create $owner/$name."
gum style --foreground 42 "✓ Created $owner/$name"

gum spin --spinner dot --show-error --title "Pushing $branch to $REMOTE..." -- \
  git push --set-upstream "$REMOTE" "$branch" \
  || die "Failed to push $branch to $REMOTE."
gum style --foreground 42 "✓ Pushed $branch"

url=$(gh repo view "$owner/$name" --json url --jq .url)

gum style \
  --border rounded --border-foreground 42 --padding "0 2" --margin "1 0" \
  "$(gum style --bold --foreground 42 "✓ $owner/$name is on GitHub")" \
  "$url"
