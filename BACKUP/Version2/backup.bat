SET LOGFILE=%TEMP%\Backup.log

SET EXCLUDE_FILES=/XF *.modd /XF *.moff /XF *.bak /XF thumbs.db /XF ~$*.*

SET PARAMS=/S /Z /A /DST /NP /X /FP /NDL /R:2 /W:5 %EXCLUDE_FILES% /LOG+:%LOGFILE% 

Robocopy.exe C:\Users\Public\Desktop "D:\OneDrive\Backup\Public\Desktop" %PARAMS% 

Robocopy.exe C:\Users\Public\Favorites "D:\OneDrive\Backup\Public\Favorites" %PARAMS% 

Robocopy.exe C:\Users\Sveta\Desktop "D:\OneDrive\Backup\Sveta\Desktop" %PARAMS% 

Robocopy.exe C:\Users\Sveta\Favorites "D:\OneDrive\Backup\Sveta\Favorites" %PARAMS% 

Robocopy.exe C:\Users\winadmin\Desktop "D:\OneDrive\Backup\winadmin\Desktop" %PARAMS% 

Robocopy.exe C:\Users\winadmin\Favorites "D:\OneDrive\Backup\winadmin\Favorites" %PARAMS% 

Robocopy.exe C:\Users\Serge\Desktop "D:\OneDrive\Backup\Serge\Desktop" %PARAMS% 

Robocopy.exe D:\Favorites "D:\OneDrive\Backup\Serge\Favorites" %PARAMS% 

Robocopy.exe D:\OneDrive\Фото \\PSVDS\PHOTO\ %PARAMS% 

