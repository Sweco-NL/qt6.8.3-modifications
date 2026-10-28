# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: BSD-3-Clause

#####################################################################
## GGSQLDriverPlugin Plugin:
#####################################################################

# Visual Studio supplies the platform; $<CONFIG> avoids an extra configuration subdirectory.
get_filename_component(GGSQL_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../.." ABSOLUTE)
set(CUSTOM_OUTPUT_FOLDER "${GGSQL_ROOT_DIR}/Libraries/${CMAKE_VS_PLATFORM_NAME}/$<CONFIG>")

# Don't install into sqlplugins folder
set(CUSTOM_DEPLOY_FOLDER "${GGSQL_ROOT_DIR}/Exe/${CMAKE_VS_PLATFORM_NAME}/$<CONFIG>/")

# Use this to generate Release and Debug instead of RelWithDebInfo 
set(CMAKE_CONFIGURATION_TYPES "Release;Debug" CACHE STRING "" FORCE)

qt_internal_add_plugin(GGSQLDriverPlugin
    OUTPUT_NAME ggsqlite
    PLUGIN_TYPE sqldrivers
    SOURCES
        GGSQLiteDriver.cpp 
        GGSQLiteDriver.h
    DEFINES
        QT_NO_CAST_FROM_ASCII
        QT_NO_CAST_TO_ASCII
    LIBRARIES
        SQLite::SQLite3
        Qt::Core
        Qt::CorePrivate
        Qt::SqlPrivate
    OUTPUT_DIRECTORY
       ${CUSTOM_OUTPUT_FOLDER}
)

set_target_properties(GGSQLDriverPlugin PROPERTIES
    DEBUG_POSTFIX ""
    PDB_OUTPUT_DIRECTORY "${CUSTOM_OUTPUT_FOLDER}"
    COMPILE_PDB_OUTPUT_DIRECTORY "${CUSTOM_OUTPUT_FOLDER}"
)

add_custom_command(TARGET GGSQLDriverPlugin POST_BUILD
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${CUSTOM_DEPLOY_FOLDER}"
    COMMAND "${CMAKE_COMMAND}" -E copy_if_different
        "$<TARGET_FILE:GGSQLDriverPlugin>"
        "${CUSTOM_DEPLOY_FOLDER}/$<TARGET_FILE_NAME:GGSQLDriverPlugin>"
    COMMENT "Deploying GGSQLDriverPlugin to the executable sqldrivers directory"
    VERBATIM
)

# Make sure a dependency is added to this project to build SQLite.vcxproj before GGSQLDriverPlugin
if(INTERNAL_SQL_BUILD)
    # Populate SQLite::SQLite3 target
    set(SQLITE_SOURCE_DIR "${CMAKE_SOURCE_DIR}/../../../ComponentenNew/SQLite")
    set(SQLITE_BUILD_DIR "${CMAKE_SOURCE_DIR}/../../../Libraries/\$(Platform)/")    

    set_target_properties(SQLite::SQLite3 PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${SQLITE_SOURCE_DIR}"
        IMPORTED_CONFIGURATIONS "Debug;Release"
        IMPORTED_LOCATION_DEBUG
            "${SQLITE_BUILD_DIR}/Debug/SQLite.dll"
        IMPORTED_IMPLIB_DEBUG
            "${SQLITE_BUILD_DIR}/Debug/SQLite.lib"

        IMPORTED_LOCATION_RELEASE
            "${SQLITE_BUILD_DIR}/Release/SQLite.dll"
        IMPORTED_IMPLIB_RELEASE
            "${SQLITE_BUILD_DIR}/Release/SQLite.lib"
    )
    set(SQLITE_VCXPROJ "${SQLITE_SOURCE_DIR}/SQLite.vcxproj")

    # Add dependency on the SQLite in Visual Studio for correct build order 
    include_external_msproject(SQLiteProject
        "${SQLITE_VCXPROJ}"
        PLATFORM "${CMAKE_VS_PLATFORM_NAME}"
    )

    add_dependencies(GGSQLDriverPlugin SQLiteProject)

endif()


## Scopes:
#####################################################################

qt_internal_force_macos_intel_arch(GGSQLDriverPlugin)

# Fixes 'error D8016: '/O2' and '/RTC1' command-line options are incompatible' by 
# overriding optimization by adding no optimization flag at the end
target_compile_options(GGSQLDriverPlugin PRIVATE $<$<CONFIG:Debug>:/Od>)
