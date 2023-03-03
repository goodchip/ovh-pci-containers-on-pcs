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
   echo "usage: $0 [-n <name>] [-p <path>] [-b <backuppath>] [-s <sitesourcedir>] [-d <database>] [-r <dbrootpass>] [-h]"
   echo -e "\t-n : set name of container to restore (default: $DEFAULT_CONTAINER_WORDPRESS_NAME)"
   echo -e "\t-p : set path of pcs containers (default: $DEFAULT_PCI_INSTALL_PATH)"
   echo -e "\t-b : set path of backup source (default: $DEFAULT_PCI_BACKUP_PATH)"
   echo -e "\t-s : set source dir of container site (default: $DEFAULT_CONTAINER_WORDPRESS_SITE_SOURCEDIR)"
   echo -e "\t-d : set name of db source (default: $DEFAULT_CONTAINER_WORDPRESS_DB_DATABASE)"
   echo -e "\t-r : set rootpass of db source (default: $DEFAULT_CONTAINER_WORDPRESS_DB_ROOTPASS)"
   echo -e "\t-h : display this help"
   exit 1
}

# define patch function:
patch()
{
  sed -i 's`'$1'.*$`'$1$2'`g' $3
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
while getopts "n:p:b:s:d:r:h" opt
do
   case "$opt" in
      n ) CONTAINERS_NAME="$OPTARG" ;;
      p ) CONTAINERS_PATH="$OPTARG" ;;
      b ) BACKUP_PATH="$OPTARG" ;;
      s ) SITE_SOURCEDIR="$OPTARG" ;;
      d ) DB_DATABASE="$OPTARG" ;;
      r ) DB_ROOTPASS="$OPTARG" ;;      
      h ) help ;;
   esac
done

# check is run in root:
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

# update container name defaults if set:
if [ -z "$CONTAINERS_NAME" ]
then
   CONTAINERS_NAME=$DEFAULT_CONTAINER_WORDPRESS_NAME;
fi

# update container path defaults if set:
if [ -z "$CONTAINERS_PATH" ]
then
   CONTAINERS_PATH=$DEFAULT_PCI_INSTALL_PATH;
fi

# update backup path defaults if set:
if [ -z "$BACKUP_PATH" ]
then
   BACKUP_PATH=$DEFAULT_PCI_BACKUP_PATH;
fi

# update site source directory defaults if set:
if [ -z "$SITE_SOURCEDIR" ]
then
   SITE_SOURCEDIR=$DEFAULT_CONTAINER_WORDPRESS_SITE_SOURCEDIR;
fi

# update db database name defaults if set:
if [ -z "$DB_DATABASE" ]
then
   DB_DATABASE=$DEFAULT_CONTAINER_WORDPRESS_DB_DATABASE;
fi

# update db rootpass defaults if set:
if [ -z "$DB_ROOTPASS" ]
then
   DB_ROOTPASS=$DEFAULT_CONTAINER_WORDPRESS_DB_ROOTPASS;
fi

# start restore:
echo "Restore wordpress containers ...";

RESTORE_DESTINATION_PATH="$CONTAINERS_PATH$CONTAINERS_NAME/$SITE_SOURCEDIR"
BACKUP_SOURCE_TAR_FILE="$BACKUP_PATH$CONTAINERS_NAME".tar.gz
BACKUP_SOURCE_CONTAINERNAME="$CONTAINERS_NAME"-db
BACKUP_SOURCE_CONTAINERID="$(docker inspect --format='{{.Id}}' $BACKUP_SOURCE_CONTAINERNAME)"
BACKUP_SOURCE_SQL_FILE="$BACKUP_PATH$CONTAINERS_NAME".sql

# restore container wordpress site:
echo "Restore wordpress backup $BACKUP_SOURCE_TAR_FILE to site $RESTORE_DESTINATION_PATH ...";
cd "$RESTORE_DESTINATION_PATH"
tar -xzf "$BACKUP_SOURCE_TAR_FILE" -C .

# restore container wordpress database:
echo "Restore wordpress database from $BACKUP_SOURCE_SQL_FILE to container $BACKUP_SOURCE_CONTAINERNAME [ $BACKUP_SOURCE_CONTAINERID ] ...";
sudo cat "$BACKUP_SOURCE_SQL_FILE" | sudo docker exec -i "$BACKUP_SOURCE_CONTAINERID" /usr/bin/mysql -u root --password=$DB_ROOTPASS "$DB_DATABASE"

# end:
echo "Restore finished.";
