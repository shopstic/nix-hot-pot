ARG fromDigest
FROM quay.io/strimzi/kafka@$fromDigest
USER root:root
RUN \
  mkdir -p /opt/kafka/plugins/debezium/ && \
  curl -Lo - https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/1.9.0.Final/debezium-connector-postgres-1.9.0.Final-plugin.tar.gz | \
  tar -xz -C /opt/kafka/plugins/debezium/ --strip-components=1
USER 1001
