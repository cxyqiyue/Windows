@echo off
title ȫ�Զ���װWin11 By ֪�˶�֪��
echo.
reg query HKU\S-1-5-19 1>nul 2>nul || goto :Admin
echo   ��������......
if  not exist  "%~dp0AutoUnattend.xml" (
reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\WinPE" || (reg query "HKLM\SYSTEM\CurrentControlSet\Control" /v SystemStartOptions | find /i "MINNT" || (start "11" "%~dp0setup.exe" &exit))
start "11" "%~dp0sources\setup.exe"
exit
)else (
reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\WinPE" || (reg query "HKLM\SYSTEM\CurrentControlSet\Control" /v SystemStartOptions | find /i "MINNT" || (start "11" "%~dp0setup.exe" /unattend:"%~dp0AutoUnattend.xml" &exit))
start "11" "%~dp0sources\setup.exe" /unattend:"%~dp0AutoUnattend.xml"
exit
)

:Admin
echo ���Թ���Ա�������
echo.
pause >nul












