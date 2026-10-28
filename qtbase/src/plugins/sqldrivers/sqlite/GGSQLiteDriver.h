// SPDX-License-Identifier: LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
#pragma once
#include <QtSql/QSqlDriver>

struct sqlite3;

#ifdef GGSQLITEDRIVER_BUILD
#define GGSQLITEDRIVER_API __declspec(dllexport)
#else
#define GGSQLITEDRIVER_API __declspec(dllimport)
#endif

extern "C" GGSQLITEDRIVER_API QSqlDriver *GGCreateSQLiteDriver(sqlite3 *pConnection);