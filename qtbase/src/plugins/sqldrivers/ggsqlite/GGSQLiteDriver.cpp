// SPDX-License-Identifier: LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
#define GGSQLITEDRIVER_BUILD
#include "GGSQLiteDriver.h"

#include "sqlite3.h"
#include "qsql_sqlite_p.h"
#include "qsql_sqlite.cpp"


extern "C" QSqlDriver *GGCreateSQLiteDriver(sqlite3 *pConnection)
{
  return new QSQLiteDriver(pConnection, nullptr);
}