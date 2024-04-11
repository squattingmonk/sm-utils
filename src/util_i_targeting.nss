/// ----------------------------------------------------------------------------
/// @file   util_i_targeting.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Functions for managing forced targeting.
/// ----------------------------------------------------------------------------
/// @details
/*
This system is designed to take advantage of NWN:EE's ability to forcibly enter
Targeting Mode for any given PC. It is designed to add a single-use, multi-use,
or unlimited-use hook to the specified PC. Once the PC has satisfied the
conditions of the hook, or manually exited targeting mode, the targeted
objects/locations will be saved and a specified script will be run.

## Setup

1.  You must attach a targeting event script to the module. For example, in your
module load script, you can add this line:

    SetEventScript(GetModule(), EVENT_SCRIPT_MODULE_ON_PLAYER_TARGET, "module_opt");

where "module_opt" is the script that will handle all forced targeting.

2.  The chosen script ("module_opt") must contain reference to the
util_i_targeting function SatisfyTargetingHook(). An example of this follows.

```nwscript
#include "util_i_targeting"

void main()
{
    object oPC = GetLastPlayerToSelectTarget();

    if (SatisfyTargetingHook(oPC))
    {
        // This PC was marked as a targeter, do something here.
    }
}
```

Alternately, if you want the assigned targeting hook scripts to handle
everything, you can just let the system know a targeting event happened:

```nwscript
void main()
{
    object oPC = GetLastPlayerToSelectTarget();
    SatisfyTargetingHook(oPC);
}
```

If oPC didn't have a targeting hook specified, nothing happens.

## Usage

The design of this system centers around a module-wide list of "Targeting Hooks"
that are accessed by util_i_targeting when a player targets any object or
manually exits targeting mode. These hooks are stored in the module's organic
sqlite database. All targeting hook information is volatile and will be reset
when the server/module is reset.

This is the prototype for the `AddTargetingHook()` function:

```nwscript
int AddTargetingHook(object oPC, string sVarName, int nObjectType = OBJECT_TYPE_ALL, string sScript = "", int nUses = 1);
```

- `oPC` is the PC object that will be associated with this hook. This PC will be
  the player that will be entered into Targeting Mode. Additionally, the results
  of his targeting will be saved to the PC object.
- `sVarName` is the variable name to save the results of targeting to. This
  allows for targeting hooks to be added that can be saved to different
  variables for several purposes.
- `nObjectType` is the limiting variable for the types of objects the PC can
  target when they are in targeting mode forced by this hook. It is an optional
  parameter and can be bitmasked with any visible `OBJECT_TYPE_*` constant.
- `sScript` is the resref of the script that will run once the targeting
  conditions have been satisfied. For example, if you create a multi-use
  targeting hook, this script will run after all uses have been exhausted. This
  script will also run if the player manually exits targeting mode without
  selecting a target. Optional. A script-run is not always desirable. The
  targeted object may be required for later use, so a script entry is not a
  requirement.
- `nUses` is the number of times this target hook can be used before it is
  deleted. This is designed to allow multiple targets to be selected and saved
  to the same variable name sVarName. Multi-selection could be useful for DMs in
  defining DM Experience members, even from different parties, or selecting
  multiple NPCs to accomplish a specific action. Optional, defaulted to 1.

  Note: Targeting mode uses specified by `nUses` will be decremented every time
  a player selects a target. Uses will also be decremented when a user manually
  exits targeting mode. Manually exiting targeting mode will delete the
  targeting hook, but any selected targets before exiting targeting mode will be
  saved to the specified variable.

To add a single-use targeting hook that enters the PC into targeting mode, allows
for the selection of a single placeable | creature, then runs the script
"temp_target" upon exiting target mode or selecting a single target:

```nwscript
int nObjectType = OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_CREATURE;
AddTargetingHook(oPC, "spell_target", nObjectType, "temp_target");
```

To add a multi-use targeting hook that enters the PC into targeting mode, allows
for the selection of a specified number of placeables | creatures, then runs the
script "DM_Party" upon exiting targeting mode or selecting the specified number
of targets:

```nwscript
int nObjectType = OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_CREATURE;
AddTargetingHook(oPC, "DM_Party", nObjectType, "DM_Party", 3);
```

> Note: In this case, the player can select up to three targets to save to the
  "DM_Party" variable.

To add an unlmited-use targeting hook that enters the PC into targeting mode,
allows for the selection of an unspecified number of creatures, then runs the
script "temp_target" upon exiting targeting mode or selection of an invalid
target:

```nwscript
int nObjectType = OBJECT_TYPE_CREATURE;
AddTargetingHook(oPC, "NPC_Townspeople", nObjectType, "temp_target", -1);
```

Here is an example "temp_target" post-targeting script that will access each of
the targets saved to the specified variable and send their data to the chat log:

```nwscript
#include "util_i_targeting"

void main()
{
    object oPC = OBJECT_SELF;
    int n, nCount = CountTargetingHookTargets(oPC, "NPC_Townspeople");

    for (n = 0; n < nCount; n++)
    {
        object oTarget = GetTargetingHookObject(oPC, "NPC_Townspeople", n);
        location lTarget = GetTargetingHookLocation(oPC, "NPC_Townspeople", n);
        vector vTarget = GetTargetingHookPosition(oPC, "NPC_Townspeople", n);
    }
}
```

Note: Target objects and positions saved to the variables are persistent while
the server is running, but are not persistent (though they can be made so). If
you wish to overwrite a set of target data with a variable you've already used,
ensure you first delete the current target data with the function
`DeleteTargetingHookTargets();`.
*/

#include "util_c_targeting"
#include "util_i_debug"
#include "util_i_varlists"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

// VarList names for the global targeting hook lists
const string TARGET_HOOK_ID = "TARGET_HOOK_ID";
const string TARGET_HOOK_BEHAVIOR = "TARGET_HOOK_BEHAVIOR";

// List Behaviors
const int TARGET_BEHAVIOR_ADD    = 1;
const int TARGET_BEHAVIOR_DELETE = 2;

// Targeting Hook Data Structure
struct TargetingHook
{
    int    nHookID;
    int    nObjectType;
    int    nUses;
    object oPC;
    string sVarName;
    string sScript;
    int    nValidCursor;
    int    nInvalidCursor;
};

struct TargetingHook TARGETING_HOOK_INVALID;

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Creates targeting hook data tables in the module's sqlite database.
/// @param bReset If TRUE, attempts to drop the tables before creation.
void CreateTargetingDataTables(int bReset = FALSE);

/// @brief Retrieve targeting hook data.
/// @param nHookID The targeting hook's ID.
/// @returns A TargetingHook containing all targeting hook data associated with
///     nHookID.
struct TargetingHook GetTargetingHookDataByHookID(int nHookID);

/// @brief Retrieve targeting hook data.
/// @param oPC The PC object associated with the targeting hook.
/// @param sVarName The varname associated with the targeting hook.
/// @returns A TargetingHook containing all targeting hook data associated with
///     nHookID.
struct TargetingHook GetTargetingHookDataByVarName(object oPC, string sVarName);

/// @brief Retrieve a list of targets.
/// @param oPC The PC object associated with the target list.
/// @param sVarName The VarName associated with the target list.
/// @param nIndex The index of the target to retrieve from the list. If omitted,
///     the entire target list will be returned.
/// @returns A prepared sqlquery containing the target list associated with
///     oPC's sVarName.
sqlquery GetTargetList(object oPC, string sVarName, int nIndex = -1);

/// @brief Add a target to a target list.
/// @param oPC The PC object associated with the target list.
/// @param sVarName The VarName associated with the target list.
/// @param oTarget The target object to be added to the target list.
/// @param oArea The area object where oTarget is located.
/// @param vTarget The position of oTarget within oArea.
/// @returns The number of targets on oPC's target list sVarName after insertion.
int AddTargetToTargetList(object oPC, string sVarName, object oTarget, object oArea, vector vTarget);

/// @brief Delete oPC's sVarName target list.
/// @param oPC The PC object associated with the target list.
/// @param sVarName The VarName associated with the target list.
void DeleteTargetList(object oPC, string sVarName);

/// @brief Delete a targeting hook and all associated targeting hook data.
/// @param nHookID The targeting hook's ID.
void DeleteTargetingHook(int nHookID);

/// @brief Force the PC object associated with targeting hook nHookID to enter
///     targeting mode using properties set by AddTargetingHook().
/// @param nHookID The targeting hook's ID.
/// @param nBehavior The behavior desired from the targeting session. Must be
///     a TARGET_BEHAVIOR_* constant.
void EnterTargetingModeByHookID(int nHookID, int nBehavior = TARGET_BEHAVIOR_ADD);

/// @brief Force the PC object associated with targeting hook nHookID to enter
///     targeting mode using properties set by AddTargetingHook().
/// @param oPC The PC object associated with the target list.
/// @param sVarName The VarName associated with the target list.
/// @param nBehavior The behavior desired from the targeting session. Must be
///     a TARGET_BEHAVIOR_* constant.
void EnterTargetingModeByVarName(object oPC, string sVarName, int nBehavior = TARGET_BEHAVIOR_ADD);

/// @brief Retrieve a targeting hook id.
/// @param oPC The PC object associated with the target list.
/// @param sVarName The VarName associated with the target list.
/// @returns The targeting hook id assocaited with oPC's sVarName target list.
int GetTargetingHookID(object oPC, string sVarName);

/// @brief Retrieve a targeting hook's sVarName.
/// @param nHookID The targeting hook's ID.
/// @returns The target list name sVarName associated with nHookID.
string GetTargetingHookVarName(int nHookID);

/// @brief Retrieve a targeting hook's allowed object types.
/// @param nHookID The targeting hook's ID.
/// @returns A bitmap containing the allowed target types associated with
///     nHookID.
int GetTargetingHookObjectType(int nHookID);

/// @brief Retrieve a targeting hook's remaining uses.
/// @param nHookID The targeting hook's ID.
/// @returns The number of uses remaining for targeting hook nHookID.
int GetTargetingHookUses(int nHookID);

/// @brief Retrieve a targeting hook's script.
/// @param nHookID The targeting hook's ID.
/// @returns The script associated with targeting hook nHookID.
string GetTargetingHookScript(int nHookID);

/// @brief Add a targeting hook to the global targeting hook list and save
///     targeting hook parameters for later use.
/// @param oPC The PC object associated with the target list.
/// @param sVarName The VarName associated with the target list.
/// @param nObjectType A bitmasked value containing all object types allowed
///     to be targeted by this hook.
/// @param sScript The script that will be run when this target hook is
///     satisfied.
/// @param nUses The number of times this targeting hook is allowed to be used
///     before it is automatically deleted. Omitting this value will yield a
///     single use hook.  Use -1 for an infinite-use hook.
/// @param nValidCursor A MOUSECURSOR_* cursor indicating a valid target.
/// @param nInvalidCursor A MOUSECURSOR_* cursor indicating an invalid target.
/// @returns A unique ID associated with the new targeting hook.
int AddTargetingHook(object oPC, string sVarName, int nObjectType = OBJECT_TYPE_ALL, string sScript = "",
                     int nUses = 1, int nValidCursor = MOUSECURSOR_MAGIC, int nInvalidCursor = MOUSECURSOR_NOMAGIC);

/// @brief Save target data to the PC object as an object and location variable
///     defined by sVarName in AddTargetingHook(). Decrements remaining targeting
///     hook uses and, if required, deletes the targeting hook.
/// @param oPC The PC object associated with the target list.
/// @returns TRUE if OpC has a current targeting hook, FALSE otherwise.
int SatisfyTargetingHook(object oPC);

/// @brief Retrieve a targeting list's object at index nIndex.
/// @param oPC The PC object associated with the target list.
/// @param sVarName The VarName associated with the target list.
/// @param nIndex The index at which to retrieve the target object.
/// @returns The targeting's lists target at index nIndex, or the first
///     target on the list if nIndex is omitted.
object GetTargetingHookObject(object oPC, string sVarName, int nIndex = 1);

/// @brief Retrieve a targeting list's location at index nIndex.
/// @param oPC The PC object associated with the target list.
/// @param sVarName The VarName associated with the target list.
/// @param nIndex The index at which to retrieve the target location.
/// @returns The targeting's lists location at index nIndex, or the first
///     location on the list if nIndex is omitted.
location GetTargetingHookLocation(object oPC, string sVarName, int nIndex = 1);

/// @brief Retrieve a targeting list's position at index nIndex.
/// @param oPC The PC object associated with the target list.
/// @param sVarName The VarName associated with the target list.
/// @param nIndex The index at which to retrieve the target position.
/// @returns The targeting's lists position at index nIndex, or the first
///     position on the list if nIndex is omitted.
vector GetTargetingHookPosition(object oPC, string sVarName, int nIndex = 1);

/// @brief Determine how many targets are on a target list.
/// @param oPC The PC object associated with the target list.
/// @param sVarName The VarName associated with the target list.
/// @returns The number of targets associated with the saved as sVarName
///     on oPC.
// ---< CountTargetingHookTargets >---
int CountTargetingHookTargets(object oPC, string sVarName);

/// @brief Delete a targeting hook target.
/// @param oPC The PC object associated with the target list.
/// @param sVarName The VarName associated with the target list.
/// @param nIndex The index at which to delete the target data. If omitted,
///     the first target on the list will be deleted.
/// @returns The number of targets remaining on oPC's sVarName target list
///     after deletion.
int DeleteTargetingHookTarget(object oPC, string sVarName, int nIndex = 1);

/// @brief Retrieve the target list object's internal index.
/// @param oPC The PC object associated with the target list.
/// @param sVarName The VarName associated with the target list.
/// @param oObject The object to find on oPC's sVarName target list.
int GetTargetingHookIndex(object oPC, string sVarName, object oTarget);

/// @brief Delete target list target data by internal index.
/// @param oPC The PC object associated with the target list.
/// @param sVarName The VarName associated with the target list.
/// @param nIndex The internal index of the target data to be deleted. This
///     index can be retrieved from GetTargetingHookIndex().
/// @returns The number of targets remaining on oPC's sVarName target list
///     after deletion.
int DeleteTargetingHookTargetByIndex(object oPC, string sVarName, int nIndex);

// -----------------------------------------------------------------------------
//                            Private Function Definitions
// -----------------------------------------------------------------------------

sqlquery _PrepareTargetingQuery(string s)
{
    return SqlPrepareQueryObject(GetModule(), s);
}

string _GetTargetingHookFieldData(int nHookID, string sField)
{
    string s =  "SELECT " + sField + " " +
                "FROM targeting_hooks " +
                "WHERE nHookID = @nHookID;";
    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindInt(q, "@nHookID", nHookID);

    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

int _GetLastTargetingHookID()
{
    string s = "SELECT seq FROM sqlite_sequence WHERE name = @name;";
    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindString(q, "@name", "targeting_hooks");

    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

string _GetTargetData(object oPC, string sVarName, string sField, int nIndex = 1)
{
    string s =  "SELECT " + sField + " " +
                "FROM targeting_targets " +
                "WHERE sUUID = @sUUID " +
                    "AND sVarName = @sVarName " +
                "LIMIT 1 OFFSET " + IntToString(nIndex) + ";";

    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindString(q, "@sUUID", GetObjectUUID(oPC));
    SqlBindString(q, "@sVarName", sVarName);

    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

void _EnterTargetingMode(struct TargetingHook th, int nBehavior)
{
    SetLocalInt(th.oPC, TARGET_HOOK_ID, th.nHookID);
    SetLocalInt(th.oPC, TARGET_HOOK_BEHAVIOR, nBehavior);
    EnterTargetingMode(th.oPC, th.nObjectType, th.nValidCursor, th.nInvalidCursor);
}

void _DeleteTargetingHookData(int nHookID)
{
    string s =  "DELETE FROM targeting_hooks " +
                "WHERE nHookID = @nHookID;";

    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindInt(q, "@nHookID", nHookID);
    SqlStep(q);
}

void _ExitTargetingMode(int nHookID)
{
    struct TargetingHook th = GetTargetingHookDataByHookID(nHookID);
    if (th.sScript != "")
    {
        Debug("Running post-targeting script " + th.sScript + " from Targeting Hook ID " +
            IntToString(nHookID) + " on " + GetName(th.oPC) + " with varname " + th.sVarName);
        RunTargetingHookScript(th.sScript, th.oPC);
    }
    else
        Debug("No post-targeting script specified for Targeting Hook ID " + IntToString(nHookID) + " " +
            "on " + GetName(th.oPC) + " with varname " + th.sVarName);

    DeleteTargetingHook(nHookID);
    DeleteLocalInt(th.oPC, TARGET_HOOK_ID);
    DeleteLocalInt(th.oPC, TARGET_HOOK_BEHAVIOR);
}

// Reduces the number of targeting hooks remaining. When the remaining number is
// 0, the hook is automatically deleted.
int _DecrementTargetingHookUses(struct TargetingHook th, int nBehavior)
{
    int nUses = GetTargetingHookUses(th.nHookID);

    if (--nUses == 0)
    {
        if (IsDebugging(DEBUG_LEVEL_DEBUG))
            Debug("Decrementing target hook uses for ID " + HexColorString(IntToString(th.nHookID), COLOR_CYAN) +
                "\n  Uses remaining -> " + (nUses ? HexColorString(IntToString(nUses), COLOR_CYAN) : HexColorString(IntToString(nUses), COLOR_RED_LIGHT)) + "\n");

        _ExitTargetingMode(th.nHookID);
    }
    else
    {
        string s =  "UPDATE targeting_hooks " +
                    "SET nUses = nUses - 1 " +
                    "WHERE nHookID = @nHookID;";

        sqlquery q = _PrepareTargetingQuery(s);
        SqlBindInt(q, "@nHookID", th.nHookID);
        SqlStep(q);

        _EnterTargetingMode(th, nBehavior);
    }

    return nUses;
}

// -----------------------------------------------------------------------------
//                            Public Function Definitions
// -----------------------------------------------------------------------------

// Temporary function for feedback purposes only
string ObjectTypeToString(int nObjectType)
{
    string sResult;

    if (nObjectType & OBJECT_TYPE_CREATURE)
        sResult += (sResult == "" ? "" : ", ") + "Creatures";

    if (nObjectType & OBJECT_TYPE_ITEM)
        sResult += (sResult == "" ? "" : ", ") + "Items";

    if (nObjectType & OBJECT_TYPE_TRIGGER)
        sResult += (sResult == "" ? "" : ", ") + "Triggers";

    if (nObjectType & OBJECT_TYPE_DOOR)
        sResult += (sResult == "" ? "" : ", ") + "Doors";

    if (nObjectType & OBJECT_TYPE_AREA_OF_EFFECT)
        sResult += (sResult == "" ? "" : ", ") + "Areas of Effect";

    if (nObjectType & OBJECT_TYPE_WAYPOINT)
        sResult += (sResult == "" ? "" : ", ") + "Waypoints";

    if (nObjectType & OBJECT_TYPE_PLACEABLE)
        sResult += (sResult == "" ? "" : ", ") + "Placeables";

    if (nObjectType & OBJECT_TYPE_STORE)
        sResult += (sResult == "" ? "" : ", ") + "Stores";

    if (nObjectType & OBJECT_TYPE_ENCOUNTER)
        sResult += (sResult == "" ? "" : ", ") + "Encounters";

    if (nObjectType & OBJECT_TYPE_TILE)
        sResult += (sResult == "" ? "" : ", ") + "Tiles";

    return sResult;
}

void CreateTargetingDataTables(int bReset = FALSE)
{
    object oModule = GetModule();

    if (bReset)
    {
        string sDropHooks = "DROP TABLE IF EXISTS targeting_hooks;";
        string sDropTargets = "DROP TABLE IF EXISTS targeting_targets;";

        sqlquery q;
        q = _PrepareTargetingQuery(sDropHooks);   SqlStep(q);
        q = _PrepareTargetingQuery(sDropTargets); SqlStep(q);

        DeleteLocalInt(oModule, "TARGETING_INITIALIZED");
        Warning(HexColorString("Targeting database tables have been dropped", COLOR_RED_LIGHT));
    }

    if (GetLocalInt(oModule, "TARGETING_INITIALIZED"))
        return;

    string sData = "CREATE TABLE IF NOT EXISTS targeting_hooks (" +
        "nHookID INTEGER PRIMARY KEY AUTOINCREMENT, " +
        "sUUID TEXT, " +
        "sVarName TEXT, " +
        "nObjectType INTEGER, " +
        "nUses INTEGER default '1', " +
        "sScript TEXT, " +
        "nValidCursor INTEGER, " +
        "nInvalidCursor INTEGER, " +
        "UNIQUE (sUUID, sVarName));";

    string sTargets = "CREATE TABLE IF NOT EXISTS targeting_targets (" +
        "nTargetID INTEGER PRIMARY KEY AUTOINCREMENT, " +
        "sUUID TEXT, " +
        "sVarName TEXT, " +
        "sTargetObject TEXT, " +
        "sTargetArea TEXT, " +
        "vTargetLocation TEXT);";

    sqlquery q;
    q = _PrepareTargetingQuery(sData);     SqlStep(q);
    q = _PrepareTargetingQuery(sTargets);  SqlStep(q);

    Debug(HexColorString("Targeting database tables have been created", COLOR_GREEN_LIGHT));
    SetLocalInt(oModule, "TARGETING_INITIALIZED", TRUE);
}

struct TargetingHook GetTargetingHookDataByHookID(int nHookID)
{
    string s =  "SELECT sUUID, sVarName, nObjectType, nUses, sScript, nValidCursor, nInvalidCursor " +
                "FROM targeting_hooks " +
                "WHERE nHookID = @nHookID;";

    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindInt(q, "@nHookID", nHookID);

    struct TargetingHook th;

    if (SqlStep(q))
    {
        th.nHookID = nHookID;
        th.oPC = GetObjectByUUID(SqlGetString(q, 0));
        th.sVarName = SqlGetString(q, 1);
        th.nObjectType = SqlGetInt(q, 2);
        th.nUses = SqlGetInt(q, 3);
        th.sScript = SqlGetString(q, 4);
        th.nValidCursor = SqlGetInt(q, 5);
        th.nInvalidCursor = SqlGetInt(q, 6);
    }
    else
        Warning("Targeting data for target hook " + IntToString(nHookID) + " not found");

    return th;
}

struct TargetingHook GetTargetingHookDataByVarName(object oPC, string sVarName)
{
    int nHookID = GetTargetingHookID(oPC, sVarName);
    return GetTargetingHookDataByHookID(nHookID);
}

sqlquery GetTargetList(object oPC, string sVarName, int nIndex = -1)
{
    string s =  "SELECT sTargetObject, sTargetArea, vTargetLocation " +
                "FROM targeting_targets " +
                "WHERE sUUID = @sUUID " +
                    "AND sVarName = @sVarName" +
                    (nIndex == -1 ? ";" : "LIMIT 1 OFFSET " + IntToString(nIndex)) + ";";

    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindString(q, "@sUUID", GetObjectUUID(oPC));
    SqlBindString(q, "@sVarName", sVarName);

    return q;
}

int AddTargetToTargetList(object oPC, string sVarName, object oTarget, object oArea, vector vTarget)
{
    string s =  "INSERT INTO targeting_targets (sUUID, sVarName, sTargetObject, sTargetArea, vTargetLocation) " +
                "VALUES (@sUUID, @sVarName, @sTargetObject, @sTargetArea, @vTargetLocation);";

    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindString(q, "@sUUID", GetObjectUUID(oPC));
    SqlBindString(q, "@sVarName", sVarName);
    SqlBindString(q, "@sTargetObject", ObjectToString(oTarget));
    SqlBindString(q, "@sTargetArea", ObjectToString(oArea));
    SqlBindVector(q, "@vTargetLocation", vTarget);
    SqlStep(q);

    return CountTargetingHookTargets(oPC, sVarName);
}

void DeleteTargetList(object oPC, string sVarName)
{
    string s =  "DELETE FROM targeting_targets " +
                "WHERE sUUID = @sUUID " +
                    "AND sVarName = @sVarName;";

    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindString(q, "@sUUID", GetObjectUUID(oPC));
    SqlBindString(q, "@sVarName", sVarName);

    SqlStep(q);
}

void EnterTargetingModeByHookID(int nHookID, int nBehavior = TARGET_BEHAVIOR_ADD)
{
    struct TargetingHook th = GetTargetingHookDataByHookID(nHookID);

    if (th == TARGETING_HOOK_INVALID)
    {
        Warning("EnterTargetingModeByHookID::Unable to retrieve valid targeting data for " +
            "targeting hook " + IntToString(nHookID));
        return;
    }

    if (GetIsObjectValid(th.oPC))
        _EnterTargetingMode(th, nBehavior);
}

void EnterTargetingModeByVarName(object oPC, string sVarName, int nBehavior = TARGET_BEHAVIOR_ADD)
{
    struct TargetingHook th = GetTargetingHookDataByVarName(oPC, sVarName);

    if (th == TARGETING_HOOK_INVALID)
    {
        Warning("EnterTargetingModeByVarName::Unable to retrieve valid targeting data for " +
            "targeting hook " + sVarName + " on " + GetName(oPC));
        return;
    }

    if (GetIsObjectValid(th.oPC))
        _EnterTargetingMode(th, nBehavior);
}

int GetTargetingHookID(object oPC, string sVarName)
{
    string s =  "SELECT nHookID " +
                "FROM targeting_hooks " +
                "WHERE sUUID = @sUUID " +
                    "AND sVarName = @sVarName;";

    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindString(q, "@sUUID", GetObjectUUID(oPC));
    SqlBindString(q, "@sVarName", sVarName);

    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

string GetTargetingHookVarName(int nHookID)
{
    return _GetTargetingHookFieldData(nHookID, "sVarName");
}

int GetTargetingHookObjectType(int nHookID)
{
    return StringToInt(_GetTargetingHookFieldData(nHookID, "nObjectType"));
}

int GetTargetingHookUses(int nHookID)
{
    return StringToInt(_GetTargetingHookFieldData(nHookID, "nUses"));
}

string GetTargetingHookScript(int nHookID)
{
    return _GetTargetingHookFieldData(nHookID, "sScript");
}

int AddTargetingHook(object oPC, string sVarName, int nObjectType = OBJECT_TYPE_ALL, string sScript = "",
                     int nUses = 1, int nValidCursor = MOUSECURSOR_MAGIC, int nInvalidCursor = MOUSECURSOR_NOMAGIC)
{
    CreateTargetingDataTables();

    string s =  "REPLACE INTO targeting_hooks (sUUID, sVarName, nObjectType, nUses, sScript, nValidCursor, nInvalidCursor) " +
                "VALUES (@sUUID, @sVarName, @nObjectType, @nUses, @sScript, @nValidCursor, @nInvalidCursor);";

    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindString(q, "@sUUID", GetObjectUUID(oPC));
    SqlBindString(q, "@sVarName", sVarName);
    SqlBindInt   (q, "@nObjectType", nObjectType);
    SqlBindInt   (q, "@nUses", nUses);
    SqlBindString(q, "@sScript", sScript);
    SqlBindInt   (q, "@nValidCursor", nValidCursor);
    SqlBindInt   (q, "@nInvalidCursor", nInvalidCursor);
    SqlStep(q);

    if (IsDebugging(DEBUG_LEVEL_DEBUG))
    {
        Debug("Adding targeting hook ID " + HexColorString(IntToString(_GetLastTargetingHookID()), COLOR_CYAN) +
            "\n  sVarName -> " + HexColorString(sVarName, COLOR_CYAN) +
            "\n  nObjectType -> " + HexColorString(ObjectTypeToString(nObjectType), COLOR_CYAN) +
            "\n  sScript -> " + (sScript == "" ? HexColorString("[None]", COLOR_RED_LIGHT) :
                HexColorString(sScript, COLOR_CYAN)) +
            "\n  nUses -> " + (nUses == -1 ? HexColorString("Unlimited", COLOR_CYAN) :
                (nUses > 0 ? HexColorString(IntToString(nUses), COLOR_CYAN) :
                HexColorString(IntToString(nUses), COLOR_RED_LIGHT))) + 
            "\n  nValidCursor -> " + IntToString(nValidCursor) +
            "\n  nInvalidCursor -> " + IntToString(nInvalidCursor) + "\n");
    }

    return _GetLastTargetingHookID();
}

void DeleteTargetingHook(int nHookID)
{
    if (IsDebugging(DEBUG_LEVEL_DEBUG))
        Debug("Deleting targeting hook ID " + HexColorString(IntToString(nHookID), COLOR_CYAN) + "\n");

    _DeleteTargetingHookData(nHookID);
}

int SatisfyTargetingHook(object oPC)
{
    int nHookID = GetLocalInt(oPC, TARGET_HOOK_ID);
    if (nHookID == 0)
        return FALSE;

    int nBehavior = GetLocalInt(oPC, TARGET_HOOK_BEHAVIOR);

    struct TargetingHook th = GetTargetingHookDataByHookID(nHookID);

    if (th == TARGETING_HOOK_INVALID)
    {
        Warning("SatisfyTargetingHook::Unable to retrieve valid targeting data for " +
            "targeting hook " + IntToString(nHookID));
        return FALSE;
    }

    string sVarName = th.sVarName;
    object oTarget = GetTargetingModeSelectedObject();
    vector vTarget = GetTargetingModeSelectedPosition();

    int bValid = TRUE;

    if (IsDebugging(DEBUG_LEVEL_DEBUG))
    {
        Debug("Targeted Object -> " + (GetIsObjectValid(oTarget) ? (GetIsPC(oTarget) ? HexColorString(GetName(oTarget), COLOR_GREEN_LIGHT) : HexColorString(GetTag(oTarget), COLOR_CYAN)) : HexColorString("OBJECT_INVALID", COLOR_RED_LIGHT)) +
            "\n  Type -> " + HexColorString(ObjectTypeToString(GetObjectType(oTarget)), COLOR_CYAN));
        Debug("Targeted Position -> " + (vTarget == Vector() ? HexColorString("POSITION_INVALID", COLOR_RED_LIGHT) :
                                        HexColorString("(" + FloatToString(vTarget.x, 3, 1) + ", " +
                                            FloatToString(vTarget.y, 3, 1) + ", " +
                                            FloatToString(vTarget.z, 3, 1) + ")", COLOR_CYAN)) + "\n");
    }

    if (GetIsObjectValid(oTarget))
    {
        if (nBehavior == TARGET_BEHAVIOR_ADD)
        {
            if (IsDebugging(DEBUG_LEVEL_DEBUG))
            {
                object oArea = GetArea(oTarget);

                Debug(HexColorString("Saving targeted object and position to list [" + th.sVarName + "]:", COLOR_CYAN) +
                        "\n  Tag -> " + HexColorString(GetTag(oTarget), COLOR_CYAN) +
                        "\n  Location -> " + HexColorString(JsonDump(LocationToJson(Location(oArea, vTarget, 0.0))), COLOR_CYAN) +
                        "\n  Area -> " + HexColorString((GetIsObjectValid(oArea) ? GetTag(oArea) : "AREA_INVALID"), COLOR_CYAN) + "\n");
            }

            AddTargetToTargetList(oPC, sVarName, oTarget, GetArea(oPC), vTarget);
        }
        else if (nBehavior == TARGET_BEHAVIOR_DELETE)
        {
            if (GetArea(oTarget) == oTarget)
                Warning("Location/Tile targets cannot be deleted; select a game object");
            else
            {
                Debug(HexColorString("Attempting to delete targeted object and position from list [" + th.sVarName + "]:", COLOR_CYAN));
                int nIndex = GetTargetingHookIndex(oPC, sVarName, oTarget);
                if (nIndex == 0 && IsDebugging(DEBUG_LEVEL_DEBUG))
                    Debug("  > " + HexColorString("Target " + (GetIsPC(oTarget) ? GetName(oTarget) : GetTag(oTarget)) + " not found " +
                        "on list [" + th.sVarName + "]; removal aborted", COLOR_RED_LIGHT));
                else
                {
                    DeleteTargetingHookTargetByIndex(oPC, sVarName, nIndex);

                    if (IsDebugging(DEBUG_LEVEL_DEBUG))
                        Debug("  > " + HexColorString("Target " + (GetIsPC(oTarget) ? GetName(oTarget) : GetTag(oTarget)) + " removed from " +
                            "list [" + th.sVarName + "]", COLOR_GREEN_LIGHT));
                }
            }
        }
    }
    else
        bValid = FALSE;

    if (!bValid)
        _ExitTargetingMode(nHookID);
    else
    {
        if (th.nUses == -1)
            _EnterTargetingMode(th, nBehavior);
        else
            _DecrementTargetingHookUses(th, nBehavior);
    }

    return TRUE;
}

int DeleteTargetingHookTargetByIndex(object oPC, string sVarName, int nIndex)
{
    string s  = "DELETE FROM targeting_targets " +
                "WHERE nTargetID = @nTargetID;";

    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindInt(q, "@nTargetID", nIndex);
    SqlStep(q);

    return CountTargetingHookTargets(oPC, sVarName);
}

int GetTargetingHookIndex(object oPC, string sVarName, object oTarget)
{
    string s =  "SELECT nTargetID " +
                "FROM targeting_targets " +
                "WHERE sUUID = @sUUID " +
                    "AND sVarName = @sVarName " +
                    "AND sTargetObject = @sTargetObject;";

    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindString(q, "@sUUID", GetObjectUUID(oPC));
    SqlBindString(q, "@sVarName", sVarName);
    SqlBindString(q, "@sTargetObject", ObjectToString(oTarget));

    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

object GetTargetingHookObject(object oPC, string sVarName, int nIndex = 1)
{
    return StringToObject(_GetTargetData(oPC, sVarName, "sTargetObject", nIndex));
}

location GetTargetingHookLocation(object oPC, string sVarName, int nIndex = 1)
{
    sqlquery q = GetTargetList(oPC, sVarName, 1);
    if (SqlStep(q))
    {
        object oArea = StringToObject(SqlGetString(q, 1));
        vector vTarget = SqlGetVector(q, 2);

        return Location(oArea, vTarget, 0.0);
    }

    return Location(OBJECT_INVALID, Vector(), 0.0);
}

vector GetTargetingHookPosition(object oPC, string sVarName, int nIndex = 1)
{
    sqlquery q = GetTargetList(oPC, sVarName, 1);
    if (SqlStep(q))
        return SqlGetVector(q, 2);

    return Vector();
}

int CountTargetingHookTargets(object oPC, string sVarName)
{
    string s =  "SELECT COUNT (nTargetID) " +
                "FROM targeting_targets " +
                "WHERE sUUID = @sUUID " +
                    "AND sVarName = @sVarName;";

    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindString(q, "@sUUID", GetObjectUUID(oPC));
    SqlBindString(q, "@sVarName", sVarName);

    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

int DeleteTargetingHookTarget(object oPC, string sVarName, int nIndex = 1)
{
    string s =  "DELETE FROM targeting_targets " +
                "WHERE sUUID = @sUUID " +
                    "AND sVarName = @sVarName " +
                "LIMIT 1 OFFSET " + IntToString(nIndex) + ";";

    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindString(q, "@sUUID", GetObjectUUID(oPC));
    SqlBindString(q, "@sVarName", sVarName);
    SqlStep(q);

    return CountTargetingHookTargets(oPC, sVarName);
}
