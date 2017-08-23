#!/bin/bash
export DEBIAN_FRONTEND="noninteractive"

rootpasswd="$(openssl rand -base64 12)"
userpasswd="$(openssl rand -base64 8)"

echo ${rootpasswd} > /root/mysql.root.pswd
chmod 400 /root/mysql.root.pswd

echo "Mysql Installing"
apt-get install -y mysql-server expect > /dev/null
echo "Mysql Starting"
service mysql start > /dev/null

echo "Mysql Secure Installation"
mysqladmin -u root password ${rootpasswd}
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"${rootpasswd}\r\"
expect \"Change the root password?\"
send \"n\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")

echo "Create Django Database & User..."
mysql -uroot -p${rootpasswd} -e "CREATE USER 'djanapp_user'@'localhost' IDENTIFIED BY '${userpasswd}';"
mysql -uroot -p${rootpasswd} -e "CREATE DATABASE djanapp;"
mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON djanapp.* TO 'djanapp_user'@'localhost';"

echo "Set Django Database & User..."
sed -i "s/'ENGINE': 'django.db.backends.sqlite3',/'ENGINE': 'django.db.backends.mysql',/" /var/www/djanapp/djanapp/settings.py
sed -i "s/'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),/'NAME': 'djanapp',\n        'USER':'djanapp_user',\n        'PASSWORD':'${userpasswd}',\n        'OPTIONS': {\n            'init_command': \"SET sql_mode='STRICT_TRANS_TABLES'\",\n        },/" /var/www/djanapp/djanapp/settings.py

echo "Cleaning..."
apt-get -y purge expect > /dev/null
apt-get -y autoremove > /dev/null
service mysql stop > /dev/null