// -----------------------------------------------------------------------------
//    File: util_i_libraries.nss
//  System: Utilities (include script)
//     URL: https://github.com/squattingmonk/sm-utils
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// This file holds functions for packaging scripts into libraries. This allows
// the builder to dramatically reduce the module script count by keeping related
// scripts in the same file.
// -----------------------------------------------------------------------------

// Debug utility functions
#include "util_i_debug"

// CSV List utility functions
#include "util_i_csvlists"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

const string LIB_RETURN  = "LIB_RETURN";
const string LIB_ENTRY   = "LIB_ENTRY";
const string LIB_LIBRARY = "LIB_LIBRARY";
const string LIB_SCRIPT  = "LIB_SCRIPT";
const string LIB_INIT    = "LIB_INIT";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< AddLibraryScript >---
// ---< util_i_libraries >---
// Creates the `library_scripts` table in the module's volatile sqlite database.
// If bReset is TRUE, the table will be dropped and recreated.
void CreateLibraryTable(int bReset = FALSE);

// ---< AddLibraryScript >---
// ---< util_i_libraries >---
// Adds a database record associating sScript with sLibrary at entry nEntry.
// sScript must be unique module-wide.
void AddLibraryScript(string sLibrary, string sScript, int nEntry);

// ---< GetScriptLibrary >---
// ---< util_i_libraries >---
// Queries the module's volatile database to return the script library
// associated with sScript.
string GetScriptLibrary(string sScript);

// ---< GetScriptEntry >---
// ---< util_i_libraries >---
// Queries the module's volatile database to return the entry number associated
// with sScript.
int GetScriptEntry(string sScript);

// ---< GetScriptData >---
// ---< util_i_libraries >---
// Returns a prepared query with the library and entry data associated with
// sScript, allowing users to retrieve the same data returned by
// GetScriptLibrary() and GetScriptEntry() with one function.
sqlquery GetScriptData(string sScript);

// ---< GetIsLibraryLoaded >---
// ---< util_i_libraries >---
// Returns whether sLibrary has been loaded.
int GetIsLibraryLoaded(string sLibrary);

// ---< LoadLibrary >---
// ---< util_i_libraries >---
// Loads library sLibrary. The scripts inside the library are registered and are
// accessible via a call to RunLibraryScript(). If the library has already been
// loaded, this will not reload it unless bForce is TRUE.
void LoadLibrary(string sLibrary, int bForce = FALSE);

// ---< LoadLibraries >---
// ---< util_i_libraries >---
// Loads all libraries in the CSV list sLibraries. The scripts inside the
// library are registered and are accessible via a call to RunLibraryScript().
// If any of the libraries have already been loaded, this will not reload them
// unless bForce is TRUE.
void LoadLibraries(string sLibraries, int bForce = FALSE);

// ---< LoadPrefixLibraries >---
// ---< util_i_libraries >---
// Loads all libraries included in script files prefixed with sPrefix.  The scripts
// inside the library are registered and are accessible via a call to
// RunLibraryScript().  If any of the libraries have already been loaded, this
// will not reload them unless bForce is TRUE.
void LoadPrefixLibraries(string sPrefix, int bForce = FALSE);

// ---< RunLibraryScript >---
// ---< util_i_libraries >---
// Runs sScript, dispatching into a library if the script is registered as a
// library script or executing the script via ExecuteScript() if it is not.
// Returns the value of SetLibraryReturnValue().
// Parameters:
// - oSelf: Who actually executes the script. This object will be treated as
//   OBJECT_SELF when the library script is called.
int RunLibraryScript(string sScript, object oSelf = OBJECT_SELF);

// ---< RunLibraryScripts >---
// ---< util_i_libraries >---
// Runs all scripts in the CSV list sScripts, dispatching into libraries if the
// script is registered as a library script or executing the script via
// ExecuteScript() if it is not.
// Parameters:
// - oSelf: the object that actually executes the script. This object will be
//   treated as OBJECT_SELF when the library script is called.
void RunLibraryScripts(string sScripts, object oSelf = OBJECT_SELF);

// ---< RegisterLibraryScript >---
// ---< util_i_libraries >---
// Registers sScript as being located inside the current library at nEntry. This
// The script can later be called using RunLibraryScript(sScript) and routed to
// the proper function using OnLibraryScript(sScript, nEntry).
// Parameters:
// - sScript: the name of the script to register. This name must be unique in
//   the module. If a second script with the same name is registered, it will
//   overwrite the first one.
// - nEntry: a number unique to this library to identify this script. Is can be
//   obtained at runtime in OnLibraryScript() and used to access the correct
//   function. If this parameter is left as the default, you will have to filter
//   your script using the sScript parameter, which is less efficient.
void RegisterLibraryScript(string sScript, int nEntry = 0);

// ---< LibraryReturn >---
// ---< util_i_library >---
// Sets the return value of the currently executing library to nValue.
void LibraryReturn(int nValue);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void CreateLibraryTable(int bReset = FALSE)
{
    if (GetLocalInt(GetModule(), LIB_INIT) && !bReset)
        return;

    SetLocalInt(GetModule(), LIB_INIT, TRUE);

    if (bReset)
    {
        string sDrop = "DROP TABLE library_scripts;";
        sqlquery sqlDrop = SqlPrepareQueryObject(GetModule(), sDrop);
        SqlStep(sqlDrop);
    }

    string sLibraries = "CREATE TABLE IF NOT EXISTS library_scripts (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                    "sLibrary TEXT NOT NULL, " +
                    "sScript TEXT NOT NULL UNIQUE ON CONFLICT REPLACE, " +
                    "nEntry INTEGER NOT NULL);";

    sqlquery sql = SqlPrepareQueryObject(GetModule(), sLibraries);
    SqlStep(sql);
}

void AddLibraryScript(string sLibrary, string sScript, int nEntry)
{
    CreateLibraryTable();

    string sQuery = "INSERT INTO library_scripts (sLibrary, sScript, nEntry) " +
                    "VALUES (@sLibrary, @sScript, @nEntry);";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindString(sql, "@sLibrary", sLibrary);
    SqlBindString(sql, "@sScript", sScript);
    SqlBindInt(sql, "@nEntry", nEntry);

    SqlStep(sql);
}

string GetScriptFieldData(string sField, string sScript)
{
    CreateLibraryTable();

    string sQuery = "SELECT " + sField + " FROM library_scripts " +
                    "WHERE sScript = @sScript;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindString(sql, "@sScript", sScript);

    return SqlStep(sql) ? SqlGetString(sql, 0) : "";
}

string GetScriptLibrary(string sScript)
{
    return GetScriptFieldData("sLibrary", sScript);
}

int GetScriptEntry(string sScript)
{
    return StringToInt(GetScriptFieldData("nEntry", sScript));
}

sqlquery GetScriptData(string sScript)
{
    CreateLibraryTable();

    string sQuery = "SELECT sLibrary, nEntry FROM library_scripts " +
                    "WHERE sScript = @sScript;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindString(sql, "@sScript", sScript);

    return sql;
}

int GetIsLibraryLoaded(string sLibrary)
{
    CreateLibraryTable();

    string sQuery = "SELECT COUNT(sLibrary) FROM library_scripts " +
                    "WHERE sLibrary = @sLibrary LIMIT 1;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindString(sql, "@sLibrary", sLibrary);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : FALSE;
}

void LoadLibrary(string sLibrary, int bForce = FALSE)
{
    Debug("Attempting to " + (bForce ? "force " : "") + "load library " + sLibrary);

    if (bForce || !GetIsLibraryLoaded(sLibrary))
    {
        SetScriptParam(LIB_LIBRARY, sLibrary);
        ExecuteScript(sLibrary, GetModule());
    }
    else
        Error("Library " + sLibrary + " already loaded!");
}

void LoadLibraries(string sLibraries, int bForce = FALSE)
{
    Debug("Attempting to " + (bForce ? "force " : "") + "load libraries " + sLibraries);

    int i, nCount = CountList(sLibraries);
    for (i = 0; i < nCount; i++)
        LoadLibrary(GetListItem(sLibraries, i), bForce);
}

void LoadPrefixLibraries(string sPrefix, int bForce = FALSE)
{
    if (sPrefix == "")
        return;

    Debug("Attempting to " + (bForce ? "force " : "") + "load libraries " +
        "prefixed with " + sPrefix);

    int i = 1;
    string sLibrary = ResManFindPrefix(sPrefix, RESTYPE_NCS, i++);
    while (sLibrary != "")
    {
        LoadLibrary(sLibrary, bForce);
        sLibrary = ResManFindPrefix(sPrefix, RESTYPE_NCS, i++);
    }
}

int RunLibraryScript(string sScript, object oSelf = OBJECT_SELF)
{
    if (sScript == "") return -1;

    string sLibrary;
    int nEntry;

    sqlquery sqlScriptData = GetScriptData(sScript);
    if (SqlStep(sqlScriptData))
    {
        sLibrary = SqlGetString(sqlScriptData, 0);
        nEntry = SqlGetInt(sqlScriptData, 1);
    }

    DeleteLocalInt(oSelf, LIB_RETURN);

    if (sLibrary != "")
    {
        Debug("Library script " + sScript + " found in " + sLibrary +
            (nEntry != 0 ? " at entry " + IntToString(nEntry) : ""));

        SetScriptParam(LIB_LIBRARY, sLibrary);
        SetScriptParam(LIB_SCRIPT, sScript);
        SetScriptParam(LIB_ENTRY, IntToString(nEntry));

        ExecuteScript(sLibrary, oSelf);
    }
    else
    {
        Debug(sScript + " is not a library script; executing directly");
        ExecuteScript(sScript, oSelf);
    }

    return GetLocalInt(oSelf, LIB_RETURN);
}

void RunLibraryScripts(string sScripts, object oSelf = OBJECT_SELF)
{
    int i, nCount = CountList(sScripts);
    for (i = 0; i < nCount; i++)
        RunLibraryScript(GetListItem(sScripts, i), oSelf);
}

void RegisterLibraryScript(string sScript, int nEntry = 0)
{
    string sLibrary = GetScriptParam(LIB_LIBRARY);
    string sExist = GetScriptLibrary(sScript);

    if (sLibrary != sExist && sExist != "")
        Warning(sLibrary + " is overriding " + sExist + "'s implementation of " + sScript);

    int nOldEntry = GetScriptEntry(sScript);
    if (nOldEntry)
        Warning(sLibrary + " already declared " + sScript +
            " Old Entry: " + IntToString(nOldEntry) +
            " New Entry: " + IntToString(nEntry));

    AddLibraryScript(sLibrary, sScript, nEntry);
}

void LibraryReturn(int nValue)
{
    SetLocalInt(OBJECT_SELF, LIB_RETURN, nValue);
}
