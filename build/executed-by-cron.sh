#!/bin/sh

echo "[$(date)] Docker GC starting." >> /var/log/cron.log 2>&1

/usr/bin/docker-gc >> /var/log/cron.log 2>&1

echo "[$(date)] Docker GC has completed." >> /var/log/cron.log 2>&1
