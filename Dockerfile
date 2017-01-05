FROM ubuntu:14.04
MAINTAINER Matt Titmus <matthew.titmus@gmail.com>

# Install Docker version 1.11.1
RUN apt-get update \
   && apt-get install --no-install-recommends -y apt-transport-https ca-certificates \
   && apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D \
   && echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' >> /etc/apt/sources.list.d/docker.list \
   && apt-get update \
   && apt-get install --no-install-recommends -y apparmor docker-engine=1.11.1-0~trusty linux-image-extra-$(uname -r) \
   && apt-get clean \
   && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD https://raw.githubusercontent.com/spotify/docker-gc/master/docker-gc /usr/bin/docker-gc
COPY build/default-docker-gc-exclude /etc/docker-gc-exclude
COPY build/executed-by-cron.sh /root/executed-by-cron.sh
COPY build/generate-crontab.sh /root/generate-crontab.sh

RUN chmod 0755 /usr/bin/docker-gc \
   && chmod 0755 /root/generate-crontab.sh \
   && chmod 0755 /root/executed-by-cron.sh \
   && chmod 0644 /etc/docker-gc-exclude 

CMD echo $TZONE > /etc/timezone \
   && dpkg-reconfigure -f noninteractive tzdata \
   && /root/generate-crontab.sh > /var/log/cron.log 2>&1 \
   && cron \
   && tail -f /var/log/cron.log
