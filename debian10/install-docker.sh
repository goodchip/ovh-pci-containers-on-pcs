#!/bin/bash
##############################################
#                                            #
# File of git repo:                          #
# goodchip/ovh-pci-containers-on-pcs/master/ #
#                                            #
# Licence MIT                                #
#                                            #
##############################################

ENV_PATH="../ovh-pci-containers-on-pcs/"
ENV_FILE=".env"

# define help function:
help()
{
   echo ""
   echo "usage: $0 [-c <version>] [-h]"
   echo -e "\t-c : set docker-compose version to install (default: $DEFAULT_PCI_DOCKER_COMPOSE_VERSION)"
   echo -e "\t-h : display this help"
   exit 1
}

# get default environnement variables:
if ! [ -d "$ENV_PATH" ]
then
  echo "[ERROR] Must be run on project root directory."
  exit 1
fi
if ! [ -f "$ENV_PATH$ENV_FILE" ]
then
  echo -e "\n\r[ERROR] Environnement variables not found:    ...please,"
  echo -e "\t> type 'cp $ENV_FILE.example $ENV_FILE'"
  echo -e "\t> edit the new file created ($ENV_FILE) and enter your server configuration"
  echo -e "\t> run this script again and rules!\n\r"
  exit 1
fi
export $(cat "$ENV_PATH$ENV_FILE" | sed 's/#.*//g' | xargs)

# scan arguments:
while getopts "c:h" opt
do
   case "$opt" in
      c ) PCI_DOCKER_COMPOSE_VERSION="$OPTARG" ;;
      h ) help ;;
   esac
done

# check is run in root:
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

# get docker-compose version if set
if [ -z "$PCI_DOCKER_COMPOSE_VERSION" ]
then
   PCI_DOCKER_COMPOSE_VERSION=$DEFAULT_PCI_DOCKER_COMPOSE_VERSION;
fi

# install docker:
echo "Installing docker...";
apt install docker.io -y
systemctl start docker
systemctl enable docker
docker version

# install docker-compose:
echo "Installing docker-compose" $PCI_DOCKER_COMPOSE_VERSION "on" $DEFAULT_PCI_DOCKER_COMPOSE_PATH "...";
curl -L "https://github.com/docker/compose/releases/download/$PCI_DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o $DEFAULT_PCI_DOCKER_COMPOSE_PATH
chmod +x $DEFAULT_PCI_DOCKER_COMPOSE_PATH

# end:
echo "Installation finished.";
