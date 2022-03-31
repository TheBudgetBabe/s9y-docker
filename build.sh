#!/bin/bash

export S9Y_VERSION=${BASH_ARGV[0]}

echo "Building S9y ${S9Y_VERSION} docker version"
# docker build . --tag "thebudgetbabe/s9y:${S9Y_VERSION}" --build-arg "S9Y_VERSION=${S9Y_VERSION}"
docker buildx build --platform linux/amd64 --tag "thebudgetbabe/s9y:${S9Y_VERSION}" --build-arg "S9Y_VERSION=${S9Y_VERSION}" .
docker tag thebudgetbabe/s9y:${S9Y_VERSION} thebudgetbabe/s9y:latest
