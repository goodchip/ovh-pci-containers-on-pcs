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
   echo "usage: $0 [-o <osname>] [-h]"
   echo -e "\t-o : set osname image of your PCS (default: $DEFAULT_PCI_OS_DISTRIBUTION)"
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
while getopts "o:h" opt
do
   case "$opt" in
      o ) OS_DISTRIBUTION="$OPTARG" ;;
      h ) help ;;
   esac
done

# check is run in root:
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

# update partition number defaults if set:
if [ -z "$OS" ]
then
   OS_DISTRIBUTION=$DEFAULT_PCI_OS_DISTRIBUTION;
fi

# start installation:
echo -e "\n\r[BEGIN] auto-install on your fresh $OS_DISTRIBUTION distribution...";

if  [ $DEFAULT_PCI_OS_AUTOINSTALL = 1 ]
then
	echo -e "\n\r[INSTALL]---- --- -- - - -> PCI:"
	./$OS_DISTRIBUTION/install-pci.sh
fi

if  [ $DEFAULT_PCS_AUTOINSTALL = 1 ]
then
	echo -e "\n\r[INSTALL]---- --- -- - - -> PCS:"
	./$OS_DISTRIBUTION/install-pcs.sh
fi

if  [ $DEFAULT_PCI_DOCKER_AUTOINSTALL = 1 ]
then
	echo -e "\n\r[INSTALL]---- --- -- - - -> DOCKER:"
	./$OS_DISTRIBUTION/install-docker.sh
fi

if  [ $DEFAULT_CONTAINER_WEBPROXY_AUTOINSTALL = 1 ]
then
	echo -e "\n\r[INSTALL]---- --- -- - - -> WEBPROXY:"
	./$OS_DISTRIBUTION/install-webproxy.sh
fi

echo -e "\n\r[END] auto-install.\n\r";
