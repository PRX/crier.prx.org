#!/bin/bash
eval $(/usr/local/bin/docker-machine env default --shell=bash)

VERSION=`cat VERSION`

_clean() {
  docker rmi crier_worker
}

_build() {
  docker-compose build
}

_up() {
  docker-compose up
}

_tag() {
  docker tag -f crier_worker publicradioexchange/crier_worker:$VERSION
  docker tag -f crier_worker publicradioexchange/crier_worker:latest
}

_push() {
  docker push publicradioexchange/crier_worker:$VERSION
  docker push publicradioexchange/crier_worker:latest
}

if [ "$1" = "clean" ]; then
  _clean
elif [ "$1" = "up" ]; then
  _up
elif [ "$1" = "tag" ]; then
  _tag
elif [ "$1" = "push" ]; then
  _push
else
  _build
fi
