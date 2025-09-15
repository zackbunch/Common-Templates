# Use an official Python base image (alpine is smaller, slim is safer for prod)
ARG CI_REGISTRY
FROM ubuntu:jammy AS builder

# Set the working directory
WORKDIR /app

# # Copy the package downloaded by the helper script
# COPY sqlcl.tar.gz /tmp/sqlcl.tar.gz

