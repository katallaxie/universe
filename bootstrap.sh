#!/bin/bash

set -eu

export DEBIAN_FRONTEND=noninteractive

UPGRADE_PACKAGES=${1:-no}

# upgrade the machine
if [ "${UPGRADE_PACKAGES}" != "no" ]; then
  echo "==> Updating and upgrading packages ..."

  # Add third party repositories
  sudo add-apt-repository ppa:keithw/mosh-dev -y
  sudo add-apt-repository ppa:jonathonf/vim -y

  sudo apt-get update
  sudo apt-get upgrade -y
  sudo apt-get -y install iptables-persistent
fi

rm -rf /var/lib/apt/lists/*

# docker compose
curl -L https://github.com/docker/compose/releases/download/1.24.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# setup local persist
curl -fsSL https://raw.githubusercontent.com/CWSpear/local-persist/master/scripts/install.sh | sudo bash

# create run dir
mkdir -p /data/swarm
touch /data/swarm/acme.json

# bring out docker swarm
docker swarm init --advertise-addr ${self.private_ip} --listen-addr ${self.private_ip}
mkdir -p /etc/traefik/acme,
mkdir -p /data,
systemctl restart docker,
systemd-machine-id-setup

# setup network & watchtwoer
docker network create --driver overlay --opt encrypted proxy
docker service create --detach=false --restart-delay 30s --restart-condition on-failure --name watchtower --mode global --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock centurylink/watchtower --cleanup

# setup traefik
docker service create --detach=false --publish 80:80 --publish 443:443 --restart-delay 30s --restart-condition on-failure --constraint 'node.role == manager' --network proxy --name traefik --mode global --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock --mount type=bind,src=/data/swarm/acme.json,dst=/acme.json --mount type=bind,src=/data/swarm/traefik.toml,dst=/etc/traefik/traefik.toml traefik:latest

# set correct timezone
timedatectl set-timezone Europe/Berlin

echo ""
echo "==> Done!"
