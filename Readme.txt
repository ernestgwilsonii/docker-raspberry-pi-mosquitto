##########################################
# Mosquitto MQTT Docker for Raspberry Pi #
#             REF: https://mosquitto.org # 
##########################################


###############################################################################
# Docker build
time docker build --no-cache -t ernestgwilsonii/docker-raspberry-pi-mosquitto:1.5.3 -f Dockerfile.armhf .
docker images

# Verify 
docker run -it -p 1883:1883 ernestgwilsonii/docker-raspberry-pi-mosquitto:1.5.3
# From another ssh session:
#docker ps

# Upload to Docker Hub
docker login
docker push ernestgwilsonii/docker-raspberry-pi-mosquitto:1.5.3
###############################################################################


###############################################################################
# First time setup #
####################
# Create bind mounted directies
sudo mkdir -p /opt/mqtt/config
sudo mkdir -p /opt/mqtt/config/conf.d
sudo mkdir -p /opt/mqtt/config/certs
sudo mkdir -p /opt/mqtt/data
sudo mkdir -p /opt/mqtt/log
sudo chmod -R a+rw /opt/mqtt
cp mosquitto.conf /opt/mqtt/config/mosquitto.conf
cp TCP_1883_Unencrypted_MQTT.conf /opt/mqtt/config/conf.d/TCP_1883_Unencrypted_MQTT.conf
cp TCP_8883_Encrypted_MQTT.conf /opt/mqtt/config/conf.d/TCP_8883_Encrypted_MQTT.conf
cp TCP_9001_Unencrypted_Websockets.conf /opt/mqtt/config/conf.d/TCP_9001_Unencrypted_Websockets.conf
cp TCP_9883_Encrypted_Websockets.conf /opt/mqtt/config/conf.d/TCP_9883_Encrypted_Websockets.conf
cp generate-CA.sh /opt/mqtt/config/certs/generate-CA.sh
cp passwd /opt/mqtt/config/passwd
cp aclfile /opt/mqtt/config/aclfile
sudo chmod +x /opt/mqtt/config/certs/generate-CA.sh
sudo chown -R 1000:1000 /opt/mqtt


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

# CentOS 7x
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

# Ubuntu
apt-get install mosquitto-clients

# Pub / Sub via command line (MQTT protocol)
mosquitto_sub -v -h 10.x.y.z -p 1883 -t "Chan19"
mosquitto_pub -d -h 10.x.y.z -p 1883 -t "Chan19" -m "Hello MQTT from command line"

# Pub / Sub via browser (Websocket protocol)
# REF: http://mitsuruog.github.io/what-mqtt/
ws://IP:9001/mqtt
Chan19
Hello from Websocket!
###############################################################################

