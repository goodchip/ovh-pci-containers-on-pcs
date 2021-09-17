#!/bin/bash
##############################################
#                                            #
# File of git repo:                          #
# goodchip/ovh-pci-containers-on-pcs/master/ #
#                                            #
# Licence MIT                                #
#                                            #
##############################################

# define default variables:
DEFAULT_DISK_NAME="/dev/sdb";
DEFAULT_PART_NUMBER=1;
DEFAULT_MOUNT_PATH="/mnt/containers/"

# define help function:
help()
{
   echo ""
   echo "usage: $0 [-d <disk>] [-p <partition>] [-h]"
   echo -e "\t-d : set disk to install (default: $DEFAULT_DISK_NAME)"
   echo -e "\t-p : set partition to install (default: $DEFAULT_PART_NUMBER)"
   echo -e "\t-m : set mount path to install (default: $DEFAULT_MOUNT_PATH)"
   echo -e "\t-h : display this help"
   exit 1
}

# scan arguments:
while getopts "d:p:m:h" opt
do
   case "$opt" in
      d ) DISK_NAME="$OPTARG" ;;
      p ) PART_NUMBER="$OPTARG" ;;
      m ) MOUNT_PATH="$OPTARG" ;;
      h ) help ;;
   esac
done

# check is run in root:
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

# update disk name defaults if set:
if [ -z "$DISK_NAME" ]
then
   DISK_NAME=$DEFAULT_DISK_NAME;
fi

# update partition number defaults if set:
if [ -z "$PART_NUMBER" ]
then
   PART_NUMBER=$DEFAULT_PART_NUMBER;
fi

# update mount path defaults if set:
if [ -z "$MOUNT_PATH" ]
then
   MOUNT_PATH=$DEFAULT_MOUNT_PATH;
fi

# start installation:
echo "Installing $DISK_NAME$PART_NUMBER on $MOUNT_PATH ...";

# partionning additional disk:
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk "$DISK_NAME"
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  $PART_NUMBER # partition number $PART_NUMBER
    # default - start at beginning of disk 
    # default - end at bottom of disk
  w # write the partition table
  q # and we're done
EOF

# format partition of additional disk:
mkfs.ext4 "$DISK_NAME$PART_NUMBER"

# automount partition of additional disk:
mkdir "$MOUNT_PATH"
mount "$DISK_NAME$PART_NUMBER" "$MOUNT_PATH"
DISK_UUID="$(blkid -s UUID -o value $DISK_NAME$PART_NUMBER)"
echo "UUID="$DISK_UUID"    $MOUNT_PATH    ext4    nofail    0    0" | tee -a /etc/fstab

# end:
echo "Installation finished.";
