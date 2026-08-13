# Red Hat Hardened Image — minimal glibc runtime (Project Hummingbird), digest-pinned
FROM registry.access.redhat.com/hi/core-runtime@sha256:4ba896089e33ea92d6ca4b03194fc3e88010077fc840d859a7893e4d5b9fd6f6

COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
