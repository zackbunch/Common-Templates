# Builder only; ship a second stage if you need a runtime image
FROM ubuntu:22.04 AS builder

ARG CI_API_V4_URL
ARG CI_PROJECT_ID

# Parameterize package coords
ARG PKG_NAME=sqlcl
ARG PKG_VERSION=0.0.1
ARG PKG_FILE=sqlcl.tar.gz
ARG PKG_DST=/opt/sqlcl

WORKDIR /tmp/pkg

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl tar \
 && rm -rf /var/lib/apt/lists/*

# BuildKit secret: pass with --secret id=gitlab_token,env=CI_JOB_TOKEN (or src=)
RUN --mount=type=secret,id=gitlab_token \
    set -Eeuo pipefail; \
    TOKEN="$(cat /run/secrets/gitlab_token)"; \
    URL="${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/${PKG_NAME}/${PKG_VERSION}/${PKG_FILE}"; \
    echo "Fetching ${URL}"; \
    curl -fSL --retry 5 --retry-connrefused --retry-delay 2 \
      -H "JOB-TOKEN: ${TOKEN}" "${URL}" \
    | tar -xz -C /tmp/pkg; \
    install -d "${PKG_DST}"; \
    shopt -s dotglob; \
    mv /tmp/pkg/* "${PKG_DST}"; \
    # sanity check – update the path to whatever your payload provides
    test -e "${PKG_DST}/bin/sql" || { echo "expected payload not found"; exit 1; }