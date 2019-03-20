#!/bin/bash

#Using getopts to parse the optional arguments

while getopts :s:S:d: opt; do
  case $opt in
    s)
      s=${OPTARG}

      # if condition to check that argument is passed properly
      if [[ $OPTARG = -* ]]; then
        ((OPTIND--))
        continue
      fi

    ;;
    S)
      S=${OPTARG}
      if [[ $OPTARG = -* ]]; then
        ((OPTIND--))
        continue
      fi
    ;;
    d)
      d=${OPTARG}
      if [[ $OPTARG = -* ]]; then
        ((OPTIND--))
        continue
      fi
     ;;
    *)
      echo "Usage: archive [−s size] [−S sDir] [−d dDir] < ext_list >"
      exit 1
    ;;
     
   esac
done
shift $((OPTIND-1))


extension=( "$@" )  #Saving the extensions in an array
if [ ${#extension[@]} -le "0" ]; then
	echo "Usage: archive [−s size] [−S sDir] [−d dDir] < ext_list >"
fi
givensize=${s}
source=${S}
destination=${d}

if [ -z "${s}" ]; then #Make size 0 if -s option not used
	givensize=0
fi

if [ -z "${S}" ]; then  #Make the current directory source directory if -S not used
	source=$(pwd)
fi

if [ -z "${d}" ]; then  #Make the destination directory same as source directory if -d not used
	destination=$source
fi	

if [[ -d "$source" && -d "$destination" ]]; then  #Checking if the source and destination are valid directories

	if [ ! -w $destination ]; then #Checking if the user has write permission for the destination
		echo "You don't have the write access for $destination"
		exit
	else

		cd $source
		if [ ! -e $destination/backup ]; then  #Creating a folder backup in the destination
			mkdir $destination/backup
		fi 

		for i in "${!extension[@]}"; do
			var="${extension[i]}"
			for file in `ls *.$var`; do
				if [ ! -r $file ]; then   #Checking if the user has read permissions for the file
					echo "You don't have the permissions"
					exit
				fi
				if [ -f $file ]; then
					
					size=`cat $file | wc -c`

      				if [[ $size -ge $givensize ]]; then #Checking if the size of file is greater than the size given by user if -s option is used

      					cp $file $destination/backup  #Copy files to folder backup
      					
      				else
      					echo "No files found below size $givensize"        		
      				fi

				else
					echo "Not a file"
				fi
			done
    	done
    	cd $destination
		tar -czf backUp.tar backup  #Create backup.tar for the folder backup
		rm -rf backup	#Delete all files in folder backup
    echo "Backup.tar created in $destination"
	fi
else
	echo "This is not a valid directory"
	exit
fi
