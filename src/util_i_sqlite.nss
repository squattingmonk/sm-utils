/// ----------------------------------------------------------------------------
/// @file   util_i_sqlite.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Helper functions for NWN:EE SQLite databases.
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Alias for `SqlPreparerQueryObject(GetModule(), sSQL)`.
sqlquery SqlPrepareQueryModule(string sSQL);

/// @brief Prepares and executes a query on a PC's peristent database.
/// @param oPC The PC that stores the database.
/// @param sQuery The SQL statement to execute.
/// @returns Whether the query was successful.
int SqlExecPC(object oPC, string sQuery);

/// @brief Prepares and executes a query on the module's volatile database.
/// @param sQuery The SQL statement to execute.
/// @returns Whether the query was successful.
int SqlExecModule(string sQuery);

/// @brief Prepares and executes a query on a persistent campaign database.
/// @param sDatabase The name of the campaign database file (minus extension).
/// @param sQuery The SQL statement to execute.
/// @returns Whether the query was successful.
int SqlExecCampaign(string sDatabase, string sQuery);

/// @brief Creates a table in a PC's persistent database.
/// @param oPC The PC that stores the database.
/// @param sTable The name of the table.
/// @param sStructure The SQL describing the structure of the table (i.e.,
/// everything that would go between the parentheses).
/// @param bForce Whether to drop an existing table.
void SqlCreateTablePC(object oPC, string sTable, string sStructure, int bForce = FALSE);

/// @brief Creates a table in the module's volatile database.
/// @param sTable The name of the table.
/// @param sStructure The SQL describing the structure of the table (i.e.,
/// everything that would go between the parentheses).
/// @param bForce Whether to drop an existing table.
void SqlCreateTableModule(string sTable, string sStructure, int bForce = FALSE);

/// @brief Creates a table in a persistent campaign database.
/// @param sDatabase The name of the campaign database file (minus extension).
/// @param sTable The name of the table.
/// @param sStructure The SQL describing the structure of the table (i.e.,
/// everything that would go between the parentheses).
/// @param bForce Whether to drop an existing table.
void SqlCreateTableCampaign(string sDatabase, string sTable, string sStructure, int bForce = FALSE);

/// @brief Checks if a table exists the PC's persistent database.
/// @param oPC The PC that stores the database.
/// @param sTable The name of the table to check for.
/// @returns Whether the table exists.
int SqlGetTableExistsPC(object oPC, string sTable);

/// @brief Checks if a table exists in the module's volatile database.
/// @param sTable The name of the table to check for.
/// @returns Whether the table exists.
int SqlGetTableExistsModule(string sTable);

/// @brief Checks if a table exists in a peristent campaign database.
/// @param sDatabase The name of the campaign database file (minus extension).
/// @param sTable The name of the table to check for.
/// @returns Whether the table exists.
int SqlGetTableExistsCampaign(string sDatabase, string sTable);

/// @brief Gets the ID of the last row inserted into a PC's persistent database.
/// @param oPC The PC that stores the database.
/// @returns The ID of the last inserted row or -1 on error.
int SqlGetLastInsertIdPC(object oPC);

/// @brief Gets the ID of the last row inserted into the module's volatile
/// database.
/// @returns The ID of the last inserted row or -1 on error.
int SqlGetLastInsertIdModule();

/// @brief Gets the ID of the last row inserted into a persistent campaign
/// database.
/// @param sDatabase The name of the campaign database file (minus extension).
/// @returns The ID of the last inserted row or -1 on error.
int SqlGetLastInsertIdCampaign(string sDatabase);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

sqlquery SqlPrepareQueryModule(string sSQL)
{
    return SqlPrepareQueryObject(GetModule(), sSQL);
}

int SqlExecPC(object oPC, string sQuery)
{
    return SqlStep(SqlPrepareQueryObject(oPC, sQuery));
}

int SqlExecModule(string sQuery)
{
    return SqlStep(SqlPrepareQueryModule(sQuery));
}

int SqlExecCampaign(string sDatabase, string sQuery)
{
    return SqlStep(SqlPrepareQueryCampaign(sDatabase, sQuery));
}

void SqlCreateTablePC(object oPC, string sTable, string sStructure, int bForce = FALSE)
{
    if (bForce)
        SqlExecPC(oPC, "DROP TABLE IF EXISTS " + sTable + ";");

    SqlExecPC(oPC, "CREATE TABLE IF NOT EXISTS " + sTable + "(" + sStructure + ");");
}

void SqlCreateTableModule(string sTable, string sStructure, int bForce = FALSE)
{
    if (bForce)
        SqlExecModule("DROP TABLE IF EXISTS " + sTable + ";");

    SqlExecModule("CREATE TABLE IF NOT EXISTS " + sTable + "(" + sStructure + ");");
}

void SqlCreateTableCampaign(string sDatabase, string sTable, string sStructure, int bForce = FALSE)
{
    if (bForce)
        SqlExecCampaign(sDatabase, "DROP TABLE IF EXISTS " + sTable + ";");

    SqlExecCampaign(sDatabase, "CREATE TABLE IF NOT EXISTS " + sTable + "(" + sStructure + ");");
}

int SqlGetTableExistsPC(object oPC, string sTable)
{
    string sQuery = "SELECT name FROM sqlite_master WHERE type='table' AND name = @table;";
    sqlquery qQuery = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(qQuery, "@table", sTable);
    return SqlStep(qQuery);
}

int SqlGetTableExistsModule(string sTable)
{
    string sQuery = "SELECT name FROM sqlite_master WHERE type='table' AND name = @table;";
    sqlquery qQuery = SqlPrepareQueryModule(sQuery);
    SqlBindString(qQuery, "@table", sTable);
    return SqlStep(qQuery);
}

int SqlGetTableExistsCampaign(string sDatabase, string sTable)
{
    string sQuery = "SELECT name FROM sqlite_master WHERE type='table' AND name = @table;";
    sqlquery qQuery = SqlPrepareQueryCampaign(sDatabase, sQuery);
    SqlBindString(qQuery, "@table", sTable);
    return SqlStep(qQuery);
}

int SqlGetLastInsertIdPC(object oPC)
{
    sqlquery qQuery = SqlPrepareQueryObject(oPC, "SELECT last_insert_rowid();");
    return SqlStep(qQuery) ? SqlGetInt(qQuery, 0) : -1;
}

int SqlGetLastInsertIdModule()
{
    sqlquery qQuery = SqlPrepareQueryModule("SELECT last_insert_rowid();");
    return SqlStep(qQuery) ? SqlGetInt(qQuery, 0) : -1;
}

int SqlGetLastInsertIdCampaign(string sDatabase)
{
    sqlquery qQuery = SqlPrepareQueryCampaign(sDatabase, "SELECT last_insert_rowid();");
    return SqlStep(qQuery) ? SqlGetInt(qQuery, 0) : -1;
}
