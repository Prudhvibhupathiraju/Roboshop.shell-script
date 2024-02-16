#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo -e "the script has started executing at $Y  $TIMESTAMP  $N" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
    echo -e "$2 .... $R FAILED $N"
    
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

dnf install python36 gcc python3-devel -y &>> $LOGFILE

VALIDATE $? "Installing Python 3.6"

id roboshop &>> $LOGFILE
if [ $? -ne 0 ]
then
   useradd roboshop &>> $LOGFILE
   VALIDATE $? "Creation of roboshop user"
else
   echo -e "user 'roboshop' already exists .... $Y SKIPPING $N"

fi

mkdir -p /app &>> $LOGFILE

VALIDATE $? "Making a directory :app"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE

VALIDATE $? "Downloading the code"

cd /app &>> $LOGFILE

VALIDATE $? "Changing the directory :app"

unzip /tmp/payment.zip &>> $LOGFILE

VALIDATE $? "Unzipping the code"

pip3.6 install -r requirements.txt &>> $LOGFILE

VALIDATE $? "Installing dependencies"

cp /home/centos/Roboshop.shell-script/payment.service /etc/systemd/system/payment.service &>> $LOGFILE

VALIDATE $? "Setuping up SystemD Payment Service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Loading the service"

systemctl enable payment &>> $LOGFILE

VALIDATE $? "enabling the service"

systemctl start payment &>> $LOGFILE

VALIDATE $? "Starting the service"

