#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[34m"
LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
SCRIPT_DIR=$PWD
SQLIP=mysql.rajkumardaws.space
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

dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "Installing python version3"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
VALIDATE $? "Adding user and passwd"

mkdir /app
VALIDATE $? "Creating a Directory"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_FILE
VALIDATE $? "Copying payment file"

cd /app 
unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "Unzipping paymentfile"

pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "Installing Dependencies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
VALIDATE $? "Copying systemctl service file"

systemctl daemon-reload
systemctl enable payment &>>$LOG_FILE
VALIDATE $? "Enabling payment service"

systemctl start payment &>>$LOG_FILE
VALIDATE $? "Restarting payment service"