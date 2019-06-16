#!/bin/bash

docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD"
docker push ernestgwilsonii/docker-raspberry-pi-mosquitto:$MOSQUITTO_VERSION

