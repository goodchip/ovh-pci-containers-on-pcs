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
   echo "usage: $0 [-o <osname>] [-h]"
   echo -e "\t-o : set osname image of your PCI (default: $DEFAULT_PCI_OS_DISTRIBUTION)"
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

# start auto backup:
echo -e "\n\r[BEGIN] auto-backup yours containers...";

if  [ $DEFAULT_CONTAINER_WORDPRESS_AUTOBACKUP = 1 ]
then
	echo -e "\n\r[BACKUP]---- --- -- - - -> WORDPRESS:"
	./$OS_DISTRIBUTION/backup-wordpress.sh
fi

#if  [ $DEFAULT_CONTAINER_NEXTCLOUD_AUTOBACKUP = 1 ]
#then
#	echo -e "\n\r[BACKUP]---- --- -- - - -> NEXTCLOUD:"
#	./$OS_DISTRIBUTION/backup-nextcloud.sh
#fi

echo -e "\n\r[END] auto-backup.\n\r";
