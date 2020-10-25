#!/bin/bash

# required parameters:
# PROSODY_USERS = username:pwd;username2:pwd2;... 

IFS=';'

#USERSTRING=$(cat /tmp/prosody_users.txt)

for ele in $PROSODY_USERS; do
    USERDATA=(${ele//:/;})
    docker exec $(docker ps -q -f name=meet_prosody)  prosodyctl --config /config/prosody.cfg.lua register ${USERDATA[0]} meet.jitsi ${USERDATA[1]}
done
