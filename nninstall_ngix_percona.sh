#!/bin/bash

clear
echo "This installs newznab Ngix with Percona sql-server and everything that is needed to your ubuntu install.\n\nSetup will continue in a few seconds.\n"
echo "After successfull install please go to http://localhost/install/\n\n"
echo "\033[1;31mYOU MUST HAVE YOUR SVN USERNAME AND PASSWORD TO FINISH THIS INSTALL.\033[1;37m\n"
echo "This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 2, as published by the Free Software Foundation.\n"

echo "This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE."
echo "See the GNU General Public License for more details.\n"


echo "Please be Patient ...."

sleep 8
clear



rootcheck ()
{
echo "Checking for root before we begin...."

if ! [ $(id -u) = 0 ]; then
echo "You must be root to do this DOH...." 1>&2
exit 100
fi 
echo "\033[1;32mElevated privileges confirmed.\nBeginning configurations...\033[1;37m"
sleep 2
}

update () 
{
echo "Updating Please Wait....." 
apt-get -q=3 update
clear
}

disclaimer ()
{
echo "               Please Wait"
echo "--------------------------------------------"
sleep 3
clear
echo "DISCLAIMER"
echo " # This script is made available to you without any express, implied or "
echo " # statutory warranty, not even the implied warranty of "
echo " # merchantability or fitness for a particular purpose, or the "
echo " # warranty of title. The entire risk of the use or the results from the use of this script remains with you."

echo "---------------------------------------------------------------------------------------------------------------"
echo "Do you Agree?"
echo "y=YES n=NO"

}
while [ 1 ]
do
    disclaimer
    read CHOICE
    case "$CHOICE" in
          "y")
               clear
              #Installing Prerequirements

                    echo "Installing Prerequirements......"

#                    apt-get install -y -q=3 openssh-server
			apt-get install -y -q=3 build-essential checkinstall
			mkdir -p /var/www/newznab
			chmod 777 /var/www/newznab
			apt-get install -y -q=3 php5
			apt-get install -y -q=3 php5-dev
			apt-get install -y -q=3 php-pear
			apt-get install -y -q=3 php5-gd
			apt-get install -y -q=3 php5-mysql
			apt-get install -y -q=3 php5-curl
			apt-get install -y -q=3 php5-fpm
			apt-get install -y -q=3 openssh-server
			apt-get install -y -q=3 python-software-properties
			mkdir -p /var/www/newznab
			chmod 777 /var/www/newznab
			gpg --keyserver  hkp://keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
			gpg -a --export CD2EFD2A | sudo apt-key add -
			sh -c "echo  \"\n#Percona\" >> /etc/apt/sources.list"
			sh -c "echo  \"deb http://repo.percona.com/apt quantal main\" >> /etc/apt/sources.list"
			sh -c "echo  \"deb-src http://repo.percona.com/apt quantal main\" >> /etc/apt/sources.list"
			apt-get update
			apt-get install -y -q=3 percona-server-client-5.5
			apt-get install -y -q=3 percona-server-server-5.5
			apt-get install -y -q=3 libmysqlclient-dev
			apt-get install -y -q=3 nginx
			mkdir -p /var/log/nginx
			chmod 755 /var/log/nginx
			sed -i -e 's/max_execution_time = 30/max_execution_time = 120/' /etc/php5/fpm/php.ini
			sed -i -e 's/memory_limit = 128M/memory_limit = 256/' /etc/php5/fpm/php.ini
			sed -i -e 's/;date.timezone =/date.timezone = America/NewYork/' /etc/php5/fpm/php.ini
			touch /etc/nginx/sites-available/newznab
			chmod 775 /etc/nginx/sites-available/newznab

cat << EOF >> /etc/nginx/sites-available/newznab
server {
    # Change these settings to match your machine
    listen 80 default_server;
    server_name localhost;

    # Everything below here doesn't need to be changed
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    root /var/www/newznab/www/;
    index index.html index.htm index.php;

    location ~* \.(?:ico|css|js|gif|inc|txt|gz|xml|png|jpe?g) {
            expires max;
            add_header Pragma public;
            add_header Cache-Control "public, must-revalidate, proxy-revalidate";
    }

    location / { try_files $uri $uri/ @rewrites; }

    location @rewrites {
            rewrite ^/([^/\.]+)/([^/]+)/([^/]+)/? /index.php?page=$1&id=$2&subpage=$3 last;
            rewrite ^/([^/\.]+)/([^/]+)/?$ /index.php?page=$1&id=$2 last;
            rewrite ^/([^/\.]+)/?$ /index.php?page=$1 last;
    }

    location /admin { }
    location /install { }

    location ~ \.php$ {
            include /etc/nginx/fastcgi_params;
            fastcgi_pass 127.0.0.1:9000;

            # The next two lines should go in your fastcgi_params
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}

EOF

			service nginx restart
			



			add-apt-repository -y  ppa:jon-severinsson/ffmpeg
			add-apt-repository -y  ppa:shiki/mediainfo
			echo "Prerequirements installed...."
			sleep 5
			clear 
			break
          ;;
          "n")     
               exit
          ;; 
      esac
 done         




echo "Installing ffmpeg x264 mediainfo unrar lame..."

apt-get -q=3 update
apt-get remove -y -q=3 ffmpeg x264 libav-tools libvpx-dev libx264-dev

git clone --depth 1 git://git.videolan.org/x264 /tmp/x264
cd /tmp/x264
./configure --enable-static
make && checkinstall --pkgname=x264 --pkgversion="3:$(./version.sh | awk -F'[" ]' '/POINT/{print $4"+git"$5}')" --backup=no --deldoc=yes --fstrans=no --default

git clone --depth 1 http://git.chromium.org/webm/libvpx.git /tmp/libvpx
cd /tmp/libvpx
./configure
make && checkinstall --pkgname=libvpx --pkgversion="1:$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default

git clone --depth 1 git://source.ffmpeg.org/ffmpeg /tmp/ffmpeg
cd /tmp/ffmpeg
./configure --enable-gpl --enable-libfaac --enable-libfdk-aac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-librtmp --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 --enable-nonfree --enable-version3
make && checkinstall --pkgname=ffmpeg --pkgversion="7:$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default
hash x264 ffmpeg ffplay ffprobe

apt-get -y install -q=3 unrar
apt-get -y install -q=3 lame

clear
echo "ffmpeg x264 mediainfo unrar lame is now installed..."
sleep 5 

clear


echo "Installing Subversion..."
apt-get -y install -q=3 subversion
clear
echo "Subversion is now installed..."
sleep 5

clear

echo "Installing Newznab+"
svn co svn://svnplus@svn.newznab.com/nn/branches/nnplus /var/www/newznab
chmod -R 777 /var/www/newznab
sed -i -e 's/listen = /var/run/php5-fpm.sock/listen = 9000/' /etc/php5/fpm/pool.d/www.conf
service php5-fpm restart
clear
echo "Please Enter Sql DB Password"
mysql -uroot -e "create database 'newznab'"

clear
echo "Newznab+ is now installed"
sleep 5

clear
echo -n -e "Do you want to install Jonnyboy's tmux scripts?\n   (y or no.)\n"
read choice
 
if [ "$choice"=="y" -o "$choice"=="Y" ]
then
apt-get install -y -q=3 nmon mytop tmux iftop bwmng vnstat atop iotop
git clone https://github.com/jonnyboy/newznab-tmux.git /var/www/newznab/misc/update_scripts/nix_scripts/tmux
cp /var/www/newznab/misc/update_scripts/nix_scripts/tmux/config.sh /var/www/newznab/misc/update_scripts/nix_scripts/tmux/defaults.sh
fi

clear
echo "Installing apc chaching "
apt-get install -y -q=3 php-apc
cp /usr/share/doc/php-apc/apc.php /var/www/newznab/www/admin/apc.php
clear
echo "Apc caching is now installed"
echo "Server restart is required to activate APC"
sleep 4


clear
echo "-----------------------------------------------"
echo "Make sure to edit the defaults.sh to your likeing if you choose to run Jonny's script then go into the scripts folder and run ./svn_update.sh"
echo "\033[1;31mDO NOT SKIP THAT STEP YOU HAVE BEEN WARNED!!!\033[1;37m"
sleep 10
clear





echo "Install Complete...."
echo "Go to http://localhost/install to finish NN+ install."
echo "For questions and problems log on to #newznab or #newznab-tmux on Synirc and look for zombu2"
echo "Good Luck."
exit 100
