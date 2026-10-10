@echo off
setlocal
where py >nul 2>nul
if errorlevel 1 goto TryPython
py -3 "%~dp0tools\build.py"
goto Finished
:TryPython
python "%~dp0tools\build.py"
:Finished
set "avpe_build_exit=%errorlevel%"
echo.
if "%avpe_build_exit%"=="0" (
    echo Build complete. Copy the rebuilt avpe_vehicles.pbo to the server and clients.
) else (
    echo Build failed. Read the error above. Python 3.9 or newer is required.
)
pause
exit /b %avpe_build_exit%

