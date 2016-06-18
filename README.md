# Docker Garbage Collection Container

The Docker Garbage Collection container is used to execute the very excellent [Spotify Docker-GC script](https://github.com/spotify/docker-gc) to clean up old and unused Docker containers and images. Currently running containers will not be removed.

This can be run in two ways:

## As a background process

If left running as a daemon process, it will periodically run the docker-gc script in the background each evening to automatically clean up unused containers and images. A docker-compose file for this purpose can be found in the compose/ directory of this repository.

## As a one-off

```
docker run -v /var/run/docker.sock:/var/run/docker.sock clockworksoul/docker-gc-cron docker-gc
```


