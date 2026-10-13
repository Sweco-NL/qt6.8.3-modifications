@echo off

REM Visual Studio Env should be initialized (e.g. with vcvarsall.bat) 
REM Qt6 install should be in the path
set ROOTPATH=%CD%
ECHO Configure for %VSCMD_ARG_TGT_ARCH%

IF %VSCMD_ARG_TGT_ARCH%==x64 (
    SET SQLDRIVER_ARCH=x64
) ELSE (
    SET SQLDRIVER_ARCH=Win32
)


ECHO Generating GGOCI projects from CMake
set SQLDRIVERPATH=%ROOTPATH%\qtbase\src\plugins
set CMAKE_BUILD_DIR=%SQLDRIVERPATH%\build
set CMAKE_PROJECT_SOURCE=%SQLDRIVERPATH%\sqldrivers
ECHO %CMAKE_PROJECT_SOURCE%
REM Remove old build directory so no problem when swtiching between x86 and x64
IF EXIST %CMAKE_BUILD_DIR% (
    ECHO %CMAKE_BUILD_DIR% exists so removing it
    rmdir /s /q %CMAKE_BUILD_DIR%
)


REM ======== ADJUST PATH TO ORACLE INCLUDE AND LIB ========
set Oracle_INCLUDE_DIR=C:\Oracle\OCI_12
set Oracle_LIBRARY_DIR=C:\Oracle\OCI_12\%VSCMD_ARG_TGT_ARCH%\msvc
if not exist "%Oracle_INCLUDE_DIR%\" (
    echo ERROR: Oracle include directory does not exist: "%Oracle_INCLUDE_DIR%"
    exit /b 1
)

if not exist "%Oracle_LIBRARY_DIR%\" (
    echo ERROR: Oracle library directory does not exist: "%Oracle_LIBRARY_DIR%"
    exit /b 1
)
REM ======== ===================================== ========

REM ======== ADJUST PATH TO SQLite INCLUDE AND LIB ========
REM 
set SQLITE_INCLUDE_DIR=C:\SQLite\include
set SQLITE_LIBRARY_DIR=C:\SQLite\lib
REM ======== ADJUST PATH TO ORACLE INCLUDE AND LIB ========

call qt-cmake -G "Visual Studio 17 2022" ^
-B %CMAKE_BUILD_DIR% ^
-A %SQLDRIVER_ARCH% ^
-DOracle_INCLUDE_DIR="%Oracle_INCLUDE_DIR%" ^
-DOracle_LIBRARY_DIR="%Oracle_LIBRARY_DIR%" ^
-DCMAKE_INCLUDE_PATH="%SQLITE_INCLUDE_DIR%" ^
-DCMAKE_LIBRARY_PATH="%SQLITE_LIBRARY_DIR%" ^
-S %CMAKE_PROJECT_SOURCE% 