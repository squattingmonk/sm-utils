// -----------------------------------------------------------------------------
//    File: util_i_datapoint.nss
//  System: Utilities (include script)
//     URL: https://github.com/squattingmonk/sm-utils
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// This file holds functions for creating and interacting with data points. Data
// points are invisible objects used to hold variables specific to a system.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

const string DATA_RESREF = "nw_waypoint001";
const string DATA_PREFIX = "Datapoint: ";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< GetDatapoint >---
// ---< util_i_datapoint >---
// Returns the object that sSystem uses to store system-related variables. If
// the datapoint has not been created and bCreate, the system will create one.
// The system-generated datapoint is a stock NWN waypoint created at the module
// starting location.
object GetDatapoint(string sSystem, int bCreate = TRUE);

// ---< SetDatapoint >---
// ---< util_i_datapoint >---
// Sets oTarget as the datapoint for sSystem. Useful if you want more control
// over the resref, object type, or location of your datapoint.
void SetDatapoint(string sSystem, object oTarget);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

object GetDatapoint(string sSystem, int bCreate = TRUE)
{
    object oData = GetLocalObject(GetModule(), DATA_PREFIX + sSystem);

    if (!GetIsObjectValid(oData) && bCreate)
    {
        oData = CreateOject(OBJECT_TYPE_WAYPOINT, DATA_RESREF,
                GetStartingLocation(), FALSE, sSystem);
        SetLocalObject(GetModule(), DATA_PREFIX + sSystem, oData);
    }

    return oData;
}

void SetDatapoint(string sSystem, object oTarget)
{
    SetLocalObject(GetModule(), DATA_PREFIX + sSystem, oTarget);
}
