rem ========= Запускаем только на определенных ПК ==============
rem IF .%COMPUTERNAME%.==.WHS. GOTO next
IF .%COMPUTERNAME%.==.PSV. GOTO next
GOTO :eof

:next
rem ========= Запускаем по очереди ==============
rem CALL :Backup WHS
CALL :Backup PSV 
goto :eof



:Backup
rem ========= Определяем, какой ПК бакапим и настраиваем пути ==============
SET BACKUPCOMP=%1
IF .%BACKUPCOMP%.==.WHS. GOTO :set_whs
IF .%BACKUPCOMP%.==.PSV. GOTO :set_psv
GOTO :eof

:set_whs
SET BACKUPDIR=\\PSV\BACKUP\
SET CHECKDIR=\\WHS\BACKUP\
GOTO :run

:set_psv
SET BACKUPDIR=\\PSVMEDIA\C\BACKUP\
SET CHECKDIR=\\PSV\D$\BACKUP\
GOTO :run

:run
set TT=%TIME: =0%
set DD=%DATE: =0%
SET BACKUPFILE=%BACKUPDIR%%BACKUPCOMP%.7z
SET TEMPFILE=%TEMP%\%BACKUPCOMP%.7z
SET BACKUPFILEUPDATE=%BACKUPDIR%%BACKUPCOMP%_%DD:~6,4%_%DD:~3,2%_%DD:~0,2%_%TT:~0,2%_%TT:~3,2%_%TT:~6,2%.7z
SET LOGFILE=LOG\%BACKUPCOMP%_%DD:~6,4%_%DD:~3,2%_%DD:~0,2%_%TT:~0,2%_%TT:~3,2%_%TT:~6,2%.log

echo Start backup at %DD% %TT% > %LOGFILE%

rem CALL :UpdateSource  >> %LOGFILE%

rem проверяем флаг сегодняшнего запуска
date /T > %CHECKDIR%CheckDate.%BACKUPCOMP%
IF NOT EXIST %CHECKDIR%CheckDate.%BACKUPCOMP% GOTO :nohost
findstr /G:%CHECKDIR%CheckDate.%BACKUPCOMP% %BACKUPDIR%LastBackup.%BACKUPCOMP%
IF %ERRORLEVEL% EQU 0 goto :nobackup
goto :gobackup
goto :eof

:nobackup
echo %BACKUPCOMP% backed up today >> %LOGFILE%
goto :eof

:nohost
echo %BACKUPCOMP% not available >> %LOGFILE%
goto :eof


:gobackup
CALL :DelOldBackup  >> %LOGFILE%
rem IF EXIST %BACKUPFILE% (CALL :IncrementBackup >> %LOGFILE%) ELSE (CALL :FullBackup >> %LOGFILE%) 
CALL :CopyToRemote D:\Cloud@Mail.Ru\psv_gray2\Photos \\PSVMEDIA\C\Photos  >> %LOGFILE%
CALL :CopyToRemote C:\Users\‘ҐаЈҐ©\Desktop \\PSVMEDIA\C\Backup\Desktop  >> %LOGFILE%
CALL :CopyToRemote C:\WM \\PSVMEDIA\C\Backup\WM  >> %LOGFILE%
CALL :CopyToRemote D:\Documents \\PSVMEDIA\C\Backup\Documents >> %LOGFILE%
CALL :CopyToRemote D:\Favorites \\PSVMEDIA\C\Backup\Favorites >> %LOGFILE%
CALL :CopyToRemote D:\Links \\PSVMEDIA\C\Backup\Links >> %LOGFILE%
CALL :CopyToRemote D:\outlook \\PSVMEDIA\C\Backup\outlook >> %LOGFILE%
CALL :CopyToRemote D:\WORK \\PSVMEDIA\C\Backup\WORK >> %LOGFILE%
CALL :CopyToRemote D:\Џа®ЄгиҐў  \\PSVMEDIA\C\Backup\Џа®ЄгиҐў  >> %LOGFILE%
CALL :CopyToRemote D:\‘ўҐв _д«ҐиЄ  \\PSVMEDIA\C\Backup\‘ўҐв _д«ҐиЄ  >> %LOGFILE%

date /T > %BACKUPDIR%LastBackup.%BACKUPCOMP%
echo Finish backup at %DATE% %TIME% >> %LOGFILE%

goto :eof


:FullBackup
del /Q %TEMPFILE%
echo %ERRORLEVEL%
7z.exe a %TEMPFILE% -pehfufy2009 -ssw -y -scsWIN -xr@exclude.all -i@include.%BACKUPCOMP%
echo %ERRORLEVEL%
xcopy %TEMPFILE% %BACKUPDIR% /Y /R /Z
echo %ERRORLEVEL%
goto :eof


:IncrementBackup
7z.exe u %BACKUPFILE% -pehfufy2009 -u- -up3q3r2x2y2z0w2!%BACKUPFILEUPDATE% -ssw -y -scsWIN -xr@exclude.all -i@include.%BACKUPCOMP%
echo %ERRORLEVEL%
goto :eof


:UpdateSource
xcopy C:\WORK\BACKUP\*.* \\%BACKUPCOMP%\C$\WORK\BACKUP\ /D /R /Y /Z /E
echo %ERRORLEVEL%
xcopy \\%BACKUPCOMP%\C$\WORK\BACKUP\*.* C:\WORK\BACKUP\ /D /R /Y /Z /E
echo %ERRORLEVEL%
goto :eof


:CopyToRemote
rem (for /r "%1" %%a in (*) do @echo N)|xcopy /s "%1\*" "%2\"
robocopy %1 %2 /E /PURGE /Z /J /M /BYTES /NP /TS /FP /R:0 /XF file P1010358*.MP4
echo %ERRORLEVEL%

rem xcopy %1\*.* %2\ /D /R /Y /Z /S
rem echo %ERRORLEVEL%
rem xcopy %2\*.* %1\ /D /R /Y /Z /S
rem echo %ERRORLEVEL%

goto :eof


:DelOldBackup
rem Waitdel.exe %BACKUPDIR%*.* 7 00:00:00
Waitdel.exe LOG\*.* 7 00:00:00
echo %ERRORLEVEL%
goto :eof



