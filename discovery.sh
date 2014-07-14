#!/bin/bash
# Ava Gailliot
# Script requires fd0ssh or gcc if using password arg
# Ex. ./discovery.sh -k /home/ava/.ssh/id_rsa.pub -l hosts_list.txt -p myseceretpassword

# Optional command line args
usage() { echo "Usage: $0 [ -k ssh_key_file ] [ -l list_of_hosts_file ]  [ -p password ]" 1>&2; exit 1; }

# Using bash built-in getopts for args
while getopts ":k:l:p:" options; do
    case "${options}" in
        k)
            k=${OPTARG}
            if [ ! -f "$k" ];then
                echo "Error: no such file $k"
                usage
            else
                export ssh_key=$k
            fi
            ;;
        l)
            l=${OPTARG}
            if [ ! -f "$l" ];then
                echo "Error: no such file $l"
                usage
            else
                export hosts=$l
            fi
            ;;
        p)
            p=${OPTARG}
            export pass=$p
            ;;
        *)
            usage
            ;;
    esac
done

# Check if password arg is set
if [ ! -z "$pass" ];then
         if [ ! -f fd0ssh ]; then
                # Install and compile C helper tool fd0ssh (from hxtools, not pmt) for stdin ssh passwords
                wget --no-check-certificate https://raw.github.com/ghthor/hxtools/master/sadmin/fd0ssh.c
                gcc fd0ssh.c  -o fd0ssh -lm
        fi
fi

#######GLOBALVARS#######
# Log file
export log=/tmp/discovery.sh

#######FUNCTIONS#######
function checkHosts()
{
        # Check if var $hosts exists from args
        if [ -z "$hosts" ];then
                # Prompt for hostname if a list of hosts is not set
        read -p "Target IP or hostname: " host
        # Check if SSH is open on port 22
        if  $(curl -s $host:22 | grep SSH > /dev/null 2>&1);then
                targetHost "$host"
                else
                echo "Error: SSH on $host is unreachable."
                fi
        else
                # Loop through list of hosts from the file
                for host in $(cat $hosts)
                do
                        # Check if SSH is open on port 22
                        if  $(curl -s $host:22 | grep SSH > /dev/null 2>&1);then
                        targetHost "$host"
                        else
                        echo "Error: SSH on $host is unreachable." >> $log 2>&1
                        fi
                done
        fi
}

function targetHost()
{
        commands="echo \"$pass\" | sudo -S su
mkdir -p /home/dbadirect/inventory
chmod -R 777 home/dbadirect/inventory
cd  /home/dbadirect/invetory
rpm -Uvh wget http://apt.sw.be/redhat/el6/en/i386/rpmforge/RPMS/cfg2html-1.79-1.el6.rf.noarch.rpm
/usr/bin/cfg2html
echo | mutt -a '$HOSTNAME.html' -s 'CFG2HTML foer $HOSTNAME' ava.gailliot@dbadirect.com"
echo $commands
        # Check if var $ssh_key exists from args
        if [ -z "$ssh_key" ];then
                if [ ! -z "$pass" ];then
                        echo "$pass" | $PWD/./fd0ssh ssh $host -t "$commands"
                else
                        $(ssh $host -t "$commands")
                fi
        else
                if [ ! -z "$pass" ];then
                         echo "$pass" | $PWD/./fd0ssh ssh -i $ssh_key $host -t "$commands"
                else
                        ssh -i $sshkey $host -t "$commands"
                fi
        fi
}

#######EXECUTION#######
# Check if SSH is open on host then pass to targetHost for SSH and other funcs
checkHosts
