#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[34m"
LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

USERID=$(id -u)

mkdir -p $LOGS_FOLDER

if [ $USERID -ne 0 ]; then
echo "ERROR :: Please Run this command in SUDO privilage"
exit1

fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $N SUCCESS $N" | tee -a $LOG_FILE
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding Mongo Repo"

dnf install mongodb-org -y 
VALIDATE $? "Installing MongoDB"

systemctl enable mongod
VALIDATE $? "Enabiling MongoDB"

systemctl start mongod 
VALIDATE $? "Start MongoDB"