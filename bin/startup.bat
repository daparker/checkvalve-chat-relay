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
REM  May 2, 2015
REM

goto check_bundled_java

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

REM --- Display an error and exit if Java could not be found
:no_java
echo.
echo ERROR: Unable to locate the 'java' executable.
echo.
echo Please ensure the Java Runtime Environment (JRE) is installed and
echo the 'java' executable can be found in your PATH.
echo.
goto exit

REM --- Run chatrelayctl to start the Chat Relay 
:run_program
cd ..\lib
%JAVA_BIN% -jar chatrelayctl.jar start
goto exit

:exit
