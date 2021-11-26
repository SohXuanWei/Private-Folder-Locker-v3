REM version 3 uses 7z utility: AES encryption, and hash calculation
REM reliance on 7z cli utility

@echo off
cls
title Folder Private
if EXIST Locked.7z goto UNLOCK
if NOT EXIST Private goto MDLOCKER

:CONFIRM
echo Are you sure you want to lock the folder(Y/N)
echo Input (R) to reset password, (H) to reset hint
set/p "cho=>"
if %cho%==Y goto LOCK
if %cho%==y goto LOCK
if %cho%==n goto END
if %cho%==N goto END
if %cho%==R goto SETPW
if %cho%==r goto SETPW
if %cho%==H goto SETHT
if %cho%==h goto SETHT
echo Invalid choice.
goto CONFIRM

:LOCK
set /p passw=<Private/password.txt
call :SETHASH
7z a -p%passw% -mhe=on Locked.7z Private > nul
attrib +h +s Locked.7z > nul
attrib +h +s hash
rmdir /Q /S "Private" > nul
echo Folder has been locked
goto End

:UNLOCK
attrib -h -s hint
set /p gethint=<hint
attrib +h +s hint
echo Enter password to unlock folder (hint: %gethint%)
set/p "pass=>"
echo %pass%> pass.txt
for /f "delims=" %%i in ('7z h pass.txt ^| findstr data:') do set userh=%%i
del /f pass.txt 
set /p compareh=<hash
IF NOT "%userh:~30,8%"=="%compareh%" goto FAIL 
rmdir /Q /S Private > nul
7z x -p%pass% Locked.7z > nul
attrib -h -s Locked.7z > nul
del /f Locked.7z > nul
echo Folder Unlocked successfully
goto End 

:FAIL
echo Invalid password
goto end

:MDLOCKER
md Private
echo Private created successfully
echo empty hash> hash
attrib +h +s hash

:SETPW
REM ask user to input password
echo Please define a password:
set/p "pwdef=>"
echo %pwdef%> Private/password.txt

:SETHT
REM ask user to set a hint
echo Enter a hint for your password (ENTER to skip):
attrib -h -s hint
set/p curht=<hint
attrib +h +s hint
echo Current Hint: %curht%
set/p "htdef=>"
attrib -h -s hint
echo %htdef%> hint
attrib +h +s hint

:SETHASH
REM find crc and place in hash file
for /f "delims=" %%i in ('7z h Private/password.txt ^| findstr data:') do set output=%%i
attrib -h -s hash
echo %output:~30,8%> hash
attrib +h +s hash

:End
pause
