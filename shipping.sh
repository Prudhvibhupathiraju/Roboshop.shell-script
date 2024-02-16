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

dnf install maven -y &>> $LOGFILE

VALIDATE $? "Installing maven"

id roboshop &>> $LOGFILE
if [ $? -ne 0 ]
then
   useradd roboshop
   VALIDATE $? "Creation of roboshop user"
else
   echo -e "user 'roboshop' already exists .... $Y SKIPPING $N"

fi

mkdir -p /app &>> $LOGFILE

VALIDATE $? "creating directory :app"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE

VALIDATE $? "Downloading the application code"

cd /app &>> $LOGFILE

VALIDATE $? "Moving to 'app' directory"

unzip /tmp/shipping.zip &>> $LOGFILE

VALIDATE $? "Uzipping the code in 'app' directory"

mvn clean package &>> $LOGFILE

VALIDATE $? "Installing Dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE

VALIDATE $? "Renaming the .jar file"

cp /home/centos/Roboshop.shell-script/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE

VALIDATE $? "Setting up the shipping.service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Loading the service"

systemctl enable shipping &>> $LOGFILE

VALIDATE $? "enabling the service"

systemctl start shipping &>> $LOGFILE

VALIDATE $? "starting the service"

dnf install mysql -y &>> $LOGFILE

VALIDATE $? "Installing MySQL client"

mysql -h mysql.bhpr.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE

VALIDATE $? "Loading Schema"

systemctl restart shipping &>> $LOGFILE

VALIDATE $? "Restarting the service"