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
   echo "usage: $0 [-h]"
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
while getopts "h" opt
do
   case "$opt" in
      h ) help ;;
   esac
done

# check is run in root:
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

# start installation:
echo "Preparing distribution...";

# upgrade distribution:
apt-get -y update && sudo apt-get -y upgrade

# end:
echo "Installation finished.";
