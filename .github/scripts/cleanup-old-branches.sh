#!/usr/bin/env bash
# Cleanup: close old PRs from Konflux CI Test App and delete branches older than CUTOFF_DAYS.
# Usage:
#   ./cleanup-old-branches.sh                    # run for real (CI)
#   ./cleanup-old-branches.sh --dry-run           # echo destructive commands to stdout
#   ./cleanup-old-branches.sh --dry-run FILE      # echo destructive commands to FILE
#
# Env: CUTOFF_DAYS, EXCLUDED_BRANCHES, PR_AUTHOR, GITHUB_REPOSITORY (or detected from git remote),
#      REMOTE (default origin) = which remote to fetch and list branches from; e.g. REMOTE=upstream for konflux-ci/testrepo)

set -e

# -----------------------------------------------------------------------------
# Parse --dry-run [file]
# -----------------------------------------------------------------------------
DRY_RUN=""
DRY_RUN_FILE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      if [ $# -gt 0 ] && [[ "$1" != --* ]]; then
        DRY_RUN_FILE="$1"
        shift
      fi
      ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Usage: $0 [--dry-run [FILE]]" >&2
      exit 1
      ;;
  esac
done

dry_run_write() {
  local line="$1"
  if [ -n "$DRY_RUN" ]; then
    if [ -n "$DRY_RUN_FILE" ]; then
      echo "$line" >> "$DRY_RUN_FILE"
    else
      echo "$line"
    fi
  fi
}

run_or_echo() {
  # run_or_echo "gh pr close 123 --repo owner/repo --delete-branch"
  local cmd="$1"
  if [ -n "$DRY_RUN" ]; then
    dry_run_write "$cmd"
  else
    eval "$cmd" || true
  fi
}

# -----------------------------------------------------------------------------
# Config (env with defaults)
# -----------------------------------------------------------------------------
CUTOFF_DAYS="${CUTOFF_DAYS:-7}"
# HEAD = refs/remotes/<remote>/HEAD (symbolic ref); must not be passed to git push --delete
EXCLUDED_BRANCHES="${EXCLUDED_BRANCHES:-main|master|integration-tests|HEAD}"
PR_AUTHOR="${PR_AUTHOR:-konflux-ci-test-app[bot]}"
REMOTE="${REMOTE:-origin}"

if [ -z "$GITHUB_REPOSITORY" ]; then
  # Detect from git remote (for local dry run)
  GITHUB_REPOSITORY=$(git remote get-url origin 2>/dev/null | sed -n 's|.*github\.com[:/]\([^/]*/[^/]*\)\.git|\1|p' | head -1)
  if [ -z "$GITHUB_REPOSITORY" ]; then
    echo "GITHUB_REPOSITORY not set and could not detect from git remote" >&2
    exit 1
  fi
  echo "Using GITHUB_REPOSITORY=$GITHUB_REPOSITORY (from git remote)" >&2
fi

REPO="$GITHUB_REPOSITORY"
DATE_LIMIT=$(date -d "-$CUTOFF_DAYS days" +%Y-%m-%d 2>/dev/null || date -v-${CUTOFF_DAYS}d +%Y-%m-%d)

if [ -n "$DRY_RUN" ]; then
  echo "DRY RUN: destructive commands will be echoed only (no PRs closed, no branches deleted)" >&2
  if [ -n "$DRY_RUN_FILE" ]; then
    echo "Output file: $DRY_RUN_FILE" >&2
    : > "$DRY_RUN_FILE"
  fi
fi

# -----------------------------------------------------------------------------
# 1. Close old PRs from Konflux Bot (server-side search)
# -----------------------------------------------------------------------------
echo "Searching for open PRs by $PR_AUTHOR created before $DATE_LIMIT..." >&2

# Use flags only; the "created:<DATE" query overrides author filter and returns 0 results.
# Fetch by author/state then filter by createdAt in jq.
CUTOFF_ISO="${DATE_LIMIT}T00:00:00Z"
pr_numbers=$(gh search prs --repo "$REPO" --author "$PR_AUTHOR" --state open \
  --json number,createdAt --limit 1000 \
  --jq ".[] | select(.createdAt < \"$CUTOFF_ISO\") | .number" || true)

if [ -z "$pr_numbers" ]; then
  echo "No PRs to close." >&2
else
  while read -r pr_number; do
    [ -z "$pr_number" ] && continue
    echo "Would close PR #$pr_number" >&2
    run_or_echo "gh pr close $pr_number --repo $REPO --delete-branch"
  done <<< "$pr_numbers"
fi

# -----------------------------------------------------------------------------
# 2. Delete branches older than CUTOFF_DAYS (git for-each-ref + batch push)
# -----------------------------------------------------------------------------
# In CI, checkout already did a full clone (fetch-depth: 0) so we have all refs.
# Locally, fetch so we see all branches on the remote (clone may only have a subset).
# --prune removes local refs for branches deleted on the server, avoiding "remote ref does not exist" errors.
if [ -z "${GITHUB_ACTIONS:-}" ]; then
  echo "Fetching from remote '$REMOTE' (this may take a while for repos with many branches)..." >&2
  git fetch "$REMOTE" --prune 2>/dev/null || true
fi

# Git config and remote URL only in CI (ephemeral runner). Locally, do not overwrite user's config or remote URL.
if [ -z "$DRY_RUN" ] && [ -n "${GITHUB_ACTIONS:-}" ]; then
  git config user.name "github-actions[bot]"
  git config user.email "github-actions[bot]@users.noreply.github.com"
  if [ -n "$GITHUB_TOKEN" ]; then
    git remote set-url "$REMOTE" "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
  fi
fi

echo "Identifying stale branches (refs/remotes/$REMOTE/)..." >&2

branches_to_delete=""
count=0
batch_size=30

# Use tab between date and ref so "date" with timezone (e.g. 12:59:09 +0300) doesn't split
while IFS=$'\t' read -r date branch; do
  [ -z "$branch" ] && continue
  branch_name=${branch#$REMOTE/}

  if echo "$branch_name" | grep -qE "^(${EXCLUDED_BRANCHES})$"; then
    continue
  fi

  branch_ts=$(date -d "$date" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%S" "${date%%+*}" +%s 2>/dev/null)
  now_ts=$(date +%s)
  age_days=$(( (now_ts - branch_ts) / 86400 ))

  if [ "$age_days" -ge "$CUTOFF_DAYS" ]; then
    echo "Would delete branch: $branch_name ($age_days days old)" >&2
    branches_to_delete="$branches_to_delete $branch_name"
    count=$((count + 1))
  fi

  if [ "$count" -ge "$batch_size" ]; then
    # Trim leading space and run one push per batch
    branches_trimmed="${branches_to_delete# }"
    run_or_echo "git push $REMOTE --delete $branches_trimmed"
    branches_to_delete=""
    count=0
  fi
done < <(git for-each-ref --sort=committerdate refs/remotes/$REMOTE/ --format=$'%(committerdate:iso8601)\t%(refname:short)')

# Final batch
if [ -n "$branches_to_delete" ]; then
  branches_trimmed="${branches_to_delete# }"
  run_or_echo "git push $REMOTE --delete $branches_trimmed"
fi

if [ -n "$DRY_RUN_FILE" ]; then
  echo "Dry-run commands written to: $DRY_RUN_FILE" >&2
fi
