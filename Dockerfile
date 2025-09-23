# Use an official Python base image (alpine is smaller, slim is safer for prod)
FROM ubuntu:jammy AS builder

ARG CI_REGISTRY
ARG CI_API_V4_URL
ARG CI_PROJECT_ID

ARG PKG_NAME=sqlcl
ARG PKG_VERSION=0.0.1
ARG PKG_FILE=sqlcl.tar.gz

# Set the working directory
WORKDIR /app

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# RUN --mount=type=secret,id=gitlab_token \
#     TOKEN="$(cat /run/secrets/gitlab_token)"; \
#     curl -fsSL --header "JOB-TOKEN: ${TOKEN}" \
#       "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/${PKG_NAME}/${PKG_VERSION}/${PKG_FILE}" \
#     -o "/app/${PKG_FILE}"

