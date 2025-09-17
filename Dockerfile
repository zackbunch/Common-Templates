# Use an official Python base image (alpine is smaller, slim is safer for prod)
FROM ubuntu:jammy AS builder

# Declare ARGs to make them available in the build stage
ARG CI_REGISTRY
ARG CI_API_V4_URL
ARG CI_PROJECT_ID

# Set the working directory
WORKDIR /app

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*

RUN --mount=type=secret,id=gitlab_token \
    TOKEN=$(cat /run/secrets/gitlab_token) && \
    curl -sSL --header "JOB-TOKEN: $TOKEN" \
      "$CI_API_V4_URL/projects/$CI_PROJECT_ID/packages/generic/sqlcl/0.0.1/sqlcl.tar.gz" 

