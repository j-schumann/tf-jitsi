#cloud-config

apt:
  sources:
    docker.list:
      source: deb [arch=amd64] https://download.docker.com/linux/ubuntu $RELEASE stable
      keyid: 9DC858229FC7DD38854AE2D88D81803C0EBFCD88

package_update: true
package_upgrade: true

packages:
  - bc
  - curl
  - docker-ce
  - docker-ce-cli
  - fail2ban
  - git
  - logrotate
  - mc
  - rsync
  - rsyslog
  - sudo
  - ufw
  - unattended-upgrades
  - unzip
  - wget

# create the docker group
groups:
  - docker

# Add default auto created user to docker group
system_info:
  default_user:
    groups: [docker]

users:
- name: jschumann
  gecos: Jakob Schumann
  lock_passwd: true
  shell: /bin/bash
  ssh-authorized-keys:
    - ${ssh_public_key}
  groups:
    - ubuntu
  sudo:
    - ALL=(ALL) NOPASSWD:ALL

runcmd:
 - export PUBLIC_IP=${public_ip}
 - export ACME_MAIL=${acme_mail}
 - export LOCAL_IP_RANGE=${ip_range}
 # load scripts & files from git, user-data can be limited to 16KB
 - git clone https://github.com/j-schumann/tf-dockerswarm.git /root/terraform-init
 - /root/terraform-init/scripts/setup-master.sh
 - echo "$LOCAL_IP_RANGE $PUBLIC_IP" >> /root/envvars

power_state:
  delay: "now"
  mode: reboot
  message: First reboot after cloud-init
  condition: True

final_message: "cloud-init finished after $UPTIME seconds"
