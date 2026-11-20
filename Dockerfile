# Red Hat Hardened Image — minimal glibc runtime (Project Hummingbird), digest-pinned
FROM registry.access.redhat.com/hi/core-runtime@sha256:81280d7fd6afa7a3d2a6da2e90e545cf8e5d187c80a69b2a1c875fdcd731aaed

COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY LICENSE /LICENSE

ENTRYPOINT ["/entrypoint.sh"]
