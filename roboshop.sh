#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo -e "the script has started executing at  $TIMESTAMP " &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
    echo -e "$2 .... $R FAILED TO CREATE $N"
    
    else
    echo -e "$2 .... $G SUCCESSFULLY CREATED $N"
    fi
}

AMI=ami-0f3c7d07486cad139
SG=sg-034af918babda9baf
Instances=("MongoDB" "Redis" "MySQL" "RabbitMQ" "Catalogue" "Cart" "User" "Shipping" "Payments" "Dispatch" "Web")

for i in ${Instances[@]}
do
echo "instance is $i"
if [ $i == "MongoDB" ]  || [ $i == "MySQL" ]  || [ $i == "Shipping" ]
then
Instance_type="t3.small"
else
Instance_type="t2.micro"
fi
aws ec2 run-instances --image-id ami-0f3c7d07486cad139 --instance-type $Instance_type --security-group-ids sg-034af918babda9baf --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" &>> $LOGFILE
VALIDATE $? "Instance $i"
done