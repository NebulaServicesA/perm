@echo off
setlocal EnableDelayedExpansion
title HWID/SMBIOS Spoofer - Temp Download Mode
color 0A

:: ───────────────────────────────────────────────
:: Check Administrator rights
:: ───────────────────────────────────────────────
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [91m[-] Administrator rights required[0m
    echo Relaunching with elevation...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: ───────────────────────────────────────────────
:: Prepare TEMP folder for tools (randomized name)
:: ───────────────────────────────────────────────
set "chars=ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
set "hex=0123456789ABCDEF"
call :randName FOLDER_RAND 8
set "TEMPDIR=%TEMP%\spoof_!FOLDER_RAND!"
if not exist "%TEMPDIR%" mkdir "%TEMPDIR%" >nul 2>&1
set "LOG=%TEMPDIR%\spoofer.log"
echo. > "%LOG%"
echo [%date% %time%] Spoofer session started >> "%LOG%"

:: ───────────────────────────────────────────────
:: Generate random file names (anti-crack / detection)
:: ───────────────────────────────────────────────
call :randName AMIDE_RAND 12
set "AMIDE_FILE=!AMIDE_RAND!.exe"
call :randName VOL_RAND 12
set "VOL_FILE=!VOL_RAND!.exe"
call :randName RSTR_RAND 12
set "RSTR_FILE=!RSTR_RAND!.bat"
call :randName TPM_RAND 12
set "TPM_FILE=!TPM_RAND!.bat"
set "AMI_FILE=amifldrv64.sys"  :: kept fixed for driver compatibility

:: ───────────────────────────────────────────────
:: Download required tools silently (random names)
:: ───────────────────────────────────────────────
set "baseurl=https://github.com/NebulaServicesA/perm/raw/refs/heads/main/"

if not exist "%TEMPDIR%\%AMIDE_FILE%" (
    powershell -Command "try { Invoke-WebRequest -Uri '%baseurl%AMIDEWINx64.EXE' -OutFile '%TEMPDIR%\%AMIDE_FILE%' -UseBasicParsing } catch { exit 1 }" >> "%LOG%" 2>&1
    if errorlevel 1 (
        echo [91m[-] Failed to download AMIDE tool[0m
        echo Check your internet or the URL. Aborting.
        goto :cleanup_fail
    )
)

if not exist "%TEMPDIR%\%VOL_FILE%" (
    powershell -Command "try { Invoke-WebRequest -Uri '%baseurl%Volumeid64.exe' -OutFile '%TEMPDIR%\%VOL_FILE%' -UseBasicParsing } catch { exit 1 }" >> "%LOG%" 2>&1
    if errorlevel 1 (
        echo [91m[-] Failed to download VolumeID tool[0m
        echo Check your internet or the URL. Aborting.
        goto :cleanup_fail
    )
)

if not exist "%TEMPDIR%\%AMI_FILE%" (
    powershell -Command "try { Invoke-WebRequest -Uri '%baseurl%amifldrv64.sys' -OutFile '%TEMPDIR%\%AMI_FILE%' -UseBasicParsing } catch { exit 1 }" >> "%LOG%" 2>&1
    if errorlevel 1 (
        echo [91m[-] Failed to download AMI driver[0m
        echo Check your internet or the URL. Aborting.
        goto :cleanup_fail
    )
)

if not exist "%TEMPDIR%\%RSTR_FILE%" (
    powershell -Command "try { Invoke-WebRequest -Uri '%baseurl%randstr.bat' -OutFile '%TEMPDIR%\%RSTR_FILE%' -UseBasicParsing } catch { exit 1 }" >> "%LOG%" 2>&1
    if errorlevel 1 (
        echo [91m[-] Failed to download randstr tool[0m
        echo Check your internet or the URL. Aborting.
        goto :cleanup_fail
    )
)

if not exist "%TEMPDIR%\%TPM_FILE%" (
    powershell -Command "try { Invoke-WebRequest -Uri '%baseurl%tpmbypass.bat' -OutFile '%TEMPDIR%\%TPM_FILE%' -UseBasicParsing } catch { exit 1 }" >> "%LOG%" 2>&1
    if errorlevel 1 (
        echo [91m[-] Failed to download TPM bypass script[0m
        echo Check your internet or the URL. Aborting.
        goto :cleanup_fail
    )
)

:: Give files a second to settle (sometimes antivirus delays)
timeout /t 2 /nobreak >nul

:: ───────────────────────────────────────────────
:: Generate random values (using local functions)
:: ───────────────────────────────────────────────
call :randSerial SERIAL 16
call :randSerial BSERIAL 16
call :randSerial CSERIAL 16
call :randSerial SK 16
call :randHex VID_C1 4 & call :randHex VID_C2 4 & set "VOL_C=!VID_C1!-!VID_C2!"
call :randHex VID_D1 4 & call :randHex VID_D2 4 & set "VOL_D=!VID_D1!-!VID_D2!"
call :randHex VID_F1 4 & call :randHex VID_F2 4 & set "VOL_F=!VID_F1!-!VID_F2!"
call :randHex VID_E1 4 & call :randHex VID_E2 4 & set "VOL_E=!VID_E1!-!VID_E2!"
call :randHex VID_G1 4 & call :randHex VID_G2 4 & set "VOL_G=!VID_G1!-!VID_G2!"

(
    echo SERIAL=!SERIAL!
    echo BASEBOARD=!BSERIAL!
    echo CPUSERIAL=!CSERIAL!
    echo SK=!SK!
    echo VOL_C=!VOL_C!
    echo VOL_D=!VOL_D!
    echo VOL_F=!VOL_F!
    echo VOL_E=!VOL_E!
    echo VOL_G=!VOL_G!
) > "%TEMPDIR%\spoofvars.txt" 2>nul

for /f "tokens=1,* delims==" %%A in ("%TEMPDIR%\spoofvars.txt") do set "%%A=%%B"

:: ───────────────────────────────────────────────
:: SMBIOS Spoofing
:: ───────────────────────────────────────────────
echo.
echo [93m[+] Spoofing SMBIOS...[0m
cd /d "%TEMPDIR%" 2>nul
(
    !AMIDE_FILE! /SS "!SERIAL!"
    !AMIDE_FILE! /BS "!BSERIAL!"
    !AMIDE_FILE! /PSN "!CSERIAL!"
    !AMIDE_FILE! /SK "!SK!"
    !AMIDE_FILE! /SU AUTO
    !AMIDE_FILE! /SP "To Be Filled By O.E.M."
    !AMIDE_FILE! /BP "To Be Filled By O.E.M."
    !AMIDE_FILE! /PAT "To Be Filled By O.E.M."
    !AMIDE_FILE! /PPN "To Be Filled By O.E.M."
) >> "%LOG%" 2>&1
if !errorlevel! equ 0 (
    echo [92m[+] SMBIOS spoofed successfully[0m
) else (
    echo [91m[-] SMBIOS write failed ─ see log[0m
    goto :cleanup_fail
)
cd /d "%~dp0"

:: ───────────────────────────────────────────────
:: Network reset / trace cleanup
:: ───────────────────────────────────────────────
echo.
echo [93m[+] Resetting network stack...[0m
(
    netsh winsock reset
    netsh winsock reset catalog
    netsh int ip reset
    netsh advfirewall reset
    netsh int ipv4 reset
    netsh int ipv6 reset
    ipconfig /release
    ipconfig /flushdns
    ipconfig /renew
    arp -d
    wmic path win32_networkadapter where physicaladapter=true call disable
    wmic path win32_networkadapter where physicaladapter=true call enable
) >> "%LOG%" 2>&1
echo [92m[+] Network reset completed[0m

:: ───────────────────────────────────────────────
:: Volume ID Spoofing
:: ───────────────────────────────────────────────
echo.
echo [93m[+] Changing Volume IDs...[0m
for %%d in (C D E F G) do (
    vol %%d: >nul 2>&1
    if !errorlevel! equ 0 (
        "%TEMPDIR%\!VOL_FILE!" %%d: !VOL_%%d! >> "%LOG%" 2>&1
        if !errorlevel! equ 0 (
            echo [92m[+] Volume %%d: set to !VOL_%%d![0m
        ) else (
            echo [91m[-] Volume %%d: failed[0m
        )
    ) else (
        echo [90m[i] Drive %%d: not present ─ skipped[0m
    )
)

:: ───────────────────────────────────────────────
:: TPM bypass (if script exists)
:: ───────────────────────────────────────────────
if exist "%TEMPDIR%\!TPM_FILE!" (
    echo.
    echo [93m[+] Running TPM bypass script...[0m
    call "%TEMPDIR%\!TPM_FILE!" >> "%LOG%" 2>&1
    echo [92m[+] TPM bypass finished[0m
)

:: ───────────────────────────────────────────────
:: Final cleanup
:: ───────────────────────────────────────────────
:cleanup
echo.
echo [92m[+] Operation completed. Cleaning up...[0m
del /f /q "%TEMPDIR%\spoofvars.txt" >nul 2>&1
rd /s /q "%TEMPDIR%" >nul 2>&1
if exist "%TEMPDIR%" (
    echo [91m[!] Could not fully delete temp folder[0m
    echo Some files may remain in: %TEMPDIR%
)
echo.
echo [93mPlease Do The Following:[0m
echo  Win+R → tpm.msc  Clear TPM Restart PC
echo  Full reboot 
echo Reset Pc For No Traces Unless Ban
echo.
echo Press any key to exit...
pause >nul
exit /b

:cleanup_fail
echo.
echo [91m[!] Process aborted due to error[0m
echo Cleaning up downloaded files...
goto :cleanup

:: ───────────────────────────────────────────────
:: Helper functions
:: ───────────────────────────────────────────────
:randName
setlocal
set "res="
set /a n=%~2
if !n! lss 1 set n=8
for /l %%i in (1,1,!n!) do (
    set /a idx=!random! %% 36
    for %%x in (!idx!) do set "res=!res!!chars:~%%x,1!"
)
endlocal & set "%~1=%res%"
exit /b

:randSerial
setlocal
set "res="
set /a n=%~2
if !n! lss 1 set n=16
for /l %%i in (1,1,!n!) do (
    set /a idx=!random! %% 36
    for %%x in (!idx!) do set "res=!res!!chars:~%%x,1!"
)
endlocal & set "%~1=%res%"
exit /b

:randHex
setlocal
set "res="
for /l %%i in (1,1,%~2) do (
    set /a idx=!random! %% 16
    for %%x in (!idx!) do set "res=!res!!hex:~%%x,1!"
)
endlocal & set "%~1=%res%"
exit /b