@echo off
rem ���� ��������� ���� ���������, ����������� �� �������� ��������� ��
rem �������� �����������.
rem %1 �������� ��������� ��� ����� ��������, ��������, VISIO.

rem ���������� ���� � ������������
echo > %2

rem ���������� �������� ����������� �� ����� checkpc.txt
for /F %%a in ('type checkpc.txt') do call :checkpc %%a %1 %2

goto :eof


rem ��������� ������� ������ ��������� �� ��������� ����������
:checkpc
rem echo '%1;%2'
set pc_name=%1
set app_name=%2

set reg_key=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
call listapp.cmd | findstr /i "%~2" >> %3

set reg_key=HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall
call listapp.cmd | findstr /i "%~2" >> %3

goto :eof


