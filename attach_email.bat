set directory="C:\Users\myuser\pictures"
set email=myemail@gmail.com

if exist "%ProgramFiles(x86)%" (
    set outlook="C:\Program Files (x86)\Microsoft Office\Office14\OUTLOOK.EXE"
    )
else(
    set outlook="C:\Program Files\Microsoft Office\Office14\OUTLOOK.EXE"
    )
pushd %directory%
for /f "delims= " %%f in ('dir /b /a-d-h-s *') do (
    %outlook% /c ipm.note /a "%%~ff" /m "%email%&subject=%%f&body=Attached %%f"
)
