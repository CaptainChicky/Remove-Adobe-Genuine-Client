@echo off

:init
setlocal DisableDelayedExpansion
set "batchPath=%~0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
setlocal EnableDelayedExpansion

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
echo Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
echo args = "ELEV " >> "%vbsGetPrivileges%"
echo For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
echo args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
echo Next >> "%vbsGetPrivileges%"
echo UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
"%SystemRoot%\System32\WScript.exe" "%vbsGetPrivileges%" %*
exit /b

:gotPrivileges
setlocal & pushd .
cd /d %~dp0
if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)
cls
goto Start

:Start
echo Important note: Please ignore any "file/service/directory not found" errors. They are natural, and completely fine if they occur.
pause
echo This script will begin by deleting the Genuine Client folder in the 32 bit Program Files folder, along with the two Genuine Client services.
echo.
echo First we will stop the Genuine Client from running...
taskkill /f /im "AGMService.exe"
taskkill /f /im "AGSService.exe"
echo ======================================================================
echo Then we will delete the folders containing the client files.
Rmdir /s /q "C:\Program Files (x86)\Common Files\Adobe\AdobeGCClient" 
Rmdir /s /q "C:\Program Files (x86)\Common Files\Adobe\OOBE\PDApp\AdobeGCClient"
echo ======================================================================
echo Finally, we will delete the two services made by the Genuine Client.
sc.exe delete "AGMService"
sc.exe delete "AGSService"
echo ======================================================================
pause
echo Now, the script will remove a few more Genuine Client related files and folders found via the tool "Everything" by voidtools.
del /f /q /s "C:\Windows\System32\Tasks\AdobeGCInvoker-1.0"
del /f /q /s "C:\Windows\System32\Tasks_Migrated\AdobeGCInvoker-1.0"
del /f /q /s "C:\Program Files (x86)\Adobe\Adobe Creative Cloud\Utils\AdobeGenuineValidator.exe"
Rmdir /s /q "C:\Users\Public\Documents\AdobeGCData"
Rmdir /s /q "C:\Program Files (x86)\Common Files\Adobe\Adobe Desktop Common\AdobeGenuineClient"
echo ======================================================================
pause
echo Now that the above is removed, would you like to also remove the logs? 
echo (Please note that logs can help with diagnosis of problems, amongst others.)
set /p "choice=Y or N?..."
if /i "%choice%" == "Y" (
    	goto DelLog
) else if /i "%choice%" == "N" (
    	goto Finish
) else (
	echo Your input is not one of the choices. 
	echo Please try again...
	pause
	cls
	goto Pre
)

:DelLog
del /f /q /s "C:\Windows\Temp\adobegc.log"
del /f /q /s "C:\Users\maxfa\AppData\Local\Temp\adobegc.log"
goto Finish

:Finish
echo ======================================================================
echo Removal of Adobe Genuine Service has finished.
echo.
echo Please note that although Adobe Genuine Service's file, services, and folders have been removed, it may come back.
echo You will need to re-run this script, as the removal is not perfect.
echo Also note the fact that if you re-install or update any Adobe apps, the Adobe Genuine Service will be reinstroduces, so the script will need to be run again.
pause
cls
goto ending

:ending
echo Before you exit, btw there is an option, manual, deletiong of prefetch files created by Adobe Genuine Service.
echo.
echo To find these prefetch files, look in "C:\Windows\Prefetch".
echo Look for any .PF file with "AGS", "AMG", "AdobeGenuine", or of the like in the filename and delete that file manually. 
echo.
echo This will cause no harm to your computer, so don't worry :)
echo ======================================================================
echo I would like to give special thanks to the tool "Everything", v1.4.1.1000, by voidtools.
echo This tool makes an index of the entire file system, and makes it extremely fast and easy to search for files.
echo If you are interested, please visit "https://www.voidtools.com/"! :D
pause
exit
