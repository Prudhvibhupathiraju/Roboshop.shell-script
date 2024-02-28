#!/bin/bash

AMI=ami-0f3c7d07486cad139
SG=sg-034af918babda9baf
Instances=("MongoDB" "Redis" "MySQL" "RabbitMQ" "Catalogue" "Cart" "User" "Shipping" "Payments" "Dispatch" "Web")

for i in ${Instances[@]}
do
if [ $i == "MongoDB" ]  || [ $i == "MySQL" ]  || [ $i == "Shipping" ]
then
Instance_type="t3.small"
else
Instance_type="t2.micro"
fi
aws ec2 run-instances --image-id ami-0f3c7d07486cad139 --instance-type $Instance_type --security-group-ids sg-034af918babda9baf
done