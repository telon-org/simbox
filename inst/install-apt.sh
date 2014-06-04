#!/bin/sh

apt-get -y update
apt-get -y upgrade
apt-get install -y ifenslave
apt-get install -y openvpn
apt-get install -y mc g++ libncurses-dev libxml2-dev subversion make automake libusb-dev bzip2 tcl iftop htop iotop
apt-get install -y linux-headers-`uname -r` gcc g++ make libnewt-dev libncurses5-dev openssl libssl-dev zlib1g-dev
apt-get install -y linux-headers
apt-get install -y apache2 php5-common php5 libapache2-mod-php5 php5-cli php5-cgi php5-mysql php5-svn
apt-get install -y usb-modeswitch 
apt-get install -y php5-curl sox flac curl
apt-get install -y sqlite3 libsqlite3-dev
apt-get install -y smartmontools lm-sensors
sensors-detect
apt-get install -y munin