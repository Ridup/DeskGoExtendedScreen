@echo off
echo current time is %date%  %time%
:begin
echo OPTIONS:
echo 1.back up
echo 2.refresh
set option=
set /p option=Please choose the option:
echo %option%
FOR /F "delims=" %%k in ('wmic process get executablepath^|findstr DesktopMgr') DO SET RunPath=%%k
echo %RunPath%
FOR /F "delims=" %%k in ('wmic process get name^|findstr DesktopMgr') DO SET Name=%%k
echo %Name%
Set "WMIC_Command=wmic path Win32_VideoController get VideoModeDescription^,CurrentHorizontalResolution^,CurrentVerticalResolution /format:Value"
Set "H=CurrentHorizontalResolution"
Set "V=CurrentVerticalResolution"
Call :GetResolution %H% HorizontalResolution
Call :GetResolution %V% VerticalResolution
::Screen Resolution
echo  Screen Resolution is : %HorizontalResolution% x %VerticalResolution%
SET GenDir="%APPDATA%\Tencent\DeskGo\Backup\%HorizontalResolution% x %VerticalResolution%"
echo %GenDir%
if not exist %GenDir% (
  md "%APPDATA%\Tencent\DeskGo\Backup\%HorizontalResolution% x %VerticalResolution%"
) else (
  echo %GenDir%
)
if "%option%"=="1" (
:: backup Your config files to %APPDATA%\Tencent\DeskGo\Backup\%HorizontalResolution% x %VerticalResolution%
copy  /Y  "%APPDATA%\Tencent\DeskGo\ConFile.dat" "%APPDATA%\Tencent\DeskGo\Backup\%HorizontalResolution% x %VerticalResolution%\ConFile.dat"
copy  /Y  "%APPDATA%\Tencent\DeskGo\DesktopMgr.lg" "%APPDATA%\Tencent\DeskGo\Backup\%HorizontalResolution% x %VerticalResolution%\DesktopMgr.lg"
copy  /Y  "%APPDATA%\Tencent\DeskGo\FencesDataFile.dat" "%APPDATA%\Tencent\DeskGo\Backup\%HorizontalResolution% x %VerticalResolution%\FencesDataFile.dat"
) else (
::kill
taskkill /F /IM %Name%
::Your backup config files eg:**/1920 x 1080
copy  /Y "%APPDATA%\Tencent\DeskGo\Backup\%HorizontalResolution% x %VerticalResolution%" "%APPDATA%\Tencent\DeskGo"
::The DeskGo installed directory
"%RunPath%"
)
goto begin
::****************************************************
:GetResolution 
FOR /F "tokens=2 delims==" %%I IN (
  '%WMIC_Command% ^| find /I "%~1" 2^>^nul'
) DO FOR /F "delims=" %%A IN ("%%I") DO SET "%2=%%A"
Exit /b
::****************************************************