#!/usr/bin/env bash
# update_version.sh
set -euo pipefail

# Grab the tag
TAG=$(git describe --tags --abbrev=0 2>/dev/null) || true

if [[ -z "$TAG" ]]; then
  COMMIT=$(git rev-parse --short HEAD)
  COMMITS=$(git rev-list --count HEAD)
  DATE=$(git log -1 --format=%cd --date=format:%Y%m%d)
  TAG="${DATE}-${COMMIT}-${COMMITS}"
fi

# Write
echo "$TAG" > VERSION

# Optionally commit the change
if git diff --quiet -- exit 0 2>/dev/null; then
    echo "VERSION unchanged – no commit needed."
else
    git add VERSION
    git commit -m "Bump VERSION to $TAG" --no-verify
    echo "Updated VERSION to $TAG."
fi
