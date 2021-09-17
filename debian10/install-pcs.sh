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
   echo "usage: $0 [-d <device>] [-u <unit>] [-p <path>] [-h]"
   echo -e "\t-d : set device to install containers (default: $DEFAULT_PCS_DEVICE_NAME)"
   echo -e "\t-u : set unit partition to install containers (default: $DEFAULT_PCS_DEVICE_UNIT)"
   echo -e "\t-p : set path to mount containers (default: $DEFAULT_PCS_DEVICE_MOUNT_PATH)"
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
while getopts "d:u:p:h" opt
do
   case "$opt" in
      d ) DEVICE_NAME="$OPTARG" ;;
      u ) DEVICE_UNIT="$OPTARG" ;;
      p ) DEVICE_MOUNT_PATH="$OPTARG" ;;
      h ) help ;;
   esac
done

# check is run in root:
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

# update disk name defaults if set:
if [ -z "$DEVICE_NAME" ]
then
   DEVICE_NAME=$DEFAULT_PCS_DEVICE_NAME;
fi

# update partition number defaults if set:
if [ -z "$DEVICE_UNIT" ]
then
   DEVICE_UNIT=$DEFAULT_PCS_DEVICE_UNIT;
fi

# update mount path defaults if set:
if [ -z "$DEVICE_MOUNT_PATH" ]
then
   DEVICE_MOUNT_PATH=$DEFAULT_PCS_DEVICE_MOUNT_PATH;
fi

# start installation:
echo "Installing $DEVICE_NAME$DEVICE_UNIT on $DEVICE_MOUNT_PATH ...";

# partionning additional disk:
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk "$DEVICE_NAME"
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  $DEVICE_UNIT # partition number $DEVICE_UNIT
    # default - start at beginning of disk 
    # default - end at bottom of disk
  w # write the partition table
  q # and we're done
EOF

# format partition of additional disk:
mkfs.ext4 "$DEVICE_NAME$DEVICE_UNIT"

# automount partition of additional disk:
mkdir "$DEVICE_MOUNT_PATH"
mount "$DEVICE_NAME$DEVICE_UNIT" "$DEVICE_MOUNT_PATH"
DISK_UUID="$(blkid -s UUID -o value $DEVICE_NAME$DEVICE_UNIT)"
echo "UUID="$DISK_UUID"    $DEVICE_MOUNT_PATH    ext4    nofail    0    0" | tee -a /etc/fstab

# end:
echo "Installation finished.";
