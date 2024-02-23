/// ----------------------------------------------------------------------------
/// @file   util_i_varlists.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Functions for manipulating local variable lists.
/// @details
/// Local variable lists are json arrays of a single type stored as local
/// variables. They are namespaced by type, so you can maintain lists of
/// different types using the same varname.
///
/// The majority of functions in this file apply to each possible variable type:
/// float, int, location, vector, object, string, json. However, there are some
/// that only apply to a subset of variable types, such as
/// Sort[Float|Int|String]List() and [Increment|Decrement]ListInt().
/// ----------------------------------------------------------------------------

#include "util_i_math"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

// Constants used to describe float|int|string sorting order
const int LIST_SORT_ASC  = 1;
const int LIST_SORT_DESC = 2;

// Prefixes used to keep list variables from colliding with other locals. These
// constants are considered private and should not be referenced from other scripts.
const string LIST_REF              = "Ref:";
const string VARLIST_TYPE_VECTOR   = "VL:";
const string VARLIST_TYPE_FLOAT    = "FL:";
const string VARLIST_TYPE_INT      = "IL:";
const string VARLIST_TYPE_LOCATION = "LL:";
const string VARLIST_TYPE_OBJECT   = "OL:";
const string VARLIST_TYPE_STRING   = "SL:";
const string VARLIST_TYPE_JSON     = "JL:";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Convert a vector to a json object.
/// @param vPosition The vector to convert.
/// @note Alias for JsonVector().
json VectorToJson(vector vPosition = [0.0, 0.0, 0.0]);

/// @brief Convert a vector to a json object.
/// @param vPosition The vector to convert.
json JsonVector(vector vPosition = [0.0, 0.0, 0.0]);

/// @brief Convert a json object to a vector.
/// @param jPosition The json object to convert.
/// @note Alias for JsonGetVector().
vector JsonToVector(json jPosition);

/// @brief Convert a json object to a vector.
/// @param jPosition The json object to convert.
vector JsonGetVector(json jPosition);

/// @brief Convert a location to a json object.
/// @param lLocation The location to convert.
/// @note Alias for JsonLocation().
json LocationToJson(location lLocation);

/// @brief Convert a location to a json object.
/// @param lLocation The location to convert.
json JsonLocation(location lLocation);

/// @brief Convert a json object to a location.
/// @param jLocation The json object to convert.
/// @note Alias for JsonGetLocation().
location JsonToLocation(json jLocation);

/// @brief Convert a json object to a location.
/// @param jLocation The json object to convert.
location JsonGetLocation(json jLocation);

/// @brief Add a value to a float list on a target.
/// @param oTarget The object the list is stored on.
/// @param fValue The value to add to the list.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, will not add the value if it is already present.
/// @returns TRUE if the operation was successful; FALSE otherwise.
int AddListFloat(object oTarget, float fValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Add a value to an int list on a target.
/// @param oTarget The object the list is stored on.
/// @param nValue The value to add to the list.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, will not add the value if it is already present.
/// @returns TRUE if the operation was successful; FALSE otherwise.
int AddListInt(object oTarget, int nValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Add a value to a location list on a target.
/// @param oTarget The object the list is stored on.
/// @param lValue The value to add to the list.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, will not add the value if it is already present.
/// @returns TRUE if the operation was successful; FALSE otherwise.
int AddListLocation(object oTarget, location lValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Add a value to a vector list on a target.
/// @param oTarget The object the list is stored on.
/// @param vValue The value to add to the list.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, will not add the value if it is already present.
/// @returns TRUE if the operation was successful; FALSE otherwise.
int AddListVector(object oTarget, vector vValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Add a value to an object list on a target.
/// @param oTarget The object the list is stored on.
/// @param oValue The value to add to the list.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, will not add the value if it is already present.
/// @returns TRUE if the operation was successful; FALSE otherwise.
int AddListObject(object oTarget, object oValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Add a value to a string list on a target.
/// @param oTarget The object the list is stored on.
/// @param sValue The value to add to the list.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, will not add the value if it is already present.
/// @returns TRUE if the operation was successful; FALSE otherwise.
int AddListString(object oTarget, string sValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Add a value to a json list on a target.
/// @param oTarget The object the list is stored on.
/// @param jValue The value to add to the list.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, will not add the value if it is already present.
/// @returns TRUE if the operation was successful; FALSE otherwise.
int AddListJson(object oTarget, json jValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Return the value at an index in a target's float list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @returns 0.0 if no value is found at nIndex.
float GetListFloat(object oTarget, int nIndex = 0, string sListName = "");

/// @brief Return the value at an index in a target's int list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @returns 0 if no value is found at nIndex.
int GetListInt(object oTarget, int nIndex = 0, string sListName = "");

/// @brief Return the value at an index in a target's location list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @returns LOCATION_INVALID if no value is found at nIndex.
location GetListLocation(object oTarget, int nIndex = 0, string sListName = "");

/// @brief Return the value at an index in a target's vector list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @returns [0.0. 0.0, 0.0] if no value was found at nIndex.
vector GetListVector(object oTarget, int nIndex = 0, string sListName = "");

/// @brief Return the value at an index in a target's object list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @returns OBJECT_INVALID if no value was found at nIndex.
object GetListObject(object oTarget, int nIndex = 0, string sListName = "");

/// @brief Return the value at an index in a target's string list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @returns "" if no value was found at nIndex.
string GetListString(object oTarget, int nIndex = 0, string sListName = "");

/// @brief Return the value at an index in a target's json list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @returns JSON_NULL if no value was found at nIndex.
json GetListJson(object oTarget, int nIndex = 0, string sListName = "");

/// @brief Delete the value at an index on an object's float list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int DeleteListFloat(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Delete the value at an index on an object's int list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int DeleteListInt(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Delete the value at an index on an object's location list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int DeleteListLocation(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Delete the value at an index on an object's vector list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int DeleteListVector(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Delete the value at an index on an object's object list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int DeleteListObject(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Delete the value at an index on an object's string list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int DeleteListString(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Delete the value at an index on an object's json list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int DeleteListJson(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Remove the first instance of a value from an object's float list.
/// @param oTarget The object the list is stored on.
/// @param fValue The value to remove.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int RemoveListFloat(object oTarget, float fValue, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Remove the first instance of a value from an object's int list.
/// @param oTarget The object the list is stored on.
/// @param nValue The value to remove.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int RemoveListInt(object oTarget, int nValue, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Remove the first instance of a value from an object's location list.
/// @param oTarget The object the list is stored on.
/// @param lValue The value to remove.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int RemoveListLocation(object oTarget, location lValue, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Remove the first instance of a value from an object's vector list.
/// @param oTarget The object the list is stored on.
/// @param vValue The value to remove.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int RemoveListVector(object oTarget, vector vValue, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Remove the first instance of a value from an object's object list.
/// @param oTarget The object the list is stored on.
/// @param oValue The value to remove.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int RemoveListObject(object oTarget, object oValue, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Remove the first instance of a value from an object's string list.
/// @param oTarget The object the list is stored on.
/// @param sValue The value to remove.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int RemoveListString(object oTarget, string sValue, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Remove the first instance of a value from an object's json list.
/// @param oTarget The object the list is stored on.
/// @param jValue The value to remove.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int RemoveListJson(object oTarget, json jValue, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Removes and returns the first value from an object's float list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
float PopListFloat(object oTarget, string sListName = "");

/// @brief Removes and returns the first value from an object's int list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
int PopListInt(object oTarget, string sListName = "");

/// @brief Removes and returns the first value from an object's location list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
location PopListLocation(object oTarget, string sListName = "");

/// @brief Removes and returns the first value from an object's vector list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
vector PopListVector(object oTarget, string sListName = "");

/// @brief Removes and returns the first value from an object's object list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
object PopListObject(object oTarget, string sListName = "");

/// @brief Removes and returns the first value from an object's string list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
string PopListString(object oTarget, string sListName = "");

/// @brief Removes and returns the first value from an object's json list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
json PopListJson(object oTarget, string sListName = "");

/// @brief Return the index of the first occurrence of a value in an object's
///     float list.
/// @param oTarget The object the list is stored on.
/// @param fValue The value to find.
/// @param sListName The name of the list.
/// @returns The index of the value (0-based), or -1 if it is not in the list.
int FindListFloat(object oTarget, float fValue, string sListName = "");

/// @brief Return the index of the first occurrence of a value in an object's
///     int list.
/// @param oTarget The object the list is stored on.
/// @param nValue The value to find.
/// @param sListName The name of the list.
/// @returns The index of the value (0-based), or -1 if it is not in the list.
int FindListInt(object oTarget, int nValue, string sListName = "");

/// @brief Return the index of the first occurrence of a value in an object's
///     location list.
/// @param oTarget The object the list is stored on.
/// @param lValue The value to find.
/// @param sListName The name of the list.
/// @returns The index of the value (0-based), or -1 if it is not in the list.
int FindListLocation(object oTarget, location lValue, string sListName = "");

/// @brief Return the index of the first occurrence of a value in an object's
///     vector list.
/// @param oTarget The object the list is stored on.
/// @param vValue The value to find.
/// @param sListName The name of the list.
/// @returns The index of the value (0-based), or -1 if it is not in the list.
int FindListVector(object oTarget, vector vValue, string sListName = "");

/// @brief Return the index of the first occurrence of a value in an object's
///     object list.
/// @param oTarget The object the list is stored on.
/// @param oValue The value to find.
/// @param sListName The name of the list.
/// @returns The index of the value (0-based), or -1 if it is not in the list.
int FindListObject(object oTarget, object oValue, string sListName = "");

/// @brief Return the index of the first occurrence of a value in an object's
///     string list.
/// @param oTarget The object the list is stored on.
/// @param sValue The value to find.
/// @param sListName The name of the list.
/// @returns The index of the value (0-based), or -1 if it is not in the list.
int FindListString(object oTarget, string sValue, string sListName = "");

/// @brief Return the index of the first occurrence of a value in an object's
///     json list.
/// @param oTarget The object the list is stored on.
/// @param jValue The value to find.
/// @param sListName The name of the list.
/// @returns The index of the value (0-based), or -1 if it is not in the list.
int FindListJson(object oTarget, json jValue, string sListName = "");

/// @brief Return whether a value is present in an object's float list.
/// @param oTarget The object the list is stored on.
/// @param fValue The value to find.
/// @param sListName The name of the list.
/// @returns TRUE if the value is in the list; FALSE otherwise.
int HasListFloat(object oTarget, float fValue, string sListName = "");

/// @brief Return whether a value is present in an object's int list.
/// @param oTarget The object the list is stored on.
/// @param nValue The value to find.
/// @param sListName The name of the list.
/// @returns TRUE if the value is in the list; FALSE otherwise.
int HasListInt(object oTarget, int nValue, string sListName = "");

/// @brief Return whether a value is present in an object's location list.
/// @param oTarget The object the list is stored on.
/// @param lValue The value to find.
/// @param sListName The name of the list.
/// @returns TRUE if the value is in the list; FALSE otherwise.
int HasListLocation(object oTarget, location lValue, string sListName = "");

/// @brief Return whether a value is present in an object's vector list.
/// @param oTarget The object the list is stored on.
/// @param vValue The value to find.
/// @param sListName The name of the list.
/// @returns TRUE if the value is in the list; FALSE otherwise.
int HasListVector(object oTarget, vector vValue, string sListName = "");

/// @brief Return whether a value is present in an object's object list.
/// @param oTarget The object the list is stored on.
/// @param oValue The value to find.
/// @param sListName The name of the list.
/// @returns TRUE if the value is in the list; FALSE otherwise.
int HasListObject(object oTarget, object oValue, string sListName = "");

/// @brief Return whether a value is present in an object's string list.
/// @param oTarget The object the list is stored on.
/// @param sValue The value to find.
/// @param sListName The name of the list.
/// @returns TRUE if the value is in the list; FALSE otherwise.
int HasListString(object oTarget, string sValue, string sListName = "");

/// @brief Return whether a value is present in an object's json list.
/// @param oTarget The object the list is stored on.
/// @param jValue The value to find.
/// @param sListName The name of the list.
/// @returns TRUE if the value is in the list; FALSE otherwise.
int HasListJson(object oTarget, json jValue, string sListName = "");

/// @brief Insert a value at an index in an object's float list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to insert the value at. If the index exceeds the
///     length of the list, nothing is added.
/// @param fValue The value to insert.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, the insert operation will be conducted first and
///     then duplicate values will be removed.
/// @returns The length of the updated list.
int InsertListFloat(object oTarget, int nIndex, float fValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Insert a value at an index in an object's int list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to insert the value at. If the index exceeds the
///     length of the list, nothing is added.
/// @param nValue The value to insert.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, the insert operation will be conducted first and
///     then duplicate values will be removed.
/// @returns The length of the updated list.
int InsertListInt(object oTarget, int nIndex, int nValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Insert a value at an index in an object's location list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to insert the value at. If the index exceeds the
///     length of the list, nothing is added.
/// @param lValue The value to insert.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, the insert operation will be conducted first and
///     then duplicate values will be removed.
/// @returns The length of the updated list.
int InsertListLocation(object oTarget, int nIndex, location lValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Insert a value at an index in an object's vector list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to insert the value at. If the index exceeds the
///     length of the list, nothing is added.
/// @param vValue The value to insert.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, the insert operation will be conducted first and
///     then duplicate values will be removed.
/// @returns The length of the updated list.
int InsertListVector(object oTarget, int nIndex, vector vValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Insert a value at an index in an object's objeect list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to insert the value at. If the index exceeds the
///     length of the list, nothing is added.
/// @param oValue The value to insert.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, the insert operation will be conducted first and
///     then duplicate values will be removed.
/// @returns The length of the updated list.
int InsertListObject(object oTarget, int nIndex, object oValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Insert a value at an index in an object's string list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to insert the value at. If the index exceeds the
///     length of the list, nothing is added.
/// @param sValue The value to insert.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, the insert operation will be conducted first and
///     then duplicate values will be removed.
/// @returns The length of the updated list.
int InsertListString(object oTarget, int nIndex, string sValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Insert a value at an index in an object's json list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to insert the value at. If the index exceeds the
///     length of the list, nothing is added.
/// @param jValue The value to insert.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, the insert operation will be conducted first and
///     then duplicate values will be removed.
/// @returns The length of the updated list.
int InsertListJson(object oTarget, int nIndex, json jValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Set the value at an index in an object's float list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to set the value of. If the index exceeds the length
///     of the list, nothing is added.
/// @param fValue The value to set.
/// @param sListName The name of the list.
void SetListFloat(object oTarget, int nIndex, float fValue, string sListName = "");

/// @brief Set the value at an index in an object's int list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to set the value of. If the index exceeds the length
///     of the list, nothing is added.
/// @param nValue The value to set.
/// @param sListName The name of the list.
void SetListInt(object oTarget, int nIndex, int nValue, string sListName = "");

/// @brief Set the value at an index in an object's location list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to set the value of. If the index exceeds the length
///     of the list, nothing is added.
/// @param lValue The value to set.
/// @param sListName The name of the list.
void SetListLocation(object oTarget, int nIndex, location lValue, string sListName = "");

/// @brief Set the value at an index in an object's vector list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to set the value of. If the index exceeds the length
///     of the list, nothing is added.
/// @param vValue The value to set.
/// @param sListName The name of the list.
void SetListVector(object oTarget, int nIndex, vector vValue, string sListName = "");

/// @brief Set the value at an index in an object's object list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to set the value of. If the index exceeds the length
///     of the list, nothing is added.
/// @param oValue The value to set.
/// @param sListName The name of the list.
void SetListObject(object oTarget, int nIndex, object oValue, string sListName = "");

/// @brief Set the value at an index in an object's string list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to set the value of. If the index exceeds the length
///     of the list, nothing is added.
/// @param sValue The value to set.
/// @param sListName The name of the list.
void SetListString(object oTarget, int nIndex, string sValue, string sListName = "");

/// @brief Set the value at an index in an object's json list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to set the value of. If the index exceeds the length
///     of the list, nothing is added.
/// @param jValue The value to set.
/// @param sListName The name of the list.
void SetListJson(object oTarget, int nIndex, json jValue, string sListName = "");

/// @brief Copy value from one object's float list to another's.
/// @param oSource The object to copy the list values of.
/// @param oTarget The object to copy the list values to.
/// @param sSourceName The name of the list on oSource.
/// @param sTargetName The name of the list on oTarget.
/// @param nIndex The index to begin copying from.
/// @param nRange The number of values to copy. If -1, will copy all values from
///     nIndex and up.
/// @param bAddUnique If TRUE, the copy operation will be conducted first and
///     then any duplicate values will be removed. Values in the target list
///     will be prioritiezed over values from the source list.
/// @returns The number of values copied.
int CopyListFloat(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE);

/// @brief Copy value from one object's int list to another's.
/// @param oSource The object to copy the list values of.
/// @param oTarget The object to copy the list values to.
/// @param sSourceName The name of the list on oSource.
/// @param sTargetName The name of the list on oTarget.
/// @param nIndex The index to begin copying from.
/// @param nRange The number of values to copy. If -1, will copy all values from
///     nIndex and up.
/// @param bAddUnique If TRUE, the copy operation will be conducted first and
///     then any duplicate values will be removed. Values in the target list
///     will be prioritiezed over values from the source list.
/// @returns The number of values copied.
int CopyListInt(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE);

/// @brief Copy value from one object's location list to another's.
/// @param oSource The object to copy the list values of.
/// @param oTarget The object to copy the list values to.
/// @param sSourceName The name of the list on oSource.
/// @param sTargetName The name of the list on oTarget.
/// @param nIndex The index to begin copying from.
/// @param nRange The number of values to copy. If -1, will copy all values from
///     nIndex and up.
/// @param bAddUnique If TRUE, the copy operation will be conducted first and
///     then any duplicate values will be removed. Values in the target list
///     will be prioritiezed over values from the source list.
/// @returns The number of values copied.
int CopyListLocation(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE);

/// @brief Copy value from one object's vector list to another's.
/// @param oSource The object to copy the list values of.
/// @param oTarget The object to copy the list values to.
/// @param sSourceName The name of the list on oSource.
/// @param sTargetName The name of the list on oTarget.
/// @param nIndex The index to begin copying from.
/// @param nRange The number of values to copy. If -1, will copy all values from
///     nIndex and up.
/// @param bAddUnique If TRUE, the copy operation will be conducted first and
///     then any duplicate values will be removed. Values in the target list
///     will be prioritiezed over values from the source list.
/// @returns The number of values copied.
int CopyListVector(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE);

/// @brief Copy value from one object's object list to another's.
/// @param oSource The object to copy the list values of.
/// @param oTarget The object to copy the list values to.
/// @param sSourceName The name of the list on oSource.
/// @param sTargetName The name of the list on oTarget.
/// @param nIndex The index to begin copying from.
/// @param nRange The number of values to copy. If -1, will copy all values from
///     nIndex and up.
/// @param bAddUnique If TRUE, the copy operation will be conducted first and
///     then any duplicate values will be removed. Values in the target list
///     will be prioritiezed over values from the source list.
/// @returns The number of values copied.
int CopyListObject(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE);

/// @brief Copy value from one object's string list to another's.
/// @param oSource The object to copy the list values of.
/// @param oTarget The object to copy the list values to.
/// @param sSourceName The name of the list on oSource.
/// @param sTargetName The name of the list on oTarget.
/// @param nIndex The index to begin copying from.
/// @param nRange The number of values to copy. If -1, will copy all values from
///     nIndex and up.
/// @param bAddUnique If TRUE, the copy operation will be conducted first and
///     then any duplicate values will be removed. Values in the target list
///     will be prioritiezed over values from the source list.
/// @returns The number of values copied.
int CopyListString(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE);

/// @brief Copy value from one object's json list to another's.
/// @param oSource The object to copy the list values of.
/// @param oTarget The object to copy the list values to.
/// @param sSourceName The name of the list on oSource.
/// @param sTargetName The name of the list on oTarget.
/// @param nIndex The index to begin copying from.
/// @param nRange The number of values to copy. If -1, will copy all values from
///     nIndex and up.
/// @param bAddUnique If TRUE, the copy operation will be conducted first and
///     then any duplicate values will be removed. Values in the target list
///     will be prioritiezed over values from the source list.
/// @returns The number of values copied.
int CopyListJson(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE);

/// @brief Increment the value at an index in an object's int list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param nIncrement The amount to increment the value by.
/// @param sListName The name of the list.
/// @returns The new value of the int.
int IncrementListInt(object oTarget, int nIndex, int nIncrement = 1, string sListName = "");

/// @brief Decrement the value at an index in an object's int list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param nIncrement The amount to decrement the value by.
/// @param sListName The name of the list.
/// @returns The new value of the int.
int DecrementListInt(object oTarget, int nIndex, int nDecrement = -1, string sListName = "");

/// @brief Convert an object's float list to a json array.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
/// @note Elements of the returned array can be decoded with JsonGetFloat().
json GetFloatList(object oTarget, string sListName = "");

/// @brief Convert an object's int list to a json array.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
/// @note Elements of the returned array can be decoded with JsonGetInt().
json GetIntList(object oTarget, string sListName = "");

/// @brief Convert an object's location list to a json array.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
/// @note Elements of the returned array can be decoded with JsonGetLocation().
json GetLocationList(object oTarget, string sListName = "");

/// @brief Convert an object's vector list to a json array.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
/// @note Elements of the returned array can be decoded with JsonGetVector().
json GetVectorList(object oTarget, string sListName = "");

/// @brief Convert an object's object list to a json array.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
/// @note Elements of the returned array can be decoded with
///     ObjectToString(JsonGetString()).
json GetObjectList(object oTarget, string sListName = "");

/// @brief Convert an object's string list to a json array.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
/// @note Elements of the returned array can be decoded with JsonGetString().
json GetStringList(object oTarget, string sListName = "");

/// @brief Convert an object's json list into a json array.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
json GetJsonList(object oTarget, string sListName = "");

/// @brief Save a json array as an object's float list.
/// @param oTarget The object the list is stored on.
/// @param jList A JsonArray() made up of JsonFloat()s.
/// @param sListName The name of the list.
void SetFloatList(object oTarget, json jList, string sListName = "");

/// @brief Save a json array as an object's int list.
/// @param oTarget The object the list is stored on.
/// @param jList A JsonArray() made up of JsonInt()s.
/// @param sListName The name of the list.
void SetIntList(object oTarget, json jList, string sListName = "");

/// @brief Save a json array as an object's location list.
/// @param oTarget The object the list is stored on.
/// @param jList A JsonArray() made up of JsonLocation()s.
/// @param sListName The name of the list.
void SetLocationList(object oTarget, json jList, string sListName = "");

/// @brief Save a json array as an object's vector list.
/// @param oTarget The object the list is stored on.
/// @param jList A JsonArray() made up of JsonVector()s.
/// @param sListName The name of the list.
void SetVectorList(object oTarget, json jList, string sListName = "");

/// @brief Save a json array as an object's object list.
/// @param oTarget The object the list is stored on.
/// @param jList A JsonArray() made up of JsonObject()s.
/// @param sListName The name of the list.
void SetObjectList(object oTarget, json jList, string sListName = "");

/// @brief Save a json array as an object's string list.
/// @param oTarget The object the list is stored on.
/// @param jList A JsonArray() made up of JsonString()s.
/// @param sListName The name of the list.
void SetStringList(object oTarget, json jList, string sListName = "");

/// @brief Save a json array as an object's json list.
/// @param oTarget The object the list is stored on.
/// @param jList A JsonArray() made up of any json types.
/// @param sListName The name of the list.
void SetJsonList(object oTarget, json jList, string sListName = "");

/// @brief Delete an object's float list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void DeleteFloatList(object oTarget, string sListName = "");

/// @brief Delete an object's float list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void DeleteIntList(object oTarget, string sListName = "");

/// @brief Delete an object's float list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void DeleteLocationList(object oTarget, string sListName = "");

/// @brief Delete an object's float list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void DeleteVectorList(object oTarget, string sListName = "");

/// @brief Delete an object's float list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void DeleteObjectList(object oTarget, string sListName = "");

/// @brief Delete an object's string list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void DeleteStringList(object oTarget, string sListName = "");

/// @brief Delete an object's json list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void DeleteJsonList(object oTarget, string sListName = "");

/// @brief Create a float list on a target, deleting any current list.
/// @param oTarget The object to create the list on.
/// @param nCount The number of values to initialize the list with.
/// @param sListName The name of the list.
/// @param fDefault The value to initialize the list with.
/// @returns A json array copy of the created list.
json DeclareFloatList(object oTarget, int nCount, string sListName = "", float fDefault = 0.0);

/// @brief Create an int list on a target, deleting any current list.
/// @param oTarget The object to create the list on.
/// @param nCount The number of values to initialize the list with.
/// @param sListName The name of the list.
/// @param nDefault The value to initialize the list with.
/// @returns A json array copy of the created list.
json DeclareIntList(object oTarget, int nCount, string sListName = "", int nDefault = 0);

/// @brief Create a location list on a target, deleting any current list.
/// @param oTarget The object to create the list on.
/// @param nCount The number of values to initialize the list with.
/// @param sListName The name of the list.
/// @returns A json array copy of the created list.
json DeclareLocationList(object oTarget, int nCount, string sListName = "");

/// @brief Create a vector list on a target, deleting any current list.
/// @param oTarget The object to create the list on.
/// @param nCount The number of values to initialize the list with.
/// @param sListName The name of the list.
/// @returns A json array copy of the created list.
json DeclareVectorList(object oTarget, int nCount, string sListName = "");

/// @brief Create an object list on a target, deleting any current list.
/// @param oTarget The object to create the list on.
/// @param nCount The number of values to initialize the list with.
/// @param sListName The name of the list.
/// @returns A json array copy of the created list.
json DeclareObjectList(object oTarget, int nCount, string sListName = "");

/// @brief Create a string list on a target, deleting any current list.
/// @param oTarget The object to create the list on.
/// @param nCount The number of values to initialize the list with.
/// @param sListName The name of the list.
/// @param sDefault The value to initialize the list with.
/// @returns A json array copy of the created list.
json DeclareStringList(object oTarget, int nCount, string sListName = "", string sDefault = "");

/// @brief Create a json list on a target, deleting any current list.
/// @param oTarget The object to create the list on.
/// @param nCount The number of values to initialize the list with.
/// @param sListName The name of the list.
/// @returns A json array copy of the created list.
json DeclareJsonList(object oTarget, int nCount, string sListName = "");

/// @brief Set the length of an object's float list.
/// @param oTarget The object the list is stored on.
/// @param nCount The length to set the list to. If less than the current
///     length, the list will be shortened to match. If greater than the current
///     length, additional values will be added to the end of the list.
/// @param sListName The name of the list.
/// @param fDefault The value to set any added elements to.
/// @returns A json array copy of the updated list.
json NormalizeFloatList(object oTarget, int nCount, string sListName = "", float fDefault = 0.0);

/// @brief Set the length of an object's int list.
/// @param oTarget The object the list is stored on.
/// @param nCount The length to set the list to. If less than the current
///     length, the list will be shortened to match. If greater than the current
///     length, additional values will be added to the end of the list.
/// @param sListName The name of the list.
/// @param nDefault The value to set any added elements to.
/// @returns A json array copy of the updated list.
json NormalizeIntList(object oTarget, int nCount, string sListName = "", int nDefault = 0);

/// @brief Set the length of an object's location list.
/// @param oTarget The object the list is stored on.
/// @param nCount The length to set the list to. If less than the current
///     length, the list will be shortened to match. If greater than the current
///     length, additional values will be added to the end of the list.
/// @param sListName The name of the list.
/// @returns A json array copy of the updated list.
json NormalizeLocationList(object oTarget, int nCount, string sListName = "");

/// @brief Set the length of an object's vector list.
/// @param oTarget The object the list is stored on.
/// @param nCount The length to set the list to. If less than the current
///     length, the list will be shortened to match. If greater than the current
///     length, additional values will be added to the end of the list.
/// @param sListName The name of the list.
/// @returns A json array copy of the updated list.
json NormalizeVectorList(object oTarget, int nCount, string sListName = "");

/// @brief Set the length of an object's object list.
/// @param oTarget The object the list is stored on.
/// @param nCount The length to set the list to. If less than the current
///     length, the list will be shortened to match. If greater than the current
///     length, additional values will be added to the end of the list.
/// @param sListName The name of the list.
/// @returns A json array copy of the updated list.
json NormalizeObjectList(object oTarget, int nCount, string sListName = "");

/// @brief Set the length of an object's string list.
/// @param oTarget The object the list is stored on.
/// @param nCount The length to set the list to. If less than the current
///     length, the list will be shortened to match. If greater than the current
///     length, additional values will be added to the end of the list.
/// @param sListName The name of the list.
/// @param sDefault The value to set any added elements to.
/// @returns A json array copy of the updated list.
json NormalizeStringList(object oTarget, int nCount, string sListName = "", string sDefault = "");

/// @brief Set the length of an object's json list.
/// @param oTarget The object the list is stored on.
/// @param nCount The length to set the list to. If less than the current
///     length, the list will be shortened to match. If greater than the current
///     length, additional null values will be added to the end of the list.
/// @param sListName The name of the list.
/// @returns A json array copy of the updated list.
json NormalizeJsonList(object oTarget, int nCount, string sListName = "");

/// @brief Copy all items from one object's float list to another's.
/// @param oSource The object to copy the list from.
/// @param oTarget The object to copy the list to.
/// @param sSourceName The name of the source list.
/// @param sTargetName The name of the target list.
/// @param bAddUnique If TRUE, will only copy items that are not already present
///     in the target list.
void CopyFloatList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE);

/// @brief Copy all items from one object's int list to another's.
/// @param oSource The object to copy the list from.
/// @param oTarget The object to copy the list to.
/// @param sSourceName The name of the source list.
/// @param sTargetName The name of the target list.
/// @param bAddUnique If TRUE, will only copy items that are not already present
///     in the target list.
void CopyIntList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE);

/// @brief Copy all items from one object's location list to another's.
/// @param oSource The object to copy the list from.
/// @param oTarget The object to copy the list to.
/// @param sSourceName The name of the source list.
/// @param sTargetName The name of the target list.
/// @param bAddUnique If TRUE, will only copy items that are not already present
///     in the target list.
void CopyLocationList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE);

/// @brief Copy all items from one object's vector list to another's.
/// @param oSource The object to copy the list from.
/// @param oTarget The object to copy the list to.
/// @param sSourceName The name of the source list.
/// @param sTargetName The name of the target list.
/// @param bAddUnique If TRUE, will only copy items that are not already present
///     in the target list.
void CopyVectorList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE);

/// @brief Copy all items from one object's object list to another's.
/// @param oSource The object to copy the list from.
/// @param oTarget The object to copy the list to.
/// @param sSourceName The name of the source list.
/// @param sTargetName The name of the target list.
/// @param bAddUnique If TRUE, will only copy items that are not already present
///     in the target list.
void CopyObjectList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE);

/// @brief Copy all items from one object's string list to another's.
/// @param oSource The object to copy the list from.
/// @param oTarget The object to copy the list to.
/// @param sSourceName The name of the source list.
/// @param sTargetName The name of the target list.
/// @param bAddUnique If TRUE, will only copy items that are not already present
///     in the target list.
void CopyStringList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE);

/// @brief Copy all items from one object's json list to another's.
/// @param oSource The object to copy the list from.
/// @param oTarget The object to copy the list to.
/// @param sSourceName The name of the source list.
/// @param sTargetName The name of the target list.
/// @param bAddUnique If TRUE, will only copy items that are not already present
///     in the target list.
void CopyJsonList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE);

/// @brief Return the number of items in an object's float list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
int CountFloatList(object oTarget, string sListName = "");

/// @brief Return the number of items in an object's int list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
int CountIntList(object oTarget, string sListName = "");

/// @brief Return the number of items in an object's location list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
int CountLocationList(object oTarget, string sListName = "");

/// @brief Return the number of items in an object's vector list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
int CountVectorList(object oTarget, string sListName = "");

/// @brief Return the number of items in an object's object list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
int CountObjectList(object oTarget, string sListName = "");

/// @brief Return the number of items in an object's string list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
int CountStringList(object oTarget, string sListName = "");

/// @brief Return the number of items in an object's json list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
int CountJsonList(object oTarget, string sListName = "");

/// @brief Sort an object's float list.
/// @param oTarget The object the list is stored on.
/// @param nOrder A `LIST_ORDER_*` constant representing how to sort the list.
/// @param sListName The name of the list.
void SortFloatList(object oTarget, int nOrder = LIST_SORT_ASC, string sListName = "");

/// @brief Sort an object's int list.
/// @param oTarget The object the list is stored on.
/// @param nOrder A `LIST_ORDER_*` constant representing how to sort the list.
/// @param sListName The name of the list.
void SortIntList(object oTarget, int nOrder = LIST_SORT_ASC, string sListName = "");

/// @brief Sort an object's string list.
/// @param oTarget The object the list is stored on.
/// @param nOrder A `LIST_ORDER_*` constant representing how to sort the list.
/// @param sListName The name of the list.
void SortStringList(object oTarget, int nOrder = LIST_SORT_ASC, string sListName = "");

/// @brief Shuffle the items in an object's float list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ShuffleFloatList(object oTarget, string sListName = "");

/// @brief Shuffle the items in an object's int list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ShuffleIntList(object oTarget, string sListName = "");

/// @brief Shuffle the items in an object's location list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ShuffleLocationList(object oTarget, string sListName = "");

/// @brief Shuffle the items in an object's vector list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ShuffleVectorList(object oTarget, string sListName = "");

/// @brief Shuffle the items in an object's object list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ShuffleObjectList(object oTarget, string sListName = "");

/// @brief Shuffle the items in an object's string list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ShuffleStringList(object oTarget, string sListName = "");

/// @brief Shuffle the items in an object's json list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ShuffleJsonList(object oTarget, string sListName = "");

/// @brief Reverse the order of the items in an object's float list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ReverseFloatList(object oTarget, string sListName = "");

/// @brief Reverse the order of the items in an object's int list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ReverseIntList(object oTarget, string sListName = "");

/// @brief Reverse the order of the items in an object's location list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ReverseLocationList(object oTarget, string sListName = "");

/// @brief Reverse the order of the items in an object's vector list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ReverseVectorList(object oTarget, string sListName = "");

/// @brief Reverse the order of the items in an object's object list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ReverseObjectList(object oTarget, string sListName = "");

/// @brief Reverse the order of the items in an object's string list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ReverseStringList(object oTarget, string sListName = "");

/// @brief Reverse the order of the items in an object's json list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ReverseJsonList(object oTarget, string sListName = "");

// -----------------------------------------------------------------------------
//                           Function Implementations
// -----------------------------------------------------------------------------

#include "util_i_debug"

// -----------------------------------------------------------------------------
//                              Private Functions
// -----------------------------------------------------------------------------

// Determines whether nIndex is a valid reference to an array element in jList.
// If bNegative is TRUE, -1 will be returned as a valid nIndex value.
int _GetIsIndexValid(json jList, int nIndex, int bNegative = FALSE)
{
    return nIndex == 0 || nIndex >= (0 - bNegative) && nIndex < JsonGetLength(jList);
}

// Retrieves json array sListName of sListType from oTarget.
json _GetList(object oTarget, string sListType, string sListName = "")
{
    json jList = GetLocalJson(oTarget, LIST_REF + sListType + sListName);
    return jList == JSON_NULL ? JSON_ARRAY : jList;
}

// Sets sListType json array jList as sListName on oTarget.
void _SetList(object oTarget, string sListType, string sListName, json jList)
{
    SetLocalJson(oTarget, LIST_REF + sListType + sListName, jList);
}

// Deletes sListType json array sListName from oTarget.
void _DeleteList(object oTarget, string sListType, string sListName)
{
    DeleteLocalJson(oTarget, LIST_REF + sListType + sListName);
}

// Inserts array element jValue into json array sListName at nIndex on oTarget.
// Returns the number of elements in the array after insertion. If bUnique is
// TRUE, duplicate values with be removed after the insert operation.
int _InsertListElement(object oTarget, string sListType, string sListName,
                       json jValue, int nIndex, int bUnique)
{
    json jList = _GetList(oTarget, sListType, sListName);

    if (_GetIsIndexValid(jList, nIndex, TRUE) == TRUE)
    {
        JsonArrayInsertInplace(jList, jValue, nIndex);
        if (bUnique == TRUE)
            jList = JsonArrayTransform(jList, JSON_ARRAY_UNIQUE);

        _SetList(oTarget, sListType, sListName, jList);
    }

    return JsonGetLength(jList);
}

// Returns array element at nIndex from array sListName on oTarget. If not
// found, returns JSON_NULL.
json _GetListElement(object oTarget, string sListType, string sListName, int nIndex)
{
    json jList = _GetList(oTarget, sListType, sListName);
    return _GetIsIndexValid(jList, nIndex) ? JsonArrayGet(jList, nIndex) : JSON_NULL;
}

// Deletes array element at nIndex from array sListName on oTarget. Element order
// is maintained. Returns the number of array elements remaining after deletion.
int _DeleteListElement(object oTarget, string sListType, string sListName, int nIndex)
{
    json jList = _GetList(oTarget, sListType, sListName);

    if (_GetIsIndexValid(jList, nIndex) == TRUE && JsonGetLength(jList) > 0)
    {
        JsonArrayDelInplace(jList, nIndex);
        _SetList(oTarget, sListType, sListName, jList);
    }

    return JsonGetLength(jList);
}

// Finds array element jValue in array sListName on oTarget. If found, returns the
// index of the elements. If not, returns -1.
int _FindListElement(object oTarget, string sListType, string sListName, json jValue)
{
    json jList = _GetList(oTarget, sListType, sListName);
    json jIndex = JsonFind(jList, jValue, 0, JSON_FIND_EQUAL);
    return jIndex == JSON_NULL ? -1 : JsonGetInt(jIndex);
}

// Deletes array element jValue from array sListName on oTarget. Element order
// is maintained. Returns the number of array elements remaining after deletion.
int _RemoveListElement(object oTarget, string sListType, string sListName, json jValue)
{
    json jList = _GetList(oTarget, sListType, sListName);
    int nIndex = _FindListElement(oTarget, sListType, sListName, jValue);

    if (nIndex > -1)
    {
        JsonArrayDelInplace(jList, nIndex);
        _SetList(oTarget, sListType, sListName, JsonArrayDel(jList, nIndex));
    }

    return JsonGetLength(jList);
}

// Finds array element jValue in array sListName on oTarget. Returns TRUE if found,
// FALSE otherwise.
int _HasListElement(object oTarget, string sListType, string sListName, json jValue)
{
    return _FindListElement(oTarget, sListType, sListName, jValue) > -1;
}

// Replaces array element at nIndex in array sListName on oTarget with jValue.
void _SetListElement(object oTarget, string sListType, string sListName, int nIndex, json jValue)
{
    json jList = _GetList(oTarget, sListType, sListName);

    if (_GetIsIndexValid(jList, nIndex) == TRUE)
        _SetList(oTarget, sListType, sListName, JsonArraySet(jList, nIndex, jValue));
}

// This procedure exists because current json operations cannot easily append a list without
// removing duplicate elements or auto-sorting the list. BD is expected to update json
// functions with an append option. If so, replace this function with the json append
// function from nwscript.nss or fold this into _SortList() below.
json _JsonArrayAppend(json jFrom, json jTo)
{
    string sFrom = JsonDump(jFrom);
    string sTo = JsonDump(jTo);

    sFrom = GetStringRight(sFrom, GetStringLength(sFrom) - 1);
    sTo = GetStringLeft(sTo, GetStringLength(sTo) - 1);

    int nFrom = JsonGetLength(jFrom);
    int nTo = JsonGetLength(jTo);

    string s = (nTo == 0 ? "" :
                nTo > 0 && nFrom == 0 ? "" : ",");

    return JsonParse(sTo + s + sFrom);
}

// Copies specified elements from oSource array sSourceName to oTarget array sTargetName.
// Copied elements start at nIndex and continue for nRange elements. Elements copied from
// oSource are appended to the end of oTarget's array.
int _CopyListElements(object oSource, object oTarget, string sListType, string sSourceName,
                      string sTargetName, int nIndex, int nRange, int bUnique)
{
    json jSource = _GetList(oSource, sListType, sSourceName);
    json jTarget = _GetList(oTarget, sListType, sTargetName);

    if (jTarget == JSON_NULL)
        jTarget = JSON_ARRAY;

    int nSource = JsonGetLength(jSource);
    int nTarget = JsonGetLength(jTarget);

    if (nSource == 0) return 0;

    json jCopy, jReturn;

    if (nIndex == 0 && (nRange == -1 || nRange >= nSource))
    {
        if (jSource == JSON_NULL || nSource == 0)
            return 0;

        jReturn = _JsonArrayAppend(jSource, jTarget);
        if (bUnique == TRUE)
            jReturn = JsonArrayTransform(jReturn, JSON_ARRAY_UNIQUE);

        _SetList(oTarget, sListType, sTargetName, jReturn);
        return nSource;
    }

    if (_GetIsIndexValid(jSource, nIndex) == TRUE)
    {
        int nMaxIndex = nSource - nIndex;
        if (nRange == -1)
            nRange = nMaxIndex;
        else if (nRange > (nMaxIndex))
            nRange = clamp(nRange, 1, nMaxIndex);

        jCopy = JsonArrayGetRange(jSource, nIndex, nIndex + (nRange - 1));
        jReturn = _JsonArrayAppend(jTarget, jCopy);
        if (bUnique == TRUE)
            jReturn = JsonArrayTransform(jReturn, JSON_ARRAY_UNIQUE);

        _SetList(oTarget, sListType, sTargetName, jReturn);
        return JsonGetLength(jCopy) - JsonGetLength(JsonSetOp(jCopy, JSON_SET_INTERSECT, jTarget));
    }

    return 0;
}

// Modifies an int list element by nIncrement and returns the new value.
int _IncrementListElement(object oTarget, string sListName, int nIndex, int nIncrement)
{
    json jList = _GetList(oTarget, VARLIST_TYPE_INT, sListName);

    if (_GetIsIndexValid(jList, nIndex))
    {
        int nValue = JsonGetInt(JsonArrayGet(jList, nIndex)) + nIncrement;
        JsonArraySetInplace(jList, nIndex, JsonInt(nValue));
        _SetList(oTarget, VARLIST_TYPE_INT, sListName, jList);

        return nValue;
    }

    return 0;
}

// Creates an array of length nLength jDefault elements as sListName on oTarget.
json _DeclareList(object oTarget, string sListType, string sListName, int nLength, json jDefault)
{
    json jList = JSON_ARRAY;

    int n;
    for (n = 0; n < nLength; n++)
        JsonArrayInsertInplace(jList, jDefault);

    _SetList(oTarget, sListType, sListName, jList);
    return jList;
}

// Sets the array length to nLength, adding/removing elements as required.
json _NormalizeList(object oTarget, string sListType, string sListName, int nLength, json jDefault)
{
    json jList = _GetList(oTarget, sListType, sListName);
    if (jList == JSON_ARRAY)
        return _DeclareList(oTarget, sListType, sListName, nLength, jDefault);
    else if (nLength < 0)
        return jList;
    else
    {
        int n, nList = JsonGetLength(jList);
        if (nList > nLength)
            jList = JsonArrayGetRange(jList, 0, nLength - 1);
        else
        {
            for (n = 0; n < nLength - nList; n++)
                JsonArrayInsertInplace(jList, jDefault);
        }

        _SetList(oTarget, sListType, sListName, jList);
    }

    return jList;
}

// Returns the length of array sListName on oTarget.
int _CountList(object oTarget, string sListType, string sListName)
{
    return JsonGetLength(_GetList(oTarget, sListType, sListName));
}

// Sorts sListName on oTarget in order specified by nOrder.
void _SortList(object oTarget, string sListType, string sListName, int nOrder)
{
    json jList = _GetList(oTarget, sListType, sListName);

    if (JsonGetLength(jList) > 1)
        _SetList(oTarget, sListType, sListName, JsonArrayTransform(jList, nOrder));
}

// -----------------------------------------------------------------------------
//                              Public Functions
// -----------------------------------------------------------------------------

json VectorToJson(vector vPosition = [0.0, 0.0, 0.0])
{
    json jPosition = JSON_OBJECT;
    JsonObjectSetInplace(jPosition, "x", JsonFloat(vPosition.x));
    JsonObjectSetInplace(jPosition, "y", JsonFloat(vPosition.y));
    JsonObjectSetInplace(jPosition, "z", JsonFloat(vPosition.z));

    return jPosition;
}

json JsonVector(vector vPosition = [0.0, 0.0, 0.0])
{
    return VectorToJson(vPosition);
}

vector JsonToVector(json jPosition)
{
    float x = JsonGetFloat(JsonObjectGet(jPosition, "x"));
    float y = JsonGetFloat(JsonObjectGet(jPosition, "y"));
    float z = JsonGetFloat(JsonObjectGet(jPosition, "z"));

    return Vector(x, y, z);
}

vector JsonGetVector(json jPosition)
{
    return JsonToVector(jPosition);
}

json LocationToJson(location lLocation)
{
    json jLocation = JSON_OBJECT;
    JsonObjectSetInplace(jLocation, "area", JsonString(GetTag(GetAreaFromLocation(lLocation))));
    JsonObjectSetInplace(jLocation, "position", VectorToJson(GetPositionFromLocation(lLocation)));
    JsonObjectSetInplace(jLocation, "facing", JsonFloat(GetFacingFromLocation(lLocation)));

    return jLocation;
}

json JsonLocation(location lLocation)
{
    return LocationToJson(lLocation);
}

location JsonToLocation(json jLocation)
{
    object oArea = GetObjectByTag(JsonGetString(JsonObjectGet(jLocation, "area")));
    vector vPosition = JsonToVector(JsonObjectGet(jLocation, "position"));
    float fFacing = JsonGetFloat(JsonObjectGet(jLocation, "facing"));

    return Location(oArea, vPosition, fFacing);
}

location JsonGetLocation(json jLocation)
{
    return JsonToLocation(jLocation);
}

int AddListFloat(object oTarget, float fValue, string sListName = "", int bAddUnique = FALSE)
{
    return _InsertListElement(oTarget, VARLIST_TYPE_FLOAT, sListName, JsonFloat(fValue), -1, bAddUnique);
}

int AddListInt(object oTarget, int nValue, string sListName = "", int bAddUnique = FALSE)
{
    return _InsertListElement(oTarget, VARLIST_TYPE_INT, sListName, JsonInt(nValue), -1, bAddUnique);
}

int AddListLocation(object oTarget, location lValue, string sListName = "", int bAddUnique = FALSE)
{
    json jLocation = LocationToJson(lValue);
    return _InsertListElement(oTarget, VARLIST_TYPE_LOCATION, sListName, jLocation, -1, bAddUnique);
}

int AddListVector(object oTarget, vector vValue, string sListName = "", int bAddUnique = FALSE)
{
    json jVector = VectorToJson(vValue);
    return _InsertListElement(oTarget, VARLIST_TYPE_VECTOR, sListName, jVector, -1, bAddUnique);
}

int AddListObject(object oTarget, object oValue, string sListName = "", int bAddUnique = FALSE)
{
    json jObject = JsonString(ObjectToString(oValue));
    return _InsertListElement(oTarget, VARLIST_TYPE_OBJECT, sListName, jObject, -1, bAddUnique);
}

int AddListString(object oTarget, string sString, string sListName = "", int bAddUnique = FALSE)
{
    return _InsertListElement(oTarget, VARLIST_TYPE_STRING, sListName, JsonString(sString), -1, bAddUnique);
}

int AddListJson(object oTarget, json jValue, string sListName = "", int bAddUnique = FALSE)
{
    return _InsertListElement(oTarget, VARLIST_TYPE_JSON, sListName, jValue, -1, bAddUnique);
}

float GetListFloat(object oTarget, int nIndex = 0, string sListName = "")
{
    json jValue = _GetListElement(oTarget, VARLIST_TYPE_FLOAT, sListName, nIndex);
    return jValue == JSON_NULL ? 0.0 : JsonGetFloat(jValue);
}

int GetListInt(object oTarget, int nIndex = 0, string sListName = "")
{
    json jValue = _GetListElement(oTarget, VARLIST_TYPE_INT, sListName, nIndex);
    return jValue == JSON_NULL ? -1 : JsonGetInt(jValue);
}

location GetListLocation(object oTarget, int nIndex = 0, string sListName = "")
{
    json jValue = _GetListElement(oTarget, VARLIST_TYPE_LOCATION, sListName, nIndex);

    if (jValue == JSON_NULL)
        return Location(OBJECT_INVALID, Vector(), 0.0);
    else
        return JsonToLocation(jValue);
}

vector GetListVector(object oTarget, int nIndex = 0, string sListName = "")
{
    json jValue = _GetListElement(oTarget, VARLIST_TYPE_VECTOR, sListName, nIndex);

    if (jValue == JSON_NULL)
        return Vector();
    else
        return JsonToVector(jValue);
}

object GetListObject(object oTarget, int nIndex = 0, string sListName = "")
{
    json jValue = _GetListElement(oTarget, VARLIST_TYPE_OBJECT, sListName, nIndex);
    return jValue == JSON_NULL ? OBJECT_INVALID : StringToObject(JsonGetString(jValue));
}

string GetListString(object oTarget, int nIndex = 0, string sListName = "")
{
    json jValue = _GetListElement(oTarget, VARLIST_TYPE_STRING, sListName, nIndex);
    return jValue == JSON_NULL ? "" : JsonGetString(jValue);
}

json GetListJson(object oTarget, int nIndex = 0, string sListName = "")
{
    return _GetListElement(oTarget, VARLIST_TYPE_JSON, sListName, nIndex);
}

int DeleteListFloat(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE)
{
    return _DeleteListElement(oTarget, VARLIST_TYPE_FLOAT, sListName, nIndex);
}

int DeleteListInt(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE)
{
    return _DeleteListElement(oTarget, VARLIST_TYPE_INT, sListName, nIndex);
}

int DeleteListLocation(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE)
{
    return _DeleteListElement(oTarget, VARLIST_TYPE_LOCATION, sListName, nIndex);
}

int DeleteListVector(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE)
{
    return _DeleteListElement(oTarget, VARLIST_TYPE_VECTOR, sListName, nIndex);
}

int DeleteListObject(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE)
{
    return _DeleteListElement(oTarget, VARLIST_TYPE_OBJECT, sListName, nIndex);
}

int DeleteListString(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE)
{
    return _DeleteListElement(oTarget, VARLIST_TYPE_STRING, sListName, nIndex);
}

int DeleteListJson(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE)
{
    return _DeleteListElement(oTarget, VARLIST_TYPE_JSON, sListName, nIndex);
}

int RemoveListFloat(object oTarget, float fValue, string sListName = "", int bMaintainOrder = FALSE)
{
    return _RemoveListElement(oTarget, VARLIST_TYPE_FLOAT, sListName, JsonFloat(fValue));
}

int RemoveListInt(object oTarget, int nValue, string sListName = "", int bMaintainOrder = FALSE)
{
    return _RemoveListElement(oTarget, VARLIST_TYPE_INT, sListName, JsonInt(nValue));
}

int RemoveListLocation(object oTarget, location lValue, string sListName = "", int bMaintainOrder = FALSE)
{
    json jLocation = LocationToJson(lValue);
    return _RemoveListElement(oTarget, VARLIST_TYPE_LOCATION, sListName, jLocation);
}

int RemoveListVector(object oTarget, vector vValue, string sListName = "", int bMaintainOrder = FALSE)
{
    json jVector = VectorToJson(vValue);
    return _RemoveListElement(oTarget, VARLIST_TYPE_VECTOR, sListName, jVector);
}

int RemoveListObject(object oTarget, object oValue, string sListName = "", int bMaintainOrder = FALSE)
{
    json jObject = JsonString(ObjectToString(oValue));
    return _RemoveListElement(oTarget, VARLIST_TYPE_OBJECT, sListName, jObject);
}

int RemoveListString(object oTarget, string sValue, string sListName = "", int bMaintainOrder = FALSE)
{
    return _RemoveListElement(oTarget, VARLIST_TYPE_STRING, sListName, JsonString(sValue));
}

int RemoveListJson(object oTarget, json jValue, string sListName = "", int bMaintainOrder = FALSE)
{
    return _RemoveListElement(oTarget, VARLIST_TYPE_JSON, sListName, jValue);
}

float PopListFloat(object oTarget, string sListName = "")
{
    float f = GetListFloat(oTarget, 0, sListName);
    DeleteListFloat(oTarget, 0, sListName);
    return f;
}

int PopListInt(object oTarget, string sListName = "")
{
    int n = GetListInt(oTarget, 0, sListName);
    DeleteListInt(oTarget, 0, sListName);
    return n;
}

location PopListLocation(object oTarget, string sListName = "")
{
    location l = GetListLocation(oTarget, 0, sListName);
    DeleteListLocation(oTarget, 0, sListName);
    return l;
}

vector PopListVector(object oTarget, string sListName = "")
{
    vector v = GetListVector(oTarget, 0, sListName);
    DeleteListVector(oTarget, 0, sListName);
    return v;
}

object PopListObject(object oTarget, string sListName = "")
{
    object o = GetListObject(oTarget, 0, sListName);
    DeleteListObject(oTarget, 0, sListName);
    return o;
}

string PopListString(object oTarget, string sListName = "")
{
    string s = GetListString(oTarget, 0, sListName);
    DeleteListString(oTarget, 0, sListName);
    return s;
}

json PopListJson(object oTarget, string sListName = "")
{
    json j = GetListJson(oTarget, 0, sListName);
    DeleteListString(oTarget, 0, sListName);
    return j;
}

int FindListFloat(object oTarget, float fValue, string sListName = "")
{
    return _FindListElement(oTarget, VARLIST_TYPE_FLOAT, sListName, JsonFloat(fValue));
}

int FindListInt(object oTarget, int nValue, string sListName = "")
{
    return _FindListElement(oTarget, VARLIST_TYPE_INT, sListName, JsonInt(nValue));
}

int FindListLocation(object oTarget, location lValue, string sListName = "")
{
    json jLocation = LocationToJson(lValue);
    return _FindListElement(oTarget, VARLIST_TYPE_LOCATION, sListName, jLocation);
}

int FindListVector(object oTarget, vector vValue, string sListName = "")
{
    json jVector = VectorToJson(vValue);
    return _FindListElement(oTarget, VARLIST_TYPE_VECTOR, sListName, jVector);
}

int FindListObject(object oTarget, object oValue, string sListName = "")
{
    json jObject = JsonString(ObjectToString(oValue));
    return _FindListElement(oTarget, VARLIST_TYPE_OBJECT, sListName, jObject);
}

int FindListString(object oTarget, string sValue, string sListName = "")
{
    return _FindListElement(oTarget, VARLIST_TYPE_STRING, sListName, JsonString(sValue));
}

int FindListJson(object oTarget, json jValue, string sListName = "")
{
    return _FindListElement(oTarget, VARLIST_TYPE_JSON, sListName, jValue);
}

int HasListFloat(object oTarget, float fValue, string sListName = "")
{
    return FindListFloat(oTarget, fValue, sListName) != -1;
}

int HasListInt(object oTarget, int nValue, string sListName = "")
{
    return FindListInt(oTarget, nValue, sListName) != -1;
}

int HasListLocation(object oTarget, location lValue, string sListName = "")
{
    return FindListLocation(oTarget, lValue, sListName) != -1;
}

int HasListVector(object oTarget, vector vValue, string sListName = "")
{
    return FindListVector(oTarget, vValue, sListName) != -1;
}

int HasListObject(object oTarget, object oValue, string sListName = "")
{
    return FindListObject(oTarget, oValue, sListName) != -1;
}

int HasListString(object oTarget, string sValue, string sListName = "")
{
    return FindListString(oTarget, sValue, sListName) != -1;
}

int HasListJson(object oTarget, json jValue, string sListName = "")
{
    return FindListJson(oTarget, jValue, sListName) != -1;
}

int InsertListFloat(object oTarget, int nIndex, float fValue, string sListName = "", int bAddUnique = FALSE)
{
    return _InsertListElement(oTarget, VARLIST_TYPE_FLOAT, sListName, JsonFloat(fValue), nIndex, bAddUnique);
}

int InsertListInt(object oTarget, int nIndex, int nValue, string sListName = "", int bAddUnique = FALSE)
{
    return _InsertListElement(oTarget, VARLIST_TYPE_INT, sListName, JsonInt(nValue), nIndex, bAddUnique);
}

int InsertListLocation(object oTarget, int nIndex, location lValue, string sListName = "", int bAddUnique = FALSE)
{
    json jLocation = LocationToJson(lValue);
    return _InsertListElement(oTarget, VARLIST_TYPE_LOCATION, sListName, jLocation, nIndex, bAddUnique);
}

int InsertListVector(object oTarget, int nIndex, vector vValue, string sListName = "", int bAddUnique = FALSE)
{
    json jVector = VectorToJson(vValue);
    return _InsertListElement(oTarget, VARLIST_TYPE_VECTOR, sListName, jVector, nIndex, bAddUnique);
}

int InsertListObject(object oTarget, int nIndex, object oValue, string sListName = "", int bAddUnique = FALSE)
{
    json jObject = JsonString(ObjectToString(oValue));
    return _InsertListElement(oTarget, VARLIST_TYPE_OBJECT, sListName, jObject, nIndex, bAddUnique);
}

int InsertListString(object oTarget, int nIndex, string sValue, string sListName = "", int bAddUnique = FALSE)
{
    return _InsertListElement(oTarget, VARLIST_TYPE_STRING, sListName, JsonString(sValue), nIndex, bAddUnique);
}

int InsertListJson(object oTarget, int nIndex, json jValue, string sListName = "", int bAddUnique = FALSE)
{
    return _InsertListElement(oTarget, VARLIST_TYPE_JSON, sListName, jValue, nIndex, bAddUnique);
}

void SetListFloat(object oTarget, int nIndex, float fValue, string sListName = "")
{
    _SetListElement(oTarget, VARLIST_TYPE_FLOAT, sListName, nIndex, JsonFloat(fValue));
}

void SetListInt(object oTarget, int nIndex, int nValue, string sListName = "")
{
    _SetListElement(oTarget, VARLIST_TYPE_INT, sListName, nIndex, JsonInt(nValue));
}

void SetListLocation(object oTarget, int nIndex, location lValue, string sListName = "")
{
    json jLocation = LocationToJson(lValue);
    _SetListElement(oTarget, VARLIST_TYPE_LOCATION, sListName, nIndex, jLocation);
}

void SetListVector(object oTarget, int nIndex, vector vValue, string sListName = "")
{
    json jVector = VectorToJson(vValue);
    _SetListElement(oTarget, VARLIST_TYPE_VECTOR, sListName, nIndex, jVector);
}

void SetListObject(object oTarget, int nIndex, object oValue, string sListName = "")
{
    json jObject = JsonString(ObjectToString(oValue));
    _SetListElement(oTarget, VARLIST_TYPE_OBJECT, sListName, nIndex, jObject);
}

void SetListString(object oTarget, int nIndex, string sValue, string sListName = "")
{
    _SetListElement(oTarget, VARLIST_TYPE_STRING, sListName, nIndex, JsonString(sValue));
}

void SetListJson(object oTarget, int nIndex, json jValue, string sListName = "")
{
    _SetListElement(oTarget, VARLIST_TYPE_JSON, sListName, nIndex, jValue);
}

int CopyListFloat(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE)
{
    return _CopyListElements(oSource, oTarget, VARLIST_TYPE_FLOAT, sSourceName, sTargetName, nIndex, nRange, bAddUnique);
}

int CopyListInt(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE)
{
    return _CopyListElements(oSource, oTarget, VARLIST_TYPE_INT, sSourceName, sTargetName, nIndex, nRange, bAddUnique);
}

int CopyListLocation(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE)
{
    return _CopyListElements(oSource, oTarget, VARLIST_TYPE_LOCATION, sSourceName, sTargetName, nIndex, nRange, bAddUnique);
}

int CopyListVector(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE)
{
    return _CopyListElements(oSource, oTarget, VARLIST_TYPE_VECTOR, sSourceName, sTargetName, nIndex, nRange, bAddUnique);
}

int CopyListObject(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE)
{
    return _CopyListElements(oSource, oTarget, VARLIST_TYPE_OBJECT, sSourceName, sTargetName, nIndex, nRange, bAddUnique);
}

int CopyListString(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE)
{
    return _CopyListElements(oSource, oTarget, VARLIST_TYPE_STRING, sSourceName, sTargetName, nIndex, nRange, bAddUnique);
}

int CopyListJson(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE)
{
    return _CopyListElements(oSource, oTarget, VARLIST_TYPE_JSON, sSourceName, sTargetName, nIndex, nRange, bAddUnique);
}

int IncrementListInt(object oTarget, int nIndex, int nIncrement = 1, string sListName = "")
{
    return _IncrementListElement(oTarget, sListName, nIndex, nIncrement);
}

int DecrementListInt(object oTarget, int nIndex, int nDecrement = -1, string sListName = "")
{
    return _IncrementListElement(oTarget, sListName, nIndex, nDecrement);
}

json GetFloatList(object oTarget, string sListName = "")
{
    return _GetList(oTarget, VARLIST_TYPE_FLOAT, sListName);
}

json GetIntList(object oTarget, string sListName = "")
{
    return _GetList(oTarget, VARLIST_TYPE_INT, sListName);
}

json GetLocationList(object oTarget, string sListName = "")
{
    return _GetList(oTarget, VARLIST_TYPE_LOCATION, sListName);
}

json GetVectorList(object oTarget, string sListName = "")
{
    return _GetList(oTarget, VARLIST_TYPE_VECTOR, sListName);
}

json GetObjectList(object oTarget, string sListName = "")
{
    return _GetList(oTarget, VARLIST_TYPE_OBJECT, sListName);
}

json GetStringList(object oTarget, string sListName = "")
{
    return _GetList(oTarget, VARLIST_TYPE_STRING, sListName);
}

json GetJsonList(object oTarget, string sListName = "")
{
    return _GetList(oTarget, VARLIST_TYPE_JSON, sListName);
}

void SetFloatList(object oTarget, json jList, string sListName = "")
{
    _SetList(oTarget, VARLIST_TYPE_FLOAT, sListName, jList);
}

void SetIntList(object oTarget, json jList, string sListName = "")
{
    _SetList(oTarget, VARLIST_TYPE_INT, sListName, jList);
}

void SetLocationList(object oTarget, json jList, string sListName = "")
{
    _SetList(oTarget, VARLIST_TYPE_LOCATION, sListName, jList);
}

void SetVectorList(object oTarget, json jList, string sListName = "")
{
    _SetList(oTarget, VARLIST_TYPE_VECTOR, sListName, jList);
}

void SetObjectList(object oTarget, json jList, string sListName = "")
{
    _SetList(oTarget, VARLIST_TYPE_OBJECT, sListName, jList);
}

void SetStringList(object oTarget, json jList, string sListName = "")
{
    _SetList(oTarget, VARLIST_TYPE_STRING, sListName, jList);
}

void SetJsonList(object oTarget, json jList, string sListName = "")
{
    _SetList(oTarget, VARLIST_TYPE_JSON, sListName, jList);
}

void DeleteFloatList(object oTarget, string sListName = "")
{
    _DeleteList(oTarget, VARLIST_TYPE_FLOAT, sListName);
}

void DeleteIntList(object oTarget, string sListName = "")
{
    _DeleteList(oTarget, VARLIST_TYPE_INT, sListName);
}

void DeleteLocationList(object oTarget, string sListName = "")
{
    _DeleteList(oTarget, VARLIST_TYPE_LOCATION, sListName);
}

void DeleteVectorList(object oTarget, string sListName = "")
{
    _DeleteList(oTarget, VARLIST_TYPE_VECTOR, sListName);
}

void DeleteObjectList(object oTarget, string sListName = "")
{
    _DeleteList(oTarget, VARLIST_TYPE_OBJECT, sListName);
}

void DeleteStringList(object oTarget, string sListName = "")
{
    _DeleteList(oTarget, VARLIST_TYPE_STRING, sListName);
}

void DeleteJsonList(object oTarget, string sListName = "")
{
    _DeleteList(oTarget, VARLIST_TYPE_JSON, sListName);
}

json DeclareFloatList(object oTarget, int nCount, string sListName = "", float fDefault = 0.0)
{
    return _DeclareList(oTarget, VARLIST_TYPE_FLOAT, sListName, nCount, JsonFloat(fDefault));
}

json DeclareIntList(object oTarget, int nCount, string sListName = "", int nDefault = 0)
{
    return _DeclareList(oTarget, VARLIST_TYPE_INT, sListName, nCount, JsonInt(nDefault));
}

json DeclareLocationList(object oTarget, int nCount, string sListName = "")
{
    return _DeclareList(oTarget, VARLIST_TYPE_LOCATION, sListName, nCount, JSON_NULL);
}

json DeclareVectorList(object oTarget, int nCount, string sListName = "")
{
    return _DeclareList(oTarget, VARLIST_TYPE_VECTOR, sListName, nCount, JSON_NULL);
}

json DeclareObjectList(object oTarget, int nCount, string sListName = "")
{
    return _DeclareList(oTarget, VARLIST_TYPE_OBJECT, sListName, nCount, JSON_NULL);
}

json DeclareStringList(object oTarget, int nCount, string sListName = "", string sDefault = "")
{
    return _DeclareList(oTarget, VARLIST_TYPE_STRING, sListName, nCount, JsonString(sDefault));
}

json DeclareJsonList(object oTarget, int nCount, string sListName = "")
{
    return _DeclareList(oTarget, VARLIST_TYPE_JSON, sListName, nCount, JSON_NULL);
}

json NormalizeFloatList(object oTarget, int nCount, string sListName = "", float fDefault = 0.0)
{
    return _NormalizeList(oTarget, VARLIST_TYPE_FLOAT, sListName, nCount, JsonFloat(fDefault));
}

json NormalizeIntList(object oTarget, int nCount, string sListName = "", int nDefault = 0)
{
    return _NormalizeList(oTarget, VARLIST_TYPE_INT, sListName, nCount, JsonInt(nDefault));
}

json NormalizeLocationList(object oTarget, int nCount, string sListName = "")
{
    return _NormalizeList(oTarget, VARLIST_TYPE_LOCATION, sListName, nCount, JSON_NULL);
}

json NormalizeVectorList(object oTarget, int nCount, string sListName = "")
{
    return _NormalizeList(oTarget, VARLIST_TYPE_VECTOR, sListName, nCount, JSON_NULL);
}

json NormalizeObjectList(object oTarget, int nCount, string sListName = "")
{
    return _NormalizeList(oTarget, VARLIST_TYPE_OBJECT, sListName, nCount, JSON_NULL);
}

json NormalizeStringList(object oTarget, int nCount, string sListName = "", string sDefault = "")
{
    return _NormalizeList(oTarget, VARLIST_TYPE_STRING, sListName, nCount, JsonString(sDefault));
}

json NormalizeJsonList(object oTarget, int nCount, string sListName = "")
{
    return _NormalizeList(oTarget, VARLIST_TYPE_JSON, sListName, nCount, JSON_NULL);
}

void CopyFloatList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE)
{
    _CopyListElements(oSource, oTarget, VARLIST_TYPE_FLOAT, sSourceName, sTargetName, 0, -1, bAddUnique);
}

void CopyIntList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE)
{
    _CopyListElements(oSource, oTarget, VARLIST_TYPE_INT, sSourceName, sTargetName, 0, -1, bAddUnique);
}

void CopyLocationList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE)
{
    _CopyListElements(oSource, oTarget, VARLIST_TYPE_LOCATION, sSourceName, sTargetName, 0, -1, bAddUnique);
}

void CopyVectorList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE)
{
    _CopyListElements(oSource, oTarget, VARLIST_TYPE_VECTOR, sSourceName, sTargetName, 0, -1, bAddUnique);
}

void CopyObjectList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE)
{
    _CopyListElements(oSource, oTarget, VARLIST_TYPE_OBJECT, sSourceName, sTargetName, 0, -1, bAddUnique);
}

void CopyStringList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE)
{
    _CopyListElements(oSource, oTarget, VARLIST_TYPE_STRING, sSourceName, sTargetName, 0, -1, bAddUnique);
}

void CopyJsonList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE)
{
    _CopyListElements(oSource, oTarget, VARLIST_TYPE_JSON, sSourceName, sTargetName, 0, -1, bAddUnique);
}

int CountFloatList(object oTarget, string sListName = "")
{
    return _CountList(oTarget, VARLIST_TYPE_FLOAT, sListName);
}

int CountIntList(object oTarget, string sListName = "")
{
    return _CountList(oTarget, VARLIST_TYPE_INT, sListName);
}

int CountLocationList(object oTarget, string sListName = "")
{
    return _CountList(oTarget, VARLIST_TYPE_LOCATION, sListName);
}

int CountVectorList(object oTarget, string sListName = "")
{
    return _CountList(oTarget, VARLIST_TYPE_VECTOR, sListName);
}

int CountObjectList(object oTarget, string sListName = "")
{
    return _CountList(oTarget, VARLIST_TYPE_OBJECT, sListName);
}

int CountStringList(object oTarget, string sListName = "")
{
    return _CountList(oTarget, VARLIST_TYPE_STRING, sListName);
}

int CountJsonList(object oTarget, string sListName = "")
{
    return _CountList(oTarget, VARLIST_TYPE_JSON, sListName);
}

void SortFloatList(object oTarget, int nOrder = LIST_SORT_ASC, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_FLOAT, sListName, nOrder);
}

void SortIntList(object oTarget, int nOrder = LIST_SORT_ASC, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_INT, sListName, nOrder);
}

void SortStringList(object oTarget, int nOrder = LIST_SORT_ASC, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_STRING, sListName, nOrder);
}

void ShuffleFloatList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_FLOAT, sListName, JSON_ARRAY_SHUFFLE);
}

void ShuffleIntList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_INT, sListName, JSON_ARRAY_SHUFFLE);
}

void ShuffleLocationList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_LOCATION, sListName, JSON_ARRAY_SHUFFLE);
}

void ShuffleVectorList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_VECTOR, sListName, JSON_ARRAY_SHUFFLE);
}

void ShuffleObjectList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_OBJECT, sListName, JSON_ARRAY_SHUFFLE);
}

void ShuffleStringList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_STRING, sListName, JSON_ARRAY_SHUFFLE);
}

void ShuffleJsonList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_JSON, sListName, JSON_ARRAY_SHUFFLE);
}

void ReverseFloatList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_FLOAT, sListName, JSON_ARRAY_REVERSE);
}

void ReverseIntList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_INT, sListName, JSON_ARRAY_REVERSE);
}

void ReverseLocationList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_LOCATION, sListName, JSON_ARRAY_REVERSE);
}

void ReverseVectorList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_VECTOR, sListName, JSON_ARRAY_REVERSE);
}

void ReverseObjectList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_OBJECT, sListName, JSON_ARRAY_REVERSE);
}

void ReverseStringList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_STRING, sListName, JSON_ARRAY_REVERSE);
}

void ReverseJsonList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_JSON, sListName, JSON_ARRAY_REVERSE);
}
