# Overview
This repository provides:
- Build script for building Qt6 6.8.3 32bit version (in Visual Studio 2022): 
  - [built_qt6_x86.ps1](built_qt6_x86.ps1)
- Modified Qt3d module and a script to build it: 
  - [qt3d](qt3d/)
  - [built_qt6_3d_module.ps1](built_qt6_3d_module.ps1)
- GGOCI and OCI SQL Drivers with build script:
  - [sqldrivers](qtbase/src/plugins/sqldrivers/)
  - [generate_sqldrivers_build.bat](generate_sqldrivers_build.bat)

## Qt3d module 

Qt3d x86 module had to be modified (\_\_SSE\_\_ conditional code was disabled ) as otherwise it produced a crash in Debug.

Steps for building:
1. Build Qt6 6.8.3 x86 version using `build_qt6_x86.ps1` script 
1. Build Qt3d module using `build_qt6_3d_module.ps1` script
    - make sure `$script:InstallDir` matches the install path (also `$script:InstallDir` ) in the previous step

## GGOCI and OCI 

### GGOCI

GGOCI is a fork of the Qt SQL driver for OCI (QOCI) and is based on Qt 6.8.3. This fork applies a number of modifications to the Qt version:

1. QOCI always returns a string for the numeric precision (when detailed). GGOCI uses the precision to return the proper type (int, double, long).
1. SQLCS_IMPLICIT instead of SQLCS_NCHAR.
1. Precision policy of QSql is not supported, because of the detailed precision handling mentioned in the first point.

### OCI

Build system of OCI was changed to incorporate it into our build system

### GGSqlite

GGSQLite is a wrapper on Qt SQL driver for SQLite and is based on Qt 6.8.3. Its sole purpose is to expose a private constructor `QSQLiteDriver(sqlite3 *)` to be able to create a `QSqlDriver` from existing opened sqlite3 connection

### Building GGOCI, OCI or GGSqlite

Build was done in  Visual Studio 2022 and also requires Oracle libraries. Steps:

1. Initialize Visual Studio 2022 environemnt (e.g. with `vcvarsall.bat`)
   - Add Qt 6.8.3 to your path
1. Modify `generate_sqldrivers_build.bat` to 
    - set the right Oracle directories (`Oracle_INCLUDE_DIR` and `Oracle_LIBRARY_DIR`)
    - set the right SQLite library  directories (`SQLITE_INCLUDE_DIR` and `SQLITE_LIBRARY_DIR`)
1. Run `generate_sqldrivers_build.bat` to generate a Visual Studio build project with CMake :
1. Open generated `qtbase\src\plugins\build\QSQLiteDriverPlugins.sln` in Visual Studio 2022 and build `ALL_BUILD` project
    - compiled GGOCI and OCI plugin libaries `.dll` (for Debug or Release) should be in e.g. `qtbase\Exe\Win32`
    - compiled ggsqlite would be in e.g. `qtbase\Libraries\Win32\Debug`

