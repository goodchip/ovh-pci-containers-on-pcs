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
   echo "usage: $0 [-u <urldomains>] [-c <cmsimage>] [-v <cmsversion>] [-s <sgbdimage>] [-g <sgbdversion>] [-d <database>] [-x <prefix>] [-j <dbusername>] [-k <dbuserpass>] [-r <dbrootpass>] [-l <logsmaxsize>] [-e <email>] [-p <path>] [-n <name>] [-w <network>] [-h]"
   echo -e "\t-u : set urldomains to listen (default: $DEFAULT_CONTAINER_WORDPRESS_SITE_DOMAINS)"
   echo -e "\t-c : set cms image to install (default: $DEFAULT_CONTAINER_WORDPRESS_SITE_IMAGE)"
   echo -e "\t-v : set version to install (default: $DEFAULT_CONTAINER_WORDPRESS_SITE_VERSION)"
   echo -e "\t-s : set sgbd image to install (default: $DEFAULT_CONTAINER_WORDPRESS_DB_IMAGE)"
   echo -e "\t-g : set sgbd version to install (default: $DEFAULT_CONTAINER_WORDPRESS_DB_VERSION)"
   echo -e "\t-d : set database name to use (default: $DEFAULT_CONTAINER_WORDPRESS_DB_DATABASE)"
   echo -e "\t-x : set db table prefix to use (default: $DEFAULT_CONTAINER_WORDPRESS_DB_PREFIX)"
   echo -e "\t-j : set db username to use (default: $DEFAULT_CONTAINER_WORDPRESS_DB_USERNAME)"
   echo -e "\t-k : set db userpass to use (default: $DEFAULT_CONTAINER_WORDPRESS_DB_USERPASS)"
   echo -e "\t-r : set db_rootpass to use (default: $DEFAULT_CONTAINER_WORDPRESS_DB_ROOTPASS)"
   echo -e "\t-l : set logs max size to use (default: $DEFAULT_CONTAINER_WORDPRESS_LOGSMAXSIZE)"
   echo -e "\t-e : set email for certificat (default: $DEFAULT_CONTAINER_WEBPROXY_EMAIL)"
   echo -e "\t-p : set path of container to install (default: $DEFAULT_PCS_DEVICE_MOUNT_PATH)"
   echo -e "\t-n : set name of container to install (default: $DEFAULT_CONTAINER_WORDPRESS_NAME)"
   echo -e "\t-w : set name of proxy network to link (default: $DEFAULT_CONTAINER_WEBPROXY_NETWORK)"   
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
while getopts "u:c:v:s:g:d:x:j:k:r:l:e:p:n:w:h" opt
do
   case "$opt" in
      u ) SITE_DOMAINS="$OPTARG" ;;
      c ) SITE_IMAGE="$OPTARG" ;;
      v ) SITE_VERSION="$OPTARG" ;;
      s ) DB_IMAGE="$OPTARG" ;;
      g ) DB_VERSION="$OPTARG" ;;
      d ) DB_DATABASE="$OPTARG" ;;
      x ) DB_PREFIX="$OPTARG" ;;
      j ) DB_USERNAME="$OPTARG" ;;
      k ) DB_USERPASS="$OPTARG" ;;
      r ) DB_ROOTPASS="$OPTARG" ;;      
      l ) LOGSMAXSIZE="$OPTARG" ;;
      e ) EMAIL="$OPTARG" ;;
      p ) CONTAINERS_PATH="$OPTARG" ;;
      n ) CONTAINERS_NAME="$OPTARG" ;;
      w ) WEBPROXY_NETWORK="$OPTARG" ;;
      h ) help ;;
   esac
done

# check is run in root:
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

# update site domains defaults if set:
if [ -z "$SITE_DOMAINS" ]
then
   SITE_DOMAINS=$DEFAULT_CONTAINER_WORDPRESS_SITE_DOMAINS;
fi

# update site image defaults if set:
if [ -z "$SITE_IMAGE" ]
then
   SITE_IMAGE=$DEFAULT_CONTAINER_WORDPRESS_SITE_IMAGE;
fi

# update site version defaults if set:
if [ -z "$SITE_VERSION" ]
then
   SITE_VERSION=$DEFAULT_CONTAINER_WORDPRESS_SITE_VERSION;
fi

# update db image defaults if set:
if [ -z "$DB_IMAGE" ]
then
   DB_IMAGE=$DEFAULT_CONTAINER_WORDPRESS_DB_IMAGE;
fi

# update db version defaults if set:
if [ -z "$DB_VERSION" ]
then
   DB_VERSION=$DEFAULT_CONTAINER_WORDPRESS_DB_VERSION;
fi

# update db database name defaults if set:
if [ -z "$DB_DATABASE" ]
then
   DB_DATABASE=$DEFAULT_CONTAINER_WORDPRESS_DB_DATABASE;
fi

# update db prefix defaults if set:
if [ -z "$DB_PREFIX" ]
then
   DB_PREFIX=$DEFAULT_CONTAINER_WORDPRESS_DB_PREFIX;
fi

# update db username defaults if set:
if [ -z "$DB_USERNAME" ]
then
   DB_USERNAME=$DEFAULT_CONTAINER_WORDPRESS_DB_USERNAME;
fi

# update db userpass defaults if set:
if [ -z "$DB_USERPASS" ]
then
   DB_USERPASS=$DEFAULT_CONTAINER_WORDPRESS_DB_USERPASS;
fi

# update db rootpass defaults if set:
if [ -z "$DB_ROOTPASS" ]
then
   DB_ROOTPASS=$DEFAULT_CONTAINER_WORDPRESS_DB_ROOTPASS;
fi

# update logmaxsize defaults if set:
if [ -z "$LOGSMAXSIZE" ]
then
   LOGSMAXSIZE=$DEFAULT_CONTAINER_WORDPRESS_LOGSMAXSIZE;
fi

# update email defaults if set:
if [ -z "$EMAIL" ]
then
   EMAIL=$DEFAULT_CONTAINER_WEBPROXY_EMAIL;
fi

# update container path defaults if set:
if [ -z "$CONTAINERS_PATH" ]
then
   CONTAINERS_PATH=$DEFAULT_PCS_DEVICE_MOUNT_PATH;
fi

# update container name defaults if set:
if [ -z "$CONTAINERS_NAME" ]
then
   CONTAINERS_NAME=$DEFAULT_CONTAINER_WORDPRESS_NAME;
fi

# update container name defaults if set:
if [ -z "$WEBPROXY_NETWORK" ]
then
   WEBPROXY_NETWORK=$DEFAULT_CONTAINER_WEBPROXY_NETWORK;
fi

# start installation:
echo "Installing wordpress on $CONTAINERS_PATH$CONTAINERS_NAME/ ...";

# prepare containers installation:
cd /mnt/containers/

# install container wordpress Automation:
git clone "$DEFAULT_CONTAINER_WORDPRESS_GIT" "$CONTAINERS_NAME"

# locate into container directory:
echo "Configuring wordpress container ...";
cd "$CONTAINERS_NAME"

# patch docker-compose.yml for bug if more one '/var/lib/mysql' is declared (multiple docker configuration):
patch '{DB_FILES}:/var/lib/' 'mysql-'$CONTAINERS_NAME 'docker-compose.yml'

# make own environnement variables in patching defaults input founded in .env.example:
cp '.env.example' '.env'
patch 'COMPOSE_PROJECT_NAME=' $CONTAINERS_NAME '.env'
patch 'CONTAINER_SITE_NAME=' $SITE_IMAGE'-site' '.env'
patch 'CONTAINER_DB_NAME=' $SITE_IMAGE'-db' '.env'
patch 'DOMAINS=' $SITE_DOMAINS '.env'
patch 'SITE_IMAGE=' $SITE_IMAGE '.env'
patch 'SITE_VERSION=' $SITE_VERSION '.env'
patch 'DB_IMAGE=' $DB_IMAGE '.env'
patch 'DB_VERSION=' $DB_VERSION '.env'
patch 'MYSQL_DATABASE=' $DB_DATABASE '.env'
patch 'WORDPRESS_TABLE_PREFIX=' $DB_PREFIX '.env'
patch 'MYSQL_USER=' $DB_USERNAME '.env'
patch 'MYSQL_PASSWORD=' $DB_USERPASS '.env'
patch 'MYSQL_ROOT_PASSWORD=' $DB_ROOTPASS '.env'
patch 'LOGGING_OPTIONS_MAX_SIZE=' $LOGSMAXSIZE '.env'
patch 'LETSENCRYPT_EMAIL=' $EMAIL '.env'
patch 'NETWORK=' $WEBPROXY_NETWORK '.env'

# launch containers:
echo "Launch wordpress container ...";
docker-compose up -d

# end:
echo "Installation finished.";
