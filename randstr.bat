@echo off
setlocal enabledelayedexpansion

set "charset=ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

set "result="
for /L %%i in (1,1,16) do (
    set /A idx=!random! %% 36
    for %%j in (!idx!) do set "char=!charset:~%%j,1!"
    set "result=!result!!char!"
)

echo %result%
exit /b
