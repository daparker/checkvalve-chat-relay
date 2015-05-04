@echo off
REM
REM  PROGRAM:
REM  shutdown.bat
REM
REM  DESCRIPTION:
REM  Stop the CheckValve Chat Relay
REM
REM  AUTHOR:
REM  Dave Parker
REM
REM  DATE:  
REM  May 4, 2015
REM

REM --- Default configuration file
set DEF_CONFIG_FILE=..\checkvalvechatrelay.properties
set CONFIG_FILE=%DEF_CONFIG_FILE%

if "%1"=="" goto check_lib_dir
if "%1"=="--help" goto usage
if "%1"=="--config" (
    if "%2"=="" (
        echo.
        echo ERROR: The option --config requires a value.
        goto usage
    ) else (
        set CONFIG_FILE=%2
        shift
        shift
        goto check_opts
    )
) else (
    echo.
    echo ERROR: Invalid option %1
    goto usage
)

REM --- Make sure the directory ..\lib exists
:check_lib_dir
if not exist ..\lib (
    goto no_lib_dir
) else (
    goto check_bundled_java
)

REM --- Check for a bundled JRE
:check_bundled_java
if exist ..\jre\bin\java.exe (
    set JAVA_BIN=..\jre\bin\java.exe
    goto run_program
) else (
    goto check_system_java
)

REM --- Check for Java in the system PATH
:check_system_java
java.exe -version >NUL 2>NUL

if errorlevel 1 (
    goto no_java
)
if errorlevel 0 (
    set JAVA_BIN=java.exe
    goto run_program
)

REM --- Display and error and exit if ..\lib does not exist
:no_lib_dir
echo.
echo ERROR: Could not find the 'lib' directory in the parent folder.
echo.
echo Please ensure that this script is being executed from the
echo <install_dir>\bin folder, where <install_dir> is the base
echo installation folder of the CheckValve Chat Relay.
echo.
pause
goto exit

REM --- Display an error and exit if Java could not be found
:no_java
echo.
echo ERROR: Unable to locate the 'java' executable.
echo.
echo Please ensure the Java Runtime Environment (JRE) is installed and
echo the 'java' executable can be found in your PATH.
echo.
pause
goto exit

REM --- Run chatrelayctl to stop the Chat Relay 
:run_program
cd ..\lib
%JAVA_BIN% -jar lib\chatrelayctl.jar --config %CONFIG_FILE% stop
goto exit

:usage
echo.
echo Usage: %0 [--config <file>]
echo        %0 [--help]
echo.
echo Command-line options:
echo.
echo   --config <file>     Read config from <file> [default = %DEF_CONFIG_FILE%]
echo   --help              Show this help text and exit
echo.
pause
goto exit

:exit
