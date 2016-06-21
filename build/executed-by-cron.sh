#!/bin/sh

echo "[$(date)] Docker GC starting." >> /var/log/cron.log 2>&1

/usr/bin/docker-gc >> /var/log/cron.log 2>&1

if [ "$CLEAN_UP_VOLUMES" -eq "1" ]
then 
   if [ $(docker volume ls -qf dangling=true | wc -l) -gt 0 ]
   then
      echo "Cleaning up dangling volumes." >> /var/log/cron.log 2>&1
      docker volume rm $(docker volume ls -qf dangling=true) >> /var/log/cron.log 2>&1
   else
      echo "No dangling volumes found." >> /var/log/cron.log 2>&1
   fi
fi

echo "[$(date)] Docker GC has completed." >> /var/log/cron.log 2>&1
