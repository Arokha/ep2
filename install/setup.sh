#!/bin/bash

# Without this, locale crap is annoying.
export DEBIAN_FRONTEND=noninteractive
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
dpkg-reconfigure locales


# PHP 7.2 repo
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update

# Utils and fun bits
sudo apt-get install -y build-essential curl git avahi-daemon
sudo apt-get install -y openssh-client openssh-server
sudo apt-get install -y zip unzip
echo -e "\e[7m OS and core software installed \e[27m"

# MySQL and friends
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo apt-get install -y mysql-server




# PHP with all the fixins
sudo apt-get install -y php7.2

sudo apt-get install -y php7.2-mysql php7.2-cli php7.2-mbstring php7.2-opcache php7.2-curl php7.2-xml php7.2-json php7.2-readline php7.2-gd php7.2-imagick php7.2-xmlrpc php7.2-zip
sudo apt-get install -y php-mcrypt php-xdebug php-mbstring
echo 'max_execution_time = 300' >> /etc/php/7.2/apache2/php.ini

# Apache
sudo apt-get install -y apache2 libapache2-mod-php7.2
sudo echo "ServerName eldrich.local"  >> /etc/apache2/apache2.conf
sudo ln -s /vagrant/install/drupal.conf /etc/apache2/sites-available/drupal.conf

sudo a2dissite 000-default.conf
sudo a2ensite drupal.conf
sudo a2enmod rewrite
sudo service apache2 restart

echo -e "\e[7m LAMP stack installed \e[27m"

sudo usermod -a -G www-data ubuntu

# Create the database, clean up after Apache, install front end requirements.
mysql -uroot -proot -e "create database drupal;"

if [ -f "/vagrant/install/initial.sql" ]
then
  mysql -uroot -proot drupal < /vagrant/install/initial.sql
  echo -e "\e[7m Database imported \e[27m"
fi

echo 'xdebug.max_nesting_level = 256' >> /etc/php/7.2/mods-available/xdebug.ini
echo 'xdebug.remote_enable=on' >> /etc/php/7.2/mods-available/xdebug.ini
echo 'xdebug.remote_connect_back=on' >> /etc/php/7.2/mods-available/xdebug.ini
echo 'html_errors=1' >> /etc/php/7.2/mods-available/xdebug.ini
echo 'xdebug.extended_info=1' >> /etc/php/7.2/mods-available/xdebug.ini

sudo usermod -a -G www-data ubuntu

sudo apachectl reload
sudo apachectl restart
