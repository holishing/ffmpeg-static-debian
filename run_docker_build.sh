#!/bin/sh

set -eu

### This shell script aim to be a POSIX-shell compatible script
### If There's a POSIX-shell run this script came into problem, welcome report as bugs

docker version                && printf "\033[1;32mDocker Commands Exist!\033[0m\n"
(id|grep docker >> /dev/null) && printf "\033[1;32mWe can run docker without root permission!\033[0m\n"

cd $(dirname "$0")  ## check runtime path is in what the script located in
docker build --no-cache -t "holishing/ffmpeg-static-env:buster" -f Dockerfile .
docker tag "holishing/ffmpeg-static-env:buster" "holishing/ffmpeg-static-env:linux3.2.0"
docker tag "holishing/ffmpeg-static-env:buster" "holishing/ffmpeg-static-env:latest"
docker build --no-cache --build-arg "DEBVER=stretch" -t "holishing/ffmpeg-static-env:stretch" -f Dockerfile .
docker tag "holishing/ffmpeg-static-env:stretch" "holishing/ffmpeg-static-env:linux2.6.32"

mkdir -p build/linux3 build/linux2
CONTAINER_LINUX3=container_linux3
CONTAINER_LINUX2=container_linux2
test -z "$TERM" || DOCKER_TERMIO_ARG=" -it"

docker run $DOCKER_TERMIO_ARG --name "$CONTAINER_LINUX3" "holishing/ffmpeg-static-env:linux3.2.0"  ./build.sh || docker rm "$CONTAINER_LINUX3"
docker cp "$CONTAINER_LINUX3":/ffmpeg-static/bin build/linux3 && docker rm "$CONTAINER_LINUX3"

docker run $DOCKER_TERMIO_ARG --name "$CONTAINER_LINUX2" "holishing/ffmpeg-static-env:linux2.6.32" ./build.sh || docker rm "$CONTAINER_LINUX2"
docker cp "$CONTAINER_LINUX2":/ffmpeg-static/bin build/linux2 && docker rm "$CONTAINER_LINUX2"

printf "\033[1;32m===================Completed!!!====================\033[0m\n"
