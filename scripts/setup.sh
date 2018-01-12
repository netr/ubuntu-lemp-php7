#!/bin/bash
# Using Ubuntu

sudo echo "127.0.1.1 ubuntu-xenial" >> /etc/hosts
#
# Install
#
echo "============    BEGIN SETUP   ============="
echo -e "----------------------------------------"
sudo apt-get install -y language-pack-UTF-8
sudo apt-get install -y build-essential python-software-properties software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt-get install -y re2c libpcre3-dev gcc make


#
# Install Git and Tools
#
echo -e "----------------------------------------"
echo "VAGRANT ==> Git"
apt-get install -y git  > /dev/null

echo -e "----------------------------------------"
echo "VAGRANT ==> tools (mc, htop, unzip etc...)"
apt-get install -y mc htop unzip grc gcc make libpcre3 libpcre3-dev lsb-core autoconf > /dev/null



#
# Install Nginx
#
echo -e "----------------------------------------"
echo "VAGRANT ==> Nginx"
apt-get install -y nginx  > /dev/null

#
# php
#
echo -e "----------------------------------------"
echo "VAGRANT ==> PHP 7"
sudo apt-get install -y php7.1-fpm php7.1-cli php7.1-common php7.1-json php7.1-opcache php7.1-mysql php7.1-phpdbg php7.1-mbstring php7.1-gd php-imagick  php7.1-pgsql php7.1-pspell php7.1-recode php7.1-tidy php7.1-dev php7.1-intl php7.1-gd php7.1-curl php7.1-zip php7.1-xml php-memcached mcrypt memcached phpunit


#
# PHP Errors
#
echo -e "----------------------------------------"
echo "VAGRANT ==> Setup PHP 7"
sudo sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php/7.1/fpm/php.ini
sudo sed -i 's/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/error_reporting = E_ALL/' /etc/php/7.1/fpm/php.ini
sudo sed -i 's/display_startup_errors = Off/display_startup_errors = On/' /etc/php/7.1/fpm/php.ini
sudo sed -i 's/display_errors = Off/display_errors = On/' /etc/php/7.1/fpm/php.ini
sudo sed -i 's/listen =/listen = 127.0.0.1:9000 ;/' /etc/php/7.1/fpm/pool.d/www.conf
service php7.1-fpm restart



#
# composer
#
echo -e "----------------------------------------"
echo "VAGRANT ==> Composer"
curl -sS https://getcomposer.org/installer | php > /dev/null
mv composer.phar /usr/local/bin/composer

#
# Frontend Tools (npm, nodejs, gulp)
#
echo -e "----------------------------------------"
echo "VAGRANT ==> Frontend Tools (npm, nodejs, gulp)"
sudo apt install -y npm nodejs nodejs-legacy
sudo npm install --global gulp-cli gulp
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
nvm install 9.4.0
nvm use 9.4.0

#
# Ethereum Tools
#
echo -e "----------------------------------------"
echo "VAGRANT ==> Ethereum tools (npm, nodejs, gulp)"
sudo npm install -g ethereumjs-testrpc
sudo apt-get install software-properties-common
sudo add-apt-repository -y ppa:ethereum/ethereum
sudo apt-get update
sudo apt-get install ethereum
sudo npm install -g truffle

#
# redis
#
echo -e "----------------------------------------"
echo "VAGRANT ==> Redis Server"
apt-get install -y redis-server redis-tools
cp /etc/redis/redis.conf /etc/redis/redis.bkup.conf
sed -i 's/bind 127.0.0.1/bind 0.0.0.0/' /etc/redis/redis.conf


echo -e "----------------------------------------"
echo "VAGRANT ==> PHP Redis"
git clone https://github.com/phpredis/phpredis.git
cd phpredis
phpize
./configure
make && make install
cd ..
rm -rf phpredis
cd ~/
echo "extension=redis.so" > ~/redis.ini
cp ~/redis.ini /etc/php/7.1/mods-available/redis.ini
ln -s /etc/php/7.1/mods-available/redis.ini /etc/php/7.1/fpm/conf.d/20-redis.ini

echo -e "----------------------------------------"
echo "VAGRANT ==> Restart Redis & PHP"
service redis-server restart
service php7.1-fpm restart


#
# MySQL
#
echo -e "----------------------------------------"
echo "VAGRANT ==> MySQL"
export DEBIAN_FRONTEND=noninteractive
apt-get install -y debconf-utils -y > /dev/null
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo apt install -y mysql-server mysql-client
sed -i 's/bind-address/bind-address = 0.0.0.0#/' /etc/mysql/mysql.conf.d/mysqld.cnf
mysql -u root -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES;"
service mysql restart

#
# Reload servers
#
echo -e "----------------------------------------"
echo "VAGRANT ==> Restart Nginx & PHP-FPM"
sudo service nginx restart
sudo service php7.1-fpm restart



#
# Add user to group
#
sudo usermod -a -G www-data vagrant

#
# COMPLETE
#
echo -e "----------------------------------------"
echo "======>  VIRTUAL MACHINE READY"
echo "======>  TYPE 'vagrant ssh"
echo -e "----------------------------------------"
