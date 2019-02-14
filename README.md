# docker-gc-cron

The `docker-gc-cron` container will periodically run the very excellent [Spotify docker-gc script](https://github.com/spotify/docker-gc) script to automatically clean up unused containers and images.  It's particularly useful when deployed on systems onto which large numbers of Docker images and containers are built or pulled, such as CI nodes.

By default, the process will run each night at midnight, but the timing and other behaviors can be precisely specified using standard `cron` syntax. A `docker-compose.yml` file for this purpose can be found in the `compose` directory of this repository to simplify execution.


## Installation tl;dr

```
$ wget https://raw.githubusercontent.com/clockworksoul/docker-gc-cron/master/compose/docker-gc-exclude
$ wget https://raw.githubusercontent.com/clockworksoul/docker-gc-cron/master/compose/docker-compose.yml
$ docker-compose up -d
```

This will pull and execute a `docker-gc-cron` image associated with your installed Docker daemon. By default, the garbage collection process will execute nightly at midnight, but this can be easily changed by modifying the `CRON` property (see below).

Yes, the `docker-gc-exclude` _is_ necessary when using this `docker-compose.yml` file.


## Supported Environmental Settings

The container understands all of the settings that are supported by [docker-gc](https://github.com/spotify/docker-gc), as well as additional settings that can be used to modify the cleanup frequency.

Much of the following documentation is borrowed and modified directly from the [docker-gc README](https://github.com/spotify/docker-gc/blob/master/README.md#excluding-images-from-garbage-collection).


All of the following environmental variables can also be used by getting and modifying the `docker-compose.yml` file.


### Modifying the cleanup schedule

By default, the docker-gc-cron process will run nightly at midnight (cron "0 0 * * *"). This schedule can be overridden by using the `CRON` setting as follows:

```
docker run -d -v /var/run/docker.sock:/var/run/docker.sock -e CRON="0 */6 * * *" clockworksoul/docker-gc-cron
```


### Forcing deletion of images that have multiple tags

By default, docker will not remove an image if it is tagged in multiple repositories. 
If you have a server running Docker where this is the case, for example in CI environments where dockers are being built, re-tagged, and pushed, you can enable a force flag to override this default.

```
docker run -d -v /var/run/docker.sock:/var/run/docker.sock -e FORCE_IMAGE_REMOVAL=1 clockworksoul/docker-gc-cron
```


### Preserving a minimum number of images for every repository

You might want to always keep a set of the most recent images for any repository. For example, if you are continually rebuilding an image during development you would want to clear out all but the most recent version of an image. To do so, set the `MINIMUM_IMAGES_TO_SAVE=1` environment variable. You can preserve any count of the most recent images, e.g. save the most recent 10 with `MINIMUM_IMAGES_TO_SAVE=10`.

```
docker run -d -v /var/run/docker.sock:/var/run/docker.sock -e MINIMUM_IMAGES_TO_SAVE=3 clockworksoul/docker-gc-cron
```


### Forcing deletion of containers

By default, if an error is encountered when cleaning up a container, Docker will report the error back and leave it on disk. 
This can sometimes lead to containers accumulating. If you run into this issue, you can force the removal of the container by setting the environment variable below:

```
docker run -d -v /var/run/docker.sock:/var/run/docker.sock -e FORCE_CONTAINER_REMOVAL=1 clockworksoul/docker-gc-cron
```


### Excluding Recently Exited Containers and Images From Garbage Collection

By default, `docker-gc` will not remove a container if it exited less than 3600 seconds (1 hour) ago. In some cases you might need to change this setting (e.g. you need exited containers to stick around for debugging for several days). Set the `GRACE_PERIOD_SECONDS` variable to override this default.

```
docker run -d -v /var/run/docker.sock:/var/run/docker.sock -e GRACE_PERIOD_SECONDS=86400 clockworksoul/docker-gc-cron
```

This setting also prevents the removal of images that have been created less than `GRACE_PERIOD_SECONDS` seconds ago.


### Cleaning up orphaned container volumes

Orphaned volumes that were created by containers that no longer exist can, over time, grow to take up a significant amount of disk space. By default, this process will leave any orphaned volumes untouched. However, to instruct the process to automatically clean up any dangling volumes using a `docker volume rm $(docker volume ls -qf dangling=true)` call after the `docker-gc` process has been executed, simply set the `CLEAN_UP_VOLUMES` value to `1`.

```
docker run -d -v /var/run/docker.sock:/var/run/docker.sock -e CLEAN_UP_VOLUMES=1 clockworksoul/docker-gc-cron
```


### Dry run
By default, `docker-gc` will proceed with deletion of containers and images. To test your command-line options set the `DRY_RUN` variable to override this default.

```
docker run -d -v /var/run/docker.sock:/var/run/docker.sock -e DRY_RUN=1 clockworksoul/docker-gc-cron
```
