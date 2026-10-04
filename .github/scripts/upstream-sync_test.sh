#!/usr/bin/env bash
# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0
#
# Tests for upstream-sync.sh using throwaway local git repositories.
# Usage: .github/scripts/upstream-sync_test.sh

set -euo pipefail

SCRIPT="$(cd "$(dirname "$0")" && pwd)/upstream-sync.sh"
failures=0

git_q() { git -c init.defaultBranch=main -c user.name=test -c user.email=test@example.com "$@" >/dev/null 2>&1; }

commit_file() {
  local repo=$1 path=$2 content=$3 msg=$4
  mkdir -p "$(dirname "$repo/$path")"
  printf '%s\n' "$content" >"$repo/$path"
  git_q -C "$repo" add "$path"
  git_q -C "$repo" commit -m "$msg"
}

# Builds: upstream (tags 1.0.0, v9.9.9, 2.0.0-rc.1), origin (fork of 1.0.0 plus
# a fork commit) and a working clone of origin. Prints the sandbox path.
setup() {
  local sandbox
  sandbox=$(mktemp -d)
  git_q init "$sandbox/upstream"
  commit_file "$sandbox/upstream" README.md "upstream readme" "initial"
  commit_file "$sandbox/upstream" shared.txt "base" "shared file"
  git_q -C "$sandbox/upstream" tag 1.0.0
  git_q -C "$sandbox/upstream" tag v9.9.9
  git_q clone --bare "$sandbox/upstream" "$sandbox/origin.git"
  git_q clone "$sandbox/origin.git" "$sandbox/work"
  commit_file "$sandbox/work" fork.txt "fork only" "fork change"
  git_q -C "$sandbox/work" push origin main
  echo "$sandbox"
}

run_sync() {
  local sandbox=$1
  : >"$sandbox/output"
  (cd "$sandbox/work" && UPSTREAM_URL="$sandbox/upstream" GITHUB_OUTPUT="$sandbox/output" \
    "$SCRIPT" >"$sandbox/log" 2>&1) || echo "upstream-sync.sh exited $?, see $sandbox/log"
}

# Reads a GITHUB_OUTPUT value, either `name=value` or multiline `name<<DELIM`.
output() {
  awk -v name="$2" '
    delim != "" { if ($0 == delim) exit; print; next }
    index($0, name "=") == 1 { print substr($0, length(name) + 2); exit }
    index($0, name "<<") == 1 { delim = substr($0, length(name) + 3) }
  ' "$1/output"
}

assert_eq() {
  if [[ "$2" == "$3" ]]; then
    echo "  ok: $1"
  else
    echo "  FAIL: $1 (expected '$3', got '$2')"
    failures=$((failures + 1))
  fi
}

test_new_release_merges_cleanly() {
  echo "test_new_release_merges_cleanly"
  local s
  s=$(setup)
  commit_file "$s/upstream" new.txt "new" "upstream feature"
  git_q -C "$s/upstream" tag 1.1.0
  commit_file "$s/upstream" rc.txt "rc" "release candidate"
  git_q -C "$s/upstream" tag 2.0.0-rc.1
  run_sync "$s"
  assert_eq "status" "$(output "$s" status)" "merged"
  assert_eq "tag ignores v-prefixed and pre-release tags" "$(output "$s" tag)" "1.1.0"
  assert_eq "branch" "$(output "$s" branch)" "sync/upstream-1.1.0"
  assert_eq "on sync branch" "$(git -C "$s/work" branch --show-current)" "sync/upstream-1.1.0"
  assert_eq "merge commit has two parents" "$(git -C "$s/work" rev-list --parents -n1 HEAD | wc -w | tr -d ' ')" "3"
  assert_eq "fork change kept" "$(cat "$s/work/fork.txt")" "fork only"
  assert_eq "no fork warnings" "$(output "$s" warnings)" ""
  rm -rf "$s"
}

test_up_to_date_is_noop() {
  echo "test_up_to_date_is_noop"
  local s
  s=$(setup)
  run_sync "$s"
  assert_eq "status" "$(output "$s" status)" "up-to-date"
  assert_eq "still on main" "$(git -C "$s/work" branch --show-current)" "main"
  rm -rf "$s"
}

test_pending_sync_branch_is_noop() {
  echo "test_pending_sync_branch_is_noop"
  local s
  s=$(setup)
  commit_file "$s/upstream" new.txt "new" "upstream feature"
  git_q -C "$s/upstream" tag 1.1.0
  git_q -C "$s/work" push origin main:refs/heads/sync/upstream-1.1.0
  run_sync "$s"
  assert_eq "status" "$(output "$s" status)" "pending"
  assert_eq "still on main" "$(git -C "$s/work" branch --show-current)" "main"
  rm -rf "$s"
}

test_conflict_is_reported_and_aborted() {
  echo "test_conflict_is_reported_and_aborted"
  local s
  s=$(setup)
  commit_file "$s/work" shared.txt "fork edit" "fork edits shared"
  git_q -C "$s/work" push origin main
  commit_file "$s/upstream" shared.txt "upstream edit" "upstream edits shared"
  git_q -C "$s/upstream" tag 1.1.0
  run_sync "$s"
  assert_eq "status" "$(output "$s" status)" "conflict"
  assert_eq "conflicting files listed" "$(output "$s" conflicts)" "shared.txt"
  assert_eq "merge aborted, tree clean" "$(git -C "$s/work" status --porcelain)" ""
  assert_eq "back on main" "$(git -C "$s/work" branch --show-current)" "main"
  rm -rf "$s"
}

test_fork_guard_is_flagged() {
  echo "test_fork_guard_is_flagged"
  local s
  s=$(setup)
  commit_file "$s/upstream" .github/workflows/build-images.yml \
    "    if: \${{ !github.event.repository.fork }}" "upstream adds fork guard"
  git_q -C "$s/upstream" tag 1.1.0
  run_sync "$s"
  assert_eq "status" "$(output "$s" status)" "merged"
  assert_eq "warning mentions file" \
    "$(grep -c 'build-images.yml' "$s/output" | tr -d ' ')" "1"
  rm -rf "$s"
}

test_invalid_uses_path_is_flagged_in_any_workflow() {
  echo "test_invalid_uses_path_is_flagged_in_any_workflow"
  local s
  s=$(setup)
  commit_file "$s/upstream" .github/workflows/checks.yml \
    "    uses: \$/.github/workflows/codeql-analysis.yml" "upstream adds bad uses path"
  git_q -C "$s/upstream" tag 1.1.0
  run_sync "$s"
  assert_eq "status" "$(output "$s" status)" "merged"
  assert_eq "warning mentions file" \
    "$(grep -c 'checks.yml' "$s/output" | tr -d ' ')" "1"
  rm -rf "$s"
}

test_new_release_merges_cleanly
test_up_to_date_is_noop
test_pending_sync_branch_is_noop
test_conflict_is_reported_and_aborted
test_fork_guard_is_flagged
test_invalid_uses_path_is_flagged_in_any_workflow

if ((failures > 0)); then
  echo "$failures assertion(s) failed"
  exit 1
fi
echo "all tests passed"
