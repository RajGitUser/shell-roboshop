#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SD_ID="sg-08e9a23d01ec385fb"

for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-08e9a23d01ec385fb --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=AWStest}]" --query 'Instances[0].InstanceId' --output text)
    
    if [ "$instance" != "frontend" ]; then
    IP=$(aws ec2 describe-instances --instance-ids i-0fc90590e97f862c3 --query 'Reservations[0].Instances[0].[InstanceId,PrivateIpAddress]' --output text)
    else
    IP=$(aws ec2 describe-instances --instance-ids i-0fc90590e97f862c3 --query 'Reservations[0].Instances[0].[InstanceId,PublicIpAddress]' --output text)

    fi

    echo $instance $IP

done