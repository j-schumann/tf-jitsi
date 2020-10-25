#!/bin/bash

parent_path=`dirname "$0"`

echo "Setting up security..."
$parent_path/init-security-master.sh

echo "Creating the Docker Swearm..."
$parent_path/init-swarm-master.sh
