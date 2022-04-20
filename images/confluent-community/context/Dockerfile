ARG fromTag
ARG fromDigest
FROM docker.io/eclipse-temurin:$fromTag@$fromDigest

RUN \
  groupadd --gid 1001 app && \
  useradd --home-dir /home/app --create-home --uid 1001 \
  --gid 1001 --shell /bin/bash --skel /dev/null app

USER app:app
