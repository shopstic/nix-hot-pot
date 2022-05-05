ARG fromTag
ARG fromDigest
FROM docker.io/ubuntu:$fromTag@$fromDigest

ARG APP_UID=1000
ARG APP_GID=1000

RUN \
  (groupadd --gid "${APP_GID}" app || true) && \
  useradd --home-dir /home/app --create-home --uid "${APP_UID}" \
  --gid "${APP_GID}" --shell /bin/bash --skel /dev/null app

USER app:app

ENTRYPOINT ["dumb-init", "--"]
