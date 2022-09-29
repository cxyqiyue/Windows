@echo off
title Windows镜像一键改造 By cxyqiyue
reg query HKU\S-1-5-19 1>nul 2>nul || goto :Admin

pushd "%~dp0"
SET "Version=v1.2"
TITLE Windows镜像一键改造 %version% By cxyqiyue
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && ( set "arch=x86" ) || ( set "arch=x64" )
if %arch%==x86 (
  set "_wimlib=bin\wimlib-imagex.exe"
  set "xOS=x86"
) else (
  set "_wimlib=bin\bin64\wimlib-imagex.exe"
  set "xOS=amd64"
)

:Loop
cls
color 2F
echo.
echo   ======================================================
ECHO     ※※※※※※ Windows 所有版本通用 ※※※※※※
echo   ======================================================
ECHO.
ECHO             [1] 无人值守
ECHO.
ECHO.
ECHO             [2] 跳过在线登录
ECHO.
ECHO.
ECHO             [3] 无人值守+跳过在线登录
ECHO.
echo   ======================================================
ECHO     ※※※※※※ 解除 Windows11 硬件要求检测 ※※※※※※
echo   ======================================================
ECHO.
ECHO             [4] 绕过Win11硬件检测
ECHO.
ECHO.
ECHO             [5] 绕过Win11硬件检测+无人值守
ECHO.
ECHO.
ECHO             [6] 绕过Win11硬件检测+跳过在线登录
ECHO.
ECHO.
ECHO             [7] 绕过Win11硬件检测+无人值守+跳过在线登录
ECHO.
ECHO.
SET "FiX="
SET "CHOICE="
SET /P CHOICE="* 请选择[1,2,3,4,5,6,7]并按回车确认: "
IF /I '%CHOICE%'=='1' SET "FiX=1"
IF /I '%CHOICE%'=='2' SET "FiX=2"
IF /I '%CHOICE%'=='3' SET "FiX=3"
IF /I '%CHOICE%'=='4' SET "FiX=4"
IF /I '%CHOICE%'=='5' SET "FiX=5"
IF /I '%CHOICE%'=='6' SET "FiX=6"
IF /I '%CHOICE%'=='7' SET "FiX=7"

IF NOT DEFINED FiX GOTO :Loop

if exist "Work" rmdir /q /s "Work"
if exist "TEMP" rmdir /q /s "TEMP"
if not exist "Source_ISO\*.iso" (
echo.
ECHO ===============================
echo 没有在文件夹Source_ISO内找到ISO镜像...
ECHO ===============================
echo.
pause
exit /b
)

mkdir "TEMP"
for /f "delims=" %%i in ('dir /b Source_ISO\*.iso') do bin\7z.exe e -y -oTEMP "Source_ISO\%%i" sources\setup.exe >nul
bin\7z.exe l .\TEMP\setup.exe >.\TEMP\version.txt 2>&1
for /f "tokens=4 delims=. " %%i in ('findstr /i /b FileVersion .\TEMP\version.txt') do set vermajor=%%i
for /f "tokens=4,5 delims=. " %%i in ('findstr /i /b FileVersion .\TEMP\version.txt') do (set majorbuildnr=%%i&set deltabuildnr=%%j)
IF NOT DEFINED vermajor (
if exist "TEMP" rmdir /q /s "TEMP"
echo.
ECHO ===============================
echo 检测到 setup.exe 版本失败...
ECHO ===============================
echo.
pause
exit /b
)

echo.
ECHO ===============================
echo 提取 Source ISO...
ECHO ===============================
bin\7z x -y -oWork\ Source_ISO\
echo.
if exist "Work\sources\install.wim" set WIMFILE=install.wim
if exist "Work\sources\install.esd" set WIMFILE=install.esd
REM detect wim arch
for /f "tokens=2 delims=: " %%# in ('dism.exe /english /get-wiminfo /wimfile:"Work\sources\%WIMFILE%" /index:1 ^| find /i "Architecture"') do set warch=%%#
for /f "tokens=3 delims=: " %%m in ('dism.exe /english /Get-WimInfo /wimfile:"Work\sources\%WIMFILE%" /Index:1 ^| findstr /i Build') do set b2=%%m

:WindowsLang
REM detect extracted win11 iso language
set "IsoLang=ar-SA,bg-BG,cs-CZ,da-DK,de-DE,el-GR,en-GB,en-US,es-ES,es-MX,et-EE,fi-FI,fr-CA,fr-FR,he-IL,hr-HR,hu-HU,it-IT,ja-JP,ko-KR,lt-LT,lv-LV,nb-NO,nl-NL,pl-PL,pt-BR,pt-PT,ro-RO,ru-RU,sk-SK,sl-SI,sr-RS,sv-SE,th-TH,tr-TR,uk-UA,zh-CN,zh-TW"
for %%i in (%IsoLang%) do if exist "Work\sources\%%i\*.mui" set %%i=1

REM set ISO label lang
for %%i in (%IsoLang%) do if defined %%i (
SET "LabelLang=%%i"
)

If /I "%FiX%"=="1" GOTO :FiX1
If /I "%FiX%"=="2" GOTO :FiX2
If /I "%FiX%"=="3" GOTO :FiX3
If /I "%FiX%"=="1" GOTO :FiX4
If /I "%FiX%"=="2" GOTO :FiX5
If /I "%FiX%"=="3" GOTO :FiX6
If /I "%FiX%"=="3" GOTO :FiX7

:FiX1
echo.
echo ===============================
echo 复制 AutoUnattend.xml 到 ISO\...
echo 复制 Auto_setup.cmd 到 ISO\...
echo ===============================
COPY /Y "Bin\Tools\AutoUnattend.xml" "Work\"
COPY /Y "Bin\Tools\Auto_setup.cmd" "Work\"

:FiX2
echo.
echo ===============================
echo 复制$OEM$到 ISO\sources\...
echo ===============================
XCOPY /S /Y "Bin\Tools\$OEM$" "Work\sources\$OEM$\"

:FiX3
echo.
echo ===============================
echo 复制 AutoUnattend.xml 到 ISO\...
echo 复制 Auto_setup.cmd 到 ISO\...
echo 复制$OEM$到 ISO\sources\...
echo ===============================
COPY /Y "Bin\Tools\AutoUnattend.xml" "Work\"
COPY /Y "Bin\Tools\Auto_setup.cmd" "Work\"
XCOPY /S /Y "Bin\Tools\$OEM$" "Work\sources\$OEM$\"

:FiX4
echo.
echo ===============================
echo 修改 install.wim/esd 安装类型...
echo ===============================
for /f "tokens=2 delims==" %%# in ('%%_wimlib%% info Work\sources\%%WIMFILE%% --header  ^| find "Image Count"') do set "_imagecount=%%#"
for /L %%i in (1,1,%_imagecount%) do %_wimlib% info Work\sources\%WIMFILE% %%i --image-property WINDOWS/INSTALLATIONTYPE=Server

:FiX5
echo.
echo ===============================
echo 修改 install.wim/esd 安装类型...
echo 复制 AutoUnattend.xml 到 ISO\...
echo 复制 Auto_setup.cmd 到 ISO\...
echo ===============================
for /f "tokens=2 delims==" %%# in ('%%_wimlib%% info Work\sources\%%WIMFILE%% --header  ^| find "Image Count"') do set "_imagecount=%%#"
for /L %%i in (1,1,%_imagecount%) do %_wimlib% info Work\sources\%WIMFILE% %%i --image-property WINDOWS/INSTALLATIONTYPE=Server
COPY /Y "Bin\Tools\AutoUnattend.xml" "Work\"
COPY /Y "Bin\Tools\Auto_setup.cmd" "Work\"

:FiX6
echo.
echo ===============================
echo 修改 install.wim/esd 安装类型...
echo 复制$OEM$到 ISO\sources\...
echo ===============================
for /f "tokens=2 delims==" %%# in ('%%_wimlib%% info Work\sources\%%WIMFILE%% --header  ^| find "Image Count"') do set "_imagecount=%%#"
for /L %%i in (1,1,%_imagecount%) do %_wimlib% info Work\sources\%WIMFILE% %%i --image-property WINDOWS/INSTALLATIONTYPE=Server
XCOPY /S /Y "Bin\Tools\$OEM$" "Work\sources\$OEM$\"

:FiX7
echo.
echo ===============================
echo 修改 install.wim/esd 安装类型...
echo 复制 AutoUnattend.xml 到 ISO\...
echo 复制 Auto_setup.cmd 到 ISO\...
echo 复制$OEM$到 ISO\sources\...
echo ===============================
for /f "tokens=2 delims==" %%# in ('%%_wimlib%% info Work\sources\%%WIMFILE%% --header  ^| find "Image Count"') do set "_imagecount=%%#"
for /L %%i in (1,1,%_imagecount%) do %_wimlib% info Work\sources\%WIMFILE% %%i --image-property WINDOWS/INSTALLATIONTYPE=Server
COPY /Y "Bin\Tools\AutoUnattend.xml" "Work\"
COPY /Y "Bin\Tools\Auto_setup.cmd" "Work\"
XCOPY /S /Y "Bin\Tools\$OEM$" "Work\sources\$OEM$\"

:ISO_FiX
echo.
echo ===============================
echo 复制 ei.cfg 到 ISO\Sources\...
echo ===============================
COPY /Y "Bin\Tools\EI.CFG" "Work\Sources\"
echo.
echo ===============================
echo 生成 %WARCH% ISO...
echo ===============================
for /f "delims=" %%i in ('dir /b Source_ISO\*.iso') do set "isoname=%%i"
set "isoname=%isoname:~0,-4%_Trained.ISO"
Bin\cdimage.exe -bootdata:2#p0,e,b"Work\boot\etfsboot.com"#pEF,e,b"Work\efi\Microsoft\boot\efisys.bin" -o -m -u2 -udfver102 -lWin_%Winver%_%vermajor%_%warch%_%LabelLang% work "%isoname%"

:cleanup
pushd "%~dp0"
if exist "TEMP" rmdir /q /s "TEMP"
if exist "Work" rmdir /q /s "Work"
pause
exit /b

:Admin
echo.
echo  请以管理员身份运行!
echo.
pause >nul