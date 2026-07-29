@echo off
REM ygg — Yggdrasil CLI entry point (batch dispatcher)
REM Usage: ygg <subcommand> [args...]

set "SCRIPT_DIR=%~dp0"

if "%1"=="" goto :noargs

REM Pass all arguments through — ygg.ps1 parses the first as subcommand.
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%ygg.ps1" %*
exit /b %ERRORLEVEL%

:noargs
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%ygg.ps1"
exit /b %ERRORLEVEL%
