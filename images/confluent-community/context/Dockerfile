ARG fromTag
ARG fromDigest
FROM public.ecr.aws/docker/library/eclipse-temurin:$fromTag@$fromDigest

RUN \
  echo "app:x:1001:1001::/home/app:/bin/bash" >> /etc/passwd && \
  echo "app:!::0:99999:7:::" >> /etc/shadow && \
  echo "app:x:1001:" >> /etc/group && \
  echo "app:!::" >> /etc/gshadow && \
  echo "app:!::" >> /etc/gshadow && \
  echo "app:100000:65536" >> /etc/subuid && \
  echo "app:100000:65536" >> /etc/subgid && \
  mkdir -p /home/app && \
  chown app:app /home/app

USER app:app
