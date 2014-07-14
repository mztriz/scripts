#!/bin/sh
# Ava Gailliot
# This script should install Webmin and WebminStats on any RHEL server
# 07/06/13

# Get RHEL version
export rhel=$(cat /etc/redhat-release | awk '{print $7}'| cut -c 1)
export arch=$(uname -a | awk '{print $13}')

#Poke a hole in the firewall
iptables -I INPUT 1 -m state --state NEW -m tcp -p tcp --dport 10000 -j ACCEPT
service iptables save
service iptables restart

# Download and install webmin
rpm -Uvh http://download.webmin.com/download/yum/webmin-1.620-1.noarch.rpm

# Packages needed for Webmin stats
if [ ${rhel} -eq 4 ]; then
	rpm -Uvh http://linux.mirrors.es.net/fedora-epel/${rhel}/${arch}/epel-release-${rhel}-10.noarch.rpm
elif [ ${rhel} -eq 5 ]; then
	rpm -Uvh http://linux.mirrors.es.net/fedora-epel/${rhel}/${arch}/epel-release-${rhel}-4.noarch.rpm
elif [ ${rhel} -eq 6 ]; then
	rpm -Uvh http://linux.mirrors.es.net/fedora-epel/${rhel}/${arch}/epel-release-${rhel}-8.noarch.rpm
else 
	 echo "Error installing EPEL repository. Try looking for RHEL${rhel} ${arch} repositories online."
fi

# Check for packages needed for Webminstats
yum -y update
yum -y install rrdtool 

#This may or may not install
yum -y install perl-rrdtool
