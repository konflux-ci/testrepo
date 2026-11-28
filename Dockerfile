# Red Hat Hardened Image — minimal glibc runtime (Project Hummingbird), digest-pinned
FROM registry.access.redhat.com/hi/core-runtime@sha256:b89211eabec2378de257b754643579aabb9b87bc67ed8411dcef0b9ef8142d68

COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY LICENSE /LICENSE

ENTRYPOINT ["/entrypoint.sh"]
