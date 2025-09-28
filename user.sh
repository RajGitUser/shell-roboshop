#!/bin/bash

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

VALIDATE(){  # functions recieves inputs through orgs just like shell orgs
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
     else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

#### NodeJS Installing ####
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disable NodeJS"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enable NodeJS 20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing Nodejs"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "User ID Added" ## Adding the user id
 else
    echo -e "User Already Existed $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "Creating a Directory"

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOG_FILE
VALIDATE $? "Copying the user file"

cd /app

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/user.zip &>>$LOG_FILE
VALIDATE $? "Unzipping the file"

npm install &>>$LOG_FILE
VALIDATE $? "Installing the Dependencies"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "Copying the system service file"

systemctl daemon-reload &>>$LOG_FILE

systemctl enable user &>>$LOG_FILE
VALIDATE $? "Enable the user"

systemctl start user &>>$LOG_FILE
VALIDATE $? "Stared the user server"

