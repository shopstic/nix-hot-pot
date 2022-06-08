ARG fromTag
ARG fromDigest
FROM docker.io/ubuntu:$fromTag@$fromDigest

RUN \
  echo "app:x:1000:1000::/home/app:/bin/bash" >> /etc/passwd && \
  echo "app:!::0:99999:7:::" >> /etc/shadow && \
  echo "app:x:1000:" >> /etc/group && \
  echo "app:!::" >> /etc/gshadow && \
  echo "app:!::" >> /etc/gshadow && \
  echo "app:100000:65536" >> /etc/subuid && \
  echo "app:100000:65536" >> /etc/subgid && \
  mkdir -p /home/app && \
  chown app:app /home/app

USER app:app

ENTRYPOINT ["dumb-init", "--"]
