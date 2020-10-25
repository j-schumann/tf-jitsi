#!/bin/bash

parent_path=`dirname "$0"`
cp $parent_path/../server-files/etc/sysctl.d/80-docker.conf /etc/sysctl.d/80-docker.conf

# enp7s0
export LOCALIP=`ip -o -4 addr show dev eth0 | cut -d' ' -f7 | cut -d'/' -f1`
docker swarm init --advertise-addr $LOCALIP

# install docker-compose from github, ubuntu has an old version
curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# shared, encrypted mesh network for all containers on all nodes
docker network create --opt encrypted --driver overlay traefik-net

mkdir -p /opt/container-data/traefik
mkdir -p /opt/container-data/jitsi/{web/letsencrypt,transcripts,prosody/config,prosody/prosody-plugins-custom,jicofo,jvb,jigasi,jibri}

function generatePassword() {
    openssl rand -hex 16
}

JICOFO_COMPONENT_SECRET=$(generatePassword)
JICOFO_AUTH_PASSWORD=$(generatePassword)
JVB_AUTH_PASSWORD=$(generatePassword)
JIGASI_XMPP_PASSWORD=$(generatePassword)
JIBRI_RECORDER_PASSWORD=$(generatePassword)
JIBRI_XMPP_PASSWORD=$(generatePassword)

sed -i \
    -e "s#PUBLIC_IP#$PUBLIC_IP#g" \
    -e "s#ACME_MAIL#$ACME_MAIL#g" \
    -e "s#JICOFO_COMPONENT_SECRET=.*#JICOFO_COMPONENT_SECRET=${JICOFO_COMPONENT_SECRET}#g" \
    -e "s#JICOFO_AUTH_PASSWORD=.*#JICOFO_AUTH_PASSWORD=${JICOFO_AUTH_PASSWORD}#g" \
    -e "s#JVB_AUTH_PASSWORD=.*#JVB_AUTH_PASSWORD=${JVB_AUTH_PASSWORD}#g" \
    -e "s#JIGASI_XMPP_PASSWORD=.*#JIGASI_XMPP_PASSWORD=${JIGASI_XMPP_PASSWORD}#g" \
    -e "s#JIBRI_RECORDER_PASSWORD=.*#JIBRI_RECORDER_PASSWORD=${JIBRI_RECORDER_PASSWORD}#g" \
    -e "s#JIBRI_XMPP_PASSWORD=.*#JIBRI_XMPP_PASSWORD=${JIBRI_XMPP_PASSWORD}#g" \
    "$parent_path/../stacks/.env"

# stack deploy does not support env-files, so prepare the config using docker-compose first...
docker stack deploy meet -c <(docker-compose -f $parent_path/../stacks/jitsi.yaml --env-file $parent_path/../stacks/.env config)
