#!/bin/bash

echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME"
docker push ernestgwilsonii/docker-raspberry-pi-mosquitto:1.6.2
