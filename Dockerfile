FROM registry.fedoraproject.org/fedora:latest

RUN python3 -c 'import random; import sys; sys.exit(random.randint(0, 1))'
