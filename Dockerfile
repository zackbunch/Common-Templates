# ubuntu:jammy is fine; keep.
FROM ubuntu:jammy AS builder

# CI args
ARG CI_API_V4_URL
ARG CI_PROJECT_ID

# Local/dev fallback (optional)
ARG GITLAB_TOKEN=""

ARG PKG_NAME=sqlcl
ARG PKG_VERSION=0.0.1
ARG PKG_FILE=sqlcl.tar.gz

WORKDIR /app

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Make the secret optional so local builds don't explode
# (requires BuildKit; 'required=false' is supported)
RUN --mount=type=secret,id=gitlab_token,required=false \
    set -eu; \
    TOKEN_FILE="/run/secrets/gitlab_token"; \
    TOKEN=""; \
    if [ -f "$TOKEN_FILE" ]; then TOKEN="$(cat "$TOKEN_FILE")"; \
    elif [ -n "$GITLAB_TOKEN" ]; then TOKEN="$GITLAB_TOKEN"; fi; \
    HEADER=""; \
    if [ -n "$TOKEN" ]; then HEADER="--header JOB-TOKEN: ${TOKEN}"; fi; \
    curl -fsSL $HEADER \
      "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/${PKG_NAME}/${PKG_VERSION}/${PKG_FILE}" \
      -o "/app/${PKG_FILE}"