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
START_TIME=$(date +%s)
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

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Adding rabbitmq repo"

dnf install rabbitmq-server -y
VALIDATE $? "Installing rabbitmq server"

systemctl enable rabbitmq-server
VALIDATE $? "Enabling rabbitmq server"

systemctl start rabbitmq-server
VALIDATE $? "Staring rabbitmq server"

rabbitmqctl add_user roboshop roboshop123
VALIDATE $? "Adding root user passwd"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "Giving the path"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"