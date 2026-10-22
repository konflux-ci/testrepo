# Red Hat Hardened Image — minimal glibc runtime (Project Hummingbird), digest-pinned
FROM registry.access.redhat.com/hi/core-runtime@sha256:756485a7f6f43804d3c1e0363b55eeee696dc0adaddbab72027a20bfcb405052

COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY LICENSE /LICENSE

ENTRYPOINT ["/entrypoint.sh"]
