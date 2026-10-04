#!/usr/bin/env bash
# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0
#
# Merges the latest upstream OpenTelemetry Demo release tag into a
# sync/upstream-<tag> branch. Pushing and opening the PR is left to the caller.
#
# Writes to $GITHUB_OUTPUT:
#   status    up-to-date | pending | merged | conflict
#   tag       latest upstream release tag
#   branch    sync branch name
#   conflicts conflicting paths (status=conflict)
#   warnings  fork-specific settings upstream may have reintroduced

set -euo pipefail

UPSTREAM_URL=${UPSTREAM_URL:-https://github.com/open-telemetry/opentelemetry-demo.git}
GITHUB_OUTPUT=${GITHUB_OUTPUT:-/dev/stdout}

set_output() { echo "$1=$2" >>"$GITHUB_OUTPUT"; }

set_multiline_output() {
  local delim="EOF_$RANDOM$RANDOM"
  { echo "$1<<$delim"; [[ -n "$2" ]] && echo "$2"; echo "$delim"; } >>"$GITHUB_OUTPUT"
}

if git remote get-url upstream >/dev/null 2>&1; then
  git remote set-url upstream "$UPSTREAM_URL"
else
  git remote add upstream "$UPSTREAM_URL"
fi

# Release tags only: plain MAJOR.MINOR.PATCH, skipping v-prefixed and pre-releases.
tag=$(git ls-remote --tags --refs upstream \
  | sed 's#.*refs/tags/##' \
  | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
  | sort -t. -k1,1n -k2,2n -k3,3n \
  | tail -1)
if [[ -z "$tag" ]]; then
  echo "No release tags found on $UPSTREAM_URL" >&2
  exit 1
fi
branch="sync/upstream-$tag"
set_output tag "$tag"
set_output branch "$branch"

git fetch --quiet --no-tags upstream "refs/tags/$tag:refs/tags/$tag"

if git merge-base --is-ancestor "$tag" HEAD; then
  echo "Already contains upstream $tag"
  set_output status up-to-date
  exit 0
fi

if git ls-remote --exit-code --heads origin "$branch" >/dev/null; then
  echo "$branch already exists on origin; waiting for it to be merged"
  set_output status pending
  exit 0
fi

base=$(git branch --show-current)
git switch --quiet -c "$branch"

if ! git merge --no-ff --no-edit -m "Merge upstream OpenTelemetry Demo $tag" "$tag"; then
  conflicts=$(git diff --name-only --diff-filter=U)
  git merge --abort
  git switch --quiet "$base"
  git branch --quiet -D "$branch"
  echo "Merge of $tag conflicts in:"
  echo "$conflicts"
  set_output status conflict
  set_multiline_output conflicts "$conflicts"
  exit 0
fi

# The fork publishes images itself, so upstream's "skip on forks" guards and
# its `uses: $/...` reusable-workflow path must stay out of these workflows.
warnings=$(grep -nE 'github\.event\.repository\.fork|uses: \$/' \
  .github/workflows/build-images.yml \
  .github/workflows/release.yml \
  .github/workflows/component-build-images.yml 2>/dev/null || true)

echo "Merged upstream $tag into $branch"
set_output status merged
set_multiline_output warnings "$warnings"
