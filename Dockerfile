FROM registry.access.redhat.com/ubi8/ubi:latest

COPY --chown=1001 entrypoint.sh /

USER 1001

ENTRYPOINT ["/entrypoint.sh"]
