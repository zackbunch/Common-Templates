# syntax=docker/dockerfile:1
FROM registry.access.redhat.com/ubi9/ubi:latest

ARG FOO=defaultfoo
ARG BAR=defaultbar

# UBI images are minimal, so you may need coreutils for "cat" or other tools
RUN  echo "FOO=$FOO BAR=$BAR" > /build-args.txt \
    && dnf clean all \
    && rm -rf /var/cache/dnf

CMD ["cat", "/build-args.txt"]