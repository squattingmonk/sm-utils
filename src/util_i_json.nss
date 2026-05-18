/// ----------------------------------------------------------------------------
/// @file   util_i_json.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Helper functions for common json operations
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Returns a local json variable or jDefault if no local variable with
///     that varname is found.
/// @param oObject The object to get the local variable from.
/// @param sVarName The varname the local variable is stored as.
/// @param jDefault A default json value to return if the variable is not
///     present.
json GetLocalJsonOrDefault(object oObject, string sVarName, json jDefault);

// ----- Conversions -----------------------------------------------------------

/// @brief Convert a vector to a json object.
/// @param vPosition The vector to convert.
json JsonVector(vector vPosition = [0.0, 0.0, 0.0]);

/// @brief Convert a vector to a json object.
/// @param vPosition The vector to convert.
/// @note Alias for JsonVector().
json VectorToJson(vector vPosition = [0.0, 0.0, 0.0]);

/// @brief Convert a json object to a vector.
/// @param jPosition The json object to convert.
vector JsonGetVector(json jPosition);

/// @brief Convert a json object to a vector.
/// @param jPosition The json object to convert.
/// @note Alias for JsonGetVector().
vector JsonToVector(json jPosition);

/// @brief Convert a location to a json object.
/// @param lLocation The location to convert.
json JsonLocation(location lLocation);

/// @brief Convert a location to a json object.
/// @param lLocation The location to convert.
/// @note Alias for JsonLocation().
json LocationToJson(location lLocation);

/// @brief Convert a json object to a location.
/// @param jLocation The json object to convert.
location JsonGetLocation(json jLocation);

/// @brief Convert a json object to a location.
/// @param jLocation The json object to convert.
/// @note Alias for JsonGetLocation().
location JsonToLocation(json jLocation);

/// @brief Convert an object to a json object reference.
/// @param oObject The object to convert.
/// @returns A json string matching the object ID of oObject.
json JsonObjectRef(object oObject);

/// @brief Resolve a json object reference to an object.
/// @param jObjectRef A json string matching the object ID to resolve.
/// @returns The object matching the object ID stored in jObjectRef.
object JsonGetObjectRef(json jObjectRef);

// ----- Objects ---------------------------------------------------------------

/// @brief Returns the type of the json value stored at a given key in a json
///     object.
/// @param jObject The json object to check.
/// @param sKey The key at which the value is stored.
/// @returns A `JSON_TYPE_*` constant matching the type of the value or
///     `JSON_TYPE_NULL` if jObject is not a json object or if sKey is not a
///     valid key in jObject.
int JsonObjectGetType(json jObject, string sKey);

/// @brief Returns whether a json object contains a given value.
/// @param jObject The json object to check.
/// @param jValue The value to check for.
/// @param nNth The instance of the value to check for. Note that ordering is
///     undefined for json objects, so this just ensures that the value occurs
///     at least nNth + 1 times in the object.
/// @param nConditional A `JSON_FIND_*` constant matching the desired comparison
///     (default: `JSON_FIND_EQUAL` == check for the value directly).
/// @returns TRUE if the value exists at least nNth + 1 times, FALSE otherwise.
int JsonObjectContains(json jObject, json jValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Returns whether a json object contains a given boolean value.
/// @param jObject The json object to check.
/// @param bValue The value to check for.
/// @param nNth The instance of the value to check for. Note that ordering is
///     undefined for json objects, so this just ensures that the value occurs
///     at least nNth + 1 times in the object.
/// @param nConditional A `JSON_FIND_*` constant matching the desired comparison
///     (default: `JSON_FIND_EQUAL` == check for the value directly).
/// @returns TRUE if the value exists at least nNth + 1 times, FALSE otherwise.
int JsonObjectContainsBool(json jObject, int bValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Returns whether a json object contains a given float value.
/// @param jObject The json object to check.
/// @param fValue The value to check for.
/// @param nNth The instance of the value to check for. Note that ordering is
///     undefined for json objects, so this just ensures that the value occurs
///     at least nNth + 1 times in the object.
/// @param nConditional A `JSON_FIND_*` constant matching the desired comparison
///     (default: `JSON_FIND_EQUAL` == check for the value directly).
/// @returns TRUE if the value exists at least nNth + 1 times, FALSE otherwise.
int JsonObjectContainsFloat(json jObject, float fValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Returns whether a json object contains a given int value.
/// @param jObject The json object to check.
/// @param nValue The value to check for.
/// @param nNth The instance of the value to check for. Note that ordering is
///     undefined for json objects, so this just ensures that the value occurs
///     at least nNth + 1 times in the object.
/// @param nConditional A `JSON_FIND_*` constant matching the desired comparison
///     (default: `JSON_FIND_EQUAL` == check for the value directly).
/// @returns TRUE if the value exists at least nNth + 1 times, FALSE otherwise.
int JsonObjectContainsInt(json jObject, int nValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Returns whether a json object contains a given location value.
/// @param jObject The json object to check.
/// @param lValue The value to check for.
/// @param nNth The instance of the value to check for. Note that ordering is
///     undefined for json objects, so this just ensures that the value occurs
///     at least nNth + 1 times in the object.
/// @param nConditional A `JSON_FIND_*` constant matching the desired comparison
///     (default: `JSON_FIND_EQUAL` == check for the value directly).
/// @returns TRUE if the value exists at least nNth + 1 times, FALSE otherwise.
int JsonObjectContainsLocation(json jObject, location lValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Returns whether a json object contains a string reference to the
///     given object value.
/// @param jObject The json object to check.
/// @param oValue The value to check for.
/// @param nNth The instance of the value to check for. Note that ordering is
///     undefined for json objects, so this just ensures that the value occurs
///     at least nNth + 1 times in the object.
/// @param nConditional A `JSON_FIND_*` constant matching the desired comparison
///     (default: `JSON_FIND_EQUAL` == check for the value directly).
/// @returns TRUE if the value exists at least nNth + 1 times, FALSE otherwise.
int JsonObjectContainsObjectRef(json jObject, object oValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Returns whether a json object contains a given string value.
/// @param jObject The json object to check.
/// @param sValue The value to check for.
/// @param nNth The instance of the value to check for. Note that ordering is
///     undefined for json objects, so this just ensures that the value occurs
///     at least nNth + 1 times in the object.
/// @param nConditional A `JSON_FIND_*` constant matching the desired comparison
///     (default: `JSON_FIND_EQUAL` == check for the value directly).
/// @returns TRUE if the value exists at least nNth + 1 times, FALSE otherwise.
int JsonObjectContainsString(json jObject, string sValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Returns whether a json object contains a given vector value.
/// @param jObject The json object to check.
/// @param vValue The value to check for.
/// @param nNth The instance of the value to check for. Note that ordering is
///     undefined for json objects, so this just ensures that the value occurs
///     at least nNth + 1 times in the object.
/// @param nConditional A `JSON_FIND_*` constant matching the desired comparison
///     (default: `JSON_FIND_EQUAL` == check for the value directly).
/// @returns TRUE if the value exists at least nNth + 1 times, FALSE otherwise.
int JsonObjectContainsVector(json jObject, vector vValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Returns a float value stored at the given key in a json object.
/// @param jObject A json object to get the value from.
/// @param sKey The key at which the value is stored.
float JsonObjectGetFloat(json jObject, string sKey);

/// @brief Returns an int value stored at the given key in a json object.
/// @param jObject A json object to get the value from.
/// @param sKey The key at which the value is stored.
int JsonObjectGetInt(json jObject, string sKey);

/// @brief Returns a location value stored at the given key in a json object.
/// @param jObject A json object to get the value from.
/// @param sKey The key at which the value is stored.
location JsonObjectGetLocation(json jObject, string sKey);

/// @brief Returns an object value stored by reference at the given key in a
///     json object.
/// @param jObject A json object to get the value from.
/// @param sKey The key at which the value is stored.
object JsonObjectGetObjectRef(json jObject, string sKey);

/// @brief Returns a string value stored at the given key in a json object.
/// @param jObject A json object to get the value from.
/// @param sKey The key at which the value is stored.
string JsonObjectGetString(json jObject, string sKey);

/// @brief Returns a vector value stored at the given key in a json object.
/// @param jObject A json object to get the value from.
/// @param sKey The key at which the value is stored.
vector JsonObjectGetVector(json jObject, string sKey);

/// @brief Sets a boolean value at the given key in a json object.
/// @param jObject A json object to set the value in.
/// @param sKey The key at which to store the value.
/// @param bValue The value to store.
/// @returns The modified json object with the key/value pair set.
json JsonObjectSetBool(json jObject, string sKey, int bValue);

/// @brief Sets a float value at the given key in a json object.
/// @param jObject A json object to set the value in.
/// @param sKey The key at which to store the value.
/// @param fValue The value to store.
/// @returns The modified json object with the key/value pair set.
json JsonObjectSetFloat(json jObject, string sKey, float fValue);

/// @brief Sets an integer value at the given key in a json object.
/// @param jObject A json object to set the value in.
/// @param sKey The key at which to store the value.
/// @param nValue The value to store.
/// @returns The modified json object with the key/value pair set.
json JsonObjectSetInt(json jObject, string sKey, int nValue);

/// @brief Sets a location value at the given key in a json object.
/// @param jObject A json object to set the value in.
/// @param sKey The key at which to store the value.
/// @param lValue The value to store.
/// @returns The modified json object with the key/value pair set.
json JsonObjectSetLocation(json jObject, string sKey, location lValue);

/// @brief Sets an object value by reference at the given key in a json object.
/// @param jObject A json object to set the value in.
/// @param sKey The key at which to store the value.
/// @param oValue The value to store.
/// @returns The modified json object with the key/value pair set.
json JsonObjectSetObjectRef(json jObject, string sKey, object oValue);

/// @brief Sets a string value at the given key in a json object.
/// @param jObject A json object to set the value in.
/// @param sKey The key at which to store the value.
/// @param sValue The value to store.
/// @returns The modified json object with the key/value pair set.
json JsonObjectSetString(json jObject, string sKey, string sValue);

/// @brief Sets a vector value at the given key in a json object.
/// @param jObject A json object to set the value in.
/// @param sKey The key at which to store the value.
/// @param vValue The value to store.
/// @returns The modified json object with the key/value pair set.
json JsonObjectSetVector(json jObject, string sKey, vector vValue);

/// @brief Sets a boolean value at the given key in a json object. The operation
///     is performed in place, modifying jObject directly.
/// @param jObject The json object to set the value in.
/// @param sKey The key at which to store the value.
/// @param bValue The value to store.
void JsonObjectSetBoolInplace(json jObject, string sKey, int bValue);

/// @brief Sets a float value at the given key in a json object. The operation
///     is performed in place, modifying jObject directly.
/// @param jObject The json object to set the value in.
/// @param sKey The key at which to store the value.
/// @param fValue The value to store.
void JsonObjectSetFloatInplace(json jObject, string sKey, float fValue);

/// @brief Sets an integer value at the given key in a json object. The operation
///     is performed in place, modifying jObject directly.
/// @param jObject The json object to set the value in.
/// @param sKey The key at which to store the value.
/// @param nValue The value to store.
void JsonObjectSetIntInplace(json jObject, string sKey, int nValue);

/// @brief Sets a location value at the given key in a json object. The operation
///     is performed in place, modifying jObject directly.
/// @param jObject The json object to set the value in.
/// @param sKey The key at which to store the value.
/// @param lValue The value to store.
void JsonObjectSetLocationInplace(json jObject, string sKey, location lValue);

/// @brief Sets an obejct value by reference at the given key in a json object.
///     The operation is performed in place, modifying jObject directly.
/// @param jObject The json object to set the value in.
/// @param sKey The key at which to store the value.
/// @param oValue The value to store.
void JsonObjectSetObjectRefInplace(json jObject, string sKey, object oValue);

/// @brief Sets a string value at the given key in a json object. The operation
///     is performed in place, modifying jObject directly.
/// @param jObject The json object to set the value in.
/// @param sKey The key at which to store the value.
/// @param sValue The value to store.
void JsonObjectSetStringInplace(json jObject, string sKey, string sValue);

/// @brief Sets a vector value at the given key in a json object. The operation
///     is performed in place, modifying jObject directly.
/// @param jObject The json object to set the value in.
/// @param sKey The key at which to store the value.
/// @param vValue The value to store.
void JsonObjectSetVectorInplace(json jObject, string sKey, vector vValue);

// ----- Arrays ----------------------------------------------------------------

/// @brief Returns the type of value stored at an index in a json array.
/// @param jArray The json array to check.
/// @param nIndex The index of the value to check.
/// @returns A `JSON_TYPE_*` constant matching the type of value or
///     JSON_TYPE_NULL if jArray is not an array or if nIndex is out of bounds.
int JsonArrayGetType(json jArray, int nIndex);

/// @brief Removes and returns the last element from a json array. The array is
///     modified in place.
/// @param jArray The json array to remove the value from.
/// @returns The json element or JSON_NULL if the jArray is empty.
json JsonArrayPop(json jArray);

/// @brief Removes and returns the first element from a json array. The array is
///     modified in place.
/// @param jArray The json array to remove the value from.
/// @returns The json element or JSON_NULL if the jArray is empty.
json JsonArrayPopLeft(json jArray);

/// @brief Returns the index at which a value occurs in a json array.
/// @param jArray The json array to check.
/// @param jValue The value to check for.
/// @param nNth The nNth value to check for (default: 0 == first).
/// @param nConditional A `JSON_FIND_*` constant matching the desired comparison
///     (default: `JSON_FIND_EQUAL` == check for the value directly).
/// @returns The index at which the value occurs or -1 if the value is not
///     present or if jArray is not a json array.
int JsonArrayFind(json jArray, json jValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Returns the index at which a boolean value occurs in a json array.
/// @param jArray The json array to check.
/// @param jValue The value to check for.
/// @param nNth The nNth value to check for (default: 0 == first).
/// @param nConditional A `JSON_FIND_*` constant matching the desired comparison
///     (default: `JSON_FIND_EQUAL` == check for the value directly).
/// @returns The index at which the value occurs or -1 if the value is not
///     present or if jArray is not a json array.
int JsonArrayFindBool(json jArray, int bValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Returns the index at which a float value occurs in a json array.
/// @param jArray The json array to check.
/// @param jValue The value to check for.
/// @param nNth The nNth value to check for (default: 0 == first).
/// @param nConditional A `JSON_FIND_*` constant matching the desired comparison
///     (default: `JSON_FIND_EQUAL` == check for the value directly).
/// @returns The index at which the value occurs or -1 if the value is not
///     present or if jArray is not a json array.
int JsonArrayFindFloat(json jArray, float fValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Returns the index at which an integer value occurs in a json array.
/// @param jArray The json array to check.
/// @param jValue The value to check for.
/// @param nNth The nNth value to check for (default: 0 == first).
/// @param nConditional A `JSON_FIND_*` constant matching the desired comparison
///     (default: `JSON_FIND_EQUAL` == check for the value directly).
/// @returns The index at which the value occurs or -1 if the value is not
///     present or if jArray is not a json array.
int JsonArrayFindInt(json jArray, int nValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Returns the index at which a location value occurs in a json array.
/// @param jArray The json array to check.
/// @param jValue The value to check for.
/// @param nNth The nNth value to check for (default: 0 == first).
/// @param nConditional A `JSON_FIND_*` constant matching the desired comparison
///     (default: `JSON_FIND_EQUAL` == check for the value directly).
/// @returns The index at which the value occurs or -1 if the value is not
///     present or if jArray is not a json array.
int JsonArrayFindLocation(json jArray, location lValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Returns the index at which a reference to an object value occurs in a
///     json array.
/// @param jArray The json array to check.
/// @param jValue The value to check for.
/// @param nNth The nNth value to check for (default: 0 == first).
/// @param nConditional A `JSON_FIND_*` constant matching the desired comparison
///     (default: `JSON_FIND_EQUAL` == check for the value directly).
/// @returns The index at which the value occurs or -1 if the value is not
///     present or if jArray is not a json array.
int JsonArrayFindObjectRef(json jArray, object oValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Returns the index at which a string value occurs in a json array.
/// @param jArray The json array to check.
/// @param jValue The value to check for.
/// @param nNth The nNth value to check for (default: 0 == first).
/// @param nConditional A `JSON_FIND_*` constant matching the desired comparison
///     (default: `JSON_FIND_EQUAL` == check for the value directly).
/// @returns The index at which the value occurs or -1 if the value is not
///     present or if jArray is not a json array.
int JsonArrayFindString(json jArray, string sValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Returns the index at which a vector value occurs in a json array.
/// @param jArray The json array to check.
/// @param jValue The value to check for.
/// @param nNth The nNth value to check for (default: 0 == first).
/// @param nConditional A `JSON_FIND_*` constant matching the desired comparison
///     (default: `JSON_FIND_EQUAL` == check for the value directly).
/// @returns The index at which the value occurs or -1 if the value is not
///     present or if jArray is not a json array.
int JsonArrayFindVector(json jArray, vector vValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Returns whether a json array contains the given value.
/// @param jArray The json array to check.
/// @param jValue The value to check for.
/// @param nNth The nNth value to check for (default: 0 == first).
/// @param nConditional A `JSON_FIND_*` constant matching the desired comparison
/// 	(default: `JSON_FIND_EQUAL` == check for the value directly).
int JsonArrayContains(json jArray, json jValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Returns whether a json array contains the given boolean value.
/// @param jArray The json array to check.
/// @param bValue The value to check for.
/// @param nNth The nNth value to check for (default: 0 == first).
/// @param nConditional A `JSON_FIND_*` constant matching the desired comparison
/// 	(default: `JSON_FIND_EQUAL` == check for the value directly).
int JsonArrayContainsBool(json jArray, int bValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Returns whether a json array contains the given float value.
/// @param jArray The json array to check.
/// @param fValue The value to check for.
/// @param nNth The nNth value to check for (default: 0 == first).
/// @param nConditional A `JSON_FIND_*` constant matching the desired comparison
/// 	(default: `JSON_FIND_EQUAL` == check for the value directly).
int JsonArrayContainsFloat(json jArray, float fValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Returns whether a json array contains the given integer value.
/// @param jArray The json array to check.
/// @param nValue The value to check for.
/// @param nNth The nNth value to check for (default: 0 == first).
/// @param nConditional A `JSON_FIND_*` constant matching the desired comparison
/// 	(default: `JSON_FIND_EQUAL` == check for the value directly).
int JsonArrayContainsInt(json jArray, int nValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Returns whether a json array contains the given location value.
/// @param jArray The json array to check.
/// @param lValue The value to check for.
/// @param nNth The nNth value to check for (default: 0 == first).
/// @param nConditional A `JSON_FIND_*` constant matching the desired comparison
/// 	(default: `JSON_FIND_EQUAL` == check for the value directly).
int JsonArrayContainsLocation(json jArray, location lValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Returns whether a json array contains a string reference to the given
///     object value.
/// @param jArray The json array to check.
/// @param oValue The value to check for.
/// @param nNth The nNth value to check for (default: 0 == first).
/// @param nConditional A `JSON_FIND_*` constant matching the desired comparison
/// 	(default: `JSON_FIND_EQUAL` == check for the value directly).
int JsonArrayContainsObjectRef(json jArray, object oValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Returns whether a json array contains the given string value.
/// @param jArray The json array to check.
/// @param sValue The value to check for.
/// @param nNth The nNth value to check for (default: 0 == first).
/// @param nConditional A `JSON_FIND_*` constant matching the desired comparison
/// 	(default: `JSON_FIND_EQUAL` == check for the value directly).
int JsonArrayContainsString(json jArray, string sValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Returns whether a json array contains the given vector value.
/// @param jArray The json array to check.
/// @param vValue The value to check for.
/// @param nNth The nNth value to check for (default: 0 == first).
/// @param nConditional A `JSON_FIND_*` constant matching the desired comparison
/// 	(default: `JSON_FIND_EQUAL` == check for the value directly).
int JsonArrayContainsVector(json jArray, vector vValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Returns the float value at the given index from a json array.
/// @param jArray The json array to get the value from.
/// @param nIndex The index at which the value is located.
/// @returns 0.0 if jArray is not an array, if nIndex is out of the array
///     bounds, or if the value at nIndex is not a float.
float JsonArrayGetFloat(json jArray, int nIndex);

/// @brief Returns the integer value at the given index from a json array.
/// @param jArray The json array to get the value from.
/// @param nIndex The index at which the value is located.
/// @returns 0 if jArray is not an array, if nIndex is out of the array bounds,
///     or if the value at nIndex is not an integer or boolean.
int JsonArrayGetInt(json jArray, int nIndex);

/// @brief Returns the location value at the given index from a json array.
/// @param jArray The json array to get the value from.
/// @param nIndex The index at which the value is located.
/// @returns LOCATION_INVALID if jArray is not an array, if nIndex is out of the
///     array bounds, or if the value at nIndex is not a location.
location JsonArrayGetLocation(json jArray, int nIndex);

/// @brief Resolves the reference to an object value at the given index from a
///     json array.
/// @param jArray The json array to get the value from.
/// @param nIndex The index at which the value is located.
/// @returns OBJECT_INVALID if jArray is not an array, if nIndex is out of the
///     array bounds, or if the value at nIndex is not a string reference to an
///     object.
object JsonArrayGetObjectRef(json jArray, int nIndex);

/// @brief Returns the string value at the given index from a json array.
/// @param jArray The json array to get the value from.
/// @param nIndex The index at which the value is located.
/// @returns "" if jArray is not an array, if nIndex is out of the array bounds,
///     or if the value at nIndex is not a string.
string JsonArrayGetString(json jArray, int nIndex);

/// @brief Returns the vector value at the given index from a json array.
/// @param jArray The json array to get the value from.
/// @param nIndex The index at which the value is located.
/// @returns [0.0, 0.0, 0.0] if jArray is not an array, if nIndex is out of the
///     array bounds, or if the value at nIndex is not a vector.
vector JsonArrayGetVector(json jArray, int nIndex);

/// @brief Sets a boolean value at an index in a json array.
/// @param jArray The json array to set the value in.
/// @param nIndex The index at which to set the value.
/// @param bValue The value to set.
/// @returns The modified json array with the value set. If jArray is not an
///     array or nIndex is out of the array bounds, returns JSON_NULL with
///     JsonGetError() filled in.
json JsonArraySetBool(json jArray, int nIndex, int bValue);

/// @brief Sets a float value at an index in a json array.
/// @param jArray The json array to set the value in.
/// @param nIndex The index at which to set the value.
/// @param fValue The value to set.
/// @returns The modified json array with the value set. If jArray is not an
///     array or nIndex is out of the array bounds, returns JSON_NULL with
///     JsonGetError() filled in.
json JsonArraySetFloat(json jArray, int nIndex, float fValue);

/// @brief Sets an integer value at an index in a json array.
/// @param jArray The json array to set the value in.
/// @param nIndex The index at which to set the value.
/// @param nValue The value to set.
/// @returns The modified json array with the value set. If jArray is not an
///     array or nIndex is out of the array bounds, returns JSON_NULL with
///     JsonGetError() filled in.
json JsonArraySetInt(json jArray, int nIndex, int nValue);

/// @brief Sets a location value at an index in a json array.
/// @param jArray The json array to set the value in.
/// @param nIndex The index at which to set the value.
/// @param lValue The value to set.
/// @returns The modified json array with the value set. If jArray is not an
///     array or nIndex is out of the array bounds, returns JSON_NULL with
///     JsonGetError() filled in.
json JsonArraySetLocation(json jArray, int nIndex, location lValue);

/// @brief Sets a reference to an object value at an index in a json array.
/// @param jArray The json array to set the value in.
/// @param nIndex The index at which to set the value.
/// @param oValue The value to set.
/// @returns The modified json array with the value set. If jArray is not an
///     array or nIndex is out of the array bounds, returns JSON_NULL with
///     JsonGetError() filled in.
json JsonArraySetObjectRef(json jArray, int nIndex, object oValue);

/// @brief Sets a string value at an index in a json array.
/// @param jArray The json array to set the value in.
/// @param nIndex The index at which to set the value.
/// @param sValue The value to set.
/// @returns The modified json array with the value set. If jArray is not an
///     array or nIndex is out of the array bounds, returns JSON_NULL with
///     JsonGetError() filled in.
json JsonArraySetString(json jArray, int nIndex, string sValue);

/// @brief Sets a vector value at an index in a json array.
/// @param jArray The json array to set the value in.
/// @param nIndex The index at which to set the value.
/// @param vValue The value to set.
/// @returns The modified json array with the value set. If jArray is not an
///     array or nIndex is out of the array bounds, returns JSON_NULL with
///     JsonGetError() filled in.
json JsonArraySetVector(json jArray, int nIndex, vector vValue);

/// @brief Inserts a boolean value into a json array.
/// @param jArray The json array in which to insert the value.
/// @param bValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @returns The modified json array with the value inserted. If jArray is not
///     an array or nIndex is not 0 or -1 and is out of the array bounds,
///     returns JSON_NULL with JsonGetError() filled in.
json JsonArrayInsertBool(json jArray, int bValue, int nIndex = -1);

/// @brief Inserts a float value into a json array.
/// @param jArray The json array in which to insert the value.
/// @param fValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @returns The modified json array with the value inserted. If jArray is not
///     an array or nIndex is not 0 or -1 and is out of the array bounds,
///     returns JSON_NULL with JsonGetError() filled in.
json JsonArrayInsertFloat(json jArray, float fValue, int nIndex = -1);

/// @brief Inserts an integer value into a json array.
/// @param jArray The json array in which to insert the value.
/// @param nValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @returns The modified json array with the value inserted. If jArray is not
///     an array or nIndex is not 0 or -1 and is out of the array bounds,
///     returns JSON_NULL with JsonGetError() filled in.
json JsonArrayInsertInt(json jArray, int nValue, int nIndex = -1);

/// @brief Inserts a location value into a json array.
/// @param jArray The json array in which to insert the value.
/// @param lValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @returns The modified json array with the value inserted. If jArray is not
///     an array or nIndex is not 0 or -1 and is out of the array bounds,
///     returns JSON_NULL with JsonGetError() filled in.
json JsonArrayInsertLocation(json jArray, location lValue, int nIndex = -1);

/// @brief Inserts a reference to an object value into a json array.
/// @param jArray The json array in which to insert the value.
/// @param oValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @returns The modified json array with the value inserted. If jArray is not
///     an array or nIndex is not 0 or -1 and is out of the array bounds,
///     returns JSON_NULL with JsonGetError() filled in.
json jsonArrayInsertObjectRef(json jArray, object oValue, int nIndex = -1);

/// @brief Inserts a string value into a json array.
/// @param jArray The json array in which to insert the value.
/// @param sValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @returns The modified json array with the value inserted. If jArray is not
///     an array or nIndex is not 0 or -1 and is out of the array bounds,
///     returns JSON_NULL with JsonGetError() filled in.
json JsonArrayInsertString(json jArray, string sValue, int nIndex = -1);

/// @brief Inserts a vector value into a json array.
/// @param jArray The json array in which to insert the value.
/// @param vValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @returns The modified json array with the value inserted. If jArray is not
///     an array or nIndex is not 0 or -1 and is out of the array bounds,
///     returns JSON_NULL with JsonGetError() filled in.
json JsonArrayInsertVector(json jArray, vector vValue, int nIndex = -1);

/// @brief Inserts a json value into a json array if not already present.
/// @param jArray The json array in which to insert the value.
/// @param jValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @returns The modified json array with the value inserted if it was not
///     already present, otherwise the unmodified json array. If jArray is not
///     an array or nIndex is not 0 or -1 and is out of the array bounds,
///     returns JSON_NULL with JsonGetError() filled in.
json JsonArrayInsertUnique(json jArray, json jValue, int nIndex = -1);

/// @brief Inserts a boolean value into a json array if not already present.
/// @param jArray The json array in which to insert the value.
/// @param jValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @returns The modified json array with the value inserted if it was not
///     already present, otherwise the unmodified json array. If jArray is not
///     an array or nIndex is not 0 or -1 and is out of the array bounds,
///     returns JSON_NULL with JsonGetError() filled in.
json JsonArrayInsertUniqueBool(json jArray, int bValue, int nIndex = -1);

/// @brief Inserts a float value into a json array if not already present.
/// @param jArray The json array in which to insert the value.
/// @param fValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @returns The modified json array with the value inserted if it was not
///     already present, otherwise the unmodified json array. If jArray is not
///     an array or nIndex is not 0 or -1 and is out of the array bounds,
///     returns JSON_NULL with JsonGetError() filled in.
json JsonArrayInsertUniqueFloat(json jArray, float fValue, int nIndex = -1);

/// @brief Inserts an integer value into a json array if not already present.
/// @param jArray The json array in which to insert the value.
/// @param nValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @returns The modified json array with the value inserted if it was not
///     already present, otherwise the unmodified json array. If jArray is not
///     an array or nIndex is not 0 or -1 and is out of the array bounds,
///     returns JSON_NULL with JsonGetError() filled in.
json JsonArrayInsertUniqueInt(json jArray, int nValue, int nIndex = -1);

/// @brief Inserts a location value into a json array if not already present.
/// @param jArray The json array in which to insert the value.
/// @param lValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @returns The modified json array with the value inserted if it was not
///     already present, otherwise the unmodified json array. If jArray is not
///     an array or nIndex is not 0 or -1 and is out of the array bounds,
///     returns JSON_NULL with JsonGetError() filled in.
json JsonArrayInsertUniqueLocation(json jArray, location lValue, int nIndex = -1);

/// @brief Inserts a reference to an object value into a json array if not
///     already present.
/// @param jArray The json array in which to insert the value.
/// @param oValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @returns The modified json array with the value inserted if it was not
///     already present, otherwise the unmodified json array. If jArray is not
///     an array or nIndex is not 0 or -1 and is out of the array bounds,
///     returns JSON_NULL with JsonGetError() filled in.
json JsonArrayInsertUniqueObjectRef(json jArray, object oValue, int nIndex = -1);

/// @brief Inserts a string value into a json array if not already present.
/// @param jArray The json array in which to insert the value.
/// @param sValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @returns The modified json array with the value inserted if it was not
///     already present, otherwise the unmodified json array. If jArray is not
///     an array or nIndex is not 0 or -1 and is out of the array bounds,
///     returns JSON_NULL with JsonGetError() filled in.
json JsonArrayInsertUniqueString(json jArray, string sValue, int nIndex = -1);

/// @brief Inserts a vector value into a json array if not already present.
/// @param jArray The json array in which to insert the value.
/// @param vValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @returns The modified json array with the value inserted if it was not
///     already present, otherwise the unmodified json array. If jArray is not
///     an array or nIndex is not 0 or -1 and is out of the array bounds,
///     returns JSON_NULL with JsonGetError() filled in.
json JsonArrayInsertUniqueVector(json jArray, vector vValue, int nIndex = -1);

/// @brief Sets a boolean value at an index in a json array. The operation is
///     performed in place, modifying jArray directly.
/// @param jArray The array in which to set the value.
/// @param nIndex The index at which to set the value.
/// @param bValue The value to set.
/// @note If jArray is not an array or if nIndex is not 0 or -1 and is outside
///     the array bounds, jArray will be set to JSON_NULL with JsonGetError()
///     filled in.
void JsonArraySetBoolInplace(json jArray, int nIndex, int bValue);

/// @brief Sets a float value at an index in a json array. The operation is
///     performed in place, modifying jArray directly.
/// @param jArray The array in which to set the value.
/// @param nIndex The index at which to set the value.
/// @param fValue The value to set.
/// @note If jArray is not an array or if nIndex is not 0 or -1 and is outside
///     the array bounds, jArray will be set to JSON_NULL with JsonGetError()
///     filled in.
void JsonArraySetFloatInplace(json jArray, int nIndex, float fValue);

/// @brief Sets an integer value at an index in a json array. The operation is
///     performed in place, modifying jArray directly.
/// @param jArray The array in which to set the value.
/// @param nIndex The index at which to set the value.
/// @param nValue The value to set.
/// @note If jArray is not an array or if nIndex is not 0 or -1 and is outside
///     the array bounds, jArray will be set to JSON_NULL with JsonGetError()
///     filled in.
void JsonArraySetIntInplace(json jArray, int nIndex, int nValue);

/// @brief Sets a location value at an index in a json array. The operation is
///     performed in place, modifying jArray directly.
/// @param jArray The array in which to set the value.
/// @param nIndex The index at which to set the value.
/// @param lValue The value to set.
/// @note If jArray is not an array or if nIndex is not 0 or -1 and is outside
///     the array bounds, jArray will be set to JSON_NULL with JsonGetError()
///     filled in.
void JsonArraySetLocationInplace(json jArray, int nIndex, location lValue);

/// @brief Sets a reference to an object value at an index in a json array. The
///     operation is performed in place, modifying jArray directly.
/// @param jArray The array in which to set the value.
/// @param nIndex The index at which to set the value.
/// @param oValue The value to set.
/// @note If jArray is not an array or if nIndex is not 0 or -1 and is outside
///     the array bounds, jArray will be set to JSON_NULL with JsonGetError()
///     filled in.
void JsonArraySetObjectRefInplace(json jArray, int nIndex, object oValue);

/// @brief Sets a string value at an index in a json array. The operation is
///     performed in place, modifying jArray directly.
/// @param jArray The array in which to set the value.
/// @param nIndex The index at which to set the value.
/// @param sValue The value to set.
/// @note If jArray is not an array or if nIndex is not 0 or -1 and is outside
///     the array bounds, jArray will be set to JSON_NULL with JsonGetError()
///     filled in.
void JsonArraySetStringInplace(json jArray, int nIndex, string sValue);

/// @brief Sets a vector value at an index in a json array. The operation is
///     performed in place, modifying jArray directly.
/// @param jArray The array in which to set the value.
/// @param nIndex The index at which to set the value.
/// @param vValue The value to set.
/// @note If jArray is not an array or if nIndex is not 0 or -1 and is outside
///     the array bounds, jArray will be set to JSON_NULL with JsonGetError()
///     filled in.
void JsonArraySetVectorInplace(json jArray, int nIndex, vector vValue);

/// @brief Inserts a boolean value into a json array. The operation is performed
///     in place, modifying jArray directly.
/// @param jArray The array in which to insert the value.
/// @param bValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @note If jArray is not an array or if nIndex is not 0 or -1 and is outside
///     the array bounds, jArray will be set to JSON_NULL with JsonGetError()
///     filled in.
void JsonArrayInsertBoolInplace(json jArray, int bValue, int nIndex = -1);

/// @brief Inserts a float value into a json array. The operation is performed
///     in place, modifying jArray directly.
/// @param jArray The array in which to insert the value.
/// @param fValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @note If jArray is not an array or if nIndex is not 0 or -1 and is outside
///     the array bounds, jArray will be set to JSON_NULL with JsonGetError()
///     filled in.
void JsonArrayInsertFloatInplace(json jArray, float fValue, int nIndex = -1);

/// @brief Inserts an integer value into a json array. The operation is performed
///     in place, modifying jArray directly.
/// @param jArray The array in which to insert the value.
/// @param nValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @note If jArray is not an array or if nIndex is not 0 or -1 and is outside
///     the array bounds, jArray will be set to JSON_NULL with JsonGetError()
///     filled in.
void JsonArrayInsertIntInplace(json jArray, int nValue, int nIndex = -1);

/// @brief Inserts a location value into a json array. The operation is performed
///     in place, modifying jArray directly.
/// @param jArray The array in which to insert the value.
/// @param lValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @note If jArray is not an array or if nIndex is not 0 or -1 and is outside
///     the array bounds, jArray will be set to JSON_NULL with JsonGetError()
///     filled in.
void JsonArrayInsertLocationInplace(json jArray, location lValue, int nIndex = -1);

/// @brief Inserts a reference to an object value into a json array. The
///     operation is performed in place, modifying jArray directly.
/// @param jArray The array in which to insert the value.
/// @param oValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @note If jArray is not an array or if nIndex is not 0 or -1 and is outside
///     the array bounds, jArray will be set to JSON_NULL with JsonGetError()
///     filled in.
void jsonArrayInsertObjectRefInplace(json jArray, object oValue, int nIndex = -1);

/// @brief Inserts a string value into a json array. The operation is performed
///     in place, modifying jArray directly.
/// @param jArray The array in which to insert the value.
/// @param sValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @note If jArray is not an array or if nIndex is not 0 or -1 and is outside
///     the array bounds, jArray will be set to JSON_NULL with JsonGetError()
///     filled in.
void JsonArrayInsertStringInplace(json jArray, string sValue, int nIndex = -1);

/// @brief Inserts a vector value into a json array. The operation is performed
///     in place, modifying jArray directly.
/// @param jArray The array in which to insert the value.
/// @param vValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @note If jArray is not an array or if nIndex is not 0 or -1 and is outside
///     the array bounds, jArray will be set to JSON_NULL with JsonGetError()
///     filled in.
void JsonArrayInsertVectorInplace(json jArray, vector vValue, int nIndex = -1);

/// @brief Inserts a value into a json array if it is not already present. The
///     operation is performed in place, modifying jArray directly.
/// @param jArray The json array in which to insert the value.
/// @param jValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @note If jArray is not an array or if nIndex is not 0 or -1 and is outside
///     the array bounds, jArray will be set to JSON_NULL with JsongetError()
///     filled in.
void JsonArrayInsertUniqueInplace(json jArray, json jValue, int nIndex = -1);

/// @brief Inserts a boolean value into a json array if it is not already
///     present. The operation is performed in place, modifying jArray directly.
/// @param jArray The json array in which to insert the value.
/// @param bValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @note If jArray is not an array or if nIndex is not 0 or -1 and is outside
///     the array bounds, jArray will be set to JSON_NULL with JsongetError()
///     filled in.
void JsonArrayInsertUniqueBoolInplace(json jArray, int bValue, int nIndex = -1);

/// @brief Inserts a float value into a json array if it is not already present.
///     The operation is performed in place, modifying jArray directly.
/// @param jArray The json array in which to insert the value.
/// @param fValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @note If jArray is not an array or if nIndex is not 0 or -1 and is outside
///     the array bounds, jArray will be set to JSON_NULL with JsongetError()
///     filled in.
void JsonArrayInsertUniqueFloatInplace(json jArray, float fValue, int nIndex = -1);

/// @brief Inserts an integer value into a json array if it is not already
///     present. The operation is performed in place, modifying jArray directly.
/// @param jArray The json array in which to insert the value.
/// @param nValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @note If jArray is not an array or if nIndex is not 0 or -1 and is outside
///     the array bounds, jArray will be set to JSON_NULL with JsongetError()
///     filled in.
void JsonArrayInsertUniqueIntInplace(json jArray, int nValue, int nIndex = -1);

/// @brief Inserts a location value into a json array if it is not already
///     present. The operation is performed in place, modifying jArray directly.
/// @param jArray The json array in which to insert the value.
/// @param lValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @note If jArray is not an array or if nIndex is not 0 or -1 and is outside
///     the array bounds, jArray will be set to JSON_NULL with JsongetError()
///     filled in.
void JsonArrayInsertUniqueLocationInplace(json jArray, location lValue, int nIndex = -1);

/// @brief Inserts a reference to an object value into a json array if it is not
///     already present. The operation is performed in place, modifying jArray
///     directly.
/// @param jArray The json array in which to insert the value.
/// @param oValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @note If jArray is not an array or if nIndex is not 0 or -1 and is outside
///     the array bounds, jArray will be set to JSON_NULL with JsongetError()
///     filled in.
void JsonArrayInsertUniqueObjectRefInplace(json jArray, object oValue, int nIndex = -1);

/// @brief Inserts a string value into a json array if it is not already
///     present. The operation is performed in place, modifying jArray directly.
/// @param jArray The json array in which to insert the value.
/// @param sValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @note If jArray is not an array or if nIndex is not 0 or -1 and is outside
///     the array bounds, jArray will be set to JSON_NULL with JsongetError()
///     filled in.
void JsonArrayInsertUniqueStringInplace(json jArray, string sValue, int nIndex = -1);

/// @brief Inserts a vector value into a json array if it is not already
///     present. The operation is performed in place, modifying jArray directly.
/// @param jArray The json array in which to insert the value.
/// @param vValue The value to insert.
/// @param nIndex The index at which to insert the value. If -1, will append the
///     value to the end of the array.
/// @note If jArray is not an array or if nIndex is not 0 or -1 and is outside
///     the array bounds, jArray will be set to JSON_NULL with JsongetError()
///     filled in.
void JsonArrayInsertUniqueVectorInplace(json jArray, vector vValue, int nIndex = -1);

/// @brief Removes an occurence of a given value from a json array.
/// @param jArray The array to modify.
/// @param jValue The value to remove.
/// @param nNth The occurence (0-indexed) of the value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
/// @returns The modified json array, or the original json array if the value
///     was not found.
json JsonArrayRemove(json jArray, json jValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes an occurence of a boolean value from a json array.
/// @param jArray The array to modify.
/// @param bValue The value to remove.
/// @param nNth The occurence (0-indexed) of the value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
/// @returns The modified json array, or the original json array if the value
///     was not found.
json JsonArrayRemoveBool(json jArray, int bValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes an occurence of a float value from a json array.
/// @param jArray The array to modify.
/// @param fValue The value to remove.
/// @param nNth The occurence (0-indexed) of the value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
/// @returns The modified json array, or the original json array if the value
///     was not found.
json JsonArrayRemoveFloat(json jArray, float fValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes an occurence of an integer value from a json array.
/// @param jArray The array to modify.
/// @param nValue The value to remove.
/// @param nNth The occurence (0-indexed) of the value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
/// @returns The modified json array, or the original json array if the value
///     was not found.
json JsonArrayRemoveInt(json jArray, int nValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes an occurence of a location value from a json array.
/// @param jArray The array to modify.
/// @param lValue The value to remove.
/// @param nNth The occurence (0-indexed) of the value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
/// @returns The modified json array, or the original json array if the value
///     was not found.
json JsonArrayRemoveLocation(json jArray, location lValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes an occurence of an object value reference from a json array.
/// @param jArray The array to modify.
/// @param oValue The value to remove.
/// @param nNth The occurence (0-indexed) of the value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
/// @returns The modified json array, or the original json array if the value
///     was not found.
json JsonArrayRemoveObjectRef(json jArray, object oValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes an occurence of a string value from a json array.
/// @param jArray The array to modify.
/// @param sValue The value to remove.
/// @param nNth The occurence (0-indexed) of the value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
/// @returns The modified json array, or the original json array if the value
///     was not found.
json JsonArrayRemoveString(json jArray, string sValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes an occurence of a vector value from a json array.
/// @param jArray The array to modify.
/// @param vValue The value to remove.
/// @param nNth The occurence (0-indexed) of the value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
/// @returns The modified json array, or the original json array if the value
///     was not found.
json JsonArrayRemoveVector(json jArray, vector vValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes an occurence of a value from a json array. The operation is
///     performed in place, modifiying jArray directly.
/// @param jArray The array to modify.
/// @param jValue The value to remove.
/// @param nNth The occurence (0-indexed) of the value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
void JsonArrayRemoveInplace(json jArray, json jValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes an occurence of a boolean value from a json array. The
///     operation is performed in place, modifiying jArray directly.
/// @param jArray The array to modify.
/// @param bValue The value to remove.
/// @param nNth The occurence (0-indexed) of the value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
void JsonArrayRemoveBoolInplace(json jArray, int bValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes an occurence of a float value from a json array. The
///     operation is performed in place, modifiying jArray directly.
/// @param jArray The array to modify.
/// @param fValue The value to remove.
/// @param nNth The occurence (0-indexed) of the value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
void JsonArrayRemoveFloatInplace(json jArray, float fValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes an occurence of an integer value from a json array. The
///     operation is performed in place, modifiying jArray directly.
/// @param jArray The array to modify.
/// @param nValue The value to remove.
/// @param nNth The occurence (0-indexed) of the value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
void JsonArrayRemoveIntInplace(json jArray, int nValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes an occurence of a location value from a json array. The
///     operation is performed in place, modifiying jArray directly.
/// @param jArray The array to modify.
/// @param lValue The value to remove.
/// @param nNth The occurence (0-indexed) of the value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
void JsonArrayRemoveLocationInplace(json jArray, location lValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes an occurence of an object reference from a json array. The
///     operation is performed in place, modifiying jArray directly.
/// @param jArray The array to modify.
/// @param oValue The value to remove.
/// @param nNth The occurence (0-indexed) of the value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
void JsonArrayRemoveObjectRefInplace(json jArray, object oValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes an occurence of a string value from a json array. The
///     operation is performed in place, modifiying jArray directly.
/// @param jArray The array to modify.
/// @param sValue The value to remove.
/// @param nNth The occurence (0-indexed) of the value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
void JsonArrayRemoveStringInplace(json jArray, string sValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes an occurence of a vector value from a json array. The
///     operation is performed in place, modifiying jArray directly.
/// @param jArray The array to modify.
/// @param vValue The value to remove.
/// @param nNth The occurence (0-indexed) of the value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
void JsonArrayRemoveVectorInplace(json jArray, vector vValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes all occurrences of a given value from a json array.
/// @param jArray The json array to modify.
/// @param jValue The value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
/// @returns The modified json array, or the original json array if the value
///     was not found.
json JsonArrayRemoveAll(json jArray, json jValue, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes all occurrences of a given boolean value from a json array.
/// @param jArray The json array to modify.
/// @param bValue The value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
/// @returns The modified json array, or the original json array if the value
///     was not found.
json JsonArrayRemoveAllBool(json jArray, int bValue, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes all occurrences of a given float value from a json array.
/// @param jArray The json array to modify.
/// @param fValue The value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
/// @returns The modified json array, or the original json array if the value
///     was not found.
json JsonArrayRemoveAllFloat(json jArray, float fValue, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes all occurrences of a given integer value from a json array.
/// @param jArray The json array to modify.
/// @param nValue The value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
/// @returns The modified json array, or the original json array if the value
///     was not found.
json JsonArrayRemoveAllInt(json jArray, int nValue, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes all occurrences of a given location value from a json array.
/// @param jArray The json array to modify.
/// @param lValue The value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
/// @returns The modified json array, or the original json array if the value
///     was not found.
json JsonArrayRemoveAllLocation(json jArray, location lValue, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes all occurrences of a given object reference from a json array.
/// @param jArray The json array to modify.
/// @param oValue The value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
/// @returns The modified json array, or the original json array if the value
///     was not found.
json JsonArrayRemoveAllObjectRef(json jArray, object oValue, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes all occurrences of a given string value from a json array.
/// @param jArray The json array to modify.
/// @param sValue The value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
/// @returns The modified json array, or the original json array if the value
///     was not found.
json JsonArrayRemoveAllString(json jArray, string sValue, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes all occurrences of a given vector value from a json array.
/// @param jArray The json array to modify.
/// @param vValue The value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
/// @returns The modified json array, or the original json array if the value
///     was not found.
json JsonArrayRemoveAllVector(json jArray, vector vValue, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes all occurrences of a given value from a json array. The
///     operation is performed in place, modifying jArray directly.
/// @param jArray The json array to modify.
/// @param jValue The value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
void JsonArrayRemoveAllInplace(json jArray, json jValue, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes all occurrences of a given boolean value from a json array.
///     The operation is performed in place, modifying jArray directly.
/// @param jArray The json array to modify.
/// @param bValue The value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
void JsonArrayRemoveAllBoolInplace(json jArray, int bValue, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes all occurrences of a given float value from a json array.
///     The operation is performed in place, modifying jArray directly.
/// @param jArray The json array to modify.
/// @param fValue The value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
void JsonArrayRemoveAllFloatInplace(json jArray, float fValue, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes all occurrences of a given integer value from a json array.
///     The operation is performed in place, modifying jArray directly.
/// @param jArray The json array to modify.
/// @param nValue The value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
void JsonArrayRemoveAllIntInplace(json jArray, int nValue, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes all occurrences of a given location value from a json array.
///     The operation is performed in place, modifying jArray directly.
/// @param jArray The json array to modify.
/// @param lValue The value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
void JsonArrayRemoveAllLocationInplace(json jArray, location lValue, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes all occurrences of a given object reference from a json array.
///     The operation is performed in place, modifying jArray directly.
/// @param jArray The json array to modify.
/// @param oValue The value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
void JsonArrayRemoveAllObjectRefInplace(json jArray, object oValue, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes all occurrences of a given string value from a json array.
///     The operation is performed in place, modifying jArray directly.
/// @param jArray The json array to modify.
/// @param sValue The value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
void JsonArrayRemoveAllStringInplace(json jArray, string sValue, int nConditional = JSON_FIND_EQUAL);

/// @brief Removes all occurrences of a given vector value from a json array.
///     The operation is performed in place, modifying jArray directly.
/// @param jArray The json array to modify.
/// @param vValue The value to remove.
/// @param nConditional A `JSON_FIND_*` constant matching the comparison to
///     perform.
void JsonArrayRemoveAllVectorInplace(json jArray, vector vValue, int nConditional = JSON_FIND_EQUAL);

// ----- Patch Builders --------------------------------------------------------

/// @brief Creates an `add` op for a `JsonPatch` call. The resulting value must
///     still be added to an array before it can be used as a patch.
/// @param sPath A json pointer to the path to add the value.
/// @param jValue The value to add.
json JsonPatchAdd(string sPath, json jValue);

/// @brief Creates a `remove` op for a `JsonPatch` call. The resulting value must
///     still be added to an array before it can be used as a patch.
/// @param sPath A json pointer to the path to remove.
json JsonPatchRemove(string sPath);

/// @brief Creates a `replace` op for a `JsonPatch` call. The resulting value
///     must still be added to an array before it can be used as a patch.
/// @param sPath A json pointer to the path of the value to replace.
/// @param jValue The value to add.
json JsonPatchReplace(string sPath, json jValue);

/// @brief Creates a `copy` op for a `JsonPatch` call. The resulting value must
///     still be added to an array before it can be used as a patch.
/// @param sFrom A json pointer to the value to be copied.
/// @param sPath A json pointer to the path the value should be copied to.
json JsonPatchCopy(string sFrom, string sPath);

/// @brief Creates a `move` op for a `JsonPatch` call. The resulting value must
///     still be added to an array before it can be used as a patch.
/// @param sFrom A json pointer to the value to be moved.
/// @param sPath A json pointer to the path the value should be moved to.
json JsonPatchMove(string sFrom, string sPath);

/// @brief Creates a `test` op for a `JsonPatch` call. The resulting value must
///     still be added to an array before it can be used as as a patch.
/// @param sPath A json pointer to the value to be tested.
/// @param jValue The value to compare to the stored value.
json JsonPatchTest(string sPath, json jValue);

// -----------------------------------------------------------------------------
//                           Function Implementations
// -----------------------------------------------------------------------------

json GetLocalJsonOrDefault(object oObject, string sVarName, json jDefault)
{
    json jLocal = GetLocalJson(oObject, sVarName);
    return JsonGetType(jLocal) ? jLocal : jDefault;
}

// ----- Conversions -----------------------------------------------------------

json JsonVector(vector vPosition = [0.0, 0.0, 0.0])
{
    json jPosition = JsonObject();
    JsonObjectSetInplace(jPosition, "x", JsonFloat(vPosition.x));
    JsonObjectSetInplace(jPosition, "y", JsonFloat(vPosition.y));
    JsonObjectSetInplace(jPosition, "z", JsonFloat(vPosition.z));

    return jPosition;
}

json VectorToJson(vector vPosition = [0.0, 0.0, 0.0])
{
    return JsonVector(vPosition);
}

vector JsonGetVector(json jPosition)
{
    float x = JsonObjectGetFloat(jPosition, "x");
    float y = JsonObjectGetFloat(jPosition, "y");
    float z = JsonObjectGetFloat(jPosition, "z");

    return Vector(x, y, z);
}

vector JsonToVector(json jPosition)
{
    return JsonGetVector(jPosition);
}

json JsonLocation(location lLocation)
{
    json jLocation = JsonObject();
    JsonObjectSetStringInplace(jLocation, "area",     GetTag(GetAreaFromLocation(lLocation)));
    JsonObjectSetVectorInplace(jLocation, "position", GetPositionFromLocation(lLocation));
    JsonObjectSetFloatInplace (jLocation, "facing",   GetFacingFromLocation(lLocation));
    return jLocation;
}

json LocationToJson(location lLocation)
{
    return JsonLocation(lLocation);
}

location JsonGetLocation(json jLocation)
{
    object oArea = GetObjectByTag(JsonObjectGetString(jLocation, "area"));
    vector vPosition = JsonObjectGetVector(jLocation, "position");
    float fFacing = JsonObjectGetFloat(jLocation, "facing");

    return Location(oArea, vPosition, fFacing);
}

location JsonToLocation(json jLocation)
{
    return JsonGetLocation(jLocation);
}

json JsonObjectRef(object oObject)
{
    return JsonString(ObjectToString(oObject));
}

object JsonGetObjectRef(json jObjectRef)
{
    return StringToObject(JsonGetString(jObjectRef));
}

// ----- Objects ---------------------------------------------------------------

int JsonObjectGetType(json jObject, string sKey)
{
    return JsonGetType(JsonObjectGet(jObject, sKey));
}

int JsonObjectEquals(json jObject1, json jObject2)
{
    return jObject1 == jObject2;
}

int JsonObjectContains(json jObject, json jValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonGetType(JsonFind(jObject, jValue, nNth, nConditional)) == JSON_TYPE_STRING;
}

int JsonObjectContainsBool(json jObject, int bValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonObjectContains(jObject, JsonBool(bValue), nNth, nConditional);
}

int JsonObjectContainsFloat(json jObject, float fValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonObjectContains(jObject, JsonFloat(fValue), nNth, nConditional);
}

int JsonObjectContainsInt(json jObject, int nValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonObjectContains(jObject, JsonInt(nValue), nNth, nConditional);
}

int JsonObjectContainsLocation(json jObject, location lValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonObjectContains(jObject, JsonLocation(lValue), nNth, nConditional);
}

int JsonObjectContainsObjectRef(json jObject, object oValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonObjectContains(jObject, JsonObjectRef(oValue), nNth, nConditional);
}

int JsonObjectContainsString(json jObject, string sValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonObjectContains(jObject, JsonString(sValue), nNth, nConditional);
}

int JsonObjectContainsVector(json jObject, vector vValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonObjectContains(jObject, JsonVector(vValue), nNth, nConditional);
}

float JsonObjectGetFloat(json jObject, string sKey)
{
    return JsonGetFloat(JsonObjectGet(jObject, sKey));
}

int JsonObjectGetInt(json jObject, string sKey)
{
    return JsonGetInt(JsonObjectGet(jObject, sKey));
}

location JsonObjectGetLocation(json jObject, string sKey)
{
    return JsonGetLocation(JsonObjectGet(jObject, sKey));
}

object JsonObjectGetObjectRef(json jObject, string sKey)
{
    return JsonGetObjectRef(JsonObjectGet(jObject, sKey));
}

string JsonObjectGetString(json jObject, string sKey)
{
    return JsonGetString(JsonObjectGet(jObject, sKey));
}

vector JsonObjectGetVector(json jObject, string sKey)
{
    return JsonGetVector(JsonObjectGet(jObject, sKey));
}

json JsonObjectSetBool(json jObject, string sKey, int bValue)
{
    return JsonObjectSet(jObject, sKey, JsonBool(bValue));
}

json JsonObjectSetFloat(json jObject, string sKey, float fValue)
{
    return JsonObjectSet(jObject, sKey, JsonFloat(fValue));
}

json JsonObjectSetInt(json jObject, string sKey, int nValue)
{
    return JsonObjectSet(jObject, sKey, JsonInt(nValue));
}

json JsonObjectSetLocation(json jObject, string sKey, location lValue)
{
    return JsonObjectSet(jObject, sKey, JsonLocation(lValue));
}

json JsonObjectSetObjectRef(json jObject, string sKey, object oValue)
{
    return JsonObjectSet(jObject, sKey, JsonObjectRef(oValue));
}

json JsonObjectSetString(json jObject, string sKey, string sValue)
{
    return JsonObjectSet(jObject, sKey, JsonString(sValue));
}

json JsonObjectSetVector(json jObject, string sKey, vector vValue)
{
    return JsonObjectSet(jObject, sKey, JsonVector(vValue));
}

void JsonObjectSetBoolInplace(json jObject, string sKey, int bValue)
{
    JsonObjectSetInplace(jObject, sKey, JsonBool(bValue));
}

void JsonObjectSetFloatInplace(json jObject, string sKey, float fValue)
{
    JsonObjectSetInplace(jObject, sKey, JsonFloat(fValue));
}

void JsonObjectSetIntInplace(json jObject, string sKey, int nValue)
{
    JsonObjectSetInplace(jObject, sKey, JsonInt(nValue));
}

void JsonObjectSetLocationInplace(json jObject, string sKey, location lValue)
{
    JsonObjectSetInplace(jObject, sKey, JsonLocation(lValue));
}

void JsonObjectSetObjectRefInplace(json jObject, string sKey, object oValue)
{
    JsonObjectSetInplace(jObject, sKey, JsonObjectRef(oValue));
}

void JsonObjectSetStringInplace(json jObject, string sKey, string sValue)
{
    JsonObjectSetInplace(jObject, sKey, JsonString(sValue));
}

void JsonObjectSetVectorInplace(json jObject, string sKey, vector vValue)
{
    JsonObjectSetInplace(jObject, sKey, JsonVector(vValue));
}

// ----- Arrays ----------------------------------------------------------------

int JsonArrayGetType(json jArray, int nIndex)
{
    return JsonGetType(JsonArrayGet(jArray, nIndex));
}

json JsonArrayPop(json jArray)
{
    int nIndex = JsonGetLength(jArray);
    if (nIndex < 0)
        return JsonNull();

    json jRet = JsonArrayGet(jArray, nIndex);
    JsonArrayDelInplace(jArray, nIndex);
    return jRet;
}

json JsonArrayPopLeft(json jArray)
{
    if (!JsonGetLength(jArray))
        return JsonNull();

    json jRet = JsonArrayGet(jArray, 0);
    JsonArrayDelInplace(jArray, 0);
    return jRet;
}

int JsonArrayFind(json jArray, json jValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    json jIndex = JsonFind(jArray, jValue, nNth, nConditional);
    return JsonGetType(jIndex) == JSON_TYPE_INTEGER ? JsonGetInt(jIndex) : -1;
}

int JsonArrayFindBool(json jArray, int bValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayFind(jArray, JsonBool(bValue), nNth, nConditional);
}

int JsonArrayFindFloat(json jArray, float fValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayFind(jArray, JsonFloat(fValue), nNth, nConditional);
}

int JsonArrayFindInt(json jArray, int nValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayFind(jArray, JsonInt(nValue), nNth, nConditional);
}

int JsonArrayFindLocation(json jArray, location lValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayFind(jArray, JsonLocation(lValue), nNth, nConditional);
}

int JsonArrayFindObjectRef(json jArray, object oValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayFind(jArray, JsonObjectRef(oValue), nNth, nConditional);
}

int JsonArrayFindString(json jArray, string sValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayFind(jArray, JsonString(sValue), nNth, nConditional);
}

int JsonArrayFindVector(json jArray, vector vValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayFind(jArray, JsonVector(vValue), nNth, nConditional);
}

int JsonArrayContains(json jArray, json jValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonGetType(JsonFind(jArray, jValue, nNth, nConditional)) == JSON_TYPE_INTEGER;
}

int JsonArrayContainsBool(json jArray, int bValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayContains(jArray, JsonBool(bValue), nNth, nConditional);
}

int JsonArrayContainsFloat(json jArray, float fValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayContains(jArray, JsonFloat(fValue), nNth, nConditional);
}

int JsonArrayContainsInt(json jArray, int nValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayContains(jArray, JsonInt(nValue), nNth, nConditional);
}

int JsonArrayContainsLocation(json jArray, location lValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayContains(jArray, JsonLocation(lValue), nNth, nConditional);
}

int JsonArrayContainsObjectRef(json jArray, object oValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayContains(jArray, JsonObjectRef(oValue), nNth, nConditional);
}

int JsonArrayContainsString(json jArray, string sValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayContains(jArray, JsonString(sValue), nNth, nConditional);
}

int JsonArrayContainsVector(json jArray, vector vValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayContains(jArray, JsonVector(vValue), nNth, nConditional);
}

float JsonArrayGetFloat(json jArray, int nIndex)
{
    return JsonGetFloat(JsonArrayGet(jArray, nIndex));
}

int JsonArrayGetInt(json jArray, int nIndex)
{
    return JsonGetInt(JsonArrayGet(jArray, nIndex));
}

location JsonArrayGetLocation(json jArray, int nIndex)
{
    return JsonGetLocation(JsonArrayGet(jArray, nIndex));
}

object JsonArrayGetObjectRef(json jArray, int nIndex)
{
    return JsonGetObjectRef(JsonArrayGet(jArray, nIndex));
}

string JsonArrayGetString(json jArray, int nIndex)
{
    return JsonGetString(JsonArrayGet(jArray, nIndex));
}

vector JsonArrayGetVector(json jArray, int nIndex)
{
    return JsonGetVector(JsonArrayGet(jArray, nIndex));
}

json JsonArraySetBool(json jArray, int nIndex, int bValue)
{
    return JsonArraySet(jArray, nIndex, JsonBool(bValue));
}

json JsonArraySetFloat(json jArray, int nIndex, float fValue)
{
    return JsonArraySet(jArray, nIndex, JsonFloat(fValue));
}

json JsonArraySetInt(json jArray, int nIndex, int nValue)
{
    return JsonArraySet(jArray, nIndex, JsonInt(nValue));
}

json JsonArraySetLocation(json jArray, int nIndex, location lValue)
{
    return JsonArraySet(jArray, nIndex, JsonLocation(lValue));
}

json JsonArraySetObjectRef(json jArray, int nIndex, object oValue)
{
    return JsonArraySet(jArray, nIndex, JsonObjectRef(oValue));
}

json JsonArraySetString(json jArray, int nIndex, string sValue)
{
    return JsonArraySet(jArray, nIndex, JsonString(sValue));
}

json JsonArraySetVector(json jArray, int nIndex, vector vValue)
{
    return JsonArraySet(jArray, nIndex, JsonVector(vValue));
}

json JsonArrayInsertBool(json jArray, int bValue, int nIndex = -1)
{
    return JsonArrayInsert(jArray, JsonBool(bValue), nIndex);
}

json JsonArrayInsertFloat(json jArray, float fValue, int nIndex = -1)
{
    return JsonArrayInsert(jArray, JsonFloat(fValue), nIndex);
}

json JsonArrayInsertInt(json jArray, int nValue, int nIndex = -1)
{
    return JsonArrayInsert(jArray, JsonInt(nValue), nIndex);
}

json JsonArrayInsertLocation(json jArray, location lValue, int nIndex = -1)
{
    return JsonArrayInsert(jArray, JsonLocation(lValue), nIndex);
}

json jsonArrayInsertObjectRef(json jArray, object oValue, int nIndex = -1)
{
    return JsonArrayInsert(jArray, JsonObjectRef(oValue), nIndex);
}

json JsonArrayInsertString(json jArray, string sValue, int nIndex = -1)
{
    return JsonArrayInsert(jArray, JsonString(sValue), nIndex);
}

json JsonArrayInsertVector(json jArray, vector vValue, int nIndex = -1)
{
    return JsonArrayInsert(jArray, JsonVector(vValue), nIndex);
}

json JsonArrayInsertUnique(json jArray, json jValue, int nIndex = -1)
{
    return JsonArrayContains(jArray, jValue) ? jArray :
        JsonArrayInsert(jArray, jValue, nIndex);
}

json JsonArrayInsertUniqueBool(json jArray, int bValue, int nIndex = -1)
{
    return JsonArrayInsertUnique(jArray, JsonBool(bValue), nIndex);
}

json JsonArrayInsertUniqueFloat(json jArray, float fValue, int nIndex = -1)
{
    return JsonArrayInsertUnique(jArray, JsonFloat(fValue), nIndex);
}

json JsonArrayInsertUniqueInt(json jArray, int nValue, int nIndex = -1)
{
    return JsonArrayInsertUnique(jArray, JsonInt(nValue), nIndex);
}

json JsonArrayInsertUniqueLocation(json jArray, location lValue, int nIndex = -1)
{
    return JsonArrayInsertUnique(jArray, JsonLocation(lValue), nIndex);
}

json JsonArrayInsertUniqueObjectRef(json jArray, object oValue, int nIndex = -1)
{
    return JsonArrayInsertUnique(jArray, JsonObjectRef(oValue), nIndex);
}

json JsonArrayInsertUniqueString(json jArray, string sValue, int nIndex = -1)
{
    return JsonArrayInsertUnique(jArray, JsonString(sValue), nIndex);
}

json JsonArrayInsertUniqueVector(json jArray, vector vValue, int nIndex = -1)
{
    return JsonArrayInsertUnique(jArray, JsonVector(vValue), nIndex);
}

void JsonArraySetBoolInplace(json jArray, int nIndex, int bValue)
{
    JsonArraySetInplace(jArray, nIndex, JsonBool(bValue));
}

void JsonArraySetFloatInplace(json jArray, int nIndex, float fValue)
{
    JsonArraySetInplace(jArray, nIndex, JsonFloat(fValue));
}

void JsonArraySetIntInplace(json jArray, int nIndex, int nValue)
{
    JsonArraySetInplace(jArray, nIndex, JsonInt(nValue));
}

void JsonArraySetLocationInplace(json jArray, int nIndex, location lValue)
{
    JsonArraySetInplace(jArray, nIndex, JsonLocation(lValue));
}

void JsonArraySetObjectRefInplace(json jArray, int nIndex, object oValue)
{
    JsonArraySetInplace(jArray, nIndex, JsonObjectRef(oValue));
}

void JsonArraySetStringInplace(json jArray, int nIndex, string sValue)
{
    JsonArraySetInplace(jArray, nIndex, JsonString(sValue));
}

void JsonArraySetVectorInplace(json jArray, int nIndex, vector vValue)
{
    JsonArraySetInplace(jArray, nIndex, JsonVector(vValue));
}

void JsonArrayInsertBoolInplace(json jArray, int bValue, int nIndex = -1)
{
    JsonArrayInsertInplace(jArray, JsonBool(bValue), nIndex);
}

void JsonArrayInsertFloatInplace(json jArray, float fValue, int nIndex = -1)
{
    JsonArrayInsertInplace(jArray, JsonFloat(fValue), nIndex);
}

void JsonArrayInsertIntInplace(json jArray, int nValue, int nIndex = -1)
{
    JsonArrayInsertInplace(jArray, JsonInt(nValue), nIndex);
}

void JsonArrayInsertLocationInplace(json jArray, location lValue, int nIndex = -1)
{
    JsonArrayInsertInplace(jArray, JsonLocation(lValue), nIndex);
}

void jsonArrayInsertObjectRefInplace(json jArray, object oValue, int nIndex = -1)
{
    JsonArrayInsertInplace(jArray, JsonObjectRef(oValue), nIndex);
}

void JsonArrayInsertStringInplace(json jArray, string sValue, int nIndex = -1)
{
    JsonArrayInsertInplace(jArray, JsonString(sValue), nIndex);
}

void JsonArrayInsertVectorInplace(json jArray, vector vValue, int nIndex = -1)
{
    JsonArrayInsertInplace(jArray, JsonVector(vValue), nIndex);
}

void JsonArrayInsertUniqueInplace(json jArray, json jValue, int nIndex = -1)
{
    if (!JsonArrayContains(jArray, jValue))
        JsonArrayInsertInplace(jArray, jValue, nIndex);
}

void JsonArrayInsertUniqueBoolInplace(json jArray, int bValue, int nIndex = -1)
{
    JsonArrayInsertUniqueInplace(jArray, JsonBool(bValue), nIndex);
}

void JsonArrayInsertUniqueFloatInplace(json jArray, float fValue, int nIndex = -1)
{
    JsonArrayInsertUniqueInplace(jArray, JsonFloat(fValue), nIndex);
}

void JsonArrayInsertUniqueIntInplace(json jArray, int nValue, int nIndex = -1)
{
    JsonArrayInsertUniqueInplace(jArray, JsonInt(nValue), nIndex);
}

void JsonArrayInsertUniqueLocationInplace(json jArray, location lValue, int nIndex = -1)
{
    JsonArrayInsertUniqueInplace(jArray, JsonLocation(lValue), nIndex);
}

void JsonArrayInsertUniqueObjectRefInplace(json jArray, object oValue, int nIndex = -1)
{
    JsonArrayInsertUniqueInplace(jArray, JsonObjectRef(oValue), nIndex);
}

void JsonArrayInsertUniqueStringInplace(json jArray, string sValue, int nIndex = -1)
{
    JsonArrayInsertUniqueInplace(jArray, JsonString(sValue), nIndex);
}

void JsonArrayInsertUniqueVectorInplace(json jArray, vector vValue, int nIndex = -1)
{
    JsonArrayInsertUniqueInplace(jArray, JsonVector(vValue), nIndex);
}

json JsonArrayRemove(json jArray, json jValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    json jIndex = JsonFind(jArray, jValue, nNth, nConditional);
    if (JsonGetType(jIndex) == JSON_TYPE_INTEGER)
        jArray = JsonArrayDel(jArray, JsonGetInt(jIndex));
    return jArray;
}

json JsonArrayRemoveBool(json jArray, int bValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayRemove(jArray, JsonBool(bValue), nNth, nConditional);
}

json JsonArrayRemoveFloat(json jArray, float fValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayRemove(jArray, JsonFloat(fValue), nNth, nConditional);
}

json JsonArrayRemoveInt(json jArray, int nValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayRemove(jArray, JsonInt(nValue), nNth, nConditional);
}

json JsonArrayRemoveLocation(json jArray, location lValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayRemove(jArray, JsonLocation(lValue), nNth, nConditional);
}

json JsonArrayRemoveObjectRef(json jArray, object oValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayRemove(jArray, JsonObjectRef(oValue), nNth, nConditional);
}

json JsonArrayRemoveString(json jArray, string sValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayRemove(jArray, JsonString(sValue), nNth, nConditional);
}

json JsonArrayRemoveVector(json jArray, vector vValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayRemove(jArray, JsonVector(vValue), nNth, nConditional);
}

json JsonArrayRemoveAll(json jArray, json jValue, int nConditional = JSON_FIND_EQUAL)
{
    json jIndex = JsonFind(jArray, jValue, 0, nConditional);
    while (JsonGetType(jIndex) == JSON_TYPE_INTEGER)
    {
        jArray = JsonArrayDel(jArray, JsonGetInt(jIndex));
        jIndex = JsonFind(jArray, jValue, 0, nConditional);
    }

    return jArray;
}

json JsonArrayRemoveAllBool(json jArray, int bValue, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayRemoveAll(jArray, JsonBool(bValue), nConditional);
}

json JsonArrayRemoveAllFloat(json jArray, float fValue, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayRemoveAll(jArray, JsonFloat(fValue), nConditional);
}

json JsonArrayRemoveAllInt(json jArray, int nValue, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayRemoveAll(jArray, JsonInt(nValue), nConditional);
}

json JsonArrayRemoveAllLocation(json jArray, location lValue, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayRemoveAll(jArray, JsonLocation(lValue), nConditional);
}

json JsonArrayRemoveAllObjectRef(json jArray, object oValue, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayRemoveAll(jArray, JsonObjectRef(oValue), nConditional);
}

json JsonArrayRemoveAllString(json jArray, string sValue, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayRemoveAll(jArray, JsonString(sValue), nConditional);
}

json JsonArrayRemoveAllVector(json jArray, vector vValue, int nConditional = JSON_FIND_EQUAL)
{
    return JsonArrayRemoveAll(jArray, JsonVector(vValue), nConditional);
}

void JsonArrayRemoveInplace(json jArray, json jValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    json jIndex = JsonFind(jArray, jValue, nNth, nConditional);
    if (JsonGetType(jIndex) == JSON_TYPE_INTEGER)
        JsonArrayDelInplace(jArray, JsonGetInt(jIndex));
}

void JsonArrayRemoveBoolInplace(json jArray, int bValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    JsonArrayRemoveInplace(jArray, JsonBool(bValue), nNth, nConditional);
}

void JsonArrayRemoveFloatInplace(json jArray, float fValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    JsonArrayRemoveInplace(jArray, JsonFloat(fValue), nNth, nConditional);
}

void JsonArrayRemoveIntInplace(json jArray, int nValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    JsonArrayRemoveInplace(jArray, JsonInt(nValue), nNth, nConditional);
}

void JsonArrayRemoveLocationInplace(json jArray, location lValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    JsonArrayRemoveInplace(jArray, JsonLocation(lValue), nNth, nConditional);
}

void JsonArrayRemoveObjectRefInplace(json jArray, object oValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    JsonArrayRemoveInplace(jArray, JsonObjectRef(oValue), nNth, nConditional);
}

void JsonArrayRemoveStringInplace(json jArray, string sValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    JsonArrayRemoveInplace(jArray, JsonString(sValue), nNth, nConditional);
}

void JsonArrayRemoveVectorInplace(json jArray, vector vValue, int nNth = 0, int nConditional = JSON_FIND_EQUAL)
{
    JsonArrayRemoveInplace(jArray, JsonVector(vValue), nNth, nConditional);
}

void JsonArrayRemoveAllInplace(json jArray, json jValue, int nConditional = JSON_FIND_EQUAL)
{
    json jIndex = JsonFind(jArray, jValue, 0, nConditional);
    while (JsonGetType(jIndex) == JSON_TYPE_INTEGER)
    {
        JsonArrayDelInplace(jArray, JsonGetInt(jIndex));
        jIndex = JsonFind(jArray, jValue, 0, nConditional);
    }
}

void JsonArrayRemoveAllBoolInplace(json jArray, int bValue, int nConditional = JSON_FIND_EQUAL)
{
    JsonArrayRemoveAllInplace(jArray, JsonBool(bValue), nConditional);
}

void JsonArrayRemoveAllFloatInplace(json jArray, float fValue, int nConditional = JSON_FIND_EQUAL)
{
    JsonArrayRemoveAllInplace(jArray, JsonFloat(fValue), nConditional);
}

void JsonArrayRemoveAllIntInplace(json jArray, int nValue, int nConditional = JSON_FIND_EQUAL)
{
    JsonArrayRemoveAllInplace(jArray, JsonInt(nValue), nConditional);
}

void JsonArrayRemoveAllLocationInplace(json jArray, location lValue, int nConditional = JSON_FIND_EQUAL)
{
    JsonArrayRemoveAllInplace(jArray, JsonLocation(lValue), nConditional);
}

void JsonArrayRemoveAllObjectRefInplace(json jArray, object oValue, int nConditional = JSON_FIND_EQUAL)
{
    JsonArrayRemoveAllInplace(jArray, JsonObjectRef(oValue), nConditional);
}

void JsonArrayRemoveAllStringInplace(json jArray, string sValue, int nConditional = JSON_FIND_EQUAL)
{
    JsonArrayRemoveAllInplace(jArray, JsonString(sValue), nConditional);
}

void JsonArrayRemoveAllVectorInplace(json jArray, vector vValue, int nConditional = JSON_FIND_EQUAL)
{
    JsonArrayRemoveAllInplace(jArray, JsonVector(vValue), nConditional);
}

// ----- Patch Builders --------------------------------------------------------

json JsonPatchAdd(string sPath, json jValue)
{
    json jRet = JsonObject();
    JsonObjectSetStringInplace(jRet, "op", "add");
    JsonObjectSetStringInplace(jRet, "path", sPath);
    JsonObjectSetInplace(jRet, "value", jValue);
    return jRet;
}

json JsonPatchRemove(string sPath)
{
    json jRet = JsonObject();
    JsonObjectSetStringInplace(jRet, "op", "remove");
    JsonObjectSetStringInplace(jRet, "path", sPath);
    return jRet;
}

json JsonPatchReplace(string sPath, json jValue)
{
    json jRet = JsonObject();
    JsonObjectSetStringInplace(jRet, "op", "replace");
    JsonObjectSetStringInplace(jRet, "path", sPath);
    JsonObjectSetInplace(jRet, "value", jValue);
    return jRet;
}

json JsonPatchCopy(string sFrom, string sPath)
{
    json jRet = JsonObject();
    JsonObjectSetStringInplace(jRet, "op", "copy");
    JsonObjectSetStringInplace(jRet, "from", sFrom);
    JsonObjectSetStringInplace(jRet, "path", sPath);
    return jRet;
}

json JsonPatchMove(string sFrom, string sPath)
{
    json jRet = JsonObject();
    JsonObjectSetStringInplace(jRet, "op", "move");
    JsonObjectSetStringInplace(jRet, "from", sFrom);
    JsonObjectSetStringInplace(jRet, "path", sPath);
    return jRet;
}

json JsonPatchTest(string sPath, json jValue)
{
    json jRet = JsonObject();
    JsonObjectSetStringInplace(jRet, "op", "test");
    JsonObjectSetStringInplace(jRet, "path", sPath);
    JsonObjectSetInplace(jRet, "value", jValue);
    return jRet;
}
