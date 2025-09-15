#!/bin/bash
# A script to download a generic package from the GitLab Package Registry.
# It handles authentication for both CI/CD pipelines and local development.

set -euo pipefail

# --- CONFIGURATION: Please edit these variables ---
# Your GitLab project ID. Find it on your project's homepage.
PROJECT_ID="YOUR_PROJECT_ID"
# The name of your package as it appears in the registry.
PACKAGE_NAME="my-package"
# The version of the package you want to download.
PACKAGE_VERSION="0.0.1"
# The filename of the package to be downloaded.
PACKAGE_FILE="my-package.zip"
# Your GitLab instance URL (e.g., https://gitlab.com)
GITLAB_URL="https://gitlab.com"
# --- END OF CONFIGURATION ---

# Construct the final package URL
PACKAGE_REGISTRY_URL="${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/packages/generic/${PACKAGE_NAME}/${PACKAGE_VERSION}/${PACKAGE_FILE}"

# Check for CI environment (uses predefined CI_JOB_TOKEN)
if [ -n "${CI_JOB_TOKEN:-}" ]; then
  echo "CI environment detected. Using CI_JOB_TOKEN for authentication."
  AUTH_HEADER="JOB-TOKEN: ${CI_JOB_TOKEN}"

# Check for local environment (uses GITLAB_PAT)
elif [ -n "${GITLAB_PAT:-}" ]; then
  echo "Local environment detected. Using GITLAB_PAT for authentication."
  AUTH_HEADER="PRIVATE-TOKEN: ${GITLAB_PAT}"

else
  echo "Authentication Error: Could not find credentials."
  echo "Please run this script in a GitLab CI pipeline or set the GITLAB_PAT environment variable for local development."
  exit 1
fi

echo "Downloading package from ${PACKAGE_REGISTRY_URL}..."

# Use curl to download the package with the appropriate auth header
curl --fail --location --header "${AUTH_HEADER}" "${PACKAGE_REGISTRY_URL}" --output "${PACKAGE_FILE}"

echo "Successfully downloaded '${PACKAGE_FILE}'."
