#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo -e "the script has started executing at $Y $TIMESTAMP $N" &>> $LOGFILE

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

dnf install nginx -y &>> $LOGFILE

VALIDATE $? "Installing Nginx"

systemctl enable nginx &>> $LOGFILE

VALIDATE $? "enabling Nginx"

systemctl start nginx &>> $LOGFILE

VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE

VALIDATE $? "Removing default content in web server"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE

VALIDATE $? "Downloading Roboshop frontend content"

cd /usr/share/nginx/html &>> $LOGFILE

VALIDATE $? "changing directory to extract frontend content"

unzip /tmp/web.zip &>> $LOGFILE

VALIDATE $? "Unzipping content"

cp /home/centos/Roboshop.shell-script/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE

VALIDATE $? "Copying roboshop.conf content"

systemctl restart nginx &>> $LOGFILE

VALIDATE $? "Restarting Nginx"