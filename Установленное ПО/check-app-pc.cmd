@echo off
rem Этот командный файл проверяет, установлена ли заданная программа на
rem удалённых компьютерах.
rem %1 Название программы или часть названия, например, VISIO.

rem подготовим файл с результатами
echo > %2

rem перебираем названия компьютеров из файла checkpc.txt
for /F %%a in ('type checkpc.txt') do call :checkpc %%a %1 %2

goto :eof


rem проверяем наличие нужной программы на удаленном компьютере
:checkpc
rem echo '%1;%2'
set pc_name=%1
set app_name=%2

set reg_key=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
call listapp.cmd | findstr /i "%~2" >> %3

set reg_key=HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall
call listapp.cmd | findstr /i "%~2" >> %3

goto :eof


