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

// Datapoint utilities
#include "util_i_datapoint"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

const string LIB_ENTRY        = "LIB_ENTRY";
const string LIB_LOADED       = "LIB_LOADED";
const string LIB_SCRIPT       = "LIB_SCRIPT";
const string LIB_LAST_ENTRY   = "LIB_LAST_ENTRY";
const string LIB_LAST_LIBRARY = "LIB_LAST_LIBRARY";
const string LIB_LAST_SCRIPT  = "LIBRARY_LAST_SCRIPT";

// -----------------------------------------------------------------------------
//                               Global Variables
// -----------------------------------------------------------------------------

object LIBRARIES = GetDatapoint("LIBRARIES");

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

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

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void LoadLibrary(string sLibrary, int bForce = FALSE)
{
    Debug("Attempting to " + (bForce ? "force " : "") + "load library " + sLibrary);

    if (bForce || !GetLocalInt(LIBRARIES, LIB_LOADED + sLibrary))
    {
        SetLocalString(LIBRARIES, LIB_LAST_LIBRARY, sLibrary);
        SetLocalString(LIBRARIES, LIB_LAST_SCRIPT,  sLibrary);
        SetLocalInt   (LIBRARIES, LIB_LAST_ENTRY,   0);
        SetLocalInt   (LIBRARIES, LIB_LOADED + sLibrary, TRUE);
        ExecuteScript (sLibrary, LIBRARIES);
    }
    else
        Debug("Library " + sLibrary + " already loaded!", DEBUG_LEVEL_ERROR);
}

void LoadLibraries(string sLibraries, int bForce = FALSE)
{
    Debug("Attempting to " + (bForce ? "force " : "") + "load libraries " + sLibraries);

    int i, nCount = CountList(sLibraries);
    for (i = 0; i < nCount; i++)
        LoadLibrary(GetListItem(sLibraries, i), bForce);
}

void RegisterLibraryScript(string sScript, int nEntry = 0)
{
    string sLibrary   = GetLocalString(LIBRARIES, LIB_LAST_LIBRARY);
    string sExist     = GetLocalString(LIBRARIES, LIB_SCRIPT + sScript);

    if (sLibrary != sExist)
    {
        if (sExist != "")
            Debug(sLibrary + " is overriding " + sLibrary + "'s implementation of " +
                sScript, DEBUG_LEVEL_WARNING);

        SetLocalString(LIBRARIES, LIB_SCRIPT + sScript, sLibrary);
    }

    int nOldEntry = GetLocalInt(LIBRARIES, LIB_ENTRY + sLibrary + sScript);
    if (nOldEntry)
        Debug(sLibrary + " already declared " + sScript + ". " +
            " Old Entry: " + IntToString(nOldEntry) +
            " New Entry: " + IntToString(nEntry), DEBUG_LEVEL_WARNING);

    SetLocalInt(LIBRARIES, LIB_ENTRY + sLibrary + sScript, nEntry);
}

void RunLibraryScript(string sScript, object oSelf = OBJECT_SELF)
{
    if (sScript == "") return;

    Debug("Running library script " + sScript + " on " + GetName(oSelf));

    string sLibrary = GetLocalString(LIBRARIES, LIB_SCRIPT + sScript);

    if (sLibrary != "")
    {
        int nEntry = GetLocalInt(LIBRARIES, LIB_ENTRY + sLibrary + sScript);
        Debug("Library script found at " + sLibrary + ":" + IntToString(nEntry));

        SetLocalString(LIBRARIES, LIB_LAST_LIBRARY, sLibrary);
        SetLocalString(LIBRARIES, LIB_LAST_SCRIPT,  sScript);
        SetLocalInt   (LIBRARIES, LIB_LAST_ENTRY,   nEntry);
        ExecuteScript (sLibrary, oSelf);
    }
    else
    {
        Debug(sScript + " is not a library script. Executing..", DEBUG_LEVEL_WARNING);
        ExecuteScript(sScript, oSelf);
    }
}

void RunLibraryScripts(string sScripts, object oSelf = OBJECT_SELF)
{
    int i, nCount = CountList(sScripts);
    for (i = 0; i < nCount; i++)
        RunLibraryScript(GetListItem(sScripts, i), oSelf);
}
