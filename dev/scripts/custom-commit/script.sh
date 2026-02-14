#!/usr/bin/env bash

set -euo pipefail

log() {
  local level="$1"
  shift
  gum log --structured --time TimeOnly --level "$level" "$@"
}

run_with_spinner() {
  local title="$1"
  shift
  gum spin --spinner points --show-error --title "$title" -- "$@"
}

if git diff --cached --quiet; then
  log error "No staged changes to commit. Use 'git add' first."
  exit 1
fi

if ! run_with_spinner \
  "Checking pre-commit hooks for potential errors..." \
  pre-commit run -a
then
  log error "Pre-commit checks failed. Please correct them."
  exit 1
fi

TYPE=$(gum choose \
  --header "Pick a type for the commit:" \
  --header.foreground "#04B575" \
  "fix: A bug fix. Correlates with PATCH in SemVer" \
  "feat: A new feature. Correlates with MINOR in SemVer" \
  "docs: Documentation only changes" \
  "style: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)" \
  "refactor: A code change that neither fixes a bug nor adds a feature" \
  "perf: A code change that improves performance" \
  "test: Adding missing or correcting existing tests" \
  "build: Changes that affect the build system or external dependencies (example scopes: pip, docker, npm)" \
  "ci: Changes to CI configuration files and scripts (example scopes: GitLabCI)"
)
TYPE=${TYPE%%:*}

SCOPE=$(gum input \
  --header "What's the scope of this commit? (optional):" \
  --header.foreground "#04B575"
)
[[ -n "$SCOPE" ]] && SCOPE="($SCOPE)"

while :; do
  SUMMARY=$(gum input \
    --prompt "> $TYPE$SCOPE: " \
    --header "Write a short summary of this commit:" \
    --header.foreground "#04B575"
  )
  [[ ! "$SUMMARY" =~ ^[[:space:]]*$ ]] && break
  log error "Summary can't be empty. Please write something."
done

DESCRIPTION=$(gum write \
  --header "Any additional contextual information? (optional):" \
  --header.foreground "#04B575"
)
[[ "$DESCRIPTION" =~ ^[[:space:]]*$ ]] && DESCRIPTION=""

BREAKING_CHANGE=$(gum choose "Yes" "No" \
  --header "Is this a BREAKING CHANGE? " \
  --header.foreground "#04B575"
)
if [ "$BREAKING_CHANGE" = "Yes" ]; then
  BREAKING_CHANGE_INFO=$(gum write \
    --header "Information about Breaking changes (recommended but optional):" \
    --header.foreground "#04B575"
  )
  COMMIT_MSG="$TYPE!$SCOPE: $SUMMARY"
  [[ "$DESCRIPTION" != "" ]] && COMMIT_MSG+=$'\n\n'"$DESCRIPTION"
  COMMIT_MSG+=$'\n\nBREAKING CHANGE: '"$BREAKING_CHANGE_INFO"
else
  COMMIT_MSG="$TYPE$SCOPE: $SUMMARY"
  [[ "$DESCRIPTION" != "" ]] && COMMIT_MSG+=$'\n\n'"$DESCRIPTION"
fi

printf "Final Commit Message:" | gum style --foreground "#FFF700" --bold
printf "\n"
printf "%s" "$COMMIT_MSG" | gum style --padding "0 1" --border double --border-foreground 255

if ! gum confirm --default=true --affirmative "Commit" --negative "Abort" \
  "Do you want to create this commit?"
then
  log info "Commit aborted."
  exit 0
fi

if ! run_with_spinner "Committing..." \
  git commit -m "$COMMIT_MSG"
then
  log error "Commit failed"
  exit 1
fi

BRANCH=$(git branch --show-current)
SHA=$(git rev-parse --short HEAD)
log info "Commit successful" branch "$BRANCH" sha "$SHA"
