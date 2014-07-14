logman delete PERFMON_BASE
logman create counter PERFMON_BASE -f bincirc -si 00:00:05 --v -o "%UserProfile%\%COMPUTERNAME%" -cf "%UserProfile%\perfmon_counters.cfg"
logman start perfmon_base
REM. ping to wait for script to gather information
REM.  -w XXXX where X is time in seconds; 21600 seconds = 6 hours
ping 127.0.0.1 -n 1 -w 21600 > nul
logman stop perfmon_base
