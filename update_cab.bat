@echo off
setlocal enabledelayedexpansion

::Ava Gailliot 
::This script will remove old CTLs in the CryptnetUrlCache directory to avoid event ID Event ID 4107 or Event ID 11 errors
::See http://support.microsoft.com/default.aspx?scid=kb;en-us;2328240 for more information on the error

::Create log file
set LOG_FILE=C:\WINDOWS\TEMP\urlCache.log 
>nul copy nul %LOG_FILE%

::Log old URL cache
certutil -v -urlcache >%LOG_FILE% 

::Remove URL cache
certutil -urlcache * delete 

::Remove certificates from local system profiles per http://support.microsoft.com/default.aspx?scid=kb;en-us;2328240
del %windir%\ServiceProfiles\LocalService\AppData\LocalLow\Microsoft\CryptnetUrlCache\Content\*.*
del %windir%\ServiceProfiles\LocalService\AppData\LocalLow\Microsoft\CryptnetUrlCache\MetaData\*.*
del %windir%\ServiceProfiles\NetworkService\AppData\LocalLow\Microsoft\CryptnetUrlCache\Content\*.*
del %windir%\ServiceProfiles\NetworkService\AppData\LocalLow\Microsoft\CryptnetUrlCache\MetaData\*.*
del %windir%\System32\config\systemprofile\AppData\LocalLow\Microsoft\CryptnetUrlCache\Content\*.*
del %windir%\System32\config\systemprofile\AppData\LocalLow\Microsoft\CryptnetUrlCache\MetaData\*.*
