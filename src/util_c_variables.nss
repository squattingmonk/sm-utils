/// ----------------------------------------------------------------------------
/// @file   util_c_variables.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Configuration file for util_i_variables.nss.
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                                Configuration
// -----------------------------------------------------------------------------

// This volatile table will be created on the GetModule() object the first time
// a module variable is set.
const string VARIABLE_TABLE_MODULE      = "module_variables";

// This persitent table will be created on the PC object the first time a player
// variable is set.  This table will be stored in the player's .bic file.
const string VARIABLE_TABLE_PC          = "player_variables";

// A persistent table will be created in a campaign database with the following
// name.  The table name will be VARIABLE_TABLE_MODULE above.
const string VARIABLE_CAMPAIGN_DATABASE = "module_variables";

// -----------------------------------------------------------------------------
//                            Local VarName Constructor
// -----------------------------------------------------------------------------
// This function is called when attempting to copy variables from a database
//  to a game object.  Since game objects do not accept additonal fields, such
//  as a tag or timestamp, this function is provided to allow construction of
//  a unique varname, if desired, from the fields in the database record.  You
//  may alter the contents of this function, but do not alter its signature.
// -----------------------------------------------------------------------------

/// @brief Constructs a varname for a local variable copied from a database.
/// @param oDatabase The database object the variable is sourced from.  Will
///     be either a player object, DB_MODULE or DM_CAMPAIGN.
/// @param oTarget The game object the variable will be copied to.
/// @param sVarName VarName field retrieved from database.
/// @param sTag Tag field retrieved from database.
/// @param nType Type field retrieved from database.  VARIABLE_TYPE_*, but
///     limited to VARIABLE_TYPE_INT|FLOAT|STRING|OBJECT|LOCATION|JSON.
/// @returns The constructed string that will be used as the varname once
///     copied to the target game object.
string DatabaseToObjectVarName(object oDatabase, object oTarget, string sVarName,
                               string sTag, int nType)
{
    return sVarName;
}

// -----------------------------------------------------------------------------
//                    Database VarName and Tag Constructors
// -----------------------------------------------------------------------------
// These functions are called when attempting to copy variables from a game
//  object to a database.  These functions are provided to allow construction
//  of unique varnames and tag from local variables varnames.  If the function
//  `DatabaseToObjectVarName()` above is used to copy database variables to a
//  local object, these functions can be used to reverse the process if
//  previously copied variables are returned to a database. You may alter the
//  contents of these functions, but do not alter their signatures.
// -----------------------------------------------------------------------------

/// @brief Constructs a varname for a local variable copied to a database.
/// @param oSource The game object the variable will be copied from.
/// @param oDatabase The database object the variable will be copied to.  Will
///     be either a player object, DB_MODULE or DM_CAMPAIGN.
/// @param sVarName VarName field retrieved from the local variable.
/// @param nType Type field retrieved from database.  VARIABLE_TYPE_*, but
///     limited to VARIABLE_TYPE_INT|FLOAT|STRING|OBJECT|LOCATION|JSON.
/// @param sTag sTag as passed to `CopyLocalVariablesToDatabase()`.
/// @returns The constructed string that will be used as the varname once
///     copied to the target game object.
string ObjectToDatabaseVarName(object oSource, object oDatabase, string sVarName,
                               int nType, string sTag)
{
    return sVarName;
}

/// @brief Constructs a varname for a local variable copied to a database.
/// @param oSource The game object the variable will be copied from.
/// @param oDatabase The database object the variable will be copied to.  Will
///     be either a player object, DB_MODULE or DM_CAMPAIGN.
/// @param sVarName VarName field retrieved from the local variable.
/// @param nType Type field retrieved from database.  VARIABLE_TYPE_*, but
///     limited to VARIABLE_TYPE_INT|FLOAT|STRING|OBJECT|LOCATION|JSON.
/// @param sTag sTag as passed to `CopyLocalVariablesToDatabase()`.
/// @returns The constructed string that will be used as the varname once
///     copied to the target game object.
string ObjectToDatabaseTag(object oSource, object oDatabase, string sVarName,
                           int nType, string sTag)
{
    return sTag;
}
