# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: BSD-3-Clause

#####################################################################
## QOCIDriverPlugin Plugin:
#####################################################################

# Visual Studio generator is assumed so escaped variables in () are 
# passed through to the generated projects (QOCIDriverPlugin-> Properties -> Output Directory) 
# and evaluated therein on build 
set(CUSTOM_OUTPUT_FOLDER "${CMAKE_SOURCE_DIR}/../../../Exe/\$(Platform)/\$(Configuration)/sqldrivers")

# Use this to generate Release and Debug instead of RelWithDebInfo 
set(CMAKE_CONFIGURATION_TYPES "Release;Debug" CACHE STRING "" FORCE)

qt_internal_add_plugin(QOCIDriverPlugin
    OUTPUT_NAME qsqloci
    PLUGIN_TYPE sqldrivers
    SOURCES
        main.cpp
        qsql_oci.cpp qsql_oci_p.h
    DEFINES
        QT_NO_CAST_FROM_ASCII
        QT_NO_CAST_TO_ASCII
    LIBRARIES
        Oracle::OCI
        Qt::Core
        Qt::CorePrivate
        Qt::SqlPrivate
    OUTPUT_DIRECTORY
       ${CUSTOM_OUTPUT_FOLDER}
)

## Scopes:
#####################################################################

qt_internal_force_macos_intel_arch(QOCIDriverPlugin)

# Fixes 'error D8016: '/O2' and '/RTC1' command-line options are incompatible' by 
# overriding optimization by adding no optimization flag at the end
target_compile_options(QOCIDriverPlugin PRIVATE $<$<CONFIG:Debug>:/Od>)
