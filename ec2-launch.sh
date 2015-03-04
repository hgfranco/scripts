#! /bin/bash

clear

echo "Enter your image ID (starting after ami-): "
read image
echo "Your AMI ID is: $image"

#ec2-describe-keypairs
if [ -f "/usr/bin/aws" ]; then
	aws ec2 describe-key-pairs
fi

echo " "
echo "Enter one of your available keypairs (name): "
read keypair
echo "Your selected keypair is: $keypair"

echo "Enter a security group (default): "
read  group
echo "Your selected group is: $group" 

aws ec2 run-instances --image-id ami-$image --count 1 --instance-type t1.micro --key-name $keypair --security-groups $group




