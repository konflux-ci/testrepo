# Red Hat Hardened Image — minimal glibc runtime (Project Hummingbird), digest-pinned
FROM registry.access.redhat.com/hi/core-runtime@sha256:329ff8f46fe69f036b96c3463272aa778a6df6a4f7570f080fd248a414652b6e

COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY LICENSE /LICENSE

ENTRYPOINT ["/entrypoint.sh"]
