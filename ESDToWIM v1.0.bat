:start
color 0f
title ESDToWIM
set /a convertedindexes=0
@echo off
cls
echo Welcome to ESDToWIM.
echo.
:esd.locate
set /p esd=Please locate install.esd: 
if exist "%esd%" (
	goto esd.output
) else (
	goto esd.locate
)
:esd.output
set /p wim=Please select output filename and location: 
goto esd.info

:esd.info
color 1f
dism /Get-WimInfo /WimFile:"%esd%"
:esd.option
echo.
echo 1=Select single index number.
echo 2=Select all indexes.
echo.
set /p option=Select an option: 
if "%option%"=="1" goto esd.getindex
if "%option%"=="2" goto esd.getallindexes
goto esd.option

:esd.getindex
echo.
set /p index=Please select an index number: 
if NOT "%index%"=="" (
	goto esd.convert
) else (
	goto esd.getindex
)

:esd.convert
cls
title ESDToWIM - Converting index %index%
echo Converting index %index%
dism /export-image /SourceImageFile:"%esd%" /SourceIndex:%index% /DestinationImageFile:"%wim%" /Compress:max /CheckIntegrity
goto wim.success

:esd.getallindexes
echo.
set /p totalindexes=What is the total amount of inexes: 
if NOT "%totalindexes%"=="" (
	goto esd.convertallindexes
) else (
	goto esd.getallindexes
)

:esd.convertallindexes
cls
set /a convertedindexes=%convertedindexes%+1
title ESDToWIM - Converting index %convertedindexes% of %totalindexes%
echo Converting index %convertedindexes% of %totalindexes%
dism /export-image /SourceImageFile:"%esd%" /SourceIndex:%convertedindexes% /DestinationImageFile:"%wim%" /Compress:max /CheckIntegrity
if %convertedindexes%==%totalindexes% goto wim.success
goto esd.convertallindexes

:wim.success
color 2f
cls
echo Successfully converted ESD to WIM.
echo.
pause