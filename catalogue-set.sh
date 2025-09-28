#!/bin/bash

trap 'echo "There is an error in $LINENO, Command is: $BASH_COMMAND"' ERR
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[34m"
LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
MONGODB_HOST="mongodb.rajkumardaws.space"
SCRIPT_DIR=$PWD
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-script/mongo-logs.log


mkdir -p $LOGS_FOLDER
echo "script started excecuted at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR :: Please Run this command in SUDO privilage"
    exit1 # Failure is other than 0
fi

#### NodeJS Installing ####
dnf module disable nodejs -y &>>$LOG_FILE

dnf module enable nodejs:20 -y &>>$LOG_FILE

dnf install nodejs -y &>>$LOG_FILE

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "User ID Added" ## Adding the user id
 else
    echo -e "User Already Existed $Y SKIPPING $N"
fi

mkdir -p /app 

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE

cd /app

rm -rf /app/*

unzip /tmp/catalogue.zip &>>$LOG_FILE

npm install &>>$LOG_FILE

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service

systemctl daemon-reload &>>$LOG_FILE

systemctl enable catalogue &>>$LOG_FILE

systemctl start catalogue &>>$LOG_FILE

INDEX=$(mongosh mongodb.rajkumardaws.space --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ INDEX -ne 0 ]; then
    cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
 else
    echo -e "Catalogue Products Already Exist .. $Y SKIPPING $N"
fi

dnf install mongodb-mongosh -y &>>$LOG_FILE

mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE