#!/usr/bin/env bash -x

# Install Essentials
sudo apt-get update
sudo apt-get install -y unzip vim git-core curl wget build-essential python-software-properties

# Install Nginx
sudo add-apt-repository -y ppa:nginx/stable
sudo apt-get update
sudo apt-get install -y nginx

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
