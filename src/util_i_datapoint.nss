/// ----------------------------------------------------------------------------
/// @file   util_i_datapoint.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Functions for creating and interacting with datapoints, which are
///     invisible objects used to hold variables specific to a system.
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

const string DATA_PREFIX = "Datapoint: ";
const string DATA_POINT  = "x1_hen_inv";       ///< Resref for data points
const string DATA_ITEM   = "nw_it_msmlmisc22"; ///< Resref for data items

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Creates a datapoint (placeable) that stores variables for a
///     specified system
/// @param sSystem Name of system associated with this datapoint
/// @param oOwner (optional) Parent object of this datapoint; if omitted,
///     defaults to GetModule();
/// @note A datapoint is created at oOwner's location; if oOwner is invalid or
///     is an area object, the datapoint is created at the module starting
///     location.
/// @returns sSystem's datapoint object
object CreateDatapoint(string sSystem, object oOwner = OBJECT_INVALID);

/// @brief Retrieves a datapoint (placeable) that stores variables for a
///     specified system
/// @param sSystem Name of system associated with this datapoint
/// @param oOwner (optional) Parent object of this datapoint; if omitted,
///     defaults to GetModule()
/// @param bCreate If TRUE and the datapoint cannot be found, a new datapoint
///     will be created at oOwner's location; if oOwner is invalid or is an
///     area object, the datapoint is created at the module starting location
/// @returns sSystem's datapoint object
object GetDatapoint(string sSystem, object oOwner = OBJECT_INVALID, int bCreate = TRUE);

/// @brief Sets a datapoint (game object) as the object that stores variables
///     for a specified system
/// @param sSystem Name of system associated with this datapoint
/// @param oTarget Object to be used as a datapoint
/// @param oOwner (optional) Parent object of this datapoint; if omitted,
///     default to GetModule()
/// @note Allows any valid game object to be used as a datapoint
void SetDatapoint(string sSystem, object oTarget, object oOwner = OBJECT_INVALID);

/// @brief Creates a data item (item) that stores variables for a specified
///     sub-system
/// @param oDatapoint Datapoint object on which to place the data item
/// @param sSubSystem Name of sub-system associated with this data item
/// @returns sSubSystem's data item object
object CreateDataItem(object oDatapoint, string sSubSystem);

/// @brief Retrieves a data item (item) that stores variables for a specified
///     sub-system
/// @param oDatapoint Datapoint object from which to retrieve the data item
/// @param sSubSystem Name of sub-system associated with the data item
/// @returns sSubSystem's data item object
object GetDataItem(object oDatapoint, string sSubSystem);

/// @brief Sets a data item (item) as the object that stores variables for a
///     specified sub-system
/// @param oDatapoint Datapoint object on which to place the data item
/// @param sSubSystem Name of sub-system assocaited with the data item
/// @param oItem Item to be used as a data item
/// @note oItem must a valid game item that can be placed into an object's
///     inventory
void SetDataItem(object oDatapoint, string sSubSystem, object oItem);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

object CreateDatapoint(string sSystem, object oOwner = OBJECT_INVALID)
{
    if (oOwner == OBJECT_INVALID)
        oOwner = GetModule();

    location lLoc = GetLocation(oOwner);
    if (!GetObjectType(oOwner))
        lLoc = GetStartingLocation();

    object oData = CreateObject(OBJECT_TYPE_PLACEABLE, DATA_POINT, lLoc);
    SetName(oData, DATA_PREFIX + sSystem);
    SetUseableFlag(oData, FALSE);
    SetDatapoint(sSystem, oData, oOwner);
    return oData;
}

object GetDatapoint(string sSystem, object oOwner = OBJECT_INVALID, int bCreate = TRUE)
{
    if (oOwner == OBJECT_INVALID)
        oOwner = GetModule();

    object oData = GetLocalObject(oOwner, DATA_PREFIX + sSystem);

    if (!GetIsObjectValid(oData) && bCreate)
        oData = CreateDatapoint(sSystem, oOwner);

    return oData;
}

void SetDatapoint(string sSystem, object oTarget, object oOwner = OBJECT_INVALID)
{
    if (oOwner == OBJECT_INVALID)
        oOwner = GetModule();

    SetLocalObject(oOwner, DATA_PREFIX + sSystem, oTarget);
}

object CreateDataItem(object oDatapoint, string sSubSystem)
{
    object oItem = CreateItemOnObject(DATA_ITEM, oDatapoint);
    SetLocalObject(oDatapoint, sSubSystem, oItem);
    SetName(oItem, sSubSystem);
    return oItem;
}

object GetDataItem(object oDatapoint, string sSubSystem)
{
    return GetLocalObject(oDatapoint, sSubSystem);
}

void SetDataItem(object oDatapoint, string sSubSystem, object oItem)
{
    SetLocalObject(oDatapoint, sSubSystem, oItem);
}
