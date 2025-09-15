# Use an official Python base image (alpine is smaller, slim is safer for prod)
FROM ubuntu:jammy AS builder

# Declare ARGs to make them available in the build stage
ARG CI_REGISTRY
ARG CI_JOB_TOKEN
ARG CI_API_V4_URL
ARG CI_PROJECT_ID

# Set the working directory
WORKDIR /app

# Download package from GitLab Package Registry
# Note: You'll need to replace the package name, version, and filename with your actual package details.
RUN apt-get update && apt-get install -y curl &&     curl --header "JOB-TOKEN: $CI_JOB_TOKEN" "$CI_API_V4_URL/projects/$CI_PROJECT_ID/packages/generic/sqlcl/0.0.1/sqlcl.tar.gz" -o sqlcl.tar.gz &&     apt-get clean && rm -rf /var/lib/apt/lists/*

# # Copy the package downloaded by the helper script
# COPY sqlcl.tar.gz /tmp/sqlcl.tar.gz
