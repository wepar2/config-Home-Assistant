#!/usr/bin/env bash

if [[ "$(id -u)" != "0" ]]; then
   echo "ESTE SCRIPT DEBE SER EJECUTADO COMO ROOT"
   sleep 3
   clear      
else
	
	set -e

	declare -a MISSING_PACKAGES

	function info { echo -e "\e[32m[info] $*\e[39m"; }
	function warn  { echo -e "\e[33m[warn] $*\e[39m"; }
	function error { echo -e "\e[31m[error] $*\e[39m"; exit 1; }

	info "¿Cual es el nombre de tu usuario?(NO ROOT)"
        read NAM < /dev/tty


	info "Comprobando actualizaciones"
	sudo apt update && sudo apt upgrade -y

	sleep 5

	info "instalando dependencias"
	sleep 5

	sudo apt-get install \
	jq \
	wget \
	curl \
	udisks2 \
	libglib2.0-bin \
	network-manager \
	software-properties-common \
	apparmor-utils \
	avahi-daemon \
	dbus \
	jq -y

	info "Creando carpetas...."

	# creacion carpetas donde guardar datos 
	sudo mkdir /docker
	sudo mkdir /docker/nodered
	sudo mkdir /docker/nodered/data
	sudo mkdir /docker/influxdb
	sudo mkdir /docker/influxdb/var/
	sudo mkdir /docker/influxdb/var/lib/
	sudo mkdir /docker/influxdb/var/lib/influxdb
	sudo mkdir /docker/influxdb/etc/
	sudo mkdir /docker/influxdb/etc/influxdb
	sudo mkdir /docker/portainer
	sudo chown $NAM -R /docker
	
	sleep 2

	info "Instalando docker"
	sleep 5
	curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh && sudo usermod -aG docker $NAM
	
	sudo apt-get install docker-compose -y
	
	info "Instalando NodeRed, influxdb, portainer web"
	sleep 5

	# instalacion nodered
	#
	sudo docker run -itd -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /docker/portainer:/data portainer/portainer-ce

	info "Descargando os-agent"
	sleep 5

	wget https://github.com/home-assistant/os-agent/releases/download/1.4.1/os-agent_1.4.1_linux_x86_64.deb

	sleep 5
	info "instalando os-agent"
	sudo dpkg -i os-agent_1.4.1_linux_x86_64.deb
	
	sudo chown $NAM -R /docker
	
	sleep 10
	info "Instalando home-assistant"
	info "sudo ./installHassio.sh  -m raspberrypi4 -d /docker/hassio/"
fi
