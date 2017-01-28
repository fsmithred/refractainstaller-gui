#!/usr/bin/env bash
# move-dir-mount-gui.sh

TEXTDOMAIN=refractainstaller-gui
TEXTDOMAINDIR=/usr/share/locale/

#set -x

# Send errors to the installer's error log.
error_log=$(grep error_log /etc/refractainstaller.conf | cut -d"\"" -f2)
exec 2>> "$error_log"


move_dir () {
# Select the directory you want to move to another partition
source_dir=$(yad --file-selection --directory --width=640 --height=640 \
	--title=$"Move directory" --text=$"Select the directory you want to move to another partition.")
	
	if [[ $? -ne 0 ]] ; then
		exit 0
	fi

# Make sure the user select selects source_dir from the new installation, mounted at /target


# The other partition (full device name, like /dev/sdb2)
destination_partition=$(find /dev -mindepth 1 -maxdepth 1  -name "*[sh]d[a-z][1-9]*" \
  | sort | awk '{print "\n" $0 }' \
  | yad --list   --title=$"/boot partition" --text=$"Select the destination partition for /${source_dir##*/}." \
  --separator="" --column ' ' --column $'Partitions' --height=380 --width=150 --button=$"OK":0)
  
  	if [[ $? -ne 0 ]] ; then
		exit 0
	fi

# Temporary mount point for the other partition, just to copy the files.
dirname="${source_dir##*/}"
temp_mountpoint="$(mktemp -d /tmp/$dirname.XXXXXX)"

echo "1 $source_dir"
echo "2 $destination_partition"
echo "3 $temp_mountpoint"

if [[ -z "$source_dir" || -z $destination_partition || -z $temp_mountpoint ]] ; then
	echo $"ERROR: Empty variable in $0"
	exit 1
fi


mount "$destination_partition" "$temp_mountpoint"

rsync -av /target"$source_dir"/ "$temp_mountpoint"/ | \
tee >(yad --progress --pulsate --width=350 --auto-close --title=$"Copying $source_dir to ${destination_partition}.")


idnum=$(blkid -c /dev/null -o value -s UUID "$destination_partition")
fstype=$(blkid -c /dev/null -o value -s TYPE "$destination_partition")

echo -e "UUID=$idnum\t$source_dir\t$fstype\tdefaults,noatime\t0\t2"  >> /target/etc/fstab

rm -rf /target"$source_dir"/*
umount "$temp_mountpoint"
rmdir "$temp_mountpoint"

ask_again

}

ask_again () {
	yad --question --title=$"Move another directory?" --text=$"Do you want to move another directory to a separate partition?" \
	--button=$"Yes":0 --button=$"No":1
	
	if [[ $? -eq 0 ]] ; then
		move_dir
	else
		exit 0
	fi
}

move_dir

exit 0

