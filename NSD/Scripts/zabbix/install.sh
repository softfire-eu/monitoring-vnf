#!/usr/bin/env bash
# asterisk installation script and configuration for sipas

# sane defaults
SERVICE="zabbix"
LOGFILE="$HOME/install.log"
CONFIG_FOLDER="/etc/zabbix/"

# If there are default options load them 
if [ -f "$SCRIPTS_PATH/default_options" ]; then
	  source $SCRIPTS_PATH/default_options
fi

echo "$SERVICE : Installing zabbix server 3.0"
sudo su
wget http://repo.zabbix.com/zabbix/3.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_3.0-1+trusty_all.deb
dpkg -i zabbix-release_3.0-1+trusty_all.deb
rm zabbix-release_3.0-1+trusty_all.deb
echo "$SERVICE : Added zabbix repo"

export DEBIAN_FRONTEND=noninteractive
mysql_pass=""
apt-get update && apt-get -y install mysql-server zabbix-server-mysql zabbix-frontend-php
echo "$SERVICE : Finished installing packages"

sed -i 's/;date.timezone =/date.timezone = "Europe\/Berlin"/' /etc/php5/apache2/php.ini
sed -i 's/# DBPassword=/DBPassword=/' /etc/zabbix/zabbix_server.conf
cp $SCRIPTS_PATH/zabbix.conf.php /etc/zabbix/web/zabbix.conf.php 

mysql -uroot -e "create database zabbix character set utf8 collate utf8_bin;" --password=""
mysql -uroot -e "grant all privileges on zabbix.* to zabbix@localhost identified by '';" --password=""
zcat /usr/share/doc/zabbix-server-mysql/create.sql.gz | mysql -uroot zabbix

service apache2 reload
service zabbix-server restart
echo "$SERVICE : Changed configuration and restarted service"

wget https://raw.githubusercontent.com/openbaton/juju-charm/develop/hooks/zbx_helper.py

python zbx_helper.py -a
