#!/usr/bin/env bash -x

# Install Essentials
sudo apt-get update
sudo apt-get install -y unzip vim git-core curl wget build-essential python-software-properties

# Install Apache
sudo apt-get install -y apache2
sudo apt-get install libapache2-mod-fastcgi
sudo apt-get install libapache2-mod-proxy-html
sudo apt-get install libxml2-dev

# Create symbolic links to enable mod proxy in Apache
cd /etc/apache/mods-enabled
sudo ln -s ../mods-available/proxy_http.load .
sudo ln -s ../mods-available/proxy.load .
sudo ln -s ../mods-available/headers.load .

# Install HHVM
sudo add-apt-repository -y ppa:mapnik/boost
wget -O - http://dl.hhvm.com/conf/hhvm.gpg.key | sudo apt-key add -
echo deb http://dl.hhvm.com/ubuntu precise main | sudo tee /etc/apt/sources.list.d/hhvm.list
sudo apt-get update
sudo apt-get install -y hhvm

# Configure HHVM
sudo /usr/share/hhvm/install_fastcgi.sh
sudo update-rc.d hhvm defaults
sudo service hhvm restart

# Running PHP
sudo /usr/bin/update-alternatives --install /usr/bin/php php /usr/bin/hhvm 60
php -v
echo "<?php phpinfo();" | sudo tee  /usr/share/nginx/html/index.php
curl localhost
curl localhost/index.php
nano /etc/nginx/hhvm.conf
# wget -O setup.sh http://goo.gl/Y5xN6A
# chmod 777 setup.sh
# sudo ./setup.sh

# Install Apache
sudo apt-get install -y apache2
sudo apt-get install -y libapache2-mod-php5

# Install php 5.5
sudo add-apt-repository ppa:ondrej/php5
sudo apt-get update
sudo apt-get install -y php5

# Install MySQL
sudo apt-get install -y mysql-server
sudo apt-get install -y php5-mysql

# http://bikerjared.wordpress.com/2012/10/18/ubuntu-12-04-mod-proxy-install-and-configuration/
# https://github.com/facebook/hhvm/wiki/FastCGI#apache-24
<IfModule mod_fastcgi.c>
    Alias /hhvm.fastcgi /var/www/fastcgi/hhvm.fastcgi
    FastCGIExternalServer /var/www/fastcgi/hhvm.fastcgi -socket /var/run/hhvm/socket -pass-header Authorization -idle-timeout 300
    <Directory "/var/www/fastcgi">
        <Files "hhvm.fastcgi">
            Order deny,allow
        </Files>
    </Directory>

    AddHandler hhvm-hack-extension .hh
    AddHandler hhvm-php-extension .php

    Action hhvm-hack-extension /hhvm.fastcgi virtual
    Action hhvm-php-extension /hhvm.fastcgi virtual
</IfModule>