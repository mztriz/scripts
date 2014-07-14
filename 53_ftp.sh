#!/bin/bash
# This script is based on the 5/3 FTP script created by Bharat Shah on 28-FEB-2012 
# Ava Gailliot 
# More desc and usage 


#######GLOBALVARS#######

export HOST=""
export UNAME=""
export PSWD=""
export data_set="" 
export phone="" # Contact info for errors
export waittime=600
export errorcode=0
export XXAP_TOP=/path/to/xxap_top/dir
export arch_file_list=$(ls -ltr "$XXAP_TOP/dat/outbound/ach_53/"| grep -v total | awk '{print $9}') # List of files to process

#######FUNCTIONS#######

function processFTPFiles()
{
	cntr=0 # Counter for loop

	for file in ${arch_file_list}; do
		
		now="$(date '+%d%h%Y_%I%M%S')" # Grab current date and time in format 12Jun2014_093713 during each iteration of $file to update time
		cntr=$("$cntr"+1) # Increase counter by one to determine the current file number being worked on
		file_path=$("$XXAP_TOP/dat/outbound/ach_53/$file") # Absolute path for $file 
        summary_file=$("$XXAP_TOP/dat/outbound/ach_53/summ_$file") # Summary for each file inside $arch_file_list          	
        
        # Need full path for these two files
        export ftp_53_cmds="ftp_53$cntr"
        export ftp_53_sum_cmds="ftp_53_summ$cntr"
        
        echo -e "\nNow working on file number $cntr named $file at time : $now"

         # Read $file and check the first char from each line for number "9"
        while read line; do 
        	char=$(echo "$line" | cut -c1-1) # Grab first char from line 
        	if [[ "$char" -eq 9 ]]; then # Check for "9"
        		 break; # Move to next line        	
        	else 
				echo -e "\n ERROR: Format non-compliance encountered. Please correct the errors in $file and re-run. Program Aborted.\n"
        		mailx -s "ACH Format non-compliance encountered in $file. Please fix these errors and re-run." appsdbas@tbamerica.com,dkumar@tbamerica.com,treasury@tbamerica.com,slad@tbamerica.com < "$file_path"
        		# Exit program
				exit
			fi
			
			# Create and write this line to $summary_file for each $file
			echo "AXXXXXXXX $(echo "$line" | cut -c32-43) $(echo "$line" | cut -c44-55) $phone" > "summary_file"

        done < "$file_path"

        # Write FTP commands out to new files "ftp_53$cntr" and "ftp_53_summ$cntr"
		echo "open $HOST
    	user $UNAME $PSWD
    	cd FTTBAI01
    	quote site lrecl=94
    	put $file_path $data_set" | tee -a "$ftp_53_cmds" "ftp_53_sum_cmds" 
        
        echo "quit" >> "$ftp_53_cmds"
    	
    	echo "put $summary_file $data_set
        quit" >> "$ftp_53_sum_cmds"

	    echo "mv $file_path $file_path$now
	    chmod 655 $file_path$now" >> "/oaprod/r12/inst/apps/oaprod_erlopd1/logs/appl/conc/log/cp_files_arch$cntr.sh" # What is this script?

	    echo "Original file $file archived to $XXAP_TOP/dat/archive/ach_53/$file$now" >> /oaprod/r12/inst/apps/oaprod_erlopd1/logs/appl/conc/log/arch_files.txt

	    # What is this script?
	    chmod 750 "ftp_53_cmds" "/oaprod/r12/inst/apps/oaprod_erlopd1/logs/appl/conc/log/cp_files_arch$cntr.sh"

	    transferFTP "$file_path" "$cntr"

    done
}

function transferFTP()
{	
	# Name the vars passed from processFTPFiles for readability
	file_path=$1
	num=$2
	
	echo "Waiting For $waittime seconds before processing file number $num"    
    sleep "$waittime"
    
    ftp -n -v < "ftp_53_cmds" 1> "ftp_53$num.log" # Need path for log file

    if [ $? -eq 0 ]; then
            echo "The wait time of $waittime seconds completed successfully for filenumber $num"
	else
    	cntr=0
	    while [ $? -ne 0 -a "$cntr" -le 3 ]; do
	        ftp -n -v < "ftp_53_cmds" 1> "ftp_53$num.log" # Need path for log file
	        cntr=$("$cntr"+1)
	        
	        if [ $? -ne 0 -a "$cntr" -eq 3 ]; then                
	            echo "Error while waiting for $waittime seconds before processing job $num"
	            mailx -s "$(echo "$HOSTNAME - Error while waiting for $waittime seconds before processing job $num")" myemail@gmail.com < "$file_path"
	        else
	        	echo "The wait time of $waittime seconds completed successfully for file number $num"
	        fi
	    done
    fi
    
    "cp_files_arch$num.sh" > "cp_files_arch$num.log" 2>&1

    echo "Waiting for $waittime seconds before FTPing the summary file $num"

    sleep "$waittime"

    echo -e "\n"

    # Check if the log file size is greater than 0
    if [ "$(ls -l "cp_files_arch$num.log" | awk '{ print $5}')" -gt 0 ]; then

        mailx -s "$(echo "$ORACLE_SID Alert $HOSTNAME") - $(echo "$ORACLE_SID") ACH (53Bank) file not archived." myemail@gmail.com < "$APPLCSF/log/cp_files_arch$num.log"
        errorcode=2 # Error interprted by Oracle app

    fi
}


#######EXECUTION#######

# Check if one or more files exsist in directory "$XXAP_TOP/dat/outbound/ach_53/" for processing
if [ "$("$arch_file_list" | wc -l)" -gt 0 ]; then 
	processFTPFiles
else
	echo "There are currently no files in $arch_files_list to process."
fi
