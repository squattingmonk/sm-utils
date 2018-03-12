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
const string DATA_PREFIX = "data_";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< GetDatapoint >---
// ---< util_i_datapoint >---
// Returns the object that sSystem uses to store system-related variables. If
// the datapoint has not been created, the system will create one.
object GetDatapoint(string sSystem);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------


object GetDatapoint(string sSystem)
{
    string sData = DATA_PREFIX + sSystem;
    object oData = GetLocalObject(GetModule(), sSystem);

    if (!GetIsObjectValid(oData))
    {
        oData = GetWaypointByTag(sData);
        if (!GetIsObjectValid(oData))
        {
            oData = CreateObject(OBJECT_TYPE_WAYPOINT, DATA_RESREF,
                    GetStartingLocation(), FALSE, sData);
        }

        SetLocalObject(GetModule(), sData, oData);
    }

    return oData;
}
