rem ===================================================================
rem MirrorDir.bat - ������������� ���������
rem ������ ������� MirrorDir.bat  S:\test C:\test1
rem 	������ �������� - �������-��������
rem 	������ �������� - �������-����������
rem ===================================================================

SET SOURCE_DIR=%1
SET DEST_DIR=%2
SET LOG=MirrorDir.log
SET MAX_SIZE_LOG=100000
chcp 1251

rem ���������� �����������
rem http://technet.microsoft.com/en-us/library/cc733145(WS.10).aspx
rem /E - ���������� � �������������
rem /PURGE - ������� � ��������-���������� �����, ������������� � ��������-���������
rem The /mir option is equivalent to the /e plus /purge options with one small difference in behavior:
rem With the /e plus /purge options, if the destination directory exists, the destination directory security settings are not overwritten.
rem With the /mir option, if the destination directory exists, the destination directory security settings are overwritten
rem /R:0 - �� ����� �������� �������� ���������� �������� �����
rem /DCOPY:T - ����� � ��������-���������� ����� ����� ����� �� timestamp ��� � ��������-���������
rem /ZB - ����� ���������� � Restart-������. ���� ��� �� �������� - ������������ Backup-�����.
rem /LOG+: - ���������� � ���-����
rem /TS /BYTES - ��� ������� ����������� ����� ���������� ������ � timestamp
rem /TEE - ����������� �� ������� ����������, ������������ � ���
rem /NP - �� ���������� �������� � % (����� ���-���� �����������)

echo ================================================================================================ >> %LOG% 2>&1
echo Started on %COMPUTERNAME% >> %LOG% 2>&1

Robocopy %SOURCE_DIR% %DEST_DIR% /E /PURGE /R:0 /DCOPY:T /ZB /LOG+:%LOG% /TS /BYTES /TEE /NP

echo ================================================================================================ >> %LOG% 2>&1

rem ����� ���-���� �� %MAX_SIZE_LOG% �����
CALL :PackLOG %LOG% %MAX_SIZE_LOG%

goto :eof



:PackLog
rem ��� �� ������ ��������� ������������ ������ � �������
rem ��� ����� ���� = %1
rem ������������ ������ ���� � ������� = %2

SET newLOG=%1
SET sizeLOG=%2
SET Line=0

For /F "usebackq" %%A In (`Type %newLOG% ^| Find /V /C ""`) Do Set /A Line=%%A - %sizeLOG%
IF %Line% LSS 0 SET Line=0
More +%Line% %newLOG% > %TEMP%\temp.log 

type %TEMP%\temp.log > %newLOG% 2>&1
del /Q %TEMP%\temp.log

goto :eof
