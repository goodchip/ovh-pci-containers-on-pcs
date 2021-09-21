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
   echo "usage: $0 [-n <name>] [-p <path>] [-b <backuppath>] [-s <sitesourcedir>] [-x <siteexcludedir>] [-d <database>] [-r <dbrootpass>] [-h]"
   echo -e "\t-n : set name of container to backup (default: $DEFAULT_CONTAINER_WORDPRESS_NAME)"
   echo -e "\t-p : set path of pcs containers (default: $DEFAULT_PCS_DEVICE_MOUNT_PATH)"
   echo -e "\t-b : set path of backup destination (default: $DEFAULT_PCS_DEVICE_BACKUP_PATH)"
   echo -e "\t-s : set source dir of container site (default: $DEFAULT_CONTAINER_WORDPRESS_SITE_SOURCEDIR)"
   echo -e "\t-x : set exclude dir of container site (default: $DEFAULT_CONTAINER_WORDPRESS_SITE_EXCLUDEDIRS)"
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
while getopts "n:p:b:s:x:d:r:h" opt
do
   case "$opt" in
      n ) CONTAINERS_NAME="$OPTARG" ;;
      p ) CONTAINERS_PATH="$OPTARG" ;;
      b ) BACKUP_PATH="$OPTARG" ;;
      s ) SITE_SOURCEDIR="$OPTARG" ;;
      x ) SITE_EXCLUDEDIRS="$OPTARG" ;;
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
   CONTAINERS_PATH=$DEFAULT_PCS_DEVICE_MOUNT_PATH;
fi

# update backup path defaults if set:
if [ -z "$BACKUP_PATH" ]
then
   BACKUP_PATH=$DEFAULT_PCS_DEVICE_BACKUP_PATH;
fi

# update site source directory defaults if set:
if [ -z "$SITE_SOURCEDIR" ]
then
   SITE_SOURCEDIR=$DEFAULT_CONTAINER_WORDPRESS_SITE_SOURCEDIR;
fi

# update site exclude directory defaults if set:
if [ -z "$SITE_EXCLUDEDIRS" ]
then
   SITE_EXCLUDEDIRS=$DEFAULT_CONTAINER_WORDPRESS_SITE_EXCLUDEDIRS;
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

# start installation:
echo "Backup wordpress containers ...";

BACKUP_SOURCE_PATH="$CONTAINERS_PATH$CONTAINERS_NAME/$SITE_SOURCEDIR"
BACKUP_DESTINATION_TAR_FILE="$BACKUP_PATH$CONTAINERS_NAME".tar.gz
BACKUP_SOURCE_CONTAINERNAME="$CONTAINERS_NAME"-db
BACKUP_SOURCE_CONTAINERID="$(docker inspect --format='{{.Id}}' $BACKUP_SOURCE_CONTAINERNAME)"
BACKUP_DESTINATION_SQL_FILE="$BACKUP_PATH$CONTAINERS_NAME".sql

BACKUP_EXCLUDE_ARG=""
BACKUP_EXCLUDE_INFOS=""
if [ "$SITE_EXCLUDEDIRS" != "" ]
then
	BACKUP_EXCLUDE_INFOS="excluding:"
	for SCAN_EXCLUDE_DIR in ${SITE_EXCLUDEDIRS//,/ }
	do
	    BACKUP_EXCLUDE_ARG=$BACKUP_EXCLUDE_ARG" --exclude=./${SCAN_EXCLUDE_DIR%/} "
	    BACKUP_EXCLUDE_INFOS=$BACKUP_EXCLUDE_INFOS" ./${SCAN_EXCLUDE_DIR%/}"
	done
fi

# prepare containers backup directory:
mkdir -p "$BACKUP_PATH"
#chown debian:debian /mnt/containers/backups/

# backup container wordpress site:
echo "Backup wordpress site $BACKUP_SOURCE_PATH to $BACKUP_DESTINATION_TAR_FILE $BACKUP_EXCLUDE_INFOS ...";
cd "$BACKUP_SOURCE_PATH"
tar -czf "$BACKUP_DESTINATION_TAR_FILE" $BACKUP_EXCLUDE_ARG .
ls -l $BACKUP_PATH$CONTAINERS_NAME*.tar.gz

# backup container wordpress database:
echo "Backup wordpress database from container $BACKUP_SOURCE_CONTAINERNAME [ $BACKUP_SOURCE_CONTAINERID ] to $BACKUP_DESTINATION_SQL_FILE ...";
docker exec "$BACKUP_SOURCE_CONTAINERID" /usr/bin/mysqldump -u root --password=$DB_ROOTPASS "$DB_DATABASE" > "$BACKUP_DESTINATION_SQL_FILE"
ls -l $BACKUP_PATH$CONTAINERS_NAME*.sql

# end:
echo "Backup finished.";
