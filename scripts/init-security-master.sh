#!/bin/bash

sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config

parent_path=`dirname "$0"`
cp $parent_path/../server-files/usr/local/sbin/fail2ban-status.sh /usr/local/sbin/fail2ban-status.sh
cp $parent_path/../server-files/etc/ufw/applications.d/* /etc/ufw/applications.d/

ufw allow OpenSSH

ufw --force enable
