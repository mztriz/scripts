#!/bin/bash
# Ava Gailliot
# Find and replace domain name from system files

olddomain=myolddomain.com
newdomain=mynewdomain.com

configs=( '/etc/hosts' '/etc/exports' '/etc/fstab' '/etc/sysconfig/network' )
for file in "${configs[@]}"
do
	# Replace domain name and create backup file
	sed -i.bak -e "s/$olddomain/$newdomain/g" ${file}
done

# Find SSH keys for all users 
for user in $(awk -F':' '{ print $1}' /etc/passwd)
do
    sed -i.bak -e "s/$olddomain/$newdomain/g" /home/${user}/.ssh/*
done

# Update DNS
echo "nameserver 172.17.238.135 
nameserver 172.17.238.7
options attempts:5
options  timeout:15" > /etc/resolv.conf

# Set domain name in path
set $HOSTNAME=$(echo "${HOSTNAME%%.*}.$newdomain")

# Restart network
service network restart

# Update NFS
exportfs -a

# Search for .sh files
# find . -name \*.sh -exec grep -l 
