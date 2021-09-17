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
DEFAULT_EMAIL="email";
DEFAULT_IP=0.0.0.0;
DEFAULT_CONTAINERS_PATH="/mnt/containers/"
DEFAULT_CONTAINERS_NAME="docker-proxy"

# define help function:
help()
{
   echo ""
   echo "usage: $0 [-e <email>] [-i <ip>] [-p <path>] [-n <name>] [-h]"
   echo -e "\t-e : set email for cetificat (default: $DEFAULT_EMAIL)"
   echo -e "\t-i : set public ip to listen (default: $DEFAULT_IP)"
   echo -e "\t-p : set path of container to install (default: $DEFAULT_CONTAINERS_PATH)"
   echo -e "\t-n : set name of container to install (default: $DEFAULT_CONTAINERS_NAME)"
   echo -e "\t-h : display this help"
   exit 1
}

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
   EMAIL=$DEFAULT_EMAIL;
fi

# update partition number defaults if set:
if [ -z "$IP" ]
then
   IP=$DEFAULT_IP;
fi

# update container path defaults if set:
if [ -z "$CONTAINERS_PATH" ]
then
   CONTAINERS_PATH=$DEFAULT_CONTAINERS_PATH;
fi

# update container name defaults if set:
if [ -z "$CONTAINERS_NAME" ]
then
   CONTAINERS_NAME=$DEFAULT_CONTAINERS_NAME;
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
