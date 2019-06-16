#!/bin/bash

docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD"
docker push ernestgwilsonii/docker-raspberry-pi-mosquitto:$MOSQUITTO_VERSION
docker tag ernestgwilsonii/docker-raspberry-pi-mosquitto:$MOSQUITTO_VERSION ernestgwilsonii/docker-raspberry-pi-mosquitto:latest
docker push ernestgwilsonii/docker-raspberry-pi-mosquitto:latest
