FROM registry.access.redhat.com/ubi8/ubi:latest

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
