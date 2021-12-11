#!/bin/bash

LOG=/tmp/sk.log
ID=$(id -u)
MYSQL_URL=https://repo.mysql.com/yum/mysql-connectors-community/el/7/x86_64/mysql-community-release-el7-5.noarch.rpm
MYSQL_RPM=$(echo $MYSQL_URL | cut -d / -f9)
SONAR_URL=https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-6.7.6.zip
SONAR_ZIP=$(echo $SONAR_URL | awk -F / '{print $NF}')
SONAR_SRC=$(echo $SONAR_URL | awk -F / '{print $NF}' | sed 's/.zip//')
SONAR_DIR=/opt/sonarqube


R='\033[0;31m'
G='\033[0;32m'
Y='\033[0;33m'
N="\033[0;37m"

if [ $ID -ne 0 ]; then 
    echo " Please Re-Run Script Using Root User Permission "
    exit 1
else
    echo " You Are Running Script Successfully "
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else 
        echo -e "$2 ....$G SUCCESS $N"
    fi
}

yum install wget java unzip -y &>>$LOG
VALIDATE $? "SonarqQube Dependences Installation"

wget  $MYSQL_URL -O /tmp/$MYSQL_RPM &>>$LOG
VALIDATE $? "Downloading MySql"

cd /tmp/
rpm -ivh $MYSQL_RPM   &>>$LOG
yum install mysql-server -y   &>>$LOG
VALIDATE $? "Installing Mysql Package"

systemctl start mysqld
VALIDATE $? "Strating Mysql Service"

if [ -f /tmp/sonar.sql ]; then
    echo -e " $Y SonarQube Database Updated $N"
else 
    echo "CREATE DATABASE sonarqube_db;
    CREATE USER 'sonarqube_user'@'localhost' IDENTIFIED BY 'password';
    GRANT ALL PRIVILEGES ON sonarqube_db.* TO 'sonarqube_user'@'localhost'
    IDENTIFIED BY 'password';
    FLUSH PRIVILEGES;" > /tmp/sonar.sql
    mysql < /tmp/sonar.sql 
    VALIDATE $? "Configuring SonarQube Database"
fi

egrep "sonarqube" /etc/passwd >/dev/null
if [ $? -eq 0 ]; then
    echo -e " $Y Sonarqube user exists! $N"
else
    useradd sonarqube  &>>$LOG
    VALIDATE $? "Creating SonarQube USer Account"
fi

if [ -d "$SONAR_DIR" ]; then
    echo -e " $Y SonarQube ZIP Exists! $N"
else 
   wget $SONAR_URL -O  /tmp/$SONAR_ZIP &>>$LOG
   VALIDATE $? "Downloading SonarQube"
    
fi

unzip -o /tmp/$SONAR_ZIP &>>$LOG
rm -rf  /opt/sonarqube 
mv  $SONAR_SRC /opt/sonarqube 
chown sonarqube. /opt/sonarqube -R 
VALIDATE $? "Sonarqube Installation"

echo 'sonar.jdbc.username=sonarqube_user
sonar.jdbc.password=password
sonar.jdbc.url=jdbc:mysql://localhost:3306/sonarqube_db?useUnicode=true&amp;characterEncoding=utf8&amp;rewriteBatchedStatements=true&amp;useConfigs=maxPerformance ' >>  /opt/sonarqube/conf/sonar.properties
VALIDATE $? "SonarQube DB Configuration"

sed -i 's/#RUN_AS_USER=/RUN_AS_USER=sonarqube/g' /opt/sonarqube/bin/linux-x86-64/sonar.sh
VALIDATE $? "Updating SonarQube Sonar.sh file"

sh /opt/sonarqube/bin/linux-x86-64/sonar.sh start
VALIDATE $? "Starting SonarQube" 


