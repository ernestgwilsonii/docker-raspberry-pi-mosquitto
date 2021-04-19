```
##########################################
# Mosquitto MQTT Docker for Raspberry Pi #
#             REF: https://mosquitto.org #
##########################################


###############################################################################
ssh pi@IpAddressOfYourRaspberryPi
# Specify Mosquito Version:
# NORMAL VERSIONS: https://hub.docker.com/_/eclipse-mosquitto
# RASPBERRY PI 4 VERSIONS: https://hub.docker.com/r/arm64v8/eclipse-mosquitto/
# The "openssl" version uses openssl instead of libressl, and enables TLS-PSK and TLS v1.3 cipher support
# REF: https://github.com/eclipse/mosquitto/tree/1c79920d78321c69add9d6d6f879dd73387bc25e/docker/2.0-openssl
MOSQUITTO_VERSION=2.0.10-openssl

# Dowbload the Raspberry Pi 4 version:
docker pull arm64v8/eclipse-mosquitto:$MOSQUITTO_VERSION

# List images and examine sizes
docker images

# Test running Mosquitto MQTT on Raspberry Pi 4
docker run -it arm64v8/eclipse-mosquitto:$MOSQUITTO_VERSION
# From another ssh session:
docker ps
###############################################################################


###############################################################################
# First time setup #
####################
# Create bind mounted directies
ssh pi@IpAddressOfYourRaspberryPi
sudo mkdir -p /opt/docker-compose
cd /opt/docker-compose
git clone https://github.com/ernestgwilsonii/docker-raspberry-pi-mosquitto.git
cd docker-raspberry-pi-mosquitto
sudo mkdir -p /opt/mqtt/config
sudo mkdir -p /opt/mqtt/config/conf.d
sudo mkdir -p /opt/mqtt/config/certs
sudo mkdir -p /opt/mqtt/data
sudo mkdir -p /opt/mqtt/log
sudo chmod -R a+rw /opt/mqtt
sudo cp mosquitto.conf /opt/mqtt/config/mosquitto.conf
sudo cp TCP_1883_Unencrypted_MQTT.conf /opt/mqtt/config/conf.d/TCP_1883_Unencrypted_MQTT.conf
sudo cp TCP_8883_Encrypted_MQTT.conf /opt/mqtt/config/conf.d/TCP_8883_Encrypted_MQTT.conf
sudo cp TCP_9001_Unencrypted_Websockets.conf /opt/mqtt/config/conf.d/TCP_9001_Unencrypted_Websockets.conf
sudo cp TCP_9883_Encrypted_Websockets.conf /opt/mqtt/config/conf.d/TCP_9883_Encrypted_Websockets.conf
sudo cp generate-CA.sh /opt/mqtt/config/certs/generate-CA.sh
sudo cp passwd /opt/mqtt/config/passwd
sudo cp aclfile /opt/mqtt/config/aclfile
sudo chmod +x /opt/mqtt/config/certs/generate-CA.sh
sudo chown -R root:1883 /opt/mqtt


##########
# Deploy #
##########
# Deploy the stack into a Docker Swarm
docker stack deploy -c docker-compose.yml mosquitto
# docker stack rm mosquitto

# Verify
docker service ls | grep mosquitto
docker service logs -f mosquitto_mqtt



###################
# MQTT Basic Test #
###################
# Install MQTT client
# REF: https://mosquitto.org/download/

# Raspberry Pi 4 client install:
sudo apt install -y mosquitto-clients

# CentOS 7x Client
vi /etc/yum.repos.d/mqtt.repo
[home_oojah_mqtt]
name=mqtt (CentOS_CentOS-7)
type=rpm-md
baseurl=http://download.opensuse.org/repositories/home:/oojah:/mqtt/CentOS_CentOS-7/
gpgcheck=1
gpgkey=http://download.opensuse.org/repositories/home:/oojah:/mqtt/CentOS_CentOS-7/repodata/repomd.xml.key
enabled=1
:wq!
yum -y install mosquitto-clients

# Mac OS Client
brew install mosquitto

# Ubuntu Client
apt-get install mosquitto-clients

# Windows Client - https://mosquitto.org/download/

# Pub / Sub via command line (MQTT protocol)
# Subscribe to "all" channels/topics aka wildcard
#mosquitto_sub -v -h 127.0.0.1 -p 1883 -t "#"
# Subscribe to everything on Chan19
mosquitto_sub -v -h 127.0.0.1 -p 1883 -t "Chan19"
# Publish to Chan19
mosquitto_pub -d -h 127.0.0.1 -p 1883 -t "Chan19" -m "Hello MQTT from command line"

# Pub / Sub via browser (Websocket protocol)
# REF: http://mitsuruog.github.io/what-mqtt/
ws://IP:9001/mqtt
Chan19
Hello from Websocket!
###############################################################################


###############################################################################
# Travis CI Notes:
# REF: https://travis-ci.org/ernestgwilsonii/docker-raspberry-pi-mosquitto
# To build ARM (for Raspberry Pi) in the cloud on X86_64 requires:
#  - a special Docker that understands "docker build --volume"
#  - qemu emulation
# REF: https://github.com/dersimn/HelloARM
# REF: https://developer.ibm.com/linuxonpower/2017/07/28/travis-multi-architecture-ci-workflow/
# REF: https://github.com/multiarch/qemu-user-static/releases
###############################################################################
```
