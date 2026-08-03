#!/usr/bin/env bash
# corporate/scripts/update.sh
# Pull the latest community release and rebase the corporate branch on top.
# Run this whenever a new community version is published.
#
# Prerequisites (one-time, already done if you followed setup):
#   git remote add upstream https://github.com/samugit83/redamon.git
#
# Usage:
#   bash corporate/scripts/update.sh

set -euo pipefail

UPSTREAM_REMOTE="upstream"
MAIN_BRANCH="master"
CORPORATE_BRANCH="corporate"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "${REPO_ROOT}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	echo "ERROR: This script must run inside a git repository." >&2
	exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
	echo "ERROR: You have uncommitted changes. Commit or stash first." >&2
	git status --short
	exit 1
fi

if ! git remote get-url "${UPSTREAM_REMOTE}" >/dev/null 2>&1; then
	echo "ERROR: Missing '${UPSTREAM_REMOTE}' remote." >&2
	echo "Run: git remote add ${UPSTREAM_REMOTE} https://github.com/samugit83/redamon.git" >&2
	exit 1
fi

echo "==> Fetching upstream..."
git fetch "${UPSTREAM_REMOTE}"

echo "==> Updating ${MAIN_BRANCH} from ${UPSTREAM_REMOTE}/${MAIN_BRANCH}..."
if git show-ref --verify --quiet "refs/heads/${MAIN_BRANCH}"; then
	git checkout "${MAIN_BRANCH}"
else
	git checkout -b "${MAIN_BRANCH}" --track "${UPSTREAM_REMOTE}/${MAIN_BRANCH}"
fi
git merge --ff-only "${UPSTREAM_REMOTE}/${MAIN_BRANCH}"

echo "==> Rebasing ${CORPORATE_BRANCH} on ${MAIN_BRANCH}..."
git checkout "${CORPORATE_BRANCH}"
git rebase "${MAIN_BRANCH}"

if ! git rev-parse --abbrev-ref "${CORPORATE_BRANCH}@{upstream}" >/dev/null 2>&1; then
	echo "==> Setting upstream tracking for ${CORPORATE_BRANCH} -> origin/${CORPORATE_BRANCH}..."
	git branch --set-upstream-to="origin/${CORPORATE_BRANCH}" "${CORPORATE_BRANCH}" 2>/dev/null || true
fi

echo ""
echo "==> Rebase complete. If there were conflicts, resolve them and run:"
echo "    git rebase --continue"
echo ""
echo "==> Push these branch updates to your GitHub fork:"
echo "    git checkout ${MAIN_BRANCH}"
echo "    git push origin ${MAIN_BRANCH}"
echo ""
echo "    git checkout ${CORPORATE_BRANCH}"
echo "    git push --force-with-lease origin ${CORPORATE_BRANCH}"
echo ""
echo "==> To rebuild and restart with corporate settings, run:"
echo "    ./redamon.sh update"
echo ""
echo "    (redamon.sh auto-detects corporate/docker-compose.corporate.yml and"
echo "     loads the Zscaler cert — no extra steps needed.)"
