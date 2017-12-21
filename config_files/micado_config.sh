#!/bin/bash

curl -o /bin/consul-set-network.sh https://raw.githubusercontent.com/osabuoun/micado/master/config_files/consul-set-network.sh
chmod 755 /bin/consul-set-network.sh
curl -o /etc/consul/config.json https://raw.githubusercontent.com/osabuoun/micado/master/config_files/consul/config.json
curl -o /etc/prometheus/prometheus.yml https://raw.githubusercontent.com/osabuoun/micado/master/config_files/prometheus/prometheus.yml
curl -o /etc/prometheus/prometheus.rules https://raw.githubusercontent.com/osabuoun/micado/master/config_files/prometheus/prometheus.rules
curl -o /etc/prometheus/alert_generator.sh https://raw.githubusercontent.com/osabuoun/micado/master/config_files/prometheus/alert_generator.sh
curl -o /etc/alertmanager/config.yml https://raw.githubusercontent.com/osabuoun/micado/master/config_files/alertmanager/config.yml
curl -o /etc/prometheus_executor/conf.sh https://raw.githubusercontent.com/osabuoun/micado/master/config_files/prometheus_executor/conf.sh
curl -o /etc/resolvconf/resolv.conf.d/base https://raw.githubusercontent.com/osabuoun/micado/master/config_files/misc/resolv.conf.d_base
curl -o /etc/micado/docker-compose.yml https://raw.githubusercontent.com/osabuoun/micado/master/config_files/docker-compose.yml
