#!/bin/bash
set -eux
GITREMOTE="$1"
SYSTEMDARGS="${@:2}"
PWD=$(pwd)


# Usage
if [ $# -eq 0 ]; then
	echo 'Usage: ./testscript.sh <git_repo> <service_1> <service_2> ..'
	exit 1
fi


# Init
CLONEDIR=$(echo "$GITREMOTE" | awk -F '/' '{print $NF}' | awk -F '.' '{print $1}' )
git clone "$GITREMOTE" "$PWD/$CLONEDIR"


# File Listing
find "$PWD/$CLONEDIR/dir_test" -type d > "$PWD/$CLONEDIR/list_directories.txt"
find "$PWD/$CLONEDIR/dir_test" -name "*.md" > "$PWD/$CLONEDIR/list_markdown.txt"
grep -iow --exclude-dir=* 'override' "$PWD/$CLONEDIR"/dir_test/* 1> "$PWD/$CLONEDIR/list_overrides.txt"


# File Sorting
sort --key=1n "$PWD/$CLONEDIR"/data.txt > "$PWD/$CLONEDIR/data_sorted.txt"
awk '{a[$2]+=$4} END {for (i in a) print a[i]}' "$PWD/$CLONEDIR/data.txt" | sort -nk1 >"$PWD/$CLONEDIR/data_summed_and_sorted.txt"


# System Information
cat /proc/cpuinfo | grep -e 'model name' -e 'vendor_id' -e 'model' | head -3 > "$PWD/$CLONEDIR/system_cpu.txt"
free -hg | grep 'Mem' | awk '{print $6}' > "$PWD/$CLONEDIR/system_ram.txt"
ip addr | grep -w 'inet' | awk '{print $2}' > "$PWD/$CLONEDIR/system_ipv4.txt"
ps axo pcpu,pmem,args k -pcpu > "$PWD/$CLONEDIR/system_processes.txt"


# Services
mkdir -p "$CLONEDIR/services"
STATUSFILE="$CLONEDIR/services/status.txt"

if test -f "$STATUSFILE"; then
	rm "$STATUSFILE" 
fi
touch "$STATUSFILE"
chmod u=rwx,g=rw,o= "$STATUSFILE"

for service in $SYSTEMDARGS;
do 
	echo "[$service]" >> "$STATUSFILE"
	systemctl status "$service" >> "$STATUSFILE"
	echo '' >> "$STATUSFILE"
done


# Bonus Task ( Dependencies )
for service in $SYSTEMDARGS; 
do
	systemctl list-units --full -all | grep $service \
	&&\
	systemctl list-dependencies $service > "$CLONEDIR/$service.dependencies"
done


# List Files
du -sh --exclude="$CLONEDIR/sizes.txt" * > "$CLONEDIR/sizes.txt"


# Commit
git init
git add --all "$PWD/$CLONEDIR"

N=$(git shortlog -s | awk '{print $1}')
if [ $(expr $N % 2) == 0 ]; 
then
	git commit -m 'even update'
else
	git commit -m 'odd update'
fi

git push --repo="$GITREMOTE"


