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
   echo "usage: $0 [-h]"
   echo -e "\t-i : set the path for install containers (default: $DEFAULT_PCI_INSTALL_PATH)"
   echo -e "\t-b : set the path for backup containers (default: $DEFAULT_PCI_BACKUP_PATH)"
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
while getopts "h" opt
do
   case "$opt" in
      i ) INSTALL_PATH="$OPTARG" ;;
      b ) BACKUP_PATH="$OPTARG" ;;
      h ) help ;;
   esac
done

# check is run in root:
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

# update container install path defaults if set:
if [ -z "$INSTALL_PATH" ]
then
   INSTALL_PATH=$DEFAULT_PCI_INSTALL_PATH;
fi

# update container backup path defaults if set:
if [ -z "$BACKUP_PATH" ]
then
   BACKUP_PATH=$DEFAULT_PCI_BACKUP_PATH;
fi

# start installation:
echo "Preparing distribution...";

# upgrade distribution:
apt-get -y update && apt-get -y upgrade

# install git if not present:
apt-get -y install git

# secure .env files:
chown root:root .env*
chmod 600 .env*

# make dirs for install and backups:
mkdir "$INSTALL_PATH"
mkdir "$BACKUP_PATH"

# end:
echo "Installation finished.";
