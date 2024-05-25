#!/bin/bash
set -eu
PARAMETERS="--progress --update --ignore-existing --links --ignore-errors"

SOURCES="/etc/backup/cloud"
EXCLUDE="-exclude=/home/milne/.config/Docker* --exclude=/home/milne/.config/libvirt/storage/autostart/gnome-boxes.xml"



# Backup .config	
DOTFILES='/home/milne/.config'
rclone sync $DOTFILES drive: $PARAMETERS '--exclude=google-chrome/* --exclude=Code/* --exclude=Docker\ Desktop/*'

# Backup rest
while IFS= read -r line;
do
	echo "Backing up $line to drive:"
	rclone sync $PARAMETERS $line drive:
done < $SOURCES



#rclone sync $DOTFILES drive: $PARAMETERS '--exclude=google-chrome/* --exclude=Code/* --exclude=Docker\ Desktop/*'

