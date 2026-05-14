FROM registry.access.redhat.com/ubi8/ubi:latest AS builder

RUN mkdir -p /maven-artifacts/com/example/test/hello-pulp/1.0.0

RUN echo "fake-jar-content" > \
    /maven-artifacts/com/example/test/hello-pulp/1.0.0/hello-pulp-1.0.0.jar

RUN printf '<?xml version="1.0" encoding="UTF-8"?>\n\
<project xmlns="http://maven.apache.org/POM/4.0.0">\n\
  <modelVersion>4.0.0</modelVersion>\n\
  <groupId>com.example.test</groupId>\n\
  <artifactId>hello-pulp</artifactId>\n\
  <version>1.0.0</version>\n\
  <packaging>jar</packaging>\n\
</project>\n' > \
    /maven-artifacts/com/example/test/hello-pulp/1.0.0/hello-pulp-1.0.0.pom

RUN printf '<?xml version="1.0" encoding="UTF-8"?>\n\
<metadata>\n\
  <groupId>com.example.test</groupId>\n\
  <artifactId>hello-pulp</artifactId>\n\
  <versioning>\n\
    <release>1.0.0</release>\n\
    <versions><version>1.0.0</version></versions>\n\
  </versioning>\n\
</metadata>\n' > \
    /maven-artifacts/com/example/test/hello-pulp/maven-metadata.xml

FROM scratch
COPY --from=builder /maven-artifacts/ /maven-artifacts/
