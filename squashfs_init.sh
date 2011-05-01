#!/bin/bash

#Created by Brando56894 from the Arch Linux Community
#Based off of a tutorial found on the Gentoo forums
#This script comes with ABSOLUTELY NO WARRANTY use it at your risk!

#checks to see if the user is root
if [[ $UID != "0" ]];then
     echo "This script MUST be run as root"
     echo "Please login to the root account"
     echo "And re-execute this script"
     exit
fi

echo "This script will place /usr into a squashfs for faster loading"
read -p "Press enter to continue"

#installs aufs2 and squashfs tools
pacman -Sy --needed aufs2 aufs2-util squashfs-tools

#creates the directories that /usr will be squashed into
echo
mkdir -p /squashed/usr/{ro,rw}

#compress /usr into a squashfile with a 64k blocksize
if [[ -e /var/lib/pacman/db.lck ]]; then
  echo "Pacman seems to be in use, please wait for it to finish"
  echo "before you create the squashfs image or else nasty things"
  echo "will most likely happen to your system"
else
  mksquashfs /usr /squashed/usr/usr.sfs -b 65536
fi

#adds the filesystems to fstab
echo "Please add the following lines to your /etc/fstab"
echo
echo "/squashed/usr/usr.sfs    /squashed/usr/ro squashfs     loop,ro 0 0" 
echo "usr /usr  aufs  br:/squashed/usr/rw:/squashed/usr/ro 0 0"
echo
read -p "Press any key to continue after you finished editing the file"
echo

#probably not needed since the umount -a option should do it but left it in case it is needed
#unmounts the squashfs during shutdown
#echo "Please add the following lines to /etc/rc.shutdown"
#echo "under the Unmounting Filesystems section"
#echo
#echo "umount -l /usr"
#echo "umount -l /squashed/usr/ro"
#echo
#read -p "Press any key to continue after you finished editing the file"
#echo

#move the /usr folder instead of deleting it
mv /usr /usr.old
mkdir /usr

echo "Would you like to set up a cron job to remake the image"
echo "Every three weeks? (y or n)"
read choice
if [[ choice == "y" ]];then
    #sets up a cron job to remake the image every three weeks
    echo "Please add the following to your crontab"
    echo "and place remake-squash.job in /etc/cron.monthly"
    echo 
    echo "It will remake the sqashfs image every 21 days at noon"
    echo
    echo "0 12 21 * * bash /etc/cron.monthly/remake-squashfs.job"
fi
