#!/bin/bash

# required parameters:
# PROSODY_USERS = username:pwd;username2:pwd2;... 


# wait till the container is up
until [ ! -z $(docker ps -q -f name=meet_prosody) ]
do
     sleep 5
     echo -n "."
done
echo ""

# set the field separator
IFS=';'

# iterate over each user, automatically split at separator
for ele in $PROSODY_USERS; do
    # replace occurrence of : with ; - this allows array access (internally split at field separator again)
    USERDATA=(${ele//:/;})

    docker exec $(docker ps -q -f name=meet_prosody) prosodyctl --config /config/prosody.cfg.lua register ${USERDATA[0]} meet.jitsi ${USERDATA[1]}
done
