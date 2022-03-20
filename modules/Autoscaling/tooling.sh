#!/bin/bash
mkdir /var/www/
sudo mount -t efs -o tls,accesspoint=fsap-03c7f79f1174c87e8 fs-0501ac1736dff39ea:/ /var/www/
yum install -y httpd 
systemctl start httpd
systemctl enable httpd
yum module reset php -y
yum module enable php:remi-7.4 -y
yum install -y php php-common php-mbstring php-opcache php-intl php-xml php-gd php-curl php-mysqlnd php-fpm php-json
systemctl start php-fpm
systemctl enable php-fpm
git clone https://github.com/Livingstone95/tooling-1.git
mkdir /var/www/html
cp -R /tooling-1/html/*  /var/www/html/
cd /tooling-1
mysql -h acs-database.cbzlhilzcstn.us-east-2.rds.amazonaws.com -u ACSADMIN -p toolingdb < tooling-db.sql
cd /var/www/html/
touch healthstatus
sed -i "s/$db = mysqli_connect('mysql.tooling.svc.cluster.local', 'admin', 'admin', 'tooling');/$db = mysqli_connect('acs-database.cbzlhilzcstn.us-east-2.rds.amazonaws.com', 'ACSADMIN', 'password', 'toolingdb');/g" functions.php
chcon -t httpd_sys_rw_content_t /var/www/html/ -R
mv /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/welcome.conf_backup
systemctl restart httpd