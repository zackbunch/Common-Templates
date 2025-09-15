#!/bin/bash
# A script to upload a generic package to the GitLab Package Registry.
# It handles authentication for both CI/CD pipelines and local development.
# https://gitlab.simulogix.com/api/v4/projects/123456/packages/generic/my-package/0.0.1/my-package.zip
set -euo pipefail

# --- CONFIGURATION: Please edit these variables ---
# Your GitLab project ID. Find it on your project's homepage.
PROJECT_ID="73"
# The desired name for your package in the registry.
PACKAGE_NAME="sqlcl"
# The desired version for the package.
PACKAGE_VERSION="0.0.1"
# The local path to the file you want to upload.
FILE_TO_UPLOAD="sqlcl.tar.gz"
# Your GitLab instance URL (e.g., https://gitlab.com)
GITLAB_URL="https://gitlab.simulogix.com"
# --- END OF CONFIGURATION ---

# Check if the file to upload actually exists
if [ ! -f "$FILE_TO_UPLOAD" ]; then
    echo "Error: File to upload not found at '${FILE_TO_UPLOAD}'" >&2
    exit 1
fi

# The filename is used as the final part of the URL
FILE_NAME=$(basename "$FILE_TO_UPLOAD")

# Construct the final package URL for the API endpoint
PACKAGE_REGISTRY_URL="${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/packages/generic/${PACKAGE_NAME}/${PACKAGE_VERSION}/${FILE_NAME}"

# Check for CI environment (uses predefined CI_JOB_TOKEN)
if [ -n "${CI_JOB_TOKEN:-}" ]; then
  echo "CI environment detected. Using CI_JOB_TOKEN for authentication."
  AUTH_HEADER="JOB-TOKEN: ${CI_JOB_TOKEN}"

# Check for local environment (uses GITLAB_PAT)
elif [ -n "${GITLAB_PAT:-}" ]; then
  echo "Local environment detected. Using GITLAB_PAT for authentication."
  AUTH_HEADER="PRIVATE-TOKEN: ${GITLAB_PAT}"

else
  echo "Authentication Error: Could not find credentials." >&2
  echo "Please run this script in a GitLab CI pipeline or set the GITLAB_PAT environment variable for local development." >&2
  exit 1
fi

echo "Uploading '${FILE_TO_UPLOAD}' to ${PACKAGE_REGISTRY_URL}..."

# Use curl to upload the package with the appropriate auth header
# The API expects a PUT request with the file data.
response_code=$(curl --silent --output /dev/stderr --write-out "%{http_code}" \
     --request PUT \
     --header "${AUTH_HEADER}" \
     --upload-file "${FILE_TO_UPLOAD}" \
     "${PACKAGE_REGISTRY_URL}")

if [[ "$response_code" -ge 200 && "$response_code" -lt 300 ]]; then
  echo "Successfully uploaded package. Server responded with HTTP $response_code."
else
  echo "Upload failed. Server responded with HTTP $response_code." >&2
  exit 1
fi
