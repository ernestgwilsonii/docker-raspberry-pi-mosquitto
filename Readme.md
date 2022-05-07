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
MOSQUITTO_VERSION=2.0.14-openssl

# Dowbload the Raspberry Pi 4 version:
docker pull eclipse-mosquitto:$MOSQUITTO_VERSION

# List images and examine sizes
docker images

# Test running Mosquitto MQTT on Raspberry Pi 4
docker run -it eclipse-mosquitto:$MOSQUITTO_VERSION
# From another ssh session:
docker ps
###############################################################################


###############################################################################
# First time setup #
####################
ssh pi@IpAddressOfYourRaspberryPi

# Clone the kit onto the Raspberry Pi
sudo mkdir -p /opt/docker-compose
sudo chmod a+rw -R /opt/docker-compose/
cd /opt/docker-compose
git clone https://github.com/ernestgwilsonii/docker-raspberry-pi-mosquitto.git
cd docker-raspberry-pi-mosquitto

# Create bind mounted directories and copy starting files into place
sudo mkdir -p /opt/mqtt/config
sudo mkdir -p /opt/mqtt/config/conf.d
sudo mkdir -p /opt/mqtt/config/certs
sudo mkdir -p /opt/mqtt/data
sudo mkdir -p /opt/mqtt/log
sudo chmod -R a+rw /opt/mqtt
sudo cp mosquitto.conf /opt/mqtt/config/mosquitto.conf
sudo cp passwd /opt/mqtt/config/passwd
sudo cp aclfile /opt/mqtt/config/aclfile
sudo cp TCP_1883_Unencrypted_MQTT.conf /opt/mqtt/config/conf.d/TCP_1883_Unencrypted_MQTT.conf
sudo cp TCP_8883_Encrypted_MQTT.conf /opt/mqtt/config/conf.d/TCP_8883_Encrypted_MQTT.conf
sudo cp TCP_9001_Unencrypted_Websockets.conf /opt/mqtt/config/conf.d/TCP_9001_Unencrypted_Websockets.conf
sudo cp TCP_9883_Encrypted_Websockets.conf /opt/mqtt/config/conf.d/TCP_9883_Encrypted_Websockets.conf
sudo cp generate-CA.sh /opt/mqtt/config/certs/generate-CA.sh
sudo cp passwd /opt/mqtt/config/passwd
sudo cp aclfile /opt/mqtt/config/aclfile
sudo chmod +x /opt/mqtt/config/certs/generate-CA.sh
# Generate CA
sudo bash -c "cd /opt/mqtt/config/certs; /opt/mqtt/config/certs/generate-CA.sh"
# Generate certs for various other users/services
#sudo bash -c "cd /opt/mqtt/config/certs; /opt/mqtt/config/certs/generate-CA.sh SomeUserName"
# Move hostname specific files to generic mqtt namming
mv /opt/mqtt/config/certs/$(hostname).crt /opt/mqtt/config/certs/mqtt.crt
mv /opt/mqtt/config/certs/$(hostname).csr /opt/mqtt/config/certs/mqtt.csr
mv /opt/mqtt/config/certs/$(hostname).key /opt/mqtt/config/certs/mqtt.key
# Reverse link naming so the generate-CA.sh script does not attempt to create these again
ln -s /opt/mqtt/config/certs/mqtt.crt /opt/mqtt/config/certs/$(hostname).crt
ln -s /opt/mqtt/config/certs/mqtt.csr /opt/mqtt/config/certs/$(hostname).csr
ln -s /opt/mqtt/config/certs/mqtt.key /opt/mqtt/config/certs/$(hostname).key
ls -alF /opt/mqtt/config/certs
# Set perms for bind mount as root and container group 1883
sudo chown -R root:1883 /opt/mqtt
ls -alF /opt/mqtt


##########
# Deploy #
##########
# Deploy the stack into a Docker Swarm
docker stack deploy -c docker-compose.yml mosquitto
# docker stack rm mosquitto

# Verify
docker service ls | grep mosquitto
docker service logs -f mosquitto_mqtt

# Login to the actual container
docker exec -ti mosquitto_mqtt.1.$(docker service ps -f 'name=mosquitto_mqtt.1' mosquitto_mqtt -q --no-trunc | head -n1) sh


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

# Next: https://github.com/mqttjs/MQTT.js/
###############################################################################


###############################################################################
# Generate Certs
# REF: https://mosquitto.org/documentation/
cd /opt/mqtt/config/certs
sudo ./generate-CA.sh
# Generate certs for users/services
#sudo ./generate-CA.sh SomeUserName
#sudo ./generate-CA.sh SomeOtherUserName
#sudo ./generate-CA.sh SomeServiceName

# Add users
# REF: https://mosquitto.org/man/mosquitto_passwd-1.html
docker ps
docker exec -it ContainerIdHere sh
mosquitto_passwd -c /mosquitto/config/passwd SomeUserName
cat /mosquitto/config/passwd

# Edit the ACL controls
# REF: https://mosquitto.org/man/mosquitto-conf-5.html
# Either from inside the Docker container
vi /mosquitto/config/aclfile
# Or from the bind mounted Docker host
vi /opt/mqtt/config/aclfile
###############################################################################
```
