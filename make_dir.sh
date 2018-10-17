#!/bin/bash

# make sure file is passed
if [ $# -lt 1 ]; then
        echo "Usage: ./make_dir.sh FILE_NAME"
        exit 127
fi

# assign file to variable
FILE=$1

# assign date variables
YEAR=`date +%G`
MONTH=`date +%m`
DAY=`date +%d`
HOUR=`date +%I`
UNIX_TIME=`date +%s`
DATE_DIR=$YEAR/$MONTH/$DAY/$HOUR

# create directory function
create_directory () {
  mkdir -p $DATE_DIR
}

# copy file function
copy_file () {
  cp $FILE $DATE_DIR/$FILE.$UNIX_TIME
}

# call functions
create_directory
copy_file
