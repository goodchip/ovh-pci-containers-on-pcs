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
   echo "usage: $0 [-o <osname>] [-X] [-h]"
   echo -e "\t-o : set osname image of your PCI (default: $DEFAULT_PCI_OS_DISTRIBUTION)"
   echo -x "\t-X : execute script"
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
while getopts "o:Xh" opt
do
   case "$opt" in
      o ) OS_DISTRIBUTION="$OPTARG" ;;
      X ) EXECUTE_FOR_REAL=1 ;;
      h ) help ;;
   esac
done

# check is run in root:
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

# check if execute the script for real or not:
if ! [ $EXECUTE_FOR_REAL == 1 ]
then
  echo -e "\n\r[WARN] not executed:    ...use:"
  echo -e "\t> $0 -X"
  echo -e "\t> to run installation for real.\n\r"
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

if  [ $DEFAULT_CONTAINER_WORDPRESS_AUTOINSTALL = 1 ]
then
	echo -e "\n\r[INSTALL]---- --- -- - - -> WORDPRESS:"
	./$OS_DISTRIBUTION/install-wordpress.sh
fi

if  [ $DEFAULT_CONTAINER_NEXTCLOUD_AUTOINSTALL = 1 ]
then
	echo -e "\n\r[INSTALL]---- --- -- - - -> NEXTCLOUD:"
	./$OS_DISTRIBUTION/install-nextcloud.sh
fi

echo -e "\n\r[END] auto-install.\n\r";
