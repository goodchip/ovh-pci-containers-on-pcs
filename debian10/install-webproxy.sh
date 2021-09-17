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
   echo "usage: $0 [-e <email>] [-i <ip>] [-p <path>] [-n <name>] [-h]"
   echo -e "\t-e : set email for cetificat (default: $DEFAULT_CONTAINER_WEBPROXY_EMAIL)"
   echo -e "\t-i : set public ip to listen (default: $DEFAULT_CONTAINER_WEBPROXY_IP)"
   echo -e "\t-p : set path of container to install (default: $DEFAULT_PCS_DEVICE_MOUNT_PATH)"
   echo -e "\t-n : set name of container to install (default: $DEFAULT_CONTAINER_WEBPROXY_NAME)"
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

# update email defaults if set:
if [ -z "$EMAIL" ]
then
   EMAIL=$DEFAULT_CONTAINER_WEBPROXY_EMAIL;
fi

# update listen ip defaults if set:
if [ -z "$IP" ]
then
   IP=$DEFAULT_CONTAINER_WEBPROXY_IP;
fi

# update container path defaults if set:
if [ -z "$CONTAINERS_PATH" ]
then
   CONTAINERS_PATH=$DEFAULT_PCS_DEVICE_MOUNT_PATH;
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

# have sure than docker-compose was started (fresh-start script is bugged sometime for run it at the end of configuration)
docker-compose up -d

# end:
echo "Installation finished.";
