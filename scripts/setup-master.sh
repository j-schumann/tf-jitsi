#!/bin/bash

parent_path=`dirname "$0"`

echo "Setting the floating IP $PUBLIC_IP as default..."
cp $parent_path/../server-files/etc/netplan/60-floating-ip.yaml /etc/netplan/
sed -i "s/PUBLIC_IP/$PUBLIC_IP/g" /etc/netplan/60-floating-ip.yaml
#netplan apply

echo "Setting up security..."
$parent_path/init-security-master.sh

echo "Creating the Docker Swearm..."
$parent_path/init-swarm-master.sh
