:start
@echo off
color

set /a convertedindexes=0
set bar==============================================================
set title=ESDToWIM
title %title%

reg query "HKEY_USERS\S-1-5-19\Environment" /v TEMP 2>&1 | findstr /I /C:"REG_EXPAND_SZ" 2>&1 >nul
If %ERRORLEVEL%==0 goto welcome
goto noadmin

:welcome
cls
echo %bar%
echo.
echo Welcome to %title%.
echo.
echo %bar%
echo.
choice /c ax /t 2 /d a >nul
if %ERRORLEVEL%==2 goto debug

:locate
title Locate files - %title%
cls
echo %bar%
echo.
echo install.esd: %esd%
echo install.wim: %wim%
echo.
echo %bar%
echo.
if "%esd%"=="" (
	set /p esd=Please locate install.esd: 
	goto locate
)
if "%wim%"=="" (
	set /p wim=Please select output filename and location: 
	goto locate
)
choice /m "Confirm file locations"
if %ERRORLEVEL%==1 goto esd.info
if %ERRORLEVEL%==2 (
	set esd=
	set wim=
	goto locate
)

:esd.info
title Select index - %title%
cls
echo %bar%
dism /Get-WimInfo /WimFile:"%esd%"
echo.
echo %bar%
echo.
echo 1=Convert single index.
echo 2=Convert all indexes.
echo.
echo %bar%
echo.
set /p choice=Please elect an option: 
if "%choice%"=="1" goto esd.getindex
if "%choice%"=="2" goto esd.getallindexes
goto esd.info

:esd.getindex
set /p index=Please select an index number: 
if NOT "%index%"=="" (
	goto esd.convert
) else (
	goto esd.getindex
)

:esd.convert
color 1f
cls
title Converting index %index% - %title%
echo Converting index %index%
dism /export-image /SourceImageFile:"%esd%" /SourceIndex:%index% /DestinationImageFile:"%wim%" /Compress:max /CheckIntegrity
goto wim.success

:esd.getallindexes
set /p totalindexes=Total amount of indexes: 
if NOT "%totalindexes%"=="" (
	goto esd.convertallindexes
) else (
	goto esd.getallindexes
)

:esd.convertallindexes
color 1f
cls
set /a convertedindexes=%convertedindexes%+1
title Converting index %convertedindexes% of %totalindexes% - %title%
echo Converting index %convertedindexes% of %totalindexes%
dism /export-image /SourceImageFile:"%esd%" /SourceIndex:%convertedindexes% /DestinationImageFile:"%wim%" /Compress:max /CheckIntegrity
if %convertedindexes%==%totalindexes% goto wim.success
goto esd.convertallindexes

:wim.success
title Success - %title%
color 2f
cls
echo Successfully converted ESD to WIM.
echo.
pause
goto eoc

:debug
title Debug - %title%
set debug=
echo.
:cmd
set /p debug="%title% Debug %cd%>"
if "%debug%"=="" goto cmd
if "%debug%"=="exit" goto eoc
%debug%
goto debug

:noadmin
title Admin rights needed - %title%
cls
echo %bar%
echo.
echo Please run as administrator.
echo.
echo %bar%
goto eoc

:eoc
title Exiting - ESDToWIM
color
echo.
echo Goodbye.
timeout /t 3 /nobreak >nul
