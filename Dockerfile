# Use an official Python base image (alpine is smaller, slim is safer for prod)
FROM ubuntu:jammy AS builder

# Declare ARGs to make them available in the build stage
ARG CI_REGISTRY
ARG CI_JOB_TOKEN
ARG CI_API_V4_URL
ARG CI_PROJECT_ID
ARG PACKAGE_NAME=sqlcl
ARG PACKAGE_VERSION=0.0.1
ARG PACKAGE_FILE=sqlcl.tar.gz

# Set the working directory
WORKDIR /app

# Download package from GitLab Package Registry
RUN apt-get update && apt-get install -y curl && \
    curl --header "JOB-TOKEN: $CI_JOB_TOKEN" "$CI_API_V4_URL/projects/$CI_PROJECT_ID/packages/generic/$PACKAGE_NAME/$PACKAGE_VERSION/$PACKAGE_FILE" -o "$PACKAGE_FILE" && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# # Copy the package downloaded by the helper script
# COPY sqlcl.tar.gz /tmp/sqlcl.tar.gz
