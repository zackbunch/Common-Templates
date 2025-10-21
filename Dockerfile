# syntax=docker/dockerfile:1
FROM registry.access.redhat.com/ubi9/ubi:latest

ARG SERVER_URL=""
ARG CI_REGISTRY=""

# UBI images are minimal, so you may need coreutils for "cat" or other tools
RUN  echo "SERVER_URL=$SERVER_URL CI_REGISTRY=$CI_REGISTRY" > /build-args.txt \
    && dnf clean all \
    && rm -rf /var/cache/dnf

CMD ["cat", "/build-args.txt"]