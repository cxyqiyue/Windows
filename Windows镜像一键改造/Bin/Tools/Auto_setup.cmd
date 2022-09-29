@echo off
title 全自动安装Win11 By 知彼而知己
echo.
reg query HKU\S-1-5-19 1>nul 2>nul || goto :Admin
echo   正在启动......
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
echo 请以管理员身份运行
echo.
pause >nul












