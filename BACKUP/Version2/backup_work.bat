SET LOGFILE=%TEMP%\Backup_work.log

SET EXCLUDE_FILES=/XF *.modd /XF *.moff /XF *.bak /XF thumbs.db /XF ~$*.*

SET PARAMS=/S /Z /A /DST /NP /X /FP /NDL /R:2 /W:5 %EXCLUDE_FILES% /LOG+:%LOGFILE% 

Robocopy.exe C:\Users\sprokushev\Desktop "D:\OneDrive\Backup\sprokushev\Desktop" %PARAMS% 

Robocopy.exe C:\Users\sprokushev\Favorites "D:\OneDrive\Backup\sprokushev\Favorites" %PARAMS% 

Robocopy.exe C:\Users\sprokushev\Links "D:\OneDrive\Backup\sprokushev\Links" %PARAMS% 

