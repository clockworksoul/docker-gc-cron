#!/bin/bash

DEFAULT_CRON="0 0 * * *"

if [ "$CRON" ]
then
   echo "Using user-defined CRON variable: $CRON"
else
   echo "CRON variable undefined. Using default of \"$DEFAULT_CRON\""
   CRON="$DEFAULT_CRON"
fi

GC_ARGS=""

if [ "$DRY_RUN" ]
then
   GC_ARGS="$GC_ARGS DRY_RUN=$DRY_RUN"
fi

if [ "$FORCE_CONTAINER_REMOVAL" ]
then
   GC_ARGS="$GC_ARGS FORCE_CONTAINER_REMOVAL=$FORCE_CONTAINER_REMOVAL"
fi

if [ "$FORCE_IMAGE_REMOVAL" ]
then
   GC_ARGS="$GC_ARGS FORCE_IMAGE_REMOVAL=$FORCE_IMAGE_REMOVAL"
fi

if [ "$GRACE_PERIOD_SECONDS" ]
then
   GC_ARGS="$GC_ARGS GRACE_PERIOD_SECONDS=$GRACE_PERIOD_SECONDS"
fi

if [ "$CLEAN_UP_VOLUMES" ]
then
   GC_ARGS="$GC_ARGS CLEAN_UP_VOLUMES=$CLEAN_UP_VOLUMES"
fi

echo -e "$CRON" "root $GC_ARGS sh /root/executed-by-cron.sh" '>> /var/log/cron.log 2>&1'"\n# An empty line is required at the end of this file for a valid cron file.\n" > /etc/cron.d/docker-gc-cron

chmod 0644 /etc/cron.d/docker-gc-cron

