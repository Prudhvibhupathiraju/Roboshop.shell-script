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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE

VALIDATE $? "Configuring YUM Repos from the script"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE

VALIDATE $? "Configuring YUM Repos for RabbitMQ"

dnf install rabbitmq-server -y >> $LOGFILE

VALIDATE $? "Installing RabbitMQ"

systemctl enable rabbitmq-server >> $LOGFILE

VALIDATE $? "Enabling RabbitMQ service"

systemctl start rabbitmq-server >> $LOGFILE

VALIDATE $? "Starting RabbitMQ service"

rabbitmqctl add_user roboshop roboshop123 >> $LOGFILE

VALIDATE $? "Setting user id"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" >> $LOGFILE

VALIDATE $? "Setting password