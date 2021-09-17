#!/bin/sh

sudo -i

# upgrade distribution:
apt-get -y update && sudo apt-get -y upgrade

# partionning additional disk:
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sdb
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk 
    # default - end at bottom of disk
  w # write the partition table
  q # and we're done
EOF

# format partition of additional disk:
mkfs.ext4 /dev/sdb1

# automount partition of additional disk:
mkdir /mnt/containers
mount /dev/sdb1 /mnt/containers/
DISKUUID="$(blkid -s UUID -o value /dev/sdb1)"
echo "UUID="$DISKUUID"    /mnt/containers/    ext4    nofail    0    0" | tee -a /etc/fstab
