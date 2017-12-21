#!/bin/bash

# Docker install
apt-get update
apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl software-properties-common wget unzip jq dnsmasq
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce=17.06.0~ce-0~ubuntu
export IP=$(hostname -I | cut -d\  -f1)
sed -i -e "s/-H fd:\/\//-H fd:\/\/ -H tcp:\/\/$IP:2375/g" /lib/systemd/system/docker.service
systemctl daemon-reload
service docker restart

# Install Docker Compose
curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose