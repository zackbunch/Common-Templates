#!/usr/bin/env bash
set -euo pipefail

# --------------------------
# Default Variables
# --------------------------
TAG_LATEST="${TAG_LATEST:-false}"
PUSH_IMAGE="${PUSH_IMAGE:-false}"
RELEASE_IMAGE="${RELEASE_IMAGE:-false}"
TAG_SUFFIX="${TAG_SUFFIX:-}" # Will be validated
DOCKER_CONTEXT="${DOCKER_CONTEXT:-.}"
DOCKERFILE="${DOCKERFILE:-Dockerfile}"
CI_PROJECT_DIR="${CI_PROJECT_DIR:-$(pwd)}"

# Simulated CI variables for local testing
CI_COMMIT_TAG="${CI_COMMIT_TAG:-}"
CI_COMMIT_SHORT_SHA="${CI_COMMIT_SHORT_SHA:-$(git rev-parse --short HEAD 2>/dev/null || echo local)}"
CI_REGISTRY="${CI_REGISTRY:-registry.local}"
CI_REGISTRY_USER="${CI_REGISTRY_USER:-localuser}"
CI_JOB_TOKEN="${CI_JOB_TOKEN:-localtoken}"

IMAGE_ENV_PATH="registry.simulogix.com/personal-websites/pipeline-templates"

# --------------------------
# Required Variable
# --------------------------
if [ -z "${IMAGE_ENV_PATH:-}" ]; then
  echo "ERROR: IMAGE_ENV_PATH must be defined!" >&2
  exit 1
fi

# --------------------------
# Docker Login
# --------------------------
echo "=== Docker login ==="
docker login -u "$CI_REGISTRY_USER" -p "$CI_JOB_TOKEN" "$CI_REGISTRY"

# --------------------------
# Validate TAG_SUFFIX
# --------------------------
if [ "${TAG_SUFFIX}" = "latest" ]; then
  echo "ERROR: TAG_SUFFIX cannot be 'latest' (use RELEASE_IMAGE=true for :latest tag)" >&2
  exit 1
fi

# --------------------------
# Compute Base Tag
# --------------------------
if [ "${RELEASE_IMAGE}" = "true" ]; then
  if [ -z "${CI_COMMIT_TAG}" ]; then
    echo "ERROR: RELEASE_IMAGE=true requires CI_COMMIT_TAG" >&2
    exit 1
  fi
  BASE_TAG="${CI_COMMIT_TAG}"
  PUSH_IMAGE="true"
  TAG_LATEST="true"
else
  BASE_TAG="${CI_COMMIT_TAG:-$CI_COMMIT_SHORT_SHA}"
fi

# --------------------------
# Final Image Tag
# --------------------------
IMAGE_TAG="${TAG_SUFFIX:+${TAG_SUFFIX}-}${BASE_TAG}"

# --------------------------
# Build
# --------------------------
echo "=== Building image ${IMAGE_ENV_PATH}:${IMAGE_TAG} ==="
docker build --pull \
  -f "${DOCKERFILE}" \
  -t "${IMAGE_ENV_PATH}:${IMAGE_TAG}" \
  "${DOCKER_CONTEXT}"

# --------------------------
# Tag :latest if requested
# --------------------------
if [ "${TAG_LATEST}" = "true" ]; then
  echo "=== Tagging as latest ==="
  docker tag "${IMAGE_ENV_PATH}:${IMAGE_TAG}" "${IMAGE_ENV_PATH}:latest"
fi

# --------------------------
# Push if requested
# --------------------------
if [ "${PUSH_IMAGE}" = "true" ]; then
  echo "=== Pushing image(s) ==="
  docker push "${IMAGE_ENV_PATH}:${IMAGE_TAG}"
  if [ "${TAG_LATEST}" = "true" ]; then
    docker push "${IMAGE_ENV_PATH}:latest"
  fi

  DIGEST_LINE=$(docker inspect --format='{{index .RepoDigests 0}}' "${IMAGE_ENV_PATH}:${IMAGE_TAG}" 2>/dev/null || true)
  if [ -n "$DIGEST_LINE" ]; then
    IMAGE_REF_VALUE="$DIGEST_LINE"
    IMAGE_DIGEST_VALUE="${DIGEST_LINE#*@sha256:}"
  else
    IMAGE_REF_VALUE="skipped"
    IMAGE_DIGEST_VALUE="skipped"
  fi
else
  IMAGE_REF_VALUE="skipped"
  IMAGE_DIGEST_VALUE="skipped"
fi

# --------------------------
# Output env file
# --------------------------
mkdir -p "${CI_PROJECT_DIR}"
{
  echo "IMAGE_ENV_PATH=${IMAGE_ENV_PATH}"
  echo "IMAGE_TAG=${IMAGE_TAG}"
  echo "IMAGE_DIGEST=${IMAGE_DIGEST_VALUE}"
  echo "IMAGE_REF=${IMAGE_REF_VALUE}"
} > "${CI_PROJECT_DIR}/image-digest.env"

echo "=== Done. Env file written to ${CI_PROJECT_DIR}/image-digest.env ==="
cat "${CI_PROJECT_DIR}/image-digest.env"