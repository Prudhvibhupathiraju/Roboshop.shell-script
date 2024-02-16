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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE

VALIDATE $? "Installing remirepo release"

dnf module enable redis:remi-6.2 -y &>> $LOGFILE

VALIDATE $? "Enabling Redis 6.2"

dnf install redis -y &>> $LOGFILE

VALIDATE $? "Installing Redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>> $LOGFILE

VALIDATE $? "Configuring Remote access"

systemctl enable redis &>> $LOGFILE

VALIDATE $? "Enabling Redis"

systemctl start redis &>> $LOGFILE

VALIDATE $? "Starting Redis"