#!/bin/bash

source="$1"
destination="$2"
size=$(rclone size drive: | grep MiB | awk '{print $3}' | awk -F'.' '{print $1}')
pid=99999
monitor(){
	clear
	pid=$(pgrep 'rclone "$')
	usage=$(du -sh $destination | awk '{print $1}' | cut -d'.' -f1 | cut -d'M' -f1 )

	echo "Progress: $usage MiB / $size MiB"
	sleep 1
}
monitor
rclone sync "$source" "$destination" & while [ pid ]; do monitor; done
