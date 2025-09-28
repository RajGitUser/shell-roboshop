#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[34m"
LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
$MONGODB_HOST=mongodb.rajkumardaws.space
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-script/mongo-logs.log


mkdir -p $LOGS_FOLDER
echo "script started excecuted at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR :: Please Run this command in SUDO privilage"
    exit1 # Failure is other than 0
fi

VALIDATE(){  # functions recieves inputs through orgs just like shell orgs
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

#### NodeJS Installing ####
dnf module disable nodejs -y
VALIDATE $? "Disable NodeJS"

dnf module enable nodejs:20 -y
VALIDATE $? "Enable NodeJS 20"

dnf install nodejs -y
VALIDATE $? "Installing Nodejs"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "User ID Added" ## Adding the user id

mkdir /app 
VALIDATE $? "Creating a Directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip
VALIDATE $? "Copying the catalogue file"

cd /app

unzip /tmp/catalogue.zip
VALIDATE $? "Unzipping the file"

npm install
VALIDATE $? "Installing the Dependencies"

cp catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying the system service file"

systemctl daemon-reload

systemctl enable catalogue 
VALIDATE $? "Enable the catalogue"

systemctl start catalogue
VALIDATE $? "Stared the catalogue server"

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Creating mongo repo"

dnf install mongodb-mongosh -y
VALIDATE $? "Installing MOngoDB"

mongosh --host $MONGODB_HOST </app/db/master-data.js
VALIDATE $? "Crating a DB"
