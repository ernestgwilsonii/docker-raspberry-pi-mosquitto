#!/bin/bash

docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD"
docker push ernestgwilsonii/docker-raspberry-pi-mosquitto:1.6.2
