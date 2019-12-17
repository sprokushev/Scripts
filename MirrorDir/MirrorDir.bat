rem ===================================================================
rem MirrorDir.bat - синхронизация каталогов
rem Пример запуска MirrorDir.bat  S:\test C:\test1
rem 	Первый параметр - каталог-источник
rem 	Второй параметр - каталог-назначение
rem ===================================================================

SET SOURCE_DIR=%1
SET DEST_DIR=%2
SET LOG=MirrorDir.log
SET MAX_SIZE_LOG=100000
chcp 1251

rem Собственно копирование
rem http://technet.microsoft.com/en-us/library/cc733145(WS.10).aspx
rem /E - копировать с подкаталогами
rem /PURGE - удалять в каталоге-назначении файлы, отстуствующие в каталоге-источнике
rem The /mir option is equivalent to the /e plus /purge options with one small difference in behavior:
rem With the /e plus /purge options, if the destination directory exists, the destination directory security settings are not overwritten.
rem With the /mir option, if the destination directory exists, the destination directory security settings are overwritten
rem /R:0 - не будет пытаться повторно копировать открытые файлы
rem /DCOPY:T - файлы в каталоге-назначении будут иметь такой же timestamp как в каталоге-источнике
rem /ZB - файлы копируются в Restart-режиме. Если это не возможно - используется Backup-режим.
rem /LOG+: - дописывать в лог-файл
rem /TS /BYTES - для каждого копируемого файла показывать размер и timestamp
rem /TEE - дублировать на консоль информацию, записываемую в лог
rem /NP - не показывать прогресс в % (иначе лог-файл раздувается)

echo ================================================================================================ >> %LOG% 2>&1
echo Started on %COMPUTERNAME% >> %LOG% 2>&1

Robocopy %SOURCE_DIR% %DEST_DIR% /E /PURGE /R:0 /DCOPY:T /ZB /LOG+:%LOG% /TS /BYTES /TEE /NP

echo ================================================================================================ >> %LOG% 2>&1

rem ужмем лог-файл до %MAX_SIZE_LOG% строк
CALL :PackLOG %LOG% %MAX_SIZE_LOG%

goto :eof



:PackLog
rem Лог не должен превышать определенный размер в строках
rem имя файла лога = %1
rem максимальный размер лога в строках = %2

SET newLOG=%1
SET sizeLOG=%2
SET Line=0

For /F "usebackq" %%A In (`Type %newLOG% ^| Find /V /C ""`) Do Set /A Line=%%A - %sizeLOG%
IF %Line% LSS 0 SET Line=0
More +%Line% %newLOG% > %TEMP%\temp.log 

type %TEMP%\temp.log > %newLOG% 2>&1
del /Q %TEMP%\temp.log

goto :eof
