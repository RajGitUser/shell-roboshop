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

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "Installing Maven"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Adding user and Passwd"
 else
    echo -e "User ID Already exist $Y SKIPPING $N"
fi

mkdir /app &>>$LOG_FILE

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "Copying shipping file"

cd /app
rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "Unzipping shipping file"

mvn clean package &>>$LOG_FILE
mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
VALIDATE $? "Cleaning Packages"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "Copying systemctl service file"

systemctl daemon-reload &>>$LOG_FILE
systemctl enable shipping &>>$LOG_FILE
VALIDATE $? "Enabling shipping"

systemctl start shipping &>>$LOG_FILE
VALIDATE $? "Starting shipping"

dnf install mysql -y &>>$LOG_FILE

mysql -h $SQLIP -uroot -pRoboShop@1 -e 'use cities' &>>$LOG_FILE
if [ $? -ne 0 ]; then
    mysql -h $SQLIP -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
    mysql -h $SQLIP -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOG_FILE
    mysql -h $SQLIP -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
 else
    echo -e "shipping data is already loaded $Y SKIPPING $N"
fi

systemctl restart shipping
VALIDATE $? "Restrting Shipping"