# DeskGo腾讯桌面整理连接扩展屏幕异常处理

## 缘由

最近从同事处薅了个显示屏，使用起来比小屏幕强多了（分辨率再高点就好了）。  
由于本人文件繁杂，故使用[腾讯桌面整理](https://guanjia.qq.com/product/zmzl/), 但是当切换/拔插显示屏的时候，桌面却乱掉了。去官网查过无果，故自己想写个脚本一键自动备份/恢复桌面的配置。

## 使用

### 思路

经过使用发现其配置文件就是ConFile.dat、DesktopMgr.lg、FencesDataFile.dat这三个文件，所以只需要备份这三个文件即可。备份路径选择为同目录的/Backup  

![](https://gitee.com/ridup/PicGo-Images/raw/master/blog/20210113110136.png)

### 脚本

``` BASH
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
```

附Github地址：https://github.com/Ridup/DeskGoExtendedScreen
