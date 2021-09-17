#!/bin/sh

helpFunction()
{
   echo ""
   echo "Usage: $0 -docker-compose-version VERSION"
   echo -e "\t-docker-compose-version  : set version of docker-compose to install (optional)"
   echo -e "\t-help                    : display this help"
   exit 1
}

while getopts "docker-compose-version:" opt
do
   case "$opt" in
      docker-compose-version ) DOCKER_COMPOSE_VERSION="$OPTARG" ;;
      h ) helpFunction ;;      
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$DOCKER_COMPOSE_VERSION" ]
then
   $DOCKER_COMPOSE_VERSION = 1.19.0
fi

echo "$DOCKER_COMPOSE_VERSION"
