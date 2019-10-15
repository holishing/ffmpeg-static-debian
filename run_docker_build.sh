#!/bin/sh

set -ex
test -z "$APPVEYOR" && APPVEYOR=0
test -z "$DEBVER"   && DEBVER=buster
set -u

### This shell script aim to be a POSIX-shell compatible script
### If There's a POSIX-shell run this script came into problem, welcome report as bugs

docker version                && printf "\033[1;32mDocker Commands Exist!\033[0m\n"
(id|grep docker >> /dev/null) && printf "\033[1;32mWe can run docker without root permission!\033[0m\n"

cd $(dirname "$0")  ## check runtime path is in what the script located in
docker build --no-cache --build-arg DEBVER="$DEBVER" -t holishing/ffmpeg-static-env:"$DEBVER" .
printf "\033[1;32m=================Build Environment Set up!=================\033[0m\n"

CONTAINER_LINUX=container_"$DEBVER"
test -eq $APPVEYOR 0 && DOCKER_TERMIO_ARG=" -it" || DOCKER_TERMIO_ARG=""
docker run $DOCKER_TERMIO_ARG --name "$CONTAINER_LINUX" holishing/ffmpeg-static-env:"$DEBVER" ./build.sh || docker rm "$CONTAINER_LINUX"

mkdir -p build/"$DEBVER"
docker cp "$CONTAINER_LINUX":/ffmpeg-static/bin build/"$DEBVER" && docker rm "$CONTAINER_LINUX"

printf "\033[1;32m===================Completed!!!====================\033[0m\n"
