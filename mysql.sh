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

dnf module disable mysql -y &>> $LOGFILE

VALIDATE $? "disabling MySQL 8 version"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE

VALIDATE $? "Setting up the MySQL5.7 repo file"

dnf install mysql-community-server -y &>> $LOGFILE

VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>> $LOGFILE

VALIDATE $? "Enabling MySQL Service"

systemctl start mysqld &>> $LOGFILE

VALIDATE $? "Starting MySQL Service"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE

VALIDATE $? "changing the default root password"
