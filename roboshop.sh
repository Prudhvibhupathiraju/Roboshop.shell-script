#!/bin/bash

AMI=ami-0f3c7d07486cad139
SG=sg-034af918babda9baf
Instances=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "cart" "user" "shipping" "payments" "dispatch" "web")
ZONE_ID=Z04351902WY9G4CTL518C
DOMAIN_NAME=bhpr.online

for i in ${Instances[@]}
do
echo "instance is $i"
if [ $i == "MongoDB" ]  || [ $i == "MySQL" ]  || [ $i == "Shipping" ]
then
Instance_type="t3.small"
else
Instance_type="t2.micro"
fi
IP_ADDRESS=$(aws ec2 run-instances --image-id $AMI --instance-type $Instance_type --security-group-ids $SG --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text) 
echo "$i : $IP_ADDRESS"
 aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Creating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$i'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP_ADDRESS'"
            }]
        }
        }]
    }
        '
done