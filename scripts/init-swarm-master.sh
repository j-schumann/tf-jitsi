#!/bin/bash

parent_path=`dirname "$0"`
cp $parent_path/../server-files/etc/sysctl.d/80-docker.conf /etc/sysctl.d/80-docker.conf

#export LOCALIP=`ip -o -4 addr show dev ens10 | cut -d' ' -f7 | cut -d'/' -f1`
#docker swarm init --advertise-addr $LOCALIP
docker swarm init 

# shared, encrypted mesh network for all containers on all nodes
docker network create --opt encrypted --driver overlay traefik-net

mkdir -p /opt/container-data/traefik
mkdir -p /opt/container-data/jitsi

sed -i "s/PUBLIC_IP/$PUBLIC_IP/g" $parent_path/../stacks/.env
sed -i "s/ACME_MAIL/$ACME_MAIL/g" $parent_path/../stacks/.env

function generatePassword() {
    openssl rand -hex 16
}

JICOFO_COMPONENT_SECRET=$(generatePassword)
JICOFO_AUTH_PASSWORD=$(generatePassword)
JVB_AUTH_PASSWORD=$(generatePassword)
JIGASI_XMPP_PASSWORD=$(generatePassword)
JIBRI_RECORDER_PASSWORD=$(generatePassword)
JIBRI_XMPP_PASSWORD=$(generatePassword)

sed -i.bak \
    -e "s#JICOFO_COMPONENT_SECRET=.*#JICOFO_COMPONENT_SECRET=${JICOFO_COMPONENT_SECRET}#g" \
    -e "s#JICOFO_AUTH_PASSWORD=.*#JICOFO_AUTH_PASSWORD=${JICOFO_AUTH_PASSWORD}#g" \
    -e "s#JVB_AUTH_PASSWORD=.*#JVB_AUTH_PASSWORD=${JVB_AUTH_PASSWORD}#g" \
    -e "s#JIGASI_XMPP_PASSWORD=.*#JIGASI_XMPP_PASSWORD=${JIGASI_XMPP_PASSWORD}#g" \
    -e "s#JIBRI_RECORDER_PASSWORD=.*#JIBRI_RECORDER_PASSWORD=${JIBRI_RECORDER_PASSWORD}#g" \
    -e "s#JIBRI_XMPP_PASSWORD=.*#JIBRI_XMPP_PASSWORD=${JIBRI_XMPP_PASSWORD}#g" \
    "$parent_path/../stacks/.env"

docker stack deploy meet -c $parent_path/../stacks/jitsi.yaml
