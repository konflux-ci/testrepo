FROM registry.access.redhat.com/ubi9/ubi:latest

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
