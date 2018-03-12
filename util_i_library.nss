// -----------------------------------------------------------------------------
//    File: util_i_library.nss
//  System: Utilities (include script)
//     URL: https://github.com/squattingmonk/sm-utils
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// This script contains boilerplate code for creating a library dispatcher. It
// should only be included in library scripts as it implements main().
// -----------------------------------------------------------------------------

#include "util_i_libraries"

// -----------------------------------------------------------------------------
//                               Global Variables
// -----------------------------------------------------------------------------

// We instantiate these here so they are automatically set when a library is
// executed. If the library itself calls another library script, these variables
// will remain valid in the scope of the parent library.
int    LIB_LOADING         = (LIBRARIES == OBJECT_SELF);
int    LIB_CURRENT_ENTRY   = GetLocalInt   (LIBRARIES, LIB_LAST_ENTRY);
string LIB_CURRENT_LIBRARY = GetLocalString(LIBRARIES, LIB_LAST_LIBRARY);
string LIB_CURRENT_SCRIPT  = GetLocalString(LIBRARIES, LIB_LAST_SCRIPT);


// -----------------------------------------------------------------------------
//                              Function Protoypes
// -----------------------------------------------------------------------------

// ---< OnLibraryLoad >---
// This is a user-defined function that registers function names to a unique (to
// this library) number. When the function name is run using RunLibraryScript(),
// this number will be passed to the user-defined function OnLibraryScript(),
// which resolves the call to the correct function.
//
// Example usage:
// void OnLibraryLoad()
// {
//     RegisterLibraryScript("MyFunction");
//     RegisterLibraryScript("MyOtherFunction");
// }
//
// or, if using nEntry...
// void OnLibraryLoad()
// {
//     RegisterLibraryScript("MyFunction",      1);
//     RegisterLibraryScript("MyOtherFunction", 2);
// }
void OnLibraryLoad();

// ---< OnLibraryScript >---
// This is a user-defined function that routes a unique (to the module) script
// name (sScript) or a unique (to this library) number (nEntry) to a function.
//
// Example usage:
// void OnLibraryScript(string sScript, int nEntry)
// {
//     if      (sScript == "MyFunction")      MyFunction();
//     else if (sScript == "MyOtherFunction") MyOtherFunction();
// }
//
// or, using nEntry...
// void OnLibraryScript(string sScript, int nEntry)
// {
//     switch (nEntry)
//     {
//         case 1: MyFunction();      break;
//         case 2: MyOtherFunction(); break;
//     }
// }
//
// For advanced usage, see the libraries included in the Core Framework.
void OnLibraryScript(string sScript, int nEntry);

// -----------------------------------------------------------------------------
//                                 Main Routine
// -----------------------------------------------------------------------------

void main()
{
    if (LIB_LOADING)
        OnLibraryLoad();
    else
        OnLibraryScript(LIB_CURRENT_SCRIPT, LIB_CURRENT_ENTRY);
}
