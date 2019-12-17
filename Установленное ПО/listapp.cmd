@echo off
rem перебираем список ПО из реестра удаленного ПК
rem echo '%pc_name%;%reg_key%;%app_name%'
for /F "tokens=1,2,*" %%a in ('reg query "\\%pc_name%\%reg_key%" /s') do if "%%a" == "DisplayName" echo %pc_name%;%reg_key%;%%c
