#!/bin/bash
# THIS SCRIPT QUERIES RACKSPACE AND AWS APIs TO GENERATE
# SERVER NAME, SERVE ID, PUBLIC IP, AND SERVER TYPE INTO
# A CSV FILE


# OUTPUT HEADING TO CSV FILE
echo "SERVER NAME, SERVER ID, PUBLIC IP, SERVER TYPE" >> AWS_RS_inventory.csv
echo " , , , " >> AWS_RS_inventory.csv

# RACKSPACE SERVER VARIABLES
RS_SERVER_NAME=`nova list --fields name | grep '|' | sort | cut -d ' ' -f4 | sed '$ d'`
RS_SERVER_ID=`nova list --fields name | grep '|' | sort | cut -d ' ' -f2 | sed '$ d'`
RS_PUBLIC_IP=`nova list --fields accessIPv4 | grep '|' | sort | cut -d ' ' -f4 | sed '$ d'`
RS_SERVER_TYPE=`nova list --fields flavor | grep '|' | sort | cut -d ' ' -f4 | sed '$ d' | sed -e 's/^[ \t]*//'`

# AMAZON AWS SERVER VARIABLES
AWS_SERVER_NAME="$(aws ec2 describe-instances --filter Name=instance-state-name,Values=running --query 'Reservations[].Instances[].[InstanceId,InstanceType,PublicIpAddress,Tags[?Key==`Name`]| [0].Value]' --output table | grep '|' | grep -v DescribeInstances | cut -d '|' -f5 | sed -e 's/^[ \t]*//')"
AWS_INSTANCE_ID="$(aws ec2 describe-instances --filter Name=instance-state-name,Values=running --query 'Reservations[].Instances[].[InstanceId,InstanceType,PublicIpAddress,Tags[?Key==`Name`]| [0].Value]' --output table | grep '|' | grep -v DescribeInstances | cut -d '|' -f2 | sed -e 's/^[ \t]*//')"
AWS_PUBLIC_IP="$(aws ec2 describe-instances --filter Name=instance-state-name,Values=running --query 'Reservations[].Instances[].[InstanceId,InstanceType,PublicIpAddress,Tags[?Key==`Name`]| [0].Value]' --output table | grep '|' | grep -v DescribeInstances | cut -d '|' -f4 | sed -e 's/^[ \t]*//')"
AWS_SERVER_TYPE="$(aws ec2 describe-instances --filter Name=instance-state-name,Values=running --query 'Reservations[].Instances[].[InstanceId,InstanceType,PublicIpAddress,Tags[?Key==`Name`]| [0].Value]' --output table | grep '|' | grep -v DescribeInstances | cut -d '|' -f3 | sed -e 's/^[ \t]*//')"

# OUTPUT TO CSV FILE 
paste -d, <(echo "$RS_SERVER_NAME") <(echo "$RS_SERVER_ID") <(echo "$RS_PUBLIC_IP") <(echo "$RS_SERVER_TYPE") >> AWS_RS_inventory.csv
paste -d, <(echo "$AWS_SERVER_NAME") <(echo "$AWS_INSTANCE_ID") <(echo "$AWS_PUBLIC_IP") <(echo "$AWS_SERVER_TYPE") >> AWS_RS_inventory.csv
