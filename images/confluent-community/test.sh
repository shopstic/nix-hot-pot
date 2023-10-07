#!/usr/bin/env bash
set -euo pipefail

nix build -L -v '.#packages.aarch64-linux.image-confluent-community'
skopeo copy --insecure-policy nix:./result docker-daemon:confluent-community:latest

TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "listeners=http://0.0.0.0:8080" >"$TEMP_DIR/schema-registry.properties"

cat <<EOF >"$TEMP_DIR/schema-registry.properties"
listeners=http://0.0.0.0:8080
EOF

cat <<EOF >"$TEMP_DIR/log4j.properties"
log4j.rootLogger=INFO, stdout
log4j.appender.stdout=org.apache.log4j.ConsoleAppender
log4j.appender.stdout.layout=org.apache.log4j.PatternLayout
log4j.appender.stdout.layout.ConversionPattern=[%d] %p %m (%c:%L)%n
log4j.logger.kafka=ERROR, stdout
log4j.logger.org.apache.zookeeper=ERROR, stdout
log4j.logger.org.apache.kafka=ERROR, stdout
log4j.additivity.kafka.server=false
EOF

docker run -it --rm \
  -v "$TEMP_DIR/schema-registry.properties:/home/app/schema-registry.properties:ro" \
  -v "$TEMP_DIR/log4j.properties:/home/app/log4j.properties:ro" \
  -e "SCHEMA_REGISTRY_LOG4J_OPTS=-Dlog4j.configuration=file:/home/app/log4j.properties" \
  --entrypoint=schema-registry-start \
  confluent-community:latest \
  /home/app/schema-registry.properties
