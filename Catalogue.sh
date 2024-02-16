#!/bin/bash

ID=$(id -u)

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
    echo -e "$2 .... $R FAILED $N"
    exit 1
    else
    echo -e "$2 .... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
echo -e "$R ERROR :: you are not root user $N"
exit 1
else
echo -e "You are in $G ROOT $N access"
fi


dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling NodeJS 10"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "enabling NodeJS 18"

dnf install nodejs -y &>> $LOGFILE
 
VALIDATE $? "Installing NodeJS"

id roboshop &>> $LOGFILE
if [ $? -ne 0 ]
then
   useradd roboshop
   VALIDATE $? "Creation of roboshop user"
else
   echo -e "user 'roboshop' already exists .... $Y SKIPPING $N"

fi

mkdir -p /app &>> $LOGFILE

VALIDATE $? "Creating directory :app"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "Downloading the application code"

cd /app 

unzip -o /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "Unzipping the code the 'app' directory"

npm install &>> $LOGFILE

VALIDATE $? "downloading the dependencies"

cp /home/centos/Roboshop.shell-script/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "Setting up SystemD Catalogue Service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Loading the Catalogue Service"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "enabling the Catalogue Service"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "Starting the Catalogue Service"

cp /home/centos/Roboshop.shell-script/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Setting up MongoDB repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing MongoDB client"

mongo --host mongodb.bhpr.online </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "Loading schema"


