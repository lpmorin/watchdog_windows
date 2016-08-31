@echo off
rem 进程监视程序，程序退出后自动重启
rem zhangpengyf@myhexin.com

set checkcolor=0A
set restartcolor=0E
set startcolor=0C
color %checkcolor%
rem 启动参数
set taskname=hexincs.exe
set taskpath=.\hexincs.exe
set configpath=..\conf\cs.ini
set steptime=2

title %taskname%监控工具V1.0
echo *****%taskname%监控工具V1.0*****

rem 读取配置文件，找到程序自动重启时间
set restarttime=NULL
for /f "skip=1 tokens=1,2 delims==" %%a IN (%configpath%) Do if Restart==%%a set restarttime=%%b

rem 判断有没有设置自动重启时间
set brestart=true
set restarthour=100
set restartmin=100
if %restarttime% == NULL (set brestart=false)
if %brestart% == true (
echo 监测到%taskname%启用自动重启功能，时间设定为:%restarttime%
set /a restarthour=%restarttime%/100
set /a restartmin=%restarttime:~-2,2%
)else (echo %taskname%程序未启用自动重启功能)

rem s==small
set shour=%restarthour%
set /a sminute=%restartmin%-2


rem b==big
set bhour=%restarthour%
set /a bminute=%restartmin%+2

rem 对前后n分钟不进行检测,如2分钟，重启时间为600则对558-602不检测

rem 计算提前n分钟，如果分钟小于n特殊处理，需要小时减一，若小时为0则减一变为23
if %restartmin% LSS %steptime% (
set /a sminute=%restartmin%+60-%steptime% 
set /a shour=%restarthour%-1
)
if %shour% EQU -1 (set /a shour=23)
set /a shhmm=%shour%*100+%sminute%

rem 计算延后n分钟，如果分钟大于等于60-n特殊处理，需要小时加一，若小时为24则减一变为0
if %restartmin% GEQ 60-%steptime% (
set /a sminute=%restartmin%+%steptime%-60 
set /a shour=%restarthour%+1
)
if %shour% EQU 24 (set /a shour=0)
set /a bhhmm=%bhour%*100+%bminute%
set bprint=false

:loop
rem 找到现在的时间并计算为一个整数
set hour=%time:~,2%
set minute=%time:~3,2%
set hhmm=%hour%%minute%

rem 分两种情况，shhmm<bhhmm和shhmm>bhhmm，用来处理特殊时间0:00
if %shhmm% LSS %bhhmm% if %brestart% == true if %hhmm% GEQ %shhmm% if %hhmm% LEQ %bhhmm% (
	color %restartcolor%
	if %bprint% == false (
		echo 现在是自动重启时间,停止监视
		set bprint=true
		)
	ping 127.1 -n 1 >nul 2>nul
	goto loop
)
if %shhmm% GTR %bhhmm% if %brestart% == true if %hhmm% GEQ %shhmm% (
	color %restartcolor%
	if %bprint% == false (
		echo 现在是自动重启时间,停止监视
		set bprint=true
		)
	ping 127.1 -n 1 >nul 2>nul
	goto loop
)
if %shhmm% GTR %bhhmm% if %brestart% == true if %hhmm% LEQ %bhhmm% (
	color %restartcolor%
	if %bprint% == false (
		echo 现在是自动重启时间,停止监视
		set bprint=true
		)
	ping 127.1 -n 1 >nul 2>nul
	goto loop
)

if %brestart% == true (color %checkcolor%)
if %bprint% == true (
	echo 已度过自动重启时间,开启监视
	set bprint=false
	)

for /f %%a in ('tasklist.exe /FI "IMAGENAME eq %taskname%" /FI "STATUS eq RUNNING" /FO TABLE /NH^|find.exe /i "没有"') do (
 color %startcolor%
 echo 检测到%taskname%未运行
 start %taskpath%
 ping 127.1 -n 2 >nul 2>nul
 color %checkcolor%
 echo 已启动
 goto :loop
)

ping 127.1 -n 1 >nul 2>nul
goto :loop
