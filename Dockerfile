FROM registry.access.redhat.com/ubi8/ubi:latest

# testing 
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
