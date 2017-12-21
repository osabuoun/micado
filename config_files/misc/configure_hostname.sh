#!/bin/bash

oldhostname=$(hostname -s)
new_host_name=master-$(date +%s | sha256sum | base64 | head -c 32 ; echo)
echo $new_host_name > /etc/hostname
hostname -F /etc/hostname
line=127.0.1.1'\t'$new_host_name
sed -i "s/$oldhostname/$new_host_name/g" /etc/hosts
echo $line >> /etc/hosts
