# Squatting Monk's NWN Utilities
This package contains various utility scripts used by my other [Neverwinter 
Nights](http://neverwinternights.info) scripts.

## Prerequisites
This package does not require any other code. However, the install script 
requires the following:

- [nwn-erf from nwn-lib](https://github.com/niv/nwn-lib)
- [ruby](https://www.ruby-lang.org)

## Installation
Get the code:
```
git clone https://github.com/squattingmonk/sm-utils
```

Run the build script:
```
cd sm-utils
rake erf
```

The `sm_utils.erf` file will be created in the `sm-utils` directory. Import 
this file into your module.

Alternatively, you can simply copy all files from `sm-utils/src` into your 
module's working directory.

This package contains the following resources:

| Resource		         | Function              				        |
| ---------------------- | -------------------------------------------- |
| `util_i_lists.nss`	 | CSV and local variable lists master include  |
| `util_i_csvlists.nss`  | CSV list utilities                           |
| `util_i_varlists.nss`  | Local variable list utilities                |
| `util_i_debug.nss`     | Debugging utilities                          |
| `util_i_libraries.nss` | Library script utilities                     |
| `util_i_library.nss`   | Library dispatcher boilerplate               |
| `util_i_datapoint.nss` | System-specific data object creation utility |

## Usage

### Datapoints
`util_i_datapoint.nss` holds functions for creating and interacting with 
datapoints. Datapoints are invisible objects used to hold variables specific to 
a system. You can use datapoints to avoid collision with similar varnames and 
to reduce variable access time in modules where large number of variables are 
saved on the module object.

Creating a datapoint is as simple as calling `GetDatapoint()`. The function 
will create and save the datapoint if it doesn't already exist, or return it if 
it does. Datapoints can be saved to the module (default) for system-wide access 
or to particular objects to hold system-specific information for that object.

``` c
// Getting a global datapoint
object oGlobal = GetDatapoint("MySystem");

// Getting a local datapoint
object oLocal = GetDatapoint("MySystem", GetFirstPC());

// Using a custom object as a datapoint
object oData = CreateObject(OBJECT_TYPE_PLACEABLE, "plc_chest1", GetModuleStartingLocation());
SetDatapoint("MyOtherSystem", oData);
```

### Debugging
`util_i_debug.nss` holds functions for generating debug messages. Use `Debug()` 
to send a debug message. Debug messages have a level of importance associated 
with them:
1. Critical errors are severe enough to stop the script from functioning
2. Errors indicate the script malfunctioned in some way
3. Warnings indicate that unexpected behavior may occur
4. Notices are general information used to track the flow of the script

The debug level can be set on individual objects or module-wide using 
`SetDebugLevel()`. You can control how debug messages are displayed using 
`SetDebugLogging()` and the colors of the messages using `SetDebugColor()`. 
`IsDebugging()` can check to see if the object will show a debug message of the 
given level; this is useful if you want to save cycles assembling a debug dump 
that would not be shown.

``` c
// Set debug messages to be sent to the log and the first PC
SetDebugLogging(DEBUG_LOG_FILE | DEBUG_LOG_PC);

// Set the module to show debug messages of Error level or greater
SetDebugLevel(DEBUG_LEVEL_ERROR, GetModule());

// Generate some debug messages on OBJECT_SELF
Debug("My critical error", DEBUG_LEVEL_CRITICAL); // Displays
Debug("My  error",         DEBUG_LEVEL_ERROR);    // Displays
Debug("My warning",        DEBUG_LEVEL_WARNING);  // Will not display
Debug("My notice",         DEBUG_LEVEL_NOTICE);   // Will not display

// Set OBJECT_SELF to show debug messages of Warning level or greater
SetDebugLevel(DEBUG_LEVEL_WARNING);

// Generate some debug messages on OBJECT_SELF
Debug("My critical error", DEBUG_LEVEL_CRITICAL); // Displays
Debug("My  error",         DEBUG_LEVEL_ERROR);    // Displays
Debug("My warning",        DEBUG_LEVEL_WARNING);  // Displays
Debug("My notice",         DEBUG_LEVEL_NOTICE);   // Will not display

// Check if the message will be displayed before doing something intensive
if (IsDebugging(DEBUG_LEVEL_NOTICE))
{
    string sMessage = MyExpensiveFunction();
    Debug(sMessage);
}
```

### Lists
Two types of lists are available. Conversions between the two list types can be 
done using the functions in `util_i_lists.nss`.

#### CSV Lists
`util_i_csvlists.nss` holds functions for CSV lists. These are comma-separated 
string lists that are altered in place. They are zero-indexed.

``` c
// Create a list of knights, then count and loop through the list
string string sKnight, sKnights = "Lancelot, Galahad, Robin";
int i, nCount = CountList(sKnights);
for (i = 0; i < nCount; i++)
{
    sKnight = GetListItem(sKnights, i);
    SpeakString("Sir " + sKnight);
}

// Check if Bedivere is in the party
int bBedivere = HasListItem(sKnights, "Bedivere");
SpeakString("Bedivere " + (bBedivere ? "is" : "is not") + " in the party.");

// Add Bedivere to the party
sKnights = AddListItem(sKnights, "Bedivere");
bBedivere = HasListItem(sKnights, "Bedivere");
SpeakString("Bedivere " + (bBedivere ? "is" : "is not") + " in the party.");

// Find the index of a knight in the party
int nRobin = FindListItem(sKnights, "Robin");
SpeakString("Robin is knight " + IntToString(nRobin) + " in the party.");
```

#### Var Lists
`util_i_varlists.nss` contains functions for handling var lists. Var lists are 
saved to objects as local variables. They support float, int, location, object, 
and string datatypes. Each variable type is maintained in a separate list to 
avoid collision. 

``` c
// Create a list of menu items on the module
object oModule = GetModule();
AddListString(oModule, "Spam", "Menu");
AddListString(oModule, "Eggs", "Menu");
AddListString(oModule, "Spam and Eggs", "Menu");

// Add the prices
AddListInt(oModule, 10, "Menu");
AddListInt(oModule, 5,  "Menu");
AddListInt(oModule, 15, "Menu");

// Count the list of menu items and loop through it
int i, nCount = CountStringList(oModule, "Menu");
string sItem;
int nItem;

for (i = 0; i < nCount; i++)
{
    sItem = GetListString(oModule, i, "Menu");
    nItem = GetListInt   (oModule, i, "Menu");
    SpeakString(sItem + " costs " + IntToString(nItem) + " GP");
}

// Check to see if Eggs are on the menu
int bEggs = HasListString(oModule, "Eggs", "Menu");
SpeakString("Eggs " (bEggs ? "are" : "are not") + " on the menu.");

// Find an item that costs 15 GP from the menu
nItem = FindListInt(oModule, 15, "Menu");
sItem = GetListItem(oModule, nItem, "Menu");

// Delete the item and its price from the menu
DeleteListString(oModule, nItem, "Menu");
DeleteListInt   (oModule, nItem, "Menu");

// Copy the menu to OBJECT_SELF's list "Eats"
CopyStringList(oModule, OBJECT_SELF, "Menu", "Eats");
```

### Libraries
Libraries allow the builder to encapsulate many scripts into one, dramatically 
reducing the script count in the module. In a library, each script is a 
function bound to a unique name and/or number. When the library is called, a 
dispatcher function routes the call to the proper function.

Since each script defined by a library has a unique name to identify it, the 
builder can execute a library script without having to know the file it is 
located in. This makes it easy to create script systems to override behavior of 
another system; you don't have to edit the other system's code, you just 
implement your own function to override it.

`util_i_libraries.nss` holds functions for interacting with libraries. This 
script requires `util_i_debug.nss`, `util_i_datapoint.nss`, and 
`util_i_csvlists.nss`. 

#### Creating a Library
First, include `util_i_library.nss` in your script. This script contains 
boilerplate code to make your own libraries. It should not be included in a 
script that is not a library because it implements `main()`. 
`util_i_library.nss` does not compile on its own; this is intentional.

Next, add the following functions to the script:

``` c
#include "util_i_library"

void OnLibraryLoad()
{
}

void OnLibraryScript(string sScript, int nEntry)
{
}

```

`OnLibraryLoad()` is called once when the library is first loaded. It uses 
`RegisterLibraryScript()` to set the name and/or number your library script 
should be routed to. 

`OnLibraryScript()` is a dispatch function which will take the name and number 
generated by the calling script and route the library to the correct function. 
You can use the provided script name and number to route to the correct 
function.

For example:

``` c
#include "util_i_library"

void MyFunction()
{
    // ...
}

void MyOtherFunction()
{
    // ...
}

void OnLibraryLoad()
{
    RegisterLibraryScript("MyFunction");
    RegisterLibraryScript("MyOtherFunction");
}

void OnLibraryScript(string sScript, int nEntry)
{
    if (sScript == "MyFunction")
        MyFunction();
    else if (sScript == "MyOtherFunction")
        MyOtherFunction();
}
```

For longer libraries, string comparison in a large if/else tree may be tedious 
and slow. Using nEntry to identify the script to run can help, and it enables 
more complicated routing:

``` c
void OnLibraryLoad()
{
    // Event functions
    RegisterLibraryScript("prr_OnComponentActivate",                 0x0100+0x01);
    RegisterLibraryScript("prr_OnClientEnter",                       0x0100+0x02);

    // Dialog utility functions
    RegisterLibraryScript("prr_SetDatabaseInt",                      0x0200+0x01);
    RegisterLibraryScript("prr_GetDatabaseInt",                      0x0200+0x02);

    RegisterLibraryScript("prr_SetHasMetNPC",                        0x0200+0x03);
    RegisterLibraryScript("prr_GetHasMetNPC",                        0x0200+0x04);

    RegisterLibraryScript("prr_GetReactionHate",                     0x0200+0x05);
    RegisterLibraryScript("prr_GetReactionNeutral",                  0x0200+0x06);
    RegisterLibraryScript("prr_GetReactionLike",                     0x0200+0x07);

    RegisterLibraryScript("prr_SkillCheckHigh",                      0x0200+0x08);
    RegisterLibraryScript("prr_SkillCheckMid",                       0x0200+0x09);
    RegisterLibraryScript("prr_SkillCheckLow",                       0x0200+0x0A);
    RegisterLibraryScript("prr_SkillCheckCustom",                    0x0200+0x0B);

    // Dialog reputation functions
    RegisterLibraryScript("prr_ReputationIncreaseHigh",              0x0300+0x01);
    RegisterLibraryScript("prr_ReputationIncreaseMid",               0x0300+0x02);
    RegisterLibraryScript("prr_ReputationIncreaseLow",               0x0300+0x03);
    RegisterLibraryScript("prr_ReputationDecreaseHigh",              0x0300+0x04);
    RegisterLibraryScript("prr_ReputationDecreaseMid",               0x0300+0x05);
    RegisterLibraryScript("prr_ReputationDecreaseLow",               0x0300+0x06);
    RegisterLibraryScript("prr_ReputationChangeCustom",              0x0300+0x07);

    RegisterLibraryScript("prr_ReputationIncreaseHigh_Party",        0x0300+0x08);
    RegisterLibraryScript("prr_ReputationIncreaseMid_Party",         0x0300+0x09);
    RegisterLibraryScript("prr_ReputationIncreaseLow_Party",         0x0300+0x0A);
    RegisterLibraryScript("prr_ReputationDecreaseHigh_Party",        0x0300+0x0B);
    RegisterLibraryScript("prr_ReputationDecreaseMid_Party",         0x0300+0x0C);
    RegisterLibraryScript("prr_ReputationDecreaseLow_Party",         0x0300+0x0D);
    RegisterLibraryScript("prr_ReputationChangeCustom_Party",        0x0300+0x0E);

    // Dialog faction reputation functions
    RegisterLibraryScript("prr_FactionReputationIncreaseHigh",       0x0400+0x01);
    RegisterLibraryScript("prr_FactionReputationIncreaseMid",        0x0400+0x02);
    RegisterLibraryScript("prr_FactionReputationIncreaseLow",        0x0400+0x03);
    RegisterLibraryScript("prr_FactionReputationDecreaseHigh",       0x0400+0x04);
    RegisterLibraryScript("prr_FactionReputationDecreaseMid",        0x0400+0x05);
    RegisterLibraryScript("prr_FactionReputationDecreaseLow",        0x0400+0x06);
    RegisterLibraryScript("prr_FactionReputationChangeCustom",       0x0400+0x07);

    RegisterLibraryScript("prr_FactionReputationIncreaseHigh_Party", 0x0400+0x08);
    RegisterLibraryScript("prr_FactionReputationIncreaseMid_Party",  0x0400+0x09);
    RegisterLibraryScript("prr_FactionReputationIncreaseLow_Party",  0x0400+0x0A);
    RegisterLibraryScript("prr_FactionReputationDecreaseHigh_Party", 0x0400+0x0B);
    RegisterLibraryScript("prr_FactionReputationDecreaseMid_Party",  0x0400+0x0C);
    RegisterLibraryScript("prr_FactionReputationDecreaseLow_Party",  0x0400+0x0D);
    RegisterLibraryScript("prr_FactionReputationChangeCustom_Party", 0x0400+0x0E);

    // General Utility functions
    RegisterLibraryScript("prr_CaptureChatText",                     0x0500+0x01);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry & 0xff00)
    {
        case 0x0100: switch (nEntry & 0x00ff)
                     {
                         case 0x01: prr_OnComponentActivate();                     break;
                         case 0x02: prr_OnClientEnter();                           break;
                     }   break;

        case 0x0200: switch (nEntry & 0x00ff)
                     {
                         case 0x01: prr_SetDatabaseInt();                          break;
                         case 0x02: prr_GetDatabaseInt();                          break;

                         case 0x03: prr_SetHasMetNPC();                            break;
                         case 0x04: prr_GetHasMetNPC();                  	   break;

                         case 0x05: prr_GetReactionHate();               	   break;
                         case 0x06: prr_GetReactionNeutral();            	   break;
                         case 0x07: prr_GetReactionLike();               	   break;

                         case 0x08: prr_SkillCheckHigh();                	   break;
                         case 0x09: prr_SkillCheckMid();                 	   break;
                         case 0x0A: prr_SkillCheckLow();                 	   break;
                         case 0x0B: prr_SkillCheckCustom();              	   break;
                     }   break;

        case 0x0300: switch (nEntry & 0x00ff)
                     {
                         case 0x01: prr_ReputationIncreaseHigh();                  break;
                         case 0x02: prr_ReputationIncreaseMid();                   break;
                         case 0x03: prr_ReputationIncreaseLow();                   break;
                         case 0x04: prr_ReputationDecreaseHigh();                  break;
                         case 0x05: prr_ReputationDecreaseMid();                   break;
                         case 0x06: prr_ReputationDecreaseLow();                   break;
                         case 0x07: prr_ReputationChangeCustom();                  break;

                         case 0x08: prr_ReputationIncreaseHigh_Party();            break;
                         case 0x09: prr_ReputationIncreaseMid_Party();             break;
                         case 0x0A: prr_ReputationIncreaseLow_Party();             break;
                         case 0x0B: prr_ReputationDecreaseHigh_Party();            break;
                         case 0x0C: prr_ReputationDecreaseMid_Party();             break;
                         case 0x0D: prr_ReputationDecreaseLow_Party();             break;
                         case 0x0E: prr_ReputationChangeCustom_Party();            break;
                     }   break;

        case 0x0400: switch (nEntry & 0x00ff)
                     {

                         case 0x01: prr_FactionReputationIncreaseHigh();           break;
                         case 0x02: prr_FactionReputationIncreaseMid();            break;
                         case 0x03: prr_FactionReputationIncreaseLow();            break;
                         case 0x04: prr_FactionReputationDecreaseHigh();           break;
                         case 0x05: prr_FactionReputationDecreaseMid();            break;
                         case 0x06: prr_FactionReputationDecreaseLow();            break;
                         case 0x07: prr_FactionReputationChangeCustom();           break;

                         case 0x08: prr_FactionReputationIncreaseHigh_Party();     break;
                         case 0x09: prr_FactionReputationIncreaseMid_Party();      break;
                         case 0x0A: prr_FactionReputationIncreaseLow_Party();      break;
                         case 0x0B: prr_FactionReputationDecreaseHigh_Party();     break;
                         case 0x0C: prr_FactionReputationDecreaseMid_Party();      break;
                         case 0x0D: prr_FactionReputationDecreaseLow_Party();      break;
                         case 0x0E: prr_FactionReputationChangeCustom_Party();     break;
                     }   break;

        case 0x0500: switch (nEntry & 0x00ff)
                     {
                         case 0x01: prr_CaptureChatText();                         break;
                     }   break;
    }
}
```

#### Using a Library
`util_i_libraries.nss` is needed to load or run library scripts.

To use a library, you must first load it. This will activate the library's 
`OnLibraryLoad()` function and bind each library script to a name and number.

``` c
// Loads a single library
LoadLibrary("my_l_library");

// Loads a CSV list of library scripts
LoadLibraries("pw_l_plugin, dlg_l_example, prr_l_main");
```

If a library implements a script that has already been implemented in another 
library, a warning will be issued and the newer script will take precedence.

Calling a library script is done using `RunLibraryScript()`. The name supplied 
should be the name bound to the function in the library's `OnLibraryLoad()`. 
This will allow the library's `OnLibraryScript()` to route it to the correct 
function. If the name supplied is a normal script and is not implemented in a 
library, the normal script will be called instead.

``` c
// Executes a single library script on OBJECT_SELF
RunLibraryScript("MyFunction");

// Executes a CSV list of library scripts, for which oPC will be OBJECT_SELF
object oPC = GetFirstPC();
RunLibraryScripts("MyFunction, "MyOtherFunction", oPC);
```

## Acknowledgements
- `util_i_varlists.nss` and `util_i_libraries.nss` adapted from 
  [MemeticAI](https://sourceforge.net/projects/memeticai/).
