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

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE

VALIDATE $? "Downloading the application code"

cd /app 

unzip -o /tmp/cart.zip &>> $LOGFILE

VALIDATE $? "Unzipping the code the 'app' directory"

npm install &>> $LOGFILE

VALIDATE $? "downloading the dependencies"

cp /home/centos/Roboshop.shell-script/cart.service /etc/systemd/system/cart.service &>> $LOGFILE

VALIDATE $? "Setting up SystemD cart Service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Loading the cart Service"

systemctl enable cart &>> $LOGFILE

VALIDATE $? "enabling the cart Service"

systemctl start cart &>> $LOGFILE

VALIDATE $? "Starting the cart Service"