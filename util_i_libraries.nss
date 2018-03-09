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
// Acknowledgement: these scripts have been adapted from Memetic AI.
// -----------------------------------------------------------------------------

// Debug utility functions
#include "util_i_debug"

// CSV List utility functions
#include "util_i_csvlists"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

const string DEBUG_LIBRARIES = "Libraries";

const string LIBRARIES            = "LIBRARIES";
const string LIBRARY_ENTRY        = "LIBRARY_ENTRY";
const string LIBRARY_LOADED       = "LIBRARY_LOADED";
const string LIBRARY_SCRIPT       = "LIBRARY_SCRIPT";
const string LIBRARY_LAST_ENTRY   = "LIBRARY_LAST_ENTRY";
const string LIBRARY_LAST_LIBRARY = "LIBRARY_LAST_LIBRARY";
const string LIBRARY_LAST_SCRIPT  = "LIBRARY_LAST_SCRIPT";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ----- Debugging Aliases -----------------------------------------------------

// ---< LibraryDebug >---
// ---< util_i_libraries >---
// Alias for Debug(). Sends sMessage if oTarget's debug level for the libraries
// system is nLevel or higher.
void LibraryDebug(string sMessage, int nLevel = DEBUG_LEVEL_NOTICE, object oTarget = OBJECT_SELF);

// ----- Library Functions -----------------------------------------------------

// ---< GetLibraries >---
// ---< util_i_libraries >---
// Returns the waypoint that holds all library data. If the waypoint does not
// exist, it will be created. If the waypoint is destroyed, all libraries will
// be unloaded.
object GetLibraries();

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

// ---< RegisterLibraryScript >---
// ---< util_i_library >---
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

// ---< RunLibraryScript >---
// ---< util_i_libraries >---
// Runs sScript, dispatching into a library if the script is registered as a
// library script or executing the script via ExecuteScript() if it is not.
// Parameters:
// - oSelf: Who actually executes the script. This object will be treated as
//   OBJECT_SELF when the library script is called.
void RunLibraryScript(string sScript, object oSelf = OBJECT_SELF);

// ---< RunLibraryScripts >---
// ---< util_i_libraries >---
// Runs all scripts in the CSV list sScripts, dispatching into libraries if the
// script is registered as a library script or executing the script via
// ExecuteScript() if it is not.
// Parameters:
// - oSelf: the object that actually executes the script. This object will be
//   treated as OBJECT_SELF when the library script is called.
void RunLibraryScripts(string sScripts, object oSelf = OBJECT_SELF);

// ---< GetLastLibrary >---
// ---< util_i_libraries >---
// Returns the name of the last executed library.
string GetLastLibrary();

// ---< GetLastLibraryScript >---
// ---< util_i_libraries >---
// Returns the name of the last called library script.
string GetLastLibraryScript();

// ---< GetLastLibraryEntry>---
// ---< util_i_libraries >---
// Returns the entry point of the last executed library. Primarily used in
// library dispatchers to determine which script from the library should be
// executed.
int GetLastLibraryEntry();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

// ----- Debugging Aliases -----------------------------------------------------

void LibraryDebug(string sMessage, int nLevel = DEBUG_LEVEL_NOTICE, object oTarget = OBJECT_SELF)
{
    Debug(sMessage, nLevel, DEBUG_LIBRARIES, oTarget);
}

// ----- Library Functions -----------------------------------------------------

object GetLibraries()
{
    object oModule = GetModule();
    object oLibraries = GetLocalObject(oModule, LIBRARIES);
    if (!GetIsObjectValid(oLibraries))
    {
        oLibraries = GetWaypointByTag(LIBRARIES);
        if (!GetIsObjectValid(oLibraries))
        {
            LibraryDebug("Initializing libraries object...");
            oLibraries = CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001",
                GetStartingLocation(), FALSE, LIBRARIES);
        }

        SetLocalObject(oModule, LIBRARIES, oLibraries);
    }

    return oLibraries;
}

void LoadLibrary(string sLibrary, int bForce = FALSE)
{
    object oLibraries = GetLibraries();

    LibraryDebug("Attempting to " + (bForce ? "force " : "") + "load library " + sLibrary);

    if (bForce || !GetLocalInt(oLibraries, LIBRARY_LOADED + sLibrary))
    {
        SetLocalString(oLibraries, LIBRARY_LAST_LIBRARY, sLibrary);
        SetLocalString(oLibraries, LIBRARY_LAST_SCRIPT,  sLibrary);
        SetLocalInt   (oLibraries, LIBRARY_LAST_ENTRY,   0);
        SetLocalInt   (oLibraries, LIBRARY_LOADED + sLibrary, TRUE);
        ExecuteScript (sLibrary, oLibraries);
    }
    else
        LibraryDebug("Library " + sLibrary + " already loaded!", DEBUG_LEVEL_ERROR);
}

void LoadLibraries(string sLibraries, int bForce = FALSE)
{
    LibraryDebug("Attempting to " + (bForce ? "force " : "") + "load libraries " + sLibraries);

    int i, nCount = CountList(sLibraries);
    for (i = 0; i < nCount; i++)
        LoadLibrary(GetListItem(sLibraries, i), bForce);
}

void RegisterLibraryScript(string sScript, int nEntry = 0)
{
    object oLibraries = GetLibraries();
    string sLibrary   = GetLocalString(oLibraries, LIBRARY_LAST_LIBRARY);
    string sExist     = GetLocalString(oLibraries, LIBRARY_SCRIPT + sScript);

    if (sLibrary != sExist)
    {
        if (sExist != "")
            LibraryDebug(sLibrary + " is overriding " + sLibrary + "'s implementation of " +
                sScript, DEBUG_LEVEL_WARNING);

        SetLocalString(oLibraries, LIBRARY_SCRIPT + sScript, sLibrary);
    }

    int nOldEntry = GetLocalInt(oLibraries, LIBRARY_ENTRY + sLibrary + sScript);
    if (nOldEntry)
        LibraryDebug(sLibrary + " already declared " + sScript + ". " +
            " Old Entry: " + IntToString(nOldEntry) +
            " New Entry: " + IntToString(nEntry), DEBUG_LEVEL_WARNING);

    SetLocalInt(oLibraries, LIBRARY_ENTRY + sLibrary + sScript, nEntry);
}

void RunLibraryScript(string sScript, object oSelf = OBJECT_SELF)
{
    if (sScript == "") return;

    LibraryDebug("Running library script " + sScript + " on " + GetName(oSelf));

    object oLibraries = GetLibraries();
    string sLibrary = GetLocalString(oLibraries, LIBRARY_SCRIPT + sScript);

    if (sLibrary != "")
    {
        int nEntry = GetLocalInt(oLibraries, LIBRARY_ENTRY + sLibrary + sScript);
        LibraryDebug("Library script found at " + sLibrary + ":" + IntToString(nEntry));

        SetLocalString(oLibraries, LIBRARY_LAST_LIBRARY, sLibrary);
        SetLocalString(oLibraries, LIBRARY_LAST_SCRIPT,  sScript);
        SetLocalInt   (oLibraries, LIBRARY_LAST_ENTRY,   nEntry);
        ExecuteScript (sLibrary, oSelf);
    }
    else
    {
        LibraryDebug(sScript + " is not a library script. Executing..", DEBUG_LEVEL_WARNING);
        ExecuteScript(sScript, oSelf);
    }
}

void RunLibraryScripts(string sScripts, object oSelf = OBJECT_SELF)
{
    int i, nCount = CountList(sScripts);
    for (i = 0; i < nCount; i++)
        RunLibraryScript(GetListItem(sScripts, i), oSelf);
}

string GetLastLibrary()
{
    return GetLocalString(GetLibraries(), LIBRARY_LAST_LIBRARY);
}

string GetLastLibraryScript()
{
    return GetLocalString(GetLibraries(), LIBRARY_LAST_SCRIPT);
}

int GetLastLibraryEntry()
{
    return GetLocalInt(GetLibraries(), LIBRARY_LAST_ENTRY);
}
