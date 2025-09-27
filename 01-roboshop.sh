#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SD_ID="sg-08e9a23d01ec385fb"
ZONE_ID="Z08088429XZJJZMETS6D"
DOMIN_NAME="rajkumardaws.space"

for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SD_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)
    
    if [ "$instance" != "frontend" ]; then
    IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].[InstanceId,PrivateIpAddress]' --output text)
    RECORD_NAME="$instance.$DOMINE_NAME"   #it will be like mongodb.rajkumardaws.space
    else
    IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].[InstanceId,PublicIpAddress]' --output text)
    RECORD_NAME="$DOMINE_NAME"
    fi

    echo "$instance: $IP"

    aws route53 change-resource-record-sets \
        --hosted-zone-id $ZONE_ID \
        --change-batch '
        {
            "Comment": "Updating record set"
            ,"Changes": [{
            "Action"              : "UPSERT"
            ,"ResourceRecordSet"  : {
                "Name"              : "'$RECORD_NAME'"
                ,"Type"             : "A"
                ,"TTL"              : 1
                ,"ResourceRecords"  : [{
                    "Value"         : "'$IP'"
                }]
            }
            }]
        }
        '
done