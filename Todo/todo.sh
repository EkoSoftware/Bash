#!/bin/bash
#Inspired by Alexander Epstein';s "todo" https://github.com/alexanderepstein
set -e

	

# [ Variables ]
TODODIR=~/.todo
TODOARCHIVE=~/.todo/archive
LIST=~/.todo/list.txt


# [ Initializing Folders && Files ]
mkdir -vp $TODOARCHIVE
if [ ! -f $LIST ]; then touch $LIST; fi


# [ Functions ]
#----------------------------------------------------
Help()
{
echo '	
[ Todo ]
Description: A Simple program for taking notes.
Usage: todo [parameters] [notes]
	-l		:Print List
	-r #	:Remove Task with number # 
	-A    :Archive the current list with and Saves it to ~/.todo/archive
	-D    :Initialize a todo-list specifically for Today.
'
}
#----------------------------------------------------
function printlist(){
	COUNT=1
	while IFS= read -r line
	do
			echo "[$COUNT] $line"
			((COUNT+=1))
	done < $LIST
}


# =================== #
## [ Main Function ] ##
# =================== #

if (( $# < 1 )); then printlist && exit 0 || exit 1; fi
if [[ $1 == help ]]; then Help && exit 0 || exit 1; fi
NOTES=${*:1}
while getopts "ADlr:" opt; do
	case "$opt" in

		A) 
			if (($# < 3)); then echo 'Usage for Archiving: "todo -S filename"'; fi
			DATE=$(date "+%y%m%d__%A")
			cp $LIST "$TODOARCHIVE/$DATE{_$2}"
			;; 

		D) 			
			DATE=$(date "+%y%m%d__%A")
			DAILYLIST=~/.todo_day_$DATE
			touch "$DAILYLIST"
			;;
		
		r)		
			L=$2
			#if [[ ! $# > 1 ]]; then echo '! Please specify lines to remove' && exit 1; fi
			echo "$L"
			sed -i 'd'"$2" $LIST
			;;
		*)	
	 esac
done

# Default if no parameter is given is to add whatever comes after "todo" in terminal
echo "$(date "+%H:%M") $NOTES" >> $LIST
