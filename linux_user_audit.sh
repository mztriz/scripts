#!/bin/bash
# Ava Gailliot
# Audit of OS users for PWC

email=myemail@gmail.com
echo "Server: $HOSTNAME"
for user in $(cat /etc/passwd | cut -d":" -f1)
do
        echo -e "\nUsername: $user"

        if [ -d "/home/$user" ]
        then
                echo "Account creation date: $(ls -lah /home/$user/.bashrc | awk '{print $6,$7,$8}')"
        else
                echo "Account creation date: $(tune2fs -l /dev/sda1 | grep created | awk '{print $4,$5,$7}')"
        fi

        echo "Account ID and OS access group: $(id $user)"
        echo "Last login: $(lastlog -u "$user" | awk '{print $5,$6,$9}')"
done
#echo | mutt -a users.txt -s "Users Audit for $HOSTNAME" $email
