#!/bin/bash
#
# The following script will destroy your AWS EC2 instance.
#
# Pass the Instance ID as a parameter
#
# henryfranco.com/2015/01/12/setting-up-aws-cli-on-centos/
#

echo 'Current ec2 instances:'
aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId]' --output text

INSTANCE=$1

if [ $# -lt 1 ]; then
        echo "./aws_destroy_ec2.sh instance-id"
	exit
fi

aws ec2 terminate-instances --instance-ids $INSTANCE

exit
