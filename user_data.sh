#!/usr/bin/env bash

apt-get update
apt-get -y install figlet

# Generate system banner
figlet "${welcome_message}" > /etc/motd

# Setup DNS Search domains
echo 'search ${search_domains}' > '/etc/resolvconf/resolv.conf.d/base'
resolvconf -u

# Setup local vanity hostname
echo '${hostname}' | sed 's/\.$//' > /etc/hostname
hostname `cat /etc/hostname`

${user_data}