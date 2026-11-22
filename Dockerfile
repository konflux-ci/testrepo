# Red Hat Hardened Image — minimal glibc runtime (Project Hummingbird), digest-pinned
FROM registry.access.redhat.com/hi/core-runtime@sha256:33539044661f70521596967ee6581b12cc49c30c9f93bf5c52b622d2e9aa8b01

COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY LICENSE /LICENSE

ENTRYPOINT ["/entrypoint.sh"]
