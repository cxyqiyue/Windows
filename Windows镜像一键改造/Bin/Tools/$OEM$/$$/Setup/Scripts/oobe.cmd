@echo off
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE /v BypassNRO /t REG_DWORD /d 1 /f
shutdown /r /t 10
del /F /Q %systemroot%\setup\scripts\oobe.cmd