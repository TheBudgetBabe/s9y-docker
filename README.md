# S9y [serendipity] Docker Image

This repository contains the Dockerfile to build an image for [Serendipity blogging platform](http://s9y.org/).

The working image is built from [the official PHP 7.0 docker PHP image](https://hub.docker.com/_/php/).

Images are available [here](https://hub.docker.com/r/thebudgetbabe/s9y/).

## Usage

This image should give you a working serendipity platform out of the box, but I'm assuming you will actually source `FROM` this image, as I am.

By default, the image uses [deco](https://github.com/YaleUniversity/deco) to filter:

- `/etc/apache2/apache2.conf`
- `/var/www/html/serendipity/serendipity_config_local.inc.php`

from `/var/run/secrets/deco.json`.  It allows you to pass the environment variable `DECOFILE` at runtime to change that location.  It's up
to you to get the `DECOFILE` on disk.  The image is setup to use [docker swarm secrets](https://docs.docker.com/engine/swarm/secrets/) without
any extra work.

### Docker build

```bash
export S9Y_VERSION=2.1.5
docker build . --tag "thebudgetbabe/s9y:${S9Y_VERSION}" --build-arg "S9Y_VERSION=${S9Y_VERSION}"
docker tag thebudgetbabe/s9y:${S9Y_VERSION} thebudgetbabe/s9y:latest
```

### Docker buildx

```bash
docker buildx build --platform linux/amd64 --tag "thebudgetbabe/s9y:${S9Y_VERSION}" --build-arg "S9Y_VERSION=${S9Y_VERSION}" -o 'type=docker' .
docker tag thebudgetbabe/s9y:${S9Y_VERSION} thebudgetbabe/s9y:latest
```

### Docker run

```bash
docker run --rm --name s9yweb -p 80:80 -v `pwd`/default_deco.json:/var/run/secrets/s9yweb.json \
    -e 'DECOFILE=/var/run/secrets/s9yweb.json' -e 'FRESHINSTALL=true' thebudgetbabe/s9y
```

### Docker service

```bash
docker network create --attachable -d overlay s9ynet
```

```bash
docker secret create s9yweb.json default_deco.json
```

```bash
docker service create --name s9ydb --network s9ynet -p 33306:3306 -e 'MYSQL_DATABASE=s9y' \
    -e 'MYSQL_USER=s9y' -e 'MYSQL_PASSWORD=s9ySekret' -e 'MYSQL_RANDOM_ROOT_PASSWORD=true' mariadb:latest
```

```bash
docker service create --name s9yweb --network s9ynet -p 80:80 --secret s9yweb.json -e 'DECOFILE=/var/run/secrets/s9yweb.json' thebudgetbabe/s9y
```

### Docker compose

Coming soon

### Environment variables

- `DECOFILE`: path to the deco configuration file on disk.  Default: `/var/run/secrets/deco.json`
- `FRESHINSTALL`: if not empty, this deletes the generated configuration file (`serendipity_config_local.inc.php`) so you can configure fresh.

### As source image

You can source from this image with something like this, where the `entrypoint.sh` does any custom setup ...

```
FROM thebudgetbabe/s9y:latest

WORKDIR /var/www/html/serendipity

COPY entrypoint.sh /src
RUN chown root:root /src/entrypoint.sh && chmod 555 /src/entrypoint.sh

RUN echo 'opcache.enable=0' >> /usr/local/etc/php/conf.d/opcache-recommended.ini

CMD ["/src/entrypoint.sh"]
```

## Author

E Camden Fisher <fish@fishnix.net>  
