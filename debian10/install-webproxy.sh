#!/bin/bash
##############################################
#                                            #
# File of git repo:                          #
# goodchip/ovh-pci-containers-on-pcs/master/ #
#                                            #
# Licence MIT                                #
#                                            #
##############################################

ENV_PATH="../ovh-pci-containers-on-pcs/.env"

# define help function:
help()
{
   echo ""
   echo "usage: $0 [-e <email>] [-i <ip>] [-p <path>] [-n <name>] [-h]"
   echo -e "\t-e : set email for cetificat (default: $DEFAULT_CONTAINER_WEBPROXY_EMAIL)"
   echo -e "\t-i : set public ip to listen (default: $DEFAULT_CONTAINER_WEBPROXY_IP)"
   echo -e "\t-p : set path of container to install (default: $DEFAULT_CONTAINER_WEBPROXY_PATH)"
   echo -e "\t-n : set name of container to install (default: $DEFAULT_CONTAINER_WEBPROXY_NAME)"
   echo -e "\t-h : display this help"
   exit 1
}

# get default environnement variables:
if ! [ -f "$ENV_PATH" ]
then
  echo "Must be run on project root directory."
  exit 1
fi
export $(cat "$ENV_PATH" | sed 's/#.*//g' | xargs)

# scan arguments:
while getopts "e:i:p:n:h" opt
do
   case "$opt" in
      e ) EMAIL="$OPTARG" ;;
      i ) IP="$OPTARG" ;;
      p ) CONTAINERS_PATH="$OPTARG" ;;
      n ) CONTAINERS_NAME="$OPTARG" ;;
      h ) help ;;
   esac
done

# check is run in root:
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

# update disk name defaults if set:
if [ -z "$EMAIL" ]
then
   EMAIL=$DEFAULT_CONTAINER_WEBPROXY_EMAIL;
fi

# update partition number defaults if set:
if [ -z "$IP" ]
then
   IP=$DEFAULT_CONTAINER_WEBPROXY_IP;
fi

# update container path defaults if set:
if [ -z "$CONTAINERS_PATH" ]
then
   CONTAINERS_PATH=$DEFAULT_CONTAINER_WEBPROXY_PATH;
fi

# update container name defaults if set:
if [ -z "$CONTAINERS_NAME" ]
then
   CONTAINERS_NAME=$DEFAULT_CONTAINER_WEBPROXY_NAME;
fi

# start installation:
echo "Installing web proxy on $CONTAINERS_PATH$CONTAINERS_NAME/ ...";

# prepare containers installation:
cd /mnt/containers/

# install NGINX Proxy Automation:
echo "Configuring web proxy to listen $IP and making bot cerficat using email: $EMAIL ...";
git clone --recurse-submodules "https://github.com/evertramos/nginx-proxy-automation.git" "$CONTAINERS_NAME"
cd "$CONTAINERS_NAME/bin"
./fresh-start.sh --yes -e "$EMAIL" -ip "$IP" --skip-docker-image-check
docker-compose up
docker-compose start

# just for futures references:
#./fresh-start.sh --yes -e contact@underscore.radio.fm --skip-docker-image-check
#docker network create webproxy

# end:
echo "Installation finished.";
