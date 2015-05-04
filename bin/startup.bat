@echo off
REM
REM  PROGRAM:
REM  startup.bat
REM
REM  DESCRIPTION:
REM  Start the CheckValve Chat Relay in the background
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

REM --- Default debugging options
set DEF_DEBUG_HOST=localhost
set DEF_DEBUG_PORT=1044
set DEBUG=0
set DEBUG_OPTS=
set DEBUG_HOST=%DEF_DEBUG_HOST%
set DEBUG_PORT=%DEF_DEBUG_PORT%

REM --- Default minimum heap size for CheckValve Chat Relay
set DEF_JVM_MIN_MEM=8m
set JVM_MIN_MEM=%DEF_JVM_MIN_MEM%

REM --- Default maximum heap size for CheckValve Chat Relay
set DEF_JVM_MAX_MEM=16m
set JVM_MAX_MEM=%DEF_JVM_MAX_MEM%

REM --- Check for command line options
:check_opts
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
)
if "%1"=="--debug" (
        set DEBUG=1
        shift
        goto check_opts
)
if "%1"=="--debughost" (
    if "%2"=="" (
        echo.
        echo ERROR: The option --debughost requires a value.
        goto usage
    ) else (
        set DEBUG_HOST=%2
        shift
        shift
        goto check_opts
    )
)
if "%1"=="--debugport" (
    if "%2"=="" (
        echo.
        echo ERROR: The option --debugport requires a value.
        goto usage
    ) else (
        set DEBUG_PORT=%2
        shift
        shift
        goto check_opts
    )
)
if "%1"=="--minheap" (
    if "%2"=="" (
        echo.
        echo ERROR: The option --minheap requires a value.
        goto usage
    ) else (
        set JVM_MIN_MEM=%2
        shift
        shift
        goto check_opts
    )
)
if "%1"=="--maxheap" (
    if "%2"=="" (
        echo.
        echo ERROR: The option --maxheap requires a value.
        goto usage
    ) else (
        set JVM_MAX_MEM=%2
        shift
        shift
        goto check_opts
    )
)

echo.
echo ERROR: Invalid option %1
goto usage

REM --- Make sure the directory ..\lib exists
:check_lib_dir
if not exist ..\lib (
    goto no_lib_dir
) else (
    goto check_bundled_java
)

REM --- Check for a bundled JRE
:check_bundled_java
if exist ..\jre\bin\javaw.exe (
    set JAVA_BIN=..\jre\bin\javaw.exe
    goto run_program
) else (
    goto check_system_java
)

REM --- Check for Java in the system PATH
:check_system_java
javaw.exe -version >NUL 2>NUL

if errorlevel 1 (
    goto no_java
)
if errorlevel 0 (
    set JAVA_BIN=javaw.exe
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
goto exit

REM --- Display an error and exit if Java could not be found
:no_java
echo.
echo ERROR: Unable to locate the 'java' executable.
echo.
echo Please ensure the Java Runtime Environment (JRE) is installed
echo and the 'java' executable can be found in your PATH.
echo.
goto exit

REM --- Run chatrelayctl to start the Chat Relay
:run_program
cd ..\lib
if %DEBUG%==1 (
    DEBUG_OPTS=--debug --debughost %DEBUG_HOST% --debugport %DEBUG_PORT%
    start /b %JAVA_BIN% -jar chatrelayctl.jar --config %CONFIG_FILE% --minheap %JVM_MIN_MEM% --maxheap %JVM_MAX_MEM "%DEBUG_OPTS%" start
    echo Started CheckValve Chat Relay.
    echo (Debugging mode is enabled, connect jdb to %DEBUG_HOST%:%DEBUG_PORT% for debugging).
) else (
    start /b %JAVA_BIN% -jar chatrelayctl.jar --config %CONFIG_FILE% --minheap %JVM_MIN_MEM% --maxheap %JVM_MAX_MEM start
    echo Started CheckValve Chat Relay.
)
goto exit

:usage
echo.
echo Usage: %0 [--config <file>] [--minheap <size>] [--maxheap <size>] [--debug [--debughost <ip>] [--debugport <port>]]
echo        %0 [--help]
echo.
echo Command-line options:
echo.
echo   --config <file>     Read config from <file> [default = %DEF_CONFIG_FILE%]
echo   --minheap <size>    Set the JVM's minimum heap size to <size> [default = %DEF_JVM_MIN_MEM%]
echo   --maxheap <size>    Set the JVM's maximum heap size to <size> [default = %DEF_JVM_MAX_MEM%]
echo   --debug             Enable the Java debugging listener (for use with jdb)
echo   --debughost <ip>    IP for jdb connections if debugging is enabled [default = %DEF_DEBUG_HOST%]
echo   --debugport <port>  Port for jdb connections if debugging is enabled [default = %DEF_DEBUG_PORT%]
echo   --help              Show this help text and exit
echo.
echo Note: For --minheap and --maxheap, the <size> value should be a number followed by k, m, or g
echo       kilobytes, megabytes, or gigabytes, respectively.  (Ex: 1048576k, 1024m, 1g).
echo.
goto exit

:exit
pause
exit
