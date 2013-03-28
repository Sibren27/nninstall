#!/bin/bash
clear
echo "This installs newznab apache sql sphinx mediainfo ffmpeg and everything that is needed to your ubuntu install."
echo "Please Hit Enter when the script asks you to hit Enter to add the repos."
echo "Setup will continue in a few seconds."
echo 
echo "After successfull install please go to http://localhost/install/"
echo
echo
echo "DO NOT FORGET TO PUT A * BY HITTING SPACE WHEN PHPMYADMIN ASKS WHICH WEBSERVER TO CONFIGURE OR PHPMYADMIN WON'T WORK."
echo
echo
echo
echo "YOU MUST HAVE YOUR SVN USER AND PASSWORD TO FINISH THIS INSTALL."

#This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 2, as published by the Free Software Foundation.

#This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 


echo "Please be Patient ...."

sleep 10



if [ $(id -u) != "0" ]; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi
       




# DISCLAIMER:
# This script is made available to you without any express, implied or 
# statutory warranty, not even the implied warranty of 
# merchantability or fitness for a particular purpose, or the 
# warranty of title. The entire risk of the use or the results from the use of this script remains with you.

sleep 1
apt-get update
apt-get install -y ssh
apt-get -y install mc
apt-get -y install htop
apt-get install -y iotop
apt-get install -y iftop

sleep 3

apt-get install -y build-essential checkinstall
sleep 3
mkdir -p /var/www/newznab
sleep 3
chmod 777 /var/www/newznab
sleep 3
apt-get install -y php5
apt-get install -y php5-dev
apt-get install -y php-pear
apt-get install -y php5-gd
apt-get install -y php5-mysql
apt-get install -y php5-curl


sleep 3
sh -c 'echo "deb http://ftp.osuosl.org/pub/mariadb/repo/5.5/ubuntu precise main" >> /etc/apt/sources.list.d/mariadb.list'
apt-get update
apt-get -y --force-yes install libmariadbclient18
apt-get -y --force-yes install mariadb-client-5.5
apt-get -y --force-yes install mariadb-client-core-5.5
apt-get -y --force-yes install mariadb-common
apt-get -y --force-yes install mariadb-server
apt-get -y --force-yes install mariadb-server-core-5.5
apt-get -y --force-yes install mysql-common

sleep 1
apt-get -y install apache2
sleep 1
sleep 1

a2dissite default
a2ensite newznab
a2enmod rewrite
service apache2 restart

sleep 1
apt-get -y install python-software-properties
add-apt-repository ppa:jon-severinsson/ffmpeg
add-apt-repository ppa:shiki/mediainfo
add-apt-repository ppa:builds/sphinxsearch-stable

sleep 1
apt-get update
apt-get -y install ffmpeg
apt-get -y install x264
apt-get -y install mediainfo
apt-get -y install sphinxsearch
apt-get -y install unrar
apt-get -y install lame
apt-get -y install phpmyadmin

service apache2 stop
service mysql stop

apt-get -y install subversion
cd /var/www/
svn co svn://svn.newznab.com/nn/branches/nnplus /var/www/newznab
chmod -R 777 /var/www/newznab

service apache2 start
service mysql start


service apache2 stop
service mysql stop

wget -O /home/newznab http://bandofbrothers.3owl.com/nn/newznab
mv /home/newznab /etc/apache2/sites-available/newznab

wget -O /home/php.ini http://bandofbrothers.3owl.com/nn/apache/php.ini
mv /home/php.ini /etc/php5/apache2/php.ini

wget -O /home/php.ini http://bandofbrothers.3owl.com/nn/cli/php.ini
mv /home/php.ini /etc/php5/cli/php.ini


sudo a2dissite default
sudo a2ensite newznab
sudo a2enmod rewrite


service apache2 start
service mysql start

#cd /var/www/newznab/misc/sphinx
#php ./nnindexer.php generate
#sleep 5
#php ./nnindexer.php daemon
#sleep 5
#php ./nnindexer.php index full all
#sleep 5
#php ./nnindexer.php delta all
#sleep 5
#php ./nnindexer.php daemon --stop
#sleep 5
#php ./nnindexer.php daemon
#sleep5

clear
echo "Install Complete...."
echo "Go to http://localhost/install to finish NN+ install."
echo "After that you have to enable sphinx in your admin panel then generate your sphinx config."
echo "For questions and problems log on to #newznab irc and look for zombu2"
echo "Good Luck."
