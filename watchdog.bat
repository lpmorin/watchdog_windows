@echo off
rem ���̼��ӳ��򣬳����˳����Զ�����
rem zhangpengyf@myhexin.com

set checkcolor=0A
set restartcolor=0E
set startcolor=0C
color %checkcolor%
rem ��������
set taskname=hexincs.exe
set taskpath=.\hexincs.exe
set configpath=..\conf\cs.ini
set steptime=2

title %taskname%��ع���V1.0
echo *****%taskname%��ع���V1.0*****

rem ��ȡ�����ļ����ҵ������Զ�����ʱ��
set restarttime=NULL
for /f "skip=1 tokens=1,2 delims==" %%a IN (%configpath%) Do if Restart==%%a set restarttime=%%b

rem �ж���û�������Զ�����ʱ��
set brestart=true
set restarthour=100
set restartmin=100
if %restarttime% == NULL (set brestart=false)
if %brestart% == true (
echo ��⵽%taskname%�����Զ��������ܣ�ʱ���趨Ϊ:%restarttime%
set /a restarthour=%restarttime%/100
set /a restartmin=%restarttime:~-2,2%
)else (echo %taskname%����δ�����Զ���������)

rem s==small
set shour=%restarthour%
set /a sminute=%restartmin%-2


rem b==big
set bhour=%restarthour%
set /a bminute=%restartmin%+2

rem ��ǰ��n���Ӳ����м��,��2���ӣ�����ʱ��Ϊ600���558-602�����

rem ������ǰn���ӣ��������С��n���⴦����ҪСʱ��һ����СʱΪ0���һ��Ϊ23
if %restartmin% LSS %steptime% (
set /a sminute=%restartmin%+60-%steptime% 
set /a shour=%restarthour%-1
)
if %shour% EQU -1 (set /a shour=23)
set /a shhmm=%shour%*100+%sminute%

rem �����Ӻ�n���ӣ�������Ӵ��ڵ���60-n���⴦����ҪСʱ��һ����СʱΪ24���һ��Ϊ0
if %restartmin% GEQ 60-%steptime% (
set /a sminute=%restartmin%+%steptime%-60 
set /a shour=%restarthour%+1
)
if %shour% EQU 24 (set /a shour=0)
set /a bhhmm=%bhour%*100+%bminute%
set bprint=false

:loop
rem �ҵ����ڵ�ʱ�䲢����Ϊһ������
set hour=%time:~,2%
set minute=%time:~3,2%
set hhmm=%hour%%minute%

rem �����������shhmm<bhhmm��shhmm>bhhmm��������������ʱ��0:00
if %shhmm% LSS %bhhmm% if %brestart% == true if %hhmm% GEQ %shhmm% if %hhmm% LEQ %bhhmm% (
	color %restartcolor%
	if %bprint% == false (
		echo �������Զ�����ʱ��,ֹͣ����
		set bprint=true
		)
	ping 127.1 -n 1 >nul 2>nul
	goto loop
)
if %shhmm% GTR %bhhmm% if %brestart% == true if %hhmm% GEQ %shhmm% (
	color %restartcolor%
	if %bprint% == false (
		echo �������Զ�����ʱ��,ֹͣ����
		set bprint=true
		)
	ping 127.1 -n 1 >nul 2>nul
	goto loop
)
if %shhmm% GTR %bhhmm% if %brestart% == true if %hhmm% LEQ %bhhmm% (
	color %restartcolor%
	if %bprint% == false (
		echo �������Զ�����ʱ��,ֹͣ����
		set bprint=true
		)
	ping 127.1 -n 1 >nul 2>nul
	goto loop
)

if %brestart% == true (color %checkcolor%)
if %bprint% == true (
	echo �Ѷȹ��Զ�����ʱ��,��������
	set bprint=false
	)

for /f %%a in ('tasklist.exe /FI "IMAGENAME eq %taskname%" /FI "STATUS eq RUNNING" /FO TABLE /NH^|find.exe /i "û��"') do (
 color %startcolor%
 echo ��⵽%taskname%δ����
 start %taskpath%
 ping 127.1 -n 2 >nul 2>nul
 color %checkcolor%
 echo ������
 goto :loop
)

ping 127.1 -n 1 >nul 2>nul
goto :loop
