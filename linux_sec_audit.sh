#!/bin/sh
# Ava Gailliot
# This script creates an audit report of the system for review and sends an e-mail to the administrator.

# Set path for cron
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin

email=myemail@gmail.com

# Log files
auditlog=/tmp/$(hostname)_audit.log

# Remove old logs
rm -rf $auditlog

# Generate audit report
aureport --summary >> $auditlog 2>&1
aureport -f -i --failed --summary >> $auditlog 2>&1

# Check for known Linux rootkits
rkhunter --versioncheck > /dev/null
rkhunter --update > /dev/null
rkhunter --cronjob --report-warnings-only  >> $auditlog 2>&1

# E-mail results
echo | mutt -a $auditlog -s "Monthly Security Audit Report for $HOSTNAME" $email
