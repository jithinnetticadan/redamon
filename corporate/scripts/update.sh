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

UPSTREAM_REMOTE="${UPSTREAM_REMOTE:-upstream}"
MAIN_BRANCH="${MAIN_BRANCH:-master}"
CORPORATE_BRANCH="${CORPORATE_BRANCH:-corporate}"

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

echo ""
echo "==> Rebase complete. If there were conflicts, resolve them and run:"
echo "    git rebase --continue"
echo ""
echo "==> To rebuild and restart with corporate settings, run:"
echo "    ./redamon.sh update"
echo ""
echo "    (redamon.sh auto-detects corporate/docker-compose.corporate.yml and"
echo "     loads the Zscaler cert — no extra steps needed.)"
