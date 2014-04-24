#!/usr/bin/env bash -x

# Ubuntu 12.04 LTS LAMP Server Setup
# http://fideloper.com/ubuntu-12-04-lamp-server-setup

# Setup
sudo apt-get update
sudo apt-get install -y nano   # Everyone likes nano, right?
sudo apt-get install -y build-essential
sudo apt-get install -y python-software-properties

# Run these 2 steps if you want php 5.4, rather than 5.3
sudo add-apt-repository ppa:ondrej/php5
sudo apt-get update

# Install the LAMP components
sudo apt-get install -y php5
sudo apt-get install -y apache2
sudo apt-get install -y libapache2-mod-php5
sudo apt-get install -y mysql-server
sudo apt-get install -y php5-mysql
sudo apt-get install -y php5-curl
sudo apt-get install -y php5-gd
sudo apt-get install -y php5-mcrypt

# Set your server name (Avoid error message on reload/restart of Apache)
echo 'ServerName localhost' | sudo tee /etc/apache2/httpd.conf

# Enable mod-rewrite
sudo a2enmod rewrite

# Git
sudo apt-get install -y git-core

# Install composer globally
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Tweaks/Security
# Create a new sudo user
adduser mysudouser            # Create user
usermod -G sudo mysudouser    # Make user a sudo user (sudoer)
# (Log in and make sure this sudo user does indeed have the sudo permissiosn)

# Don't let root login in via ssh
sudo nano /etc/ssh/sshd_config
> PermitRootLogin no            # Change from yes
sudo reload ssh

# Deploy user
adduser mydeployuser
usermod -g www-data mydeployuser

# Apache tweaks
sudo nano /etc/apache2/apache2.conf
> Timeout 45                            # Change from 300
> MaxKeepAliveRequests 200              # Change from 100

# sudo nano /etc/apache2/conf.d/security
sudo nano /etc/apache2/conf-enabled/security.conf
> ServerTokens Prod                     # Change from 'OS' or any other
> ServerSignature Off                   # Change from 'On'

sudo nano /etc/php5/apache2/php.ini
> post_max_size = 8M                    # Change to 8M
> upload_max_filesize = 8M              # Change from 2M
> max_file_uploads = 5                  # Change from 20
> expose_php = off                      # Change fron 'On'
sudo service apache2 restart

# Web-root permissions
sudo chown -R www-data:www-data /var/www # make sure same owner:group
sudo chmod -R go-rwx /var/www             # Remove all group/other permissions
sudo chmod -R g+rw /var/www               # Add group read/write
sudo chmod -R o+r /var/www                # Allow other to read only

# Virtual Hosts
# vhosts
# sudo curl https://gist.github.com/fideloper/2710970/raw/6b5fd9de45f75e613178d296e87f586ca5b61220/vhost.sh > /usr/local/bin/vhost
# sudo wget -O vhost https://gist.github.com/fideloper/2710970/raw/6b5fd9de45f75e613178d296e87f586ca5b61220/vhost.sh
sudo wget -O vhost https://gist.githubusercontent.com/fideloper/2710970/raw/c378dbd53ebc9c821931fc3ba7249d32f681f99a/vhost.sh
sudo chmod guo+x /usr/local/bin/vhost
sudo vhost -h # See the available options

# Firewall
# Run as root or use sudo
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -p tcp --dport ssh -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -A INPUT -j DROP
sudo iptables -I INPUT 1 -i lo -j ACCEPT

# Install so firewalls are saved through restarts
sudo apt-get install -y iptables-persistent
sudo service iptables-persistent start

# Add MySQL user
sudo mysql -u root -p
> CREATE USER 'rluna'@'localhost' IDENTIFIED BY '$3cr3t4?';
> GRANT ALL PRIVILEGES ON *.* TO 'rluna'@'localhost';

# Add SSL
sudo a2enmod ssl    # Enable loading of SSL module
sudo service apache2 restart
sudo mkdir /etc/apache2/ssl
cd /etc/apache2/ssl
# Change the domain from "robertoluna.com" to what you need
sudo openssl req -new -days 365 -nodes -newkey rsa:2048 -keyout robertoluna.com.key -out robertoluna.com.csr
sudo chmod 400 robertoluna.com.key
… add csr, get key back
sudo nano /etc/apache2/sites-available/your_vhost.conf
> SSLEngine on
> SSLCertificateFile /etc/apache2/ssl/robertoluna.com.crt
> SSLCertificateKeyFile /etc/apache2/ssl/robertoluna.com.key
> SSLCertificateChainFile /etc/apache2/ssl/sf_bundle.crt
