ARG fromTag
ARG fromDigest
FROM docker.io/ubuntu:$fromTag@$fromDigest

COPY config /default_config
COPY config /config
COPY bin /bin
COPY etc/protocols /etc/protocols