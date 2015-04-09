#!/bin/bash

# Parameterize Build with jenkins API:

while read line
do

  	EMAIL=`echo $line | cut -d ',' -f3 | grep '@'`
  	echo $EMAIL

	# Get token from here: http://jenkins.server.com/user/jdoe/configure

  	curl -X POST 'http://api:**************************************@jenkins.server.com/view/Ops/job/Delete%20VPN%20Credentials/buildWithParameters?server=vpn.server.com&user_email='$EMAIL''

  	sleep 20

done < file.csv
