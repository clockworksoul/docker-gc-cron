FROM alpine:3.19

LABEL maintainer="Matt Titmus <matthew.titmus@gmail.com>"
LABEL date="2025-02-01"

ARG DOCKER_VERSION=27.5.1
ARG TARGETARCH

# We get curl so that we can avoid a separate ADD to fetch the Docker binary, and then we'll remove it.
# Blatantly "borrowed" from Spotify's spotify/docker-gc image. Thanks, folks!
# Map Docker's architecture for multi-platform build
RUN apk --update add bash curl tzdata \
  && case "${TARGETARCH}" in \
         "amd64") ARCH="x86_64" ;; \
         "arm64") ARCH="aarch64" ;; \
         "arm") ARCH="armhf" ;; \
         *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
     esac \
  && echo "Resolved ARCH: ${ARCH}" \
  && echo "Download URL: https://download.docker.com/linux/static/stable/${ARCH}/docker-${DOCKER_VERSION}.tgz" \
  && cd /tmp/ \
  && curl -fSL -O https://download.docker.com/linux/static/stable/${ARCH}/docker-${DOCKER_VERSION}.tgz \
  && tar zxf docker-${DOCKER_VERSION}.tgz \
  && mkdir -p /usr/local/bin/ \
  && mv /tmp/docker/docker /usr/local/bin/ \
  && chmod +x /usr/local/bin/docker \
  && apk del curl \
  && rm -rf /tmp/* \
  && rm -rf /var/cache/apk/*

ADD https://raw.githubusercontent.com/spotify/docker-gc/master/docker-gc /usr/bin/docker-gc
COPY build/default-docker-gc-exclude /etc/docker-gc-exclude
COPY build/executed-by-cron.sh /executed-by-cron.sh
COPY build/generate-crontab.sh /generate-crontab.sh

RUN chmod 0755 /usr/bin/docker-gc \
  && chmod 0755 /generate-crontab.sh \
  && chmod 0755 /executed-by-cron.sh \
  && chmod 0644 /etc/docker-gc-exclude 

CMD ["/bin/sh", "-c", "/generate-crontab.sh > /var/log/cron.log 2>&1 && crontab crontab.tmp && /usr/sbin/crond && tail -f /var/log/cron.log"]
