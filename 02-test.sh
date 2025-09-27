#!/bin/bash
AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-08e9a23d01ec385fb"
ZONE_ID="Z08088429XZJJZMETS6D"
DOMAIN="rajkumardaws.space"
for i in $@
do
     INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].InstanceId' --output text)
 #GET INSTACE PRIVATE IP
    if [ $i != "frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
        RECORD_NAME="$i.$DOMAIN" # mongodb.anilkathoju.space
     else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
        RECORD_NAME="$DOMAIN" # anilkathoju.space
    fi
 echo "$i: $IP Instance created"
#Updating records
aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --change-batch '
  {
    "Comment": "update record set"
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