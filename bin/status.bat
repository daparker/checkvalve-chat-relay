@echo off
REM
REM  PROGRAM:
REM  status.bat
REM
REM  DESCRIPTION:
REM  Get current status information from the CheckValve Chat Relay
REM
REM  AUTHOR:
REM  Dave Parker
REM
REM  DATE:  
REM  May 4, 2015
REM

REM --- Make sure the directory ..\lib exists
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

REM --- Run chatrelayctl to start the Chat Relay 
:run_program
cd ..\lib
start /b %JAVA_BIN% -jar chatrelayctl.jar status
pause
goto exit

:exit
