#!/bin/bash

wget https://releases.hashicorp.com/terraform/0.13.4/terraform_0.13.4_linux_amd64.zip
unzip terraform_0.13.4_linux_amd64.zip
mv terraform /usr/local/bin/
chmod ugo+x /usr/local/bin/terraform
rm terraform_0.13.4_linux_amd64.zip
