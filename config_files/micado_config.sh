#!/bin/bash

curl -o /bin/consul-set-network.sh https://raw.githubusercontent.com/osabuoun/micado/master/config_files/consul/consul-set-network.sh
chmod 755 /bin/consul-set-network.sh
curl -o /bin/configure_hostname.sh https://raw.githubusercontent.com/osabuoun/micado/master/config_files/misc/configure_hostname.sh
chmod 755 /bin/configure_hostname.sh
curl -o /bin/install_docker.sh https://raw.githubusercontent.com/osabuoun/micado/master/config_files/misc/install_docker.sh
chmod 755 /bin/install_docker.sh

curl -o /etc/consul/config.json https://raw.githubusercontent.com/osabuoun/micado/master/config_files/consul/config.json
curl -o /etc/prometheus/prometheus.yml https://raw.githubusercontent.com/osabuoun/micado/master/config_files/prometheus/prometheus.yml
curl -o /etc/prometheus/prometheus.rules https://raw.githubusercontent.com/osabuoun/micado/master/config_files/prometheus/prometheus.rules
curl -o /etc/prometheus/alert_generator.sh https://raw.githubusercontent.com/osabuoun/micado/master/config_files/prometheus/alert_generator.sh
curl -o /etc/alertmanager/config.yml https://raw.githubusercontent.com/osabuoun/micado/master/config_files/alertmanager/config.yml
curl -o /etc/prometheus_executor/conf.sh https://raw.githubusercontent.com/osabuoun/micado/master/config_files/prometheus_executor/conf.sh
curl -o /etc/resolvconf/resolv.conf.d/base https://raw.githubusercontent.com/osabuoun/micado/master/config_files/misc/resolv.conf.d_base
curl -o /etc/micado/docker-compose.yml https://raw.githubusercontent.com/osabuoun/micado/master/config_files/docker-compose.yml


adduser --disabled-password --gecos "" prometheus
export DEBIAN_FRONTEND=noninteractive 
dpkg-reconfigure openssh-server
resolvconf -u
echo nameserver 8.8.8.8 >> /etc/resolv.conf
sudo dhclient
/bin/configure_hostname.sh
/bin/install_docker.sh
#download config files
curl -L https://raw.githubusercontent.com/osabuoun/micado/master/config_files/prometheus_executor/executor_config.sh --create-dirs -o /etc/prometheus_executor/conf.sh
curl -L https://raw.githubusercontent.com/osabuoun/micado/master/config_files/consul/consul_checks.json --create-dirs -o /etc/consul/checks.json

#change health check ip address for host ip
sed -i 's/healthcheck_ip_change/'$(hostname --ip-address)'/g' /etc/consul/*

# Start Swarm
docker swarm init --advertise-addr=$IP
docker network create --driver overlay --subnet 172.31.1.0/24 --gateway 172.31.1.1 --attachable jef_network

#Start JEF
curl -o jef_docker_compose.yml https://raw.githubusercontent.com/osabuoun/jqueuer/master/jef_docker_compose.yml
curl -o celeryconfig.py https://raw.githubusercontent.com/osabuoun/jqueuer/master/celeryconfig.py 
curl -o flowerconfig.py https://raw.githubusercontent.com/osabuoun/jqueuer/master/flowerconfig.py 
docker-compose --file jef_docker_compose.yml up -d
# update executor IP
export IP=$(hostname -I | cut -d\  -f1)
sed -i -e 's/hostIP/'$IP'/g' /etc/prometheus_executor/conf.sh
sed -i -e 's/hostIP/'$IP'/g' /etc/prometheus/alert_generator.sh
#Start infra. services
curl -L https://raw.githubusercontent.com/osabuoun/micado/master/worker_node/templates/temp_auth_data.yaml --create-dirs -o /var/lib/micado/occopus/temp_auth_data.yaml
curl -L https://raw.githubusercontent.com/osabuoun/micado/master/worker_node/templates/temp_node_definitions.yaml --create-dirs -o /var/lib/micado/occopus/temp_node_definitions.yaml
curl -L https://raw.githubusercontent.com/osabuoun/micado/master/worker_node/infrastructure_descriptor.yaml  --create-dirs -o /var/lib/micado/occopus/temp_infrastructure_descriptor.yaml
curl -L https://raw.githubusercontent.com/osabuoun/micado/master/worker_node/nodes/cloud_init_worker.yaml --create-dirs -o /etc/micado/occopus/nodes/cloud_init_worker.yaml
docker-compose -f /etc/micado/docker-compose.yml up -d
chmod 777 /etc/prometheus_executor/conf.sh
chmod 777 /etc/prometheus/alert_generator.sh
docker network create -d bridge my-net --subnet 172.31.0.0/24
docker run -d --network=my-net --ip="172.31.0.2" -p 9090:9090 -v /etc/:/etc prom/prometheus:v1.8.0
docker run -d --network=my-net --ip="172.31.0.3" -v /etc/alertmanager/:/etc/alertmanager/ -p 9093:9093 prom/alertmanager
docker run -d --network=my-net --ip="172.31.0.4" -p 9095:9095 -v /etc/prometheus_executor/:/etc/prometheus_executor micado/prometheus_executor
export IP=$(hostname -I | cut -d\  -f1)
docker run -d --network=my-net --ip="172.31.0.5" -p 8301:8301 -p 8301:8301/udp -p 8300:8300 -p 8302:8302 -p 8302:8302/udp -p 8400:8400 -p 8500:8500 -p 8600:8600/udp  -v /etc/consul/:/etc/consul  -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt":true}'  consul agent -server -client=0.0.0.0 -advertise=$IP -bootstrap=true -ui -config-dir=/etc/consul
docker run -d --name MYSQL_DATABASE -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=dataavenue -e MYSQL_USER=da -e MYSQL_PASSWORD=da -p 3306:3306 mysql/mysql-server:5.5
docker run -d -v /etc/prometheus/:/etc/prometheus micado/alert_generator:1.0
 # - docker run -d -p 3000:3000 grafana/grafana
# Drain the node
docker node update --availability drain $(hostname)
