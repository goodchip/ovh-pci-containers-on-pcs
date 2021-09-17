#!/bin/bash
##############################################
#                                            #
# File of git repo:                          #
# goodchip/ovh-pci-containers-on-pcs/master/ #
#                                            #
# Licence MIT                                #
#                                            #
##############################################

# define default variables:
DEFAULT_DOCKER_COMPOSE_VERSION=1.19.0;
DEFAULT_DOCKER_COMPOSE_PATH="/usr/local/bin/docker-compose";

# define help function:
help()
{
   echo ""
   echo "usage: $0 [-c <version>] [-h]"
   echo -e "\t-c : set docker-compose version to install (optional)"
   echo -e "\t-h : display this help"
   exit 1
}

# scan arguments:
while getopts "c:h" opt
do
   case "$opt" in
      c ) DOCKER_COMPOSE_VERSION="$OPTARG" ;;
      h ) help ;;
   esac
done

# check is run in root:
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

# get docker-compose version if set
if [ -z "$DOCKER_COMPOSE_VERSION" ]
then
   DOCKER_COMPOSE_VERSION=$DEFAULT_DOCKER_COMPOSE_VERSION;
fi

# install docker:
echo "Installing docker...";
apt install docker.io -y
systemctl start docker
systemctl enable docker
docker version

# install docker-compose:
echo "Installing docker-compose" $DOCKER_COMPOSE_VERSION "on" $DEFAULT_DOCKER_COMPOSE_PATH "...";
curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o $DEFAULT_DOCKER_COMPOSE_PATH
chmod +x $DEFAULT_DOCKER_COMPOSE_PATH

# end:
echo "Installation finished.";
