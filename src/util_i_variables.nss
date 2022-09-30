// -----------------------------------------------------------------------------
//    File: util_i_variables.nss
//  System: PW Administration (data management)
// -----------------------------------------------------------------------------
// Description:
//  Include for primary data control functions.
// -----------------------------------------------------------------------------

/// @details The functions in this include are meant to complement and extend
/// the game's basic variable handling functions, such as GetLocalInt() and
/// SetLocalString().  These functions allow variable storage in the module's
/// volatile sqlite database, the module's persistent campaign database, and the
/// player's sqlite database.  Configuration option for this utility can be
/// set in `util_c_variables`.
///
/// Concepts:
///     - Tag: Any Set, Increment, Decrement or Append function allows a variable
///         to be tagged with a string value of any composition or length.  This
///         tag is designed to be used to group values for future delete
///         operations, but may be used for any other purpose.  This is an
///         example of deleting variable en masse.
///
///         ```nwscript
///         // Set the initial values.
///         SetModuleInt("VARIABLE_1", 1, "my_test_event");
///         SetModuleInt("VARIABLE_2", 2, "my_test_event");
///         SetModuleString("VARIABLE_1, "my_test_string", "my_test_event");
///
///         // When the variables are no longer needed, delete all of the
///         // variables at once.
///         DeleteModuleVariablesByTag("my_test_event");
///         ```
///
///     - Advanced Usage:  There are several functions which allow criteria
///         to be specified to retrieve or delete variables.  These criteria
///         allow the use of bitmasked types and glob expressions.
///             nType - Can be a single variable type, such as
///                 VARIABLE_TYPE_INT, or a bitmasked set of variable types,
///                 such as VARIABLE_TYPE_INT | VARIABLE_TYPE_FLOAT.  Other
///                 normal bitwise operators are also allowed.  To select
///                 all variables types except integer, the value can be
///                 passed as ~VARIABLE_TYPE_INT.  Pass 0 or VARIABLE_TYPE_NONE
///                 to ignore variable types.
///             sVarName - Can be an exact varname as previously set, or
///                 will accept any wildcards or sets allowed by glob:
///                     **Glob operations are case-senstive**
///                     * - 0 or more characters
///                     ? - A single character
///                     [a-j] - Any single character in the range a-j
///                     [a-zA-Z] - Any single upper or lowercase letter
///                     [0-9] - Any single digit
///                     [^cde] - Any single character not in [cde]
///                 Pass "" to ignore varnames.
///             sTag - Can be an exact tag as previously set, or will accept
///                 any wildcards or sets allowed by glob.  See previous
///                 examples for sVarName.  Pass "" to ignore tags.
///             nTime - Filter results by timestamp.  A timestamp is set on
///                 the variable anytime a variable is inserted or updated.
///                 If nTime is negative, the system will match all variables
///                 set before nTime.  If nTime is positive, the system will
///                 match all variables set after nTime.  Omitting nTime or
///                 pass 0 to ignore timestamps.

#include "util_i_lists"
#include "util_c_variables"

// -----------------------------------------------------------------------------
//                                  Constants
// -----------------------------------------------------------------------------

const int VARIABLE_TYPE_NONE         = 0x00;
const int VARIABLE_TYPE_INT          = 0x01;
const int VARIABLE_TYPE_FLOAT        = 0x02;
const int VARIABLE_TYPE_STRING       = 0x04;
const int VARIABLE_TYPE_OBJECT       = 0x08;
const int VARIABLE_TYPE_VECTOR       = 0x10;
const int VARIABLE_TYPE_LOCATION     = 0x20;
const int VARIABLE_TYPE_JSON         = 0x40;
const int VARIABLE_TYPE_SERIALIZED   = 0x80;
const int VARIABLE_TYPE_ALL          = 0xff;

const string VARIABLE_OBJECT   = "VARIABLE:VOLATILE";
const string VARIABLE_CAMPAIGN = "VARIABLE:CAMPAIGN";

// TODO superfluous with .35 LOCATION_INVALID update?
// Delete once .35 is stable and nwnsc has been udpated.
// Udpate GetModuleSerialized() signature with LOCATION_INVALID?
location LOCATION_INVALID = Location(OBJECT_INVALID, Vector(), 0.0);

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Creates a variable table in oObject's database.
/// @param oObject Optional object reference.  If passed, should
///     be a PC or the module (i.e. GetModule()).  For the
///     campaign database, pass OBJECT_INVALID or omit.
/// @note This function is never required to be called separately
///     during OnModuleLoad.  Table creation is handled during
///     the variable setting process.
void CreateVariableTable(object oObject = OBJECT_INVALID);

// -----------------------------------------------------------------------------
//                               Module Database
// -----------------------------------------------------------------------------

/// @brief Set a variable into the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param nValue Value of the variable.
/// @param sTag Optional tag reference.
void SetModuleInt(string sVarName, int nValue, string sTag = "");

/// @brief Set a variable into the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param fValue Value of the variable.
/// @param sTag Optional tag reference.
void SetModuleFloat(string sVarName, float fValue, string sTag = "");

/// @brief Set a variable into the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param sValue Value of the variable.
/// @param sTag Optional tag reference.
void SetModuleString(string sVarName, string sValue, string sTag = "");

/// @brief Set a variable into the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param oValue Value of the variable.
/// @param sTag Optional tag reference.
void SetModuleObject(string sVarName, object oValue, string sTag = "");

/// @brief Set a serialized object into the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param oValue Value of the variable.
/// @param sTag Optional tag reference.
/// @note This function will serialize the passed object.  To store an object by
///     reference, use SetModuleObject().
void SetModuleSerialized(string sVarName, object oValue, string sTag = "");

/// @brief Set a variable into the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param lValue Value of the variable.
/// @param sTag Optional tag reference.
void SetModuleLocation(string sVarName, location lValue, string sTag = "");

/// @brief Set a variable into the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param vValue Value of the variable.
/// @param sTag Optional tag reference.
void SetModuleVector(string sVarName, vector vValue, string sTag = "");

/// @brief Set a variable into the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param jValue Value of the variable.
/// @param sTag Optional tag reference.
void SetModuleJson(string sVarName, json jValue, string sTag = "");

/// @brief Set a previously set variable's tag to sTag.
/// @param nType VARIABLE_TYPE_* constant.
/// @param sVarName Name of the variable.
/// @param sTag Tag reference.
void SetModuleVariableTag(int nType, string sVarName, string sTag);

/// @brief Retrieve a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise 0.
int GetModuleInt(string sVarName);

/// @brief Retrieve a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise 0.0.
float GetModuleFloat(string sVarName);

/// @brief Retrieve a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise "".
string GetModuleString(string sVarName);

/// @brief Retrieve a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise OBJECT_INVALID.
object GetModuleObject(string sVarName);

/// @brief Retrieve and create a serialized object from the module's
///     volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param l Location to create the deserialized object.
/// @param oTarget Target object on which to create the deserialized object.
/// @returns The requested serialized object, if found, otherwise
///     OBJECT_INVALID.
/// @note If oTarget is passed and has inventory, the retrieved object
///     will be created in oTarget's inventory, otherwise it will be created
///     at location l.
object GetModuleSerialized(string sVarName, location l, object oTarget = OBJECT_INVALID);

/// @brief Retrieve a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise LOCATION_INVALID.
location GetModuleLocation(string sVarName);

/// @brief Retrieve a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise Vector().
vector GetModuleVector(string sVarName);

/// @brief Retrieve a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise JsonNull().
json GetModuleJson(string sVarName);

/// @brief Retrieve the tag associated with a variable.
/// @param nType VARIABLE_TYPE_* constant.
/// @param sVarName Name of the variable.
string GetModuleVariableTag(int nType, string sVarName);

/// @brief Returns a json array of key-value pairs.
/// @param nType VARIABLE_TYPE_*, accepts bitmasked values.
/// @param sVarName Variable name pattern, accepts glob patterns, sets
///     and wildcards.
/// @param sTag Tag pattern, accepts glob patterns, sets and wildcards.
/// @param nTime A positive value will filter for timestamps after
///     nTime, a negative value will filter for timestamps before nTime.
/// @note If no parameters are passed, all variables will be returned.
/// @details This function will return an array of json objects containing
///     information about each variable found.  Each json object in the
///     array will contain the following key-value pairs:
///         tag: <tag> {string}
///         timestamp: <timestamp> {int} UNIX seconds
///         type: <type> {int} Reference to VARIABLE_TYPE_*
///         value: <value> {type} Type depends on type
///             -- objects will be returned as a string object id which
///                 can be used in StringToObject()
///             -- serialized objects will be returned as their json
///                 representation and can be used in JsonToObject()
///         varname: <varname> {string}
json GetModuleVariablesByPattern(int nType = VARIABLE_TYPE_ALL, string sVarName = "",
                                 string sTag = "", int nTime = 0);

/// @brief Delete a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
int DeleteModuleInt(string sVarName);

/// @brief Delete a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
float DeleteModuleFloat(string sVarName);

/// @brief Delete a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
string DeleteModuleString(string sVarName);

/// @brief Delete a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
object DeleteModuleObject(string sVarName);

/// @brief Delete a serialized object from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
void DeleteModuleSerialized(string sVarName);

/// @brief Delete a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
location DeleteModuleLocation(string sVarName);

/// @brief Delete a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
vector DeleteModuleVector(string sVarName);

/// @brief Delete a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
json DeleteModuleJson(string sVarName);

/// @brief Deletes all variables from the module's volatile sqlite database.
/// @warning Calling this method will result in all variables in the module's
///     volatile sqlite database being deleted without additional warning.
void DeleteModuleVariables();

/// @brief Delets all variables from the module's volatile sqlite database
///     with variable name sVarName.
/// @param sVarName Name of the variable.
void DeleteModuleVariableByName(string sVarName);

/// @brief Deletes all variables from the module's volatile sqlite database
///     tagged with sTag.
/// @param sTag Tag reference.
void DeleteModuleVariablesByTag(string sTag);

/// @brief Deletes all variables from the module's volatile sqlite database
///     of type nType.
/// @param nType Type of variable (VARIABLE_TYPE_*) to delete.  Multiple
///     variable types can be passed with bitwise operations.  For example,
///     to delete all integers and floats in the database:
///     DeleteModuleVariablesByType(VARIABLE_TYPE_INTEGER | VARIABLE_TYPE_FLOAT);
void DeleteModuleVariablesByType(int nType);

/// @brief Deletes all variables from the module's volatile sqlite database
///     which were added or updated before nTime.
/// @param nTime Time, in unix seconds, before which to delete variables.
void DeleteModuleVariablesBefore(int nTime);

/// @brief Deletes all variables from the module's volatile sqlite database
///     which were added or updated after nTime.
/// @param nTime Time, in unix seconds, after which to delete variables.
void DeleteModuleVariablesAfter(int nTime);

/// @brief Deletes all variables from the module's volatile sqlite database
///     that match the parameter criteria.
/// @param nType Bitwise VARIABLE_TYPE_*.
/// @param sVarName Variable name pattern, accepts glob patterns, sets
///     and wildcards.
/// @param sTag Tag pattern, accepts glob patterns, sets and wildcards.
/// @param nTime A positive value will filter for timestamps after
///     nTime, a negative value will filter for timestamps before nTime.
/// @note If no parameters are passed, no variables will be returned.
/// @warning Calling this method without passing any parameters will result
///     in all variables in the module's volatile sqlite database being
///     deleted without additional warning.
void DeleteModuleVariablesByPattern(int nType = VARIABLE_TYPE_NONE, string sVarName = "",
                                    string sTag = "", int nTime = 0);

/// @brief Increments an integer variable in the module's volatile sqlite
///     database by nIncrement. If the variable doesn't exist, it will be
///     initialized to 0 before incrementing.
/// @param sVarName Name of the variable.
/// @param nIncrement Amount to increment the variable by.
/// @param sTag Optional tag reference.  Only used if the variable was not
///      previously set.
/// @returns The value of the variable after incrementing.
/// @note nIncrement is expected to be positive, however, this method will
///     accept a negative value for nIncrement and will decrement the variable
///     value.
int IncrementModuleInt(string sVarName, int nIncrement = 1, string sTag = "");

/// @brief Decrements an integer variable in the module's volatile sqlite
///     database by nDecrement. If the variable doesn't exist, it will be
///     initialized to 0 before decrementing.
/// @param sVarName Name of the variable.
/// @param nDecrement Amount to increment the variable by.
/// @param sTag Optional tag reference.  Only used if the variable was not
///     previously set.
/// @returns The value of the variable after decrementing.
/// @note nDecrement is expected to be negative.  If nDecrement is positive,
///     this method will decrement the variable by nDecrement and will not
///     fallback to incrementing behavior.
int DecrementModuleInt(string sVarName, int nDecrement = -1, string sTag = "");

/// @brief Increments an float variable in the module's volatile sqlite
///     database by nIncrement. If the variable doesn't exist, it will be
///     initialized to 0.0 before incrementing.
/// @param sVarName Name of the variable.
/// @param fIncrement Amount to increment the variable by.
/// @param sTag Optional tag reference.  Only used if the variable was not
///     previously set.
/// @returns The value of the variable after incrementing.
/// @note nIncrement is expected to be positing, however, this method will
///     accept a negative value for nIncrement and will decrement the variable
///     value.
float IncrementModuleFloat(string sVarName, float fIncrement = 1.0, string sTag = "");

/// @brief Decrements an float variable in the module's volatile sqlite
///     database by nDecrement. If the variable doesn't exist, it will be
///     initialized to 0.0 before decrementing.
/// @param sVarName Name of the variable.
/// @param fDecrement Amount to increment the variable by.
/// @param sTag Optional tag reference.  Only used if the variable was not
///     previously set.
/// @returns The value of the variable after decrementing.
/// @note nDecrement is expected to be negative.  If nDecrement is a positive,
///     this method will decrement the variable by nDecrement and will not
///     fallback to incrementing behavior.
float DecrementModuleFloat(string sVarName, float fDecrement = -1.0, string sTag = "");

/// @brief Appends sAppend to the end of a string variable in the module's
///     volatile sqlite database. If the variable doesn't exist, it will be
///     initialized to "" before appending.
/// @param sVarName Name of the variable.
/// @param sAppend Value to append.
/// @param sTag Optional tag reference.  Only used if the variable was not
///     previously set.
/// @returns The value of the variable after appending.
string AppendModuleString(string sVarName, string sAppend, string sTag = "");

// -----------------------------------------------------------------------------
//                               Player Database
// -----------------------------------------------------------------------------

/// @brief Set a variable into the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param nValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPlayerInt(object oPlayer, string sVarName, int nValue, string sTag = "");

/// @brief Set a variable into the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param fValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPlayerFloat(object oPlayer, string sVarName, float fValue, string sTag = "");

/// @brief Set a variable into the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param sValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPlayerString(object oPlayer, string sVarName, string sValue, string sTag = "");

/// @brief Set a variable into the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param oValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPlayerObject(object oPlayer, string sVarName, object oValue, string sTag = "");

/// @brief Set a serialized object into the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param oValue Value of the variable.
/// @param sTag Optional tag reference.
/// @note This function will serialize the passed object.  To store an object by
///     reference, use SetPlayerObject().
void SetPlayerSerialized(object oPlayer, string sVarName, object oValue, string sTag = "");

/// @brief Set a variable into the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param lValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPlayerLocation(object oPlayer, string sVarName, location lValue, string sTag = "");

/// @brief Set a variable into the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param vValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPlayerVector(object oPlayer, string sVarName, vector vValue, string sTag = "");

/// @brief Set a variable into the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param jValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPlayerJson(object oPlayer, string sVarName, json jValue, string sTag = "");

/// @brief Set a previously set variable's tag to sTag.
/// @param oPlayer Player object reference.
/// @param nType VARIABLE_TYPE_* constant.
/// @param sVarName Name of the variable.
/// @param sTag Tag reference.
void SetPlayerVariableTag(object oPlayer, int nType, string sVarName, string sTag);

/// @brief Retrieve a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise 0.
int GetPlayerInt(object oPlayer, string sVarName);

/// @brief Retrieve a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise 0.0.
float GetPlayerFloat(object oPlayer, string sVarName);

/// @brief Retrieve a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise "".
string GetPlayerString(object oPlayer, string sVarName);

/// @brief Retrieve a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise OBJECT_INVALID.
object GetPlayerObject(object oPlayer, string sVarName);

/// @brief Retrieve and create a serialized object from the player's sqlite
///     database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param l Location to create the deserialized object.
/// @param oTarget Target object on which to create the deserialized object.
/// @returns The requested serialized object, if found, otherwise
///     OBJECT_INVALID.
/// @note If oTarget is passed and has inventory, the retrieved object
///     will be created in oTarget's inventory, otherwise it will be created
///     at location l.
object GetPlayerSerialized(object oPlayer, string sVarName, location l, object oTarget = OBJECT_INVALID);

/// @brief Retrieve a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise LOCATION_INVALID.
location GetPlayerLocation(object oPlayer, string sVarName);

/// @brief Retrieve a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise Vector().
vector GetPlayerVector(object oPlayer, string sVarName);

/// @brief Retrieve a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise JsonNull().
json GetPlayerJson(object oPlayer, string sVarName);

/// @brief Retrieve the tag associated with a variable.
/// @param oPlayer Player object reference.
/// @param nType VARIABLE_TYPE_* constant.
/// @param sVarName Name of the variable.
string GetPlayerVariableTag(object oPlayer, int nType, string sVarName);

/// @brief Returns a json array of key-value pairs.
/// @param oPlayer Player object reference.
/// @param nType VARIABLE_TYPE_*, accepts bitmasked values.
/// @param sVarName Variable name pattern, accepts glob patterns, sets
///     and wildcards.
/// @param sTag Tag pattern, accepts glob patterns, sets and wildcards.
/// @param nTime A positive value will filter for timestamps after
///     nTime, a negative value will filter for timestamps before nTime.
/// @note If no parameters are passed, all variables will be returned.
/// @details This function will return an array of json objects containing
///     information about each variable found.  Each json object in the
///     array will contain the following key-value pairs:
///         tag: <tag> {string}
///         timestamp: <timestamp> {int} UNIX seconds
///         type: <type> {int} Reference to VARIABLE_TYPE_*
///         value: <value> {type} Type depends on type
///             -- objects will be returned as a string object id which
///                 can be used in StringToObject()
///             -- serialized objects will be returned as their json
///                 representation and can be used in JsonToObject()
///         varname: <varname> {string}
json GetPlayerVariablesByPattern(object oPlayer, int nType = VARIABLE_TYPE_ALL,
                                 string sVarName = "", string sTag = "", int nTime = 0);

/// @brief Delete a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
int DeletePlayerInt(object oPlayer, string sVarName);

/// @brief Delete a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
float DeletePlayerFloat(object oPlayer, string sVarName);

/// @brief Delete a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
string DeletePlayerString(object oPlayer, string sVarName);

/// @brief Delete a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
object DeletePlayerObject(object oPlayer, string sVarName);

/// @brief Delete a serialized object from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
void DeletePlayerSerialized(object oPlayer, string sVarName);

/// @brief Delete a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
location DeletePlayerLocation(object oPlayer, string sVarName);

/// @brief Delete a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
vector DeletePlayerVector(object oPlayer, string sVarName);

/// @brief Delete a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
json DeletePlayerJson(object oPlayer, string sVarName);

/// @brief Deletes all variables from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @warning Calling this method will result in all variables in the module's
///     volatile sqlite database being deleted without additional warning.
void DeletePlayerVariables(object oPlayer);

/// @brief Delets all variables from the player's sqlite database
///     with variable name sVarName.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
void DeletePlayerVariableByName(object oPlayer, string sVarName);

/// @brief Deletes all variables from the player's sqlite database
///     tagged with sTag.
/// @param oPlayer Player object reference.
/// @param sTag Tag reference.
void DeletePlayerVariablesByTag(object oPlayer, string sTag);

/// @brief Deletes all variables from the player's sqlite database
///     of type nType.
/// @param oPlayer Player object reference.
/// @param nType Type of variable (VARIABLE_TYPE_*) to delete.  Multiple
///     variable types can be passed with bitwise operations.  For example,
///     to delete all integers and floats in the database:
///     DeletePlayerVariablesByType(VARIABLE_TYPE_INTEGER | VARIABLE_TYPE_FLOAT);
void DeletePlayerVariablesByType(object oPlayer, int nType);

/// @brief Deletes all variables from the player's sqlite database
///     which were added or updated before nTime.
/// @param oPlayer Player object reference.
/// @param nTime Time, in unix seconds, before which to delete variables.
void DeletePlayerVariablesBefore(object oPlayer, int nTime);

/// @brief Deletes all variables from the player's sqlite database
///     which were added or updated after nTime.
/// @param oPlayer Player object reference.
/// @param nTime Time, in unix seconds, after which to delete variables.
void DeletePlayerVariablesAfter(object oPlayer, int nTime);

/// @brief Deletes all variables from the player's sqlite database
///     that match the parameter criteria.
/// @param oPlayer Player object reference.
/// @param nType Bitwise VARIABLE_TYPE_*.
/// @param sVarName Variable name pattern, accepts glob patterns, sets
///     and wildcards.
/// @param sTag Tag pattern, accepts glob patterns, sets and wildcards.
/// @param nTime A positive value will filter for timestamps after
///     nTime, a negative value will filter for timestamps before nTime.
/// @note If no parameters are passed, no variables will be returned.
/// @warning Calling this method without passing any parameters will result
///     in all variables in the player's sqlite database being
///     deleted without additional warning.
void DeletePlayerVariablesByPattern(object oPlayer, int nType = VARIABLE_TYPE_NONE,
                                    string sVarName = "", string sTag = "", int nTime = 0);

/// @brief Increments an integer variable in the player's sqlite database.
///     If the variable doesn't exist, it will be initialized to 0 before
///     incrementing.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param nIncrement Amount to increment the variable by.
/// @param sTag Optional tag reference.  Only used if the variable was not
///      previously set.
/// @returns The value of the variable after incrementing.
/// @note nIncrement is expected to be positive, however, this method will
///     accept a negative value for nIncrement and will decrement the variable
///     value.
int IncrementPlayerInt(object oPlayer, string sVarName, int nIncrement = 1, string sTag = "");

/// @brief Decrements an integer variable in the player's sqlite database.
///     If the variable doesn't exist, it will be initialized to 0 before
///     decrementing.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param nDecrement Amount to increment the variable by.
/// @param sTag Optional tag reference.  Only used if the variable was not
///     previously set.
/// @returns The value of the variable after decrementing.
/// @note nDecrement is expected to be negative.  If nDecrement is positive,
///     this method will decrement the variable by nDecrement and will not
///     fallback to incrementing behavior.
int DecrementPlayerInt(object oPlayer, string sVarName, int nDecrement = -1, string sTag = "");

/// @brief Increments an float variable in the player's sqlite database.
///     If the variable doesn't exist, it will be initialized to 0.0 before
///     incrementing.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param fIncrement Amount to increment the variable by.
/// @param sTag Optional tag reference.  Only used if the variable was not
///     previously set.
/// @returns The value of the variable after incrementing.
/// @note nIncrement is expected to be positing, however, this method will
///     accept a negative value for nIncrement and will decrement the variable
///     value.
float IncrementPlayerFloat(object oPlayer, string sVarName, float fIncrement = 1.0, string sTag = "");

/// @brief Decrements an float variable in the player's sqlite database.
///     If the variable doesn't exist, it will be initialized to 0.0 before
///     decrementing.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param fDecrement Amount to increment the variable by.
/// @param sTag Optional tag reference.  Only used if the variable was not
///     previously set.
/// @returns The value of the variable after decrementing.
/// @note nDecrement is expected to be negative.  If nDecrement is a positive,
///     this method will decrement the variable by nDecrement and will not
///     fallback to incrementing behavior.
float DecrementPlayerFloat(object oPlayer, string sVarName, float fDecrement = -1.0, string sTag = "");

/// @brief Appends sAppend to the end of a string variable in the player's
///     sqlite database.  If the variable doesn't exist, it will be
///     initialized to "" before appending.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param sAppend Value to append.
/// @param sTag Optional tag reference.  Only used if the variable was not
///     previously set.
/// @returns The value of the variable after appending.
string AppendPlayerString(object oPlayer, string sVarName, string sAppend, string sTag = "");

// -----------------------------------------------------------------------------
//                               Campaign Database
// -----------------------------------------------------------------------------

/// @brief Set a variable into the campaign database.
/// @param sVarName Name of the variable.
/// @param nValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPersistentInt(string sVarName, int nValue, string sTag = "");

/// @brief Set a variable into the campaign database.
/// @param sVarName Name of the variable.
/// @param fValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPersistentFloat(string sVarName, float fValue, string sTag = "");

/// @brief Set a variable into the campaign database.
/// @param sVarName Name of the variable.
/// @param sValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPersistentString(string sVarName, string sValue, string sTag = "");

/// @brief Set a variable into the campaign database.
/// @param sVarName Name of the variable.
/// @param oValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPersistentObject(string sVarName, object oValue, string sTag = "");

/// @brief Set a serialized object into the campaign database.
/// @param sVarName Name of the variable.
/// @param oValue Value of the variable.
/// @param sTag Optional tag reference.
/// @note This function will serialize the passed object.  To store an object by
///     reference, use SetPersistentObject().
void SetPersistentSerialized(string sVarName, object oValue, string sTag = "");

/// @brief Set a variable into the campaign database.
/// @param sVarName Name of the variable.
/// @param lValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPersistentLocation(string sVarName, location lValue, string sTag = "");

/// @brief Set a variable into the campaign database.
/// @param sVarName Name of the variable.
/// @param vValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPersistentVector(string sVarName, vector vValue, string sTag = "");

/// @brief Set a variable into the campaign database.
/// @param sVarName Name of the variable.
/// @param jValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPersistentJson(string sVarName, json jValue, string sTag = "");

/// @brief Set a previously set variable's tag to sTag.
/// @param nType VARIABLE_TYPE_* constant.
/// @param sVarName Name of the variable.
/// @param sTag Tag reference.
void SetPersistentVariableTag(int nType, string sVarName, string sTag);

/// @brief Retrieve a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise 0.
int GetPersistentInt(string sVarName);

/// @brief Retrieve a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise 0.0.
float GetPersistentFloat(string sVarName);

/// @brief Retrieve a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise "".
string GetPersistentString(string sVarName);

/// @brief Retrieve a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise OBJECT_INVALID.
object GetPersistentObject(string sVarName);

/// @brief Retrieve and create a serialized object from the campaign database.
/// @param sVarName Name of the variable.
/// @param l Location to create the deserialized object.
/// @param oTarget Target object on which to create the deserialized object.
/// @returns The requested serialized object, if found, otherwise
///     OBJECT_INVALID.
/// @note If oTarget is passed and has inventory, the retrieved object
///     will be created in oTarget's inventory, otherwise it will be created
///     at location l.
object GetPersistentSerialized(string sVarName, location l, object oTarget = OBJECT_INVALID);

/// @brief Retrieve a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise LOCATION_INVALID.
location GetPersistentLocation(string sVarName);

/// @brief Retrieve a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise Vector().
vector GetPersistentVector(string sVarName);

/// @brief Retrieve a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise JsonNull().
json GetPersistentJson(string sVarName);

/// @brief Retrieve the tag associated with a variable.
/// @param nType VARIABLE_TYPE_* constant.
/// @param sVarName Name of the variable.
string GetPersistentVariableTag(int nType, string sVarName);

/// @brief Returns a json array of key-value pairs.
/// @param nType VARIABLE_TYPE_*, accepts bitmasked values.
/// @param sVarName Variable name pattern, accepts glob patterns, sets
///     and wildcards.
/// @param sTag Tag pattern, accepts glob patterns, sets and wildcards.
/// @param nTime A positive value will filter for timestamps after
///     nTime, a negative value will filter for timestamps before nTime.
/// @note If no parameters are passed, all variables will be returned.
/// @details This function will return an array of json objects containing
///     information about each variable found.  Each json object in the
///     array will contain the following key-value pairs:
///         tag: <tag> {string}
///         timestamp: <timestamp> {int} UNIX seconds
///         type: <type> {int} Reference to VARIABLE_TYPE_*
///         value: <value> {type} Type depends on type
///             -- objects will be returned as a string object id which
///                 can be used in StringToObject()
///             -- serialized objects will be returned as their json
///                 representation and can be used in JsonToObject()
///         varname: <varname> {string}
json GetPersistentVariablesByPattern(int nType = VARIABLE_TYPE_ALL, string sVarName = "",
                                     string sTag = "", int nTime = 0);

/// @brief Delete a variable from the campaign database.
/// @param sVarName Name of the variable.
int DeletePersistentInt(string sVarName);

/// @brief Delete a variable from the campaign database.
/// @param sVarName Name of the variable.
float DeletePersistentFloat(string sVarName);

/// @brief Delete a variable from the campaign database.
/// @param sVarName Name of the variable.
string DeletePersistentString(string sVarName);

/// @brief Delete a variable from the campaign database.
/// @param sVarName Name of the variable.
object DeletePersistentObject(string sVarName);

/// @brief Delete a serialized object from the campaign database.
/// @param sVarName Name of the variable.
void DeletePersistentSerialized(string sVarName);

/// @brief Delete a variable from the campaign database.
/// @param sVarName Name of the variable.
location DeletePersistentLocation(string sVarName);

/// @brief Delete a variable from the campaign database.
/// @param sVarName Name of the variable.
vector DeletePersistentVector(string sVarName);

/// @brief Delete a variable from the campaign database.
/// @param sVarName Name of the variable.
json DeletePersistentJson(string sVarName);

/// @brief Deletes all variables from the campaign database.
/// @warning Calling this method will result in all variables in the campaign
///     database being deleted without additional warning.
void DeletePersistentVariables();

/// @brief Delets all variables from the campaign database with variable
///     name sVarName.
/// @param sVarName Name of the variable.
void DeletePersistentVariableByName(string sVarName);

/// @brief Deletes all variables from the campaign database tagged with sTag.
/// @param sTag Tag reference.
void DeletePersistentVariablesByTag(string sTag);

/// @brief Deletes all variables from the campaign database of type nType.
/// @param nType Type of variable (VARIABLE_TYPE_*) to delete.  Multiple
///     variable types can be passed with bitwise operations.  For example,
///     to delete all integers and floats in the database:
///     DeletePersistentVariablesByType(VARIABLE_TYPE_INTEGER | VARIABLE_TYPE_FLOAT);
void DeletePersistentVariablesByType(int nType);

/// @brief Deletes all variables from the campaign database which were added
///     or updated before nTime.
/// @param nTime Time, in unix seconds, before which to delete variables.
void DeletePersistentVariablesBefore(int nTime);

/// @brief Deletes all variables from the campaign database which were added
///     or updated after nTime.
/// @param nTime Time, in unix seconds, after which to delete variables.
void DeletePersistentVariablesAfter(int nTime);

/// @brief Deletes all variables from the campaign database that match the
///     parameter criteria.
/// @param nType Bitwise VARIABLE_TYPE_*.
/// @param sVarName Variable name pattern, accepts glob patterns, sets
///     and wildcards.
/// @param sTag Tag pattern, accepts glob patterns, sets and wildcards.
/// @param nTime A positive value will filter for timestamps after
///     nTime, a negative value will filter for timestamps before nTime.
/// @note If no parameters are passed, no variables will be returned.
/// @warning Calling this method without passing any parameters will result
///     in all variables in the campaign database being
///     deleted without additional warning.
void DeletePersistentVariablesByPattern(int nType = VARIABLE_TYPE_NONE, string sVarName = "",
                                        string sTag = "", int nTime = 0);

/// @brief Increments an integer variable in the campaign database by nIncrement.
///     If the variable doesn't exist, it will be initialized to 0 before
///     incrementing.
/// @param sVarName Name of the variable.
/// @param nIncrement Amount to increment the variable by.
/// @param sTag Optional tag reference.  Only used if the variable was not
///      previously set.
/// @returns The value of the variable after incrementing.
/// @note nIncrement is expected to be positive, however, this method will
///     accept a negative value for nIncrement and will decrement the variable
///     value.
int IncrementPersistentInt(string sVarName, int nIncrement = 1, string sTag = "");

/// @brief Decrements an integer variable in the campaign database by nDecrement.
///     If the variable doesn't exist, it will be initialized to 0 before
///     decrementing.
/// @param sVarName Name of the variable.
/// @param nDecrement Amount to increment the variable by.
/// @param sTag Optional tag reference.  Only used if the variable was not
///     previously set.
/// @returns The value of the variable after decrementing.
/// @note nDecrement is expected to be negative.  If nDecrement is positive,
///     this method will decrement the variable by nDecrement and will not
///     fallback to incrementing behavior.
int DecrementPersistentInt(string sVarName, int nDecrement = -1, string sTag = "");

/// @brief Increments an float variable in the campaign database by nIncrement.
///     If the variable doesn't exist, it will be initialized to 0.0 before
///     incrementing.
/// @param sVarName Name of the variable.
/// @param fIncrement Amount to increment the variable by.
/// @param sTag Optional tag reference.  Only used if the variable was not
///     previously set.
/// @returns The value of the variable after incrementing.
/// @note nIncrement is expected to be positing, however, this method will
///     accept a negative value for nIncrement and will decrement the variable
///     value.
float IncrementPersistentFloat(string sVarName, float fIncrement = 1.0, string sTag = "");

/// @brief Decrements an float variable in the campaign database by nDecrement.
///     If the variable doesn't exist, it will be initialized to 0.0 before
///     decrementing.
/// @param sVarName Name of the variable.
/// @param fDecrement Amount to increment the variable by.
/// @param sTag Optional tag reference.  Only used if the variable was not
///     previously set.
/// @returns The value of the variable after decrementing.
/// @note nDecrement is expected to be negative.  If nDecrement is a positive,
///     this method will decrement the variable by nDecrement and will not
///     fallback to incrementing behavior.
float DecrementPersistentFloat(string sVarName, float fDecrement = -1.0, string sTag = "");

/// @brief Appends sAppend to the end of a string variable in the campaign
///     database. If the variable doesn't exist, it will be initialized to ""
///     before appending.
/// @param sVarName Name of the variable.
/// @param sAppend Value to append.
/// @param sTag Optional tag reference.  Only used if the variable was not
///     previously set.
/// @returns The value of the variable after appending.
string AppendPersistentString(string sVarName, string sAppend, string sTag = "");

// -----------------------------------------------------------------------------
//                              Private Functions
// -----------------------------------------------------------------------------

/// @brief Returns the variable type as a string
/// @note For debug purposes only.
string _VariableTypeToString(int nType)
{
    if      (nType == VARIABLE_TYPE_INT)        return "INT";
    else if (nType == VARIABLE_TYPE_FLOAT)      return "FLOAT";
    else if (nType == VARIABLE_TYPE_STRING)     return "STRING";
    else if (nType == VARIABLE_TYPE_OBJECT)     return "OBJECT";
    else if (nType == VARIABLE_TYPE_VECTOR)     return "VECTOR";
    else if (nType == VARIABLE_TYPE_LOCATION)   return "LOCATION";
    else if (nType == VARIABLE_TYPE_JSON)       return "JSON";
    else if (nType == VARIABLE_TYPE_SERIALIZED) return "SERIALIZED";
    else if (nType == VARIABLE_TYPE_NONE)       return "NONE";
    else if (nType == VARIABLE_TYPE_ALL)        return "ALL";
    else                                        return "UNKNOWN";    
}

/// @brief Prepares an query against an object (module/player).  Ensures
///     appropriate tables have been created before attempting query.
sqlquery _PrepareQueryObject(object oObject, string sQuery)
{
    CreateVariableTable(oObject);
    return SqlPrepareQueryObject(oObject, sQuery);
}

/// @brief Prepares an query against an campaign database.  Ensures
///     appropriate tables have been created before attempting query.
sqlquery _PrepareQueryCampaign(string sQuery)
{
    CreateVariableTable();
    return SqlPrepareQueryCampaign(VARIABLE_CAMPAIGN_DATABASE, sQuery);
}

/// @brief Prepares a select query to retrieve a variable value stored
///     in any database.
sqlquery _PrepareVariableSelect(object oObject, int nType, string sVarName, int bCampaign)
{
    int bPC = GetIsPC(oObject);
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;

    string s = "SELECT value FROM " + sTable + " " +
                "WHERE type = @type " +
                    "AND varname = @varname;";

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    SqlBindInt   (q, "@type", nType);
    SqlBindString(q, "@varname", sVarName);
    return q;
}

sqlquery _PrepareTagSelect(object oObject, int nType, string sVarName, int bCampaign)
{
    int bPC = GetIsPC(oObject);
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;

    string s = "SELECT tag FROM " + sTable + " " +
                "WHERE type = @type " +
                    "AND varname = @varname;";

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    SqlBindInt   (q, "@type", nType);
    SqlBindString(q, "@varname", sVarName);
    return q;
}

/// @brief Prepares an insert query to stored a variable in any database.
sqlquery _PrepareVariableInsert(object oObject, int nType, string sVarName, string sTag, int bCampaign)
{
    int bPC = GetIsPC(oObject);
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;

    string s =  "INSERT INTO " + sTable + " " +
                    "(type, varname, value, tag, timestamp) " +
                "VALUES (@type, @varname, @value, @tag, strftime('%s','now')) " +
                "ON CONFLICT (type, varname) " +
                "DO UPDATE SET value = @value, " +
                    "tag = @tag, " +
                    "timestamp = strftime('%s','now');";

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    SqlBindInt   (q, "@type", nType);
    SqlBindString(q, "@varname", sVarName);
    SqlBindString(q, "@tag", sTag);
    return q;
}

sqlquery _PrepareTagUpdate(object oObject, int nType, string sVarName, string sTag, int bCampaign)
{
    int bPC = GetIsPC(oObject);
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;

    string s =  "UPDATE " + sTable + " " +
                "SET tag = @tag " +
                "WHERE type = @type " +
                    "AND varname = @varname;";

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    SqlBindInt   (q, "@type", nType);
    SqlBindString(q, "@varname", sVarName);
    SqlBindString(q, "@tag", sTag);
    return q;    
}

/// @brief Prepares an delete query to remove a variable stored in any database.
sqlquery _PrepareSimpleVariableDelete(object oObject, int nType, string sVarName, int bCampaign)
{
    int bPC = GetIsPC(oObject);
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;

    string s =  "DELETE FROM " + sTable + " " +
                "WHERE type = @type " +
                    "AND varname = @varname " +
                "RETURNING value;";

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    SqlBindInt   (q, "@type", nType);
    SqlBindString(q, "@varname", sVarName);
    return q;
}

/// @brief Prepares a complex delete query to remove multiple variables by criteria.
/// @param nType Bitwise VARIABLE_TYPE_*
/// @param sVarName Variable name pattern, accept glob patterns, sets and wildcards
/// @param sTag Tag pattern, accepts glob patterns, sets and wildcards
/// @param nTime A positive value will filter for timestamps after
///     nTime, a negative value will filter for timestamps before nTime.
/// @warning If no parameters are passed, this query will result in a simple "DELETE ALL"
///     and will delete all variables in oObject's database.
sqlquery _PrepareComplexVariableDelete(object oObject, int nType = VARIABLE_TYPE_NONE, string sVarName = "", 
                                       string sTag = "", int nTime = 0, int bCampaign = FALSE)
{
    int n, bPC = GetIsPC(oObject);
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;
    string sWhere =  (sVarName == "" ? "" : " $" + IntToString(++n) + " varname GLOB @varname");
           sWhere += (sTag == ""     ? "" : " $" + IntToString(++n) + " tag GLOB @tag");
           sWhere += (nType <= 0     ? "" : " $" + IntToString(++n) + " type & @type > 0");
           sWhere += (nTime == 0     ? "" : " $" + IntToString(++n) + " timestamp " + (nTime > 0 ? ">" : "<") + " @time");
    
    json jKeyWords = ListToJson("WHERE,AND,AND,AND");
    string s = "DELETE FROM " + sTable + sWhere + ";";
           s = SubstituteString(s, jKeyWords);

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    if (sVarName != "") SqlBindString(q, "@varname", sVarName);
    if (sTag != "")     SqlBindString(q, "@tag", sTag);
    if (nType > 0)      SqlBindInt   (q, "@type", nType);
    if (nTime != 0)     SqlBindInt   (q, "@time", abs(nTime));
    return q;
}

/// @brief Prepares a complex select query to retrieve multiple variables by criteria.
/// @param nType Bitwise VARIABLE_TYPE_*
/// @param sVarName Variable name pattern, accept glob patterns, sets and wildcards
/// @param sTag Tag pattern, accepts glob patterns, sets and wildcards
/// @param nTime A positive value will filter for timestamps after
///     nTime, a negative value will filter for timestamps before nTime.
/// @warning If no parameters are passed, this query will result in no variables being
///     retrieved.
sqlquery _PrepareComplexVariableSelect(object oObject, int nType = VARIABLE_TYPE_NONE, string sVarName = "", 
                                       string sTag = "", int nTime = 0, int bCampaign = FALSE)
{
    int n, bPC = GetIsPC(oObject);
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;
    string sWhere =  (sVarName == "" ? "" : " $" + IntToString(++n) + " varname GLOB @varname");
           sWhere += (sTag == ""     ? "" : " $" + IntToString(++n) + " tag GLOB @tag");
           sWhere += (nType <= 0     ? "" : " $" + IntToString(++n) + " type & @type > 0");
           sWhere += (nTime == 0     ? "" : " $" + IntToString(++n) + " timestamp " + (nTime > 0 ? ">" : "<") + " @time");
    
    json jKeyWords = ListToJson("WHERE,AND,AND,AND");
    string s = "SELECT type, varname, value, tag, timestamp FROM " + sTable + sWhere + ";";
           s = SubstituteString(s, jKeyWords);

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    if (sVarName != "") SqlBindString(q, "@varname", sVarName);
    if (sTag != "")     SqlBindString(q, "@tag", sTag);
    if (nType > 0)      SqlBindInt   (q, "@type", nType);
    if (nTime != 0)     SqlBindInt   (q, "@time", abs(nTime));
    return q;
}

/// @brief Wrapper for ComplexDelete
sqlquery _PrepareVariableDeleteAll(object oObject, string sTag, int bCampaign)
{
    return _PrepareComplexVariableDelete(oObject, 0, "", sTag, 0, bCampaign);
}

/// @brief Wrapper for ComplexDelete
sqlquery _PrepareVariableDeleteByName(object oObject, string sVarName, string sTag, int bCampaign)
{
    return _PrepareComplexVariableDelete(oObject, 0, sVarName, sTag, 0, bCampaign);
}

/// @brief Wrapper for ComplexDelete
sqlquery _PrepareVariableDeleteByType(object oObject, int nType, string sTag, int bCampaign)
{
    return _PrepareComplexVariableDelete(oObject, nType, "", sTag, 0, bCampaign);
}

/// @brief Wrapper for ComplexDelete
sqlquery _PrepareVariableDeleteByTime(object oObject, int nTime, string sTag, int bCampaign)
{
    return _PrepareComplexVariableDelete(oObject, 0, "", sTag, nTime, bCampaign);
}

/// @brief Increments/Decremenst an existing variable (int/float).  If the variable
///     does not exist, creates variables, then increments/decrements.
sqlquery _PrepareVariableIncrement(object oObject, int nType, string sVarName, string sTag, int bCampaign)
{
    int bPC = GetIsPC(oObject);
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;

    string s =  "INSERT INTO " + sTable + " " +
                    "(type, varname, value, tag, timestamp) " +
                "VALUES (@type, @varname, @value, @tag, strftime('%s','now')) " +
                "ON CONFLICT (type, varname) " +
                    "DO UPDATE SET value = value + @value, " +
                        "timestamp = strftime('%s','now') " +
                "RETURNING value;";

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    SqlBindInt   (q, "@type", nType);
    SqlBindString(q, "@varname", sVarName);
    SqlBindString(q, "@tag", sTag);
    return q;
}

/// @brief Appends a string to an existing variable.  If the variables does not
///     exist, creates the variable, then appends.
sqlquery _PrepareVariableAppend(object oObject, string sVarName, string sTag, int bCampaign)
{
    int bPC = GetIsPC(oObject);
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;

    string s =  "INSERT INTO " + sTable + " " +
                    "(type, varname, value, tag, timestamp) " +
                "VALUES (@type, @varname, @value, @tag, strftime('%s', 'now')) " +
                "ON CONFLICT (type, varname) " +
                    "DO UPDATE SET value = value || @value, " +
                        "timestamp = strftime('%s', 'now') " +
                "RETURNING value;";

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    SqlBindString(q, "@varname", sVarName);
    SqlBindString(q, "@tag", sTag);
    return q;
}

/// @brief Returns a json array of json objects containing variable metadata.
json _GetVariablesByPattern(sqlquery q)
{
    json jResult = JsonArray();
    json jInsert = JsonObject();

    while (SqlStep(q))
    {
        // Query fields: type, varname, value, tag, timestamp
        //                 0      1       2     3       4
        int nType = SqlGetInt(q, 0);

        jInsert = JsonObjectSet(jInsert, "type", JsonInt(nType));
        jInsert = JsonObjectSet(jInsert, "varname", JsonString(SqlGetString(q, 1)));
    
        json jValue;
        if (nType & (VARIABLE_TYPE_STRING | VARIABLE_TYPE_OBJECT))
            jValue = JsonString(SqlGetString(q, 2));
        else
            jValue = SqlGetJson(q, 2);

        jInsert = JsonObjectSet(jInsert, "value", jValue);
        jInsert = JsonObjectSet(jInsert, "tag", JsonString(SqlGetString(q, 3)));
        jInsert = JsonObjectSet(jInsert, "timestamp", SqlGetJson(q, 4));

        jResult = JsonArrayInsert(jResult, jInsert);
    }

    return jResult;
}

// -----------------------------------------------------------------------------
//                             Public Functions
// -----------------------------------------------------------------------------

void CreateVariableTable(object oObject = OBJECT_INVALID)
{
    string sVarName = VARIABLE_OBJECT;
    string sTable = VARIABLE_TABLE_MODULE;
    int bCampaign = oObject == OBJECT_INVALID;

    if (bCampaign)
    {
        sVarName = VARIABLE_CAMPAIGN;
        oObject = GetModule();
    }
    else if (GetIsPC(oObject))
        sTable = VARIABLE_TABLE_PC;
    else if (oObject != GetModule())
        return;

    if (GetLocalInt(oObject, sVarName))
        return;

    string s = "CREATE TABLE IF NOT EXISTS " + sTable + " (" +
        "type INTEGER, " +
        "varname TEXT, " +
        "value TEXT, " +
        "tag TEXT, " +
        "timestamp INTEGER, " +
        "PRIMARY KEY (type, varname));";

    sqlquery q;
    if (bCampaign)
        q = SqlPrepareQueryCampaign(VARIABLE_CAMPAIGN_DATABASE, s);
    else
        q = SqlPrepareQueryObject(oObject, s);

    SqlStep(q);
    SetLocalInt(oObject, sVarName, TRUE);
}

// SetModule* ------------------------------------------------------------------

void SetModuleInt(string sVarName, int nValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(GetModule(), VARIABLE_TYPE_INT, sVarName, sTag, FALSE);
    SqlBindInt(q, "@value", nValue);
    SqlStep(q);
}

void SetModuleFloat(string sVarName, float fValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(GetModule(), VARIABLE_TYPE_FLOAT, sVarName, sTag, FALSE);
    SqlBindFloat(q, "@value", fValue);
    SqlStep(q);
}

void SetModuleString(string sVarName, string sValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(GetModule(), VARIABLE_TYPE_STRING, sVarName, sTag, FALSE);
    SqlBindString(q, "@value", sValue);
    SqlStep(q);
}

void SetModuleObject(string sVarName, object oValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(GetModule(), VARIABLE_TYPE_OBJECT, sVarName, sTag, FALSE);
    SqlBindString(q, "@value", ObjectToString(oValue));
    SqlStep(q);
}

void SetModuleSerialized(string sVarName, object oValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(GetModule(), VARIABLE_TYPE_SERIALIZED, sVarName, sTag, FALSE);
    SqlBindJson(q, "@value", ObjectToJson(oValue, TRUE));
    SqlStep(q);
}

void SetModuleLocation(string sVarName, location lValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(GetModule(), VARIABLE_TYPE_LOCATION, sVarName, sTag, FALSE);
    SqlBindJson(q, "@value", LocationToJson(lValue));
    SqlStep(q);
}

void SetModuleVector(string sVarName, vector vValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(GetModule(), VARIABLE_TYPE_VECTOR, sVarName, sTag, FALSE);
    SqlBindJson(q, "@value", VectorToJson(vValue));
    SqlStep(q);
}

void SetModuleJson(string sVarName, json jValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(GetModule(), VARIABLE_TYPE_JSON, sVarName, sTag, FALSE);
    SqlBindJson(q, "@value", jValue);
    SqlStep(q);
}

void SetModuleVariableTag(int nType, string sVarName, string sTag)
{
    SqlStep(_PrepareTagUpdate(GetModule(), nType, sVarName, sTag, FALSE));
}

// GetModule* ------------------------------------------------------------------

int GetModuleInt(string sVarName)
{
    sqlquery q = _PrepareVariableSelect(GetModule(), VARIABLE_TYPE_INT, sVarName, FALSE);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

float GetModuleFloat(string sVarName)
{
    sqlquery q = _PrepareVariableSelect(GetModule(), VARIABLE_TYPE_FLOAT, sVarName, FALSE);
    return SqlStep(q) ? SqlGetFloat(q, 0) : 0.0;
}

string GetModuleString(string sVarName)
{
    sqlquery q = _PrepareVariableSelect(GetModule(), VARIABLE_TYPE_STRING, sVarName, FALSE);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

object GetModuleObject(string sVarName)
{
    sqlquery q = _PrepareVariableSelect(GetModule(), VARIABLE_TYPE_OBJECT, sVarName, FALSE);
    return SqlStep(q) ? StringToObject(SqlGetString(q, 0)) : OBJECT_INVALID;
}

object GetModuleSerialized(string sVarName, location l, object oTarget = OBJECT_INVALID)
{
    sqlquery q = _PrepareVariableSelect(GetModule(), VARIABLE_TYPE_SERIALIZED, sVarName, FALSE);
    return SqlStep(q) ? JsonToObject(SqlGetJson(q, 0), l, oTarget, TRUE) : OBJECT_INVALID;
}

location GetModuleLocation(string sVarName)
{
    sqlquery q = _PrepareVariableSelect(GetModule(), VARIABLE_TYPE_LOCATION, sVarName, FALSE);
    return SqlStep(q) ? JsonToLocation(SqlGetJson(q, 0)) : LOCATION_INVALID;
}

vector GetModuleVector(string sVarName)
{
    sqlquery q = _PrepareVariableSelect(GetModule(), VARIABLE_TYPE_VECTOR, sVarName, FALSE);
    return SqlStep(q) ? JsonToVector(SqlGetJson(q, 0)) : Vector();
}

json GetModuleJson(string sVarName)
{
    sqlquery q = _PrepareVariableSelect(GetModule(), VARIABLE_TYPE_JSON, sVarName, FALSE);
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();
}

string GetModuleVariableTag(int nType, string sVarName)
{
    sqlquery q = _PrepareTagSelect(GetModule(), nType, sVarName, FALSE);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

json GetModuleVariablesByPattern(int nType = VARIABLE_TYPE_ALL, string sVarName = "",
                                 string sTag = "", int nTime = 0)
{
    sqlquery q = _PrepareComplexVariableSelect(GetModule(), nType, sVarName, sTag, nTime, FALSE);
    return _GetVariablesByPattern(q);
}

// DeleteModule* ---------------------------------------------------------------

int DeleteModuleInt(string sVarName)
{
    sqlquery q = _PrepareSimpleVariableDelete(GetModule(), VARIABLE_TYPE_INT, sVarName, FALSE);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

float DeleteModuleFloat(string sVarName)
{
    sqlquery q = _PrepareSimpleVariableDelete(GetModule(), VARIABLE_TYPE_FLOAT, sVarName, FALSE);
    return SqlStep(q) ? SqlGetFloat(q, 0) : 0.0;
}

string DeleteModuleString(string sVarName)
{
    sqlquery q = _PrepareSimpleVariableDelete(GetModule(), VARIABLE_TYPE_STRING, sVarName, FALSE);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

object DeleteModuleObject(string sVarName)
{
    sqlquery q = _PrepareSimpleVariableDelete(GetModule(), VARIABLE_TYPE_OBJECT, sVarName, FALSE);
    return SqlStep(q) ? StringToObject(SqlGetString(q, 0)) : OBJECT_INVALID;
}

void DeleteModuleSerialized(string sVarName)
{
    SqlStep(_PrepareSimpleVariableDelete(GetModule(), VARIABLE_TYPE_SERIALIZED, sVarName, FALSE));
}

location DeleteModuleLocation(string sVarName)
{
    sqlquery q = _PrepareSimpleVariableDelete(GetModule(), VARIABLE_TYPE_LOCATION, sVarName, FALSE);
    return SqlStep(q) ? JsonToLocation(SqlGetJson(q, 0)) : LOCATION_INVALID;
}

vector DeleteModuleVector(string sVarName)
{
    sqlquery q = _PrepareSimpleVariableDelete(GetModule(), VARIABLE_TYPE_VECTOR, sVarName, FALSE);
    return SqlStep(q) ? JsonToVector(SqlGetJson(q, 0)) : Vector();
}

json DeleteModuleJson(string sVarName)
{
    sqlquery q = _PrepareSimpleVariableDelete(GetModule(), VARIABLE_TYPE_JSON, sVarName, FALSE);
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();
}

void DeleteModuleVariables()
{
    SqlStep(_PrepareComplexVariableDelete(GetModule(), 0, "*", "*", 0, FALSE));
}

void DeleteModuleVariablesByName(string sVarName)
{
    SqlStep(_PrepareComplexVariableDelete(GetModule(), 0, sVarName, "", 0, FALSE));
}

void DeleteModuleVariablesByTag(string sTag)
{
    SqlStep(_PrepareComplexVariableDelete(GetModule(), 0, "", sTag, 0, FALSE));
}

void DeleteModuleVariablesByType(int nType)
{
    SqlStep(_PrepareComplexVariableDelete(GetModule(), nType, "", "", 0, FALSE));
}

void DeleteModuleVariablesBefore(int nTime)
{
    SqlStep(_PrepareComplexVariableDelete(GetModule(), 0, "", "", -nTime, FALSE));
}

void DeleteModuleVariablesAfter(int nTime)
{
    SqlStep(_PrepareComplexVariableDelete(GetModule(), 0, "", "", abs(nTime), FALSE));
}

void DeleteModuleVariablesByPattern(int nType = VARIABLE_TYPE_NONE, string sVarName = "",
                                    string sTag = "", int nTime = 0)
{
    SqlStep(_PrepareComplexVariableDelete(GetModule(), nType, sVarName, sTag, nTime, FALSE));
}

int IncrementModuleInt(string sVarName, int nIncrement = 1, string sTag = "")
{
    sqlquery q = _PrepareVariableIncrement(GetModule(), VARIABLE_TYPE_INT, sVarName, sTag, FALSE);
    SqlBindInt(q, "@value", nIncrement);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

int DecrementModuleInt(string sVarName, int nDecrement = -1, string sTag = "")
{
    if      (nDecrement == 0) return GetModuleInt(sVarName);
    else if (nDecrement > 0) nDecrement *= -1;

    return IncrementModuleInt(sVarName, nDecrement, sTag);
}

float IncrementModuleFloat(string sVarName, float fIncrement = 1.0, string sTag = "")
{
    sqlquery q = _PrepareVariableIncrement(GetModule(), VARIABLE_TYPE_FLOAT, sVarName, sTag, FALSE);
    SqlBindFloat(q, "@value", fIncrement);
    return SqlStep(q) ? SqlGetFloat(q, 0) : 0.0;
}

float DecrementModuleFloat(string sVarName, float fDecrement = -1.0, string sTag = "")
{
    if      (fDecrement == 0.0) return GetModuleFloat(sVarName);
    else if (fDecrement > 0.0) fDecrement *= -1.0;

    return IncrementModuleFloat(sVarName, fDecrement, sTag);
}

string AppendModuleString(string sVarName, string sAppend, string sTag = "")
{
    sqlquery q = _PrepareVariableAppend(GetModule(), sVarName, sTag, FALSE);
    SqlBindString(q, "@value", sAppend);
    SqlBindInt   (q, "@type", VARIABLE_TYPE_STRING);

    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

// Player Database -------------------------------------------------------------

void SetPlayerInt(object oPlayer, string sVarName, int nValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(oPlayer, VARIABLE_TYPE_INT, sVarName, sTag, FALSE);
    SqlBindInt(q, "@value", nValue);
    SqlStep(q);
}

void SetPlayerFloat(object oPlayer, string sVarName, float fValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(oPlayer, VARIABLE_TYPE_FLOAT, sVarName, sTag, FALSE);
    SqlBindFloat(q, "@value", fValue);
    SqlStep(q);
}

void SetPlayerString(object oPlayer, string sVarName, string sValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(oPlayer, VARIABLE_TYPE_STRING, sVarName, sTag, FALSE);
    SqlBindString(q, "@value", sValue);
    SqlStep(q);
}

void SetPlayerObject(object oPlayer, string sVarName, object oValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(oPlayer, VARIABLE_TYPE_OBJECT, sVarName, sTag, FALSE);
    SqlBindString(q, "@value", ObjectToString(oValue));
    SqlStep(q);
}

void SetPlayerSerialized(object oPlayer, string sVarName, object oValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(oPlayer, VARIABLE_TYPE_SERIALIZED, sVarName, sTag, FALSE);
    SqlBindJson(q, "@value", ObjectToJson(oValue, TRUE));
    SqlStep(q);
}

void SetPlayerLocation(object oPlayer, string sVarName, location lValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(oPlayer, VARIABLE_TYPE_LOCATION, sVarName, sTag, FALSE);
    SqlBindJson(q, "@value", LocationToJson(lValue));
    SqlStep(q);
}

void SetPlayerVector(object oPlayer, string sVarName, vector vValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(oPlayer, VARIABLE_TYPE_VECTOR, sVarName, sTag, FALSE);
    SqlBindJson(q, "@value", VectorToJson(vValue));
    SqlStep(q);
}

void SetPlayerJson(object oPlayer, string sVarName, json jValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(oPlayer, VARIABLE_TYPE_JSON, sVarName, sTag, FALSE);
    SqlBindJson(q, "@value", jValue);
    SqlStep(q);
}

void SetPlayerVariableTag(object oPlayer, int nType, string sVarName, string sTag)
{
    SqlStep(_PrepareTagUpdate(oPlayer, nType, sVarName, sTag, FALSE));
}

// GetPlayer* ------------------------------------------------------------------

int GetPlayerInt(object oPlayer, string sVarName)
{
    sqlquery q = _PrepareVariableSelect(oPlayer, VARIABLE_TYPE_INT, sVarName, FALSE);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

float GetPlayerFloat(object oPlayer, string sVarName)
{
    sqlquery q = _PrepareVariableSelect(oPlayer, VARIABLE_TYPE_FLOAT, sVarName, FALSE);
    return SqlStep(q) ? SqlGetFloat(q, 0) : 0.0;
}

string GetPlayerString(object oPlayer, string sVarName)
{
    sqlquery q = _PrepareVariableSelect(oPlayer, VARIABLE_TYPE_STRING, sVarName, FALSE);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

object GetPlayerObject(object oPlayer, string sVarName)
{
    sqlquery q = _PrepareVariableSelect(oPlayer, VARIABLE_TYPE_OBJECT, sVarName, FALSE);
    return SqlStep(q) ? StringToObject(SqlGetString(q, 0)) : OBJECT_INVALID;
}

object GetPlayerSerialized(object oPlayer, string sVarName, location l, object oTarget = OBJECT_INVALID)
{
    sqlquery q = _PrepareVariableSelect(oPlayer, VARIABLE_TYPE_SERIALIZED, sVarName, FALSE);
    return SqlStep(q) ? JsonToObject(SqlGetJson(q, 0), l, oTarget, TRUE) : OBJECT_INVALID;
}

location GetPlayerLocation(object oPlayer, string sVarName)
{
    sqlquery q = _PrepareVariableSelect(oPlayer, VARIABLE_TYPE_LOCATION, sVarName, FALSE);
    return SqlStep(q) ? JsonToLocation(SqlGetJson(q, 0)) : LOCATION_INVALID;
}

vector GetPlayerVector(object oPlayer, string sVarName)
{
    sqlquery q = _PrepareVariableSelect(oPlayer, VARIABLE_TYPE_VECTOR, sVarName, FALSE);
    return SqlStep(q) ? JsonToVector(SqlGetJson(q, 0)) : Vector();
}

json GetPlayerJson(object oPlayer, string sVarName)
{
    sqlquery q = _PrepareVariableSelect(oPlayer, VARIABLE_TYPE_JSON, sVarName, FALSE);
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();
}

string GetPlayerVariableTag(object oPlayer, int nType, string sVarName)
{
    sqlquery q = _PrepareTagSelect(oPlayer, nType, sVarName, FALSE);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

json GetPlayerVariablesByPattern(object oPlayer, int nType = VARIABLE_TYPE_ALL,
                                 string sVarName = "", string sTag = "", int nTime = 0)
{
    sqlquery q = _PrepareComplexVariableSelect(oPlayer, nType, sVarName, sTag, nTime, FALSE);
    return _GetVariablesByPattern(q);
}

// DeletePlayer* ---------------------------------------------------------------

int DeletePlayerInt(object oPlayer, string sVarName)
{
    sqlquery q = _PrepareSimpleVariableDelete(oPlayer, VARIABLE_TYPE_INT, sVarName, FALSE);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

float DeletePlayerFloat(object oPlayer, string sVarName)
{
    sqlquery q = _PrepareSimpleVariableDelete(oPlayer, VARIABLE_TYPE_FLOAT, sVarName, FALSE);
    return SqlStep(q) ? SqlGetFloat(q, 0) : 0.0;
}

string DeletePlayerString(object oPlayer, string sVarName)
{
    sqlquery q = _PrepareSimpleVariableDelete(oPlayer, VARIABLE_TYPE_STRING, sVarName, FALSE);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

object DeletePlayerObject(object oPlayer, string sVarName)
{
    sqlquery q = _PrepareSimpleVariableDelete(oPlayer, VARIABLE_TYPE_OBJECT, sVarName, FALSE);
    return SqlStep(q) ? StringToObject(SqlGetString(q, 0)) : OBJECT_INVALID;
}

void DeletePlayerSerialized(object oPlayer, string sVarName)
{
    SqlStep(_PrepareSimpleVariableDelete(oPlayer, VARIABLE_TYPE_SERIALIZED, sVarName, FALSE));
}

location DeletePlayerLocation(object oPlayer, string sVarName)
{
    sqlquery q = _PrepareSimpleVariableDelete(oPlayer, VARIABLE_TYPE_LOCATION, sVarName, FALSE);
    return SqlStep(q) ? JsonToLocation(SqlGetJson(q, 0)) : LOCATION_INVALID;
}

vector DeletePlayerVector(object oPlayer, string sVarName)
{
    sqlquery q = _PrepareSimpleVariableDelete(oPlayer, VARIABLE_TYPE_VECTOR, sVarName, FALSE);
    return SqlStep(q) ? JsonToVector(SqlGetJson(q, 0)) : Vector();
}

json DeletePlayerJson(object oPlayer, string sVarName)
{
    sqlquery q = _PrepareSimpleVariableDelete(oPlayer, VARIABLE_TYPE_JSON, sVarName, FALSE);
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();
}

void DeletePlayerVariables(object oPlayer)
{
    SqlStep(_PrepareComplexVariableDelete(oPlayer, 0, "*", "*", 0, FALSE));
}

void DeletePlayerVariablesByName(object oPlayer, string sVarName)
{
    SqlStep(_PrepareComplexVariableDelete(oPlayer, 0, sVarName, "", 0, FALSE));
}

void DeletePlayerVariablesByTag(object oPlayer, string sTag)
{
    SqlStep(_PrepareComplexVariableDelete(oPlayer, 0, "", sTag, 0, FALSE));
}

void DeletePlayerVariablesByType(object oPlayer, int nType)
{
    SqlStep(_PrepareComplexVariableDelete(oPlayer, nType, "", "", 0, FALSE));
}

void DeletePlayerVariablesBefore(object oPlayer, int nTime)
{
    SqlStep(_PrepareComplexVariableDelete(oPlayer, 0, "", "", -nTime, FALSE));
}

void DeletePlayerVariablesAfter(object oPlayer, int nTime)
{
    SqlStep(_PrepareComplexVariableDelete(oPlayer, 0, "", "", abs(nTime), FALSE));
}

void DeletePlayerVariablesByPattern(object oPlayer, int nType = VARIABLE_TYPE_NONE,
                                    string sVarName = "", string sTag = "", int nTime = 0)
{
    SqlStep(_PrepareComplexVariableDelete(oPlayer, nType, sVarName, sTag, nTime, FALSE));
}

int IncrementPlayerInt(object oPlayer, string sVarName, int nIncrement = 1, string sTag = "")
{
    sqlquery q = _PrepareVariableIncrement(oPlayer, VARIABLE_TYPE_INT, sVarName, sTag, FALSE);
    SqlBindInt(q, "@value", nIncrement);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

int DecrementPlayerInt(object oPlayer, string sVarName, int nDecrement = -1, string sTag = "")
{
    if      (nDecrement == 0) return GetPlayerInt(oPlayer, sVarName);
    else if (nDecrement > 0) nDecrement *= -1;

    return IncrementPlayerInt(oPlayer, sVarName, nDecrement, sTag);
}

float IncrementPlayerFloat(object oPlayer, string sVarName, float fIncrement = 1.0, string sTag = "")
{
    sqlquery q = _PrepareVariableIncrement(oPlayer, VARIABLE_TYPE_FLOAT, sVarName, sTag, FALSE);
    SqlBindFloat(q, "@value", fIncrement);
    return SqlStep(q) ? SqlGetFloat(q, 0) : 0.0;
}

float DecrementPlayerFloat(object oPlayer, string sVarName, float fDecrement = -1.0, string sTag = "")
{
    if      (fDecrement == 0.0) return GetPlayerFloat(oPlayer, sVarName);
    else if (fDecrement > 0.0) fDecrement *= -1.0;

    return IncrementPlayerFloat(oPlayer, sVarName, fDecrement, sTag);
}

string AppendPlayerString(object oPlayer, string sVarName, string sAppend, string sTag = "")
{
    sqlquery q = _PrepareVariableAppend(oPlayer, sVarName, sTag, FALSE);
    SqlBindString(q, "@value", sAppend);
    SqlBindInt   (q, "@type", VARIABLE_TYPE_STRING);

    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

// SetPersistent* ------------------------------------------------------------------

void SetPersistentInt(string sVarName, int nValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(OBJECT_INVALID, VARIABLE_TYPE_INT, sVarName, sTag, FALSE);
    SqlBindInt(q, "@value", nValue);
    SqlStep(q);
}

void SetPersistentFloat(string sVarName, float fValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(OBJECT_INVALID, VARIABLE_TYPE_FLOAT, sVarName, sTag, FALSE);
    SqlBindFloat(q, "@value", fValue);
    SqlStep(q);
}

void SetPersistentString(string sVarName, string sValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(OBJECT_INVALID, VARIABLE_TYPE_STRING, sVarName, sTag, FALSE);
    SqlBindString(q, "@value", sValue);
    SqlStep(q);
}

void SetPersistentObject(string sVarName, object oValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(OBJECT_INVALID, VARIABLE_TYPE_OBJECT, sVarName, sTag, FALSE);
    SqlBindString(q, "@value", ObjectToString(oValue));
    SqlStep(q);
}

void SetPersistentSerialized(string sVarName, object oValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(OBJECT_INVALID, VARIABLE_TYPE_SERIALIZED, sVarName, sTag, FALSE);
    SqlBindJson(q, "@value", ObjectToJson(oValue, TRUE));
    SqlStep(q);
}

void SetPersistentLocation(string sVarName, location lValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(OBJECT_INVALID, VARIABLE_TYPE_LOCATION, sVarName, sTag, FALSE);
    SqlBindJson(q, "@value", LocationToJson(lValue));
    SqlStep(q);
}

void SetPersistentVector(string sVarName, vector vValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(OBJECT_INVALID, VARIABLE_TYPE_VECTOR, sVarName, sTag, FALSE);
    SqlBindJson(q, "@value", VectorToJson(vValue));
    SqlStep(q);
}

void SetPersistentJson(string sVarName, json jValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(OBJECT_INVALID, VARIABLE_TYPE_JSON, sVarName, sTag, FALSE);
    SqlBindJson(q, "@value", jValue);
    SqlStep(q);
}

void SetPersistentVariableTag(int nType, string sVarName, string sTag)
{
    SqlStep(_PrepareTagUpdate(OBJECT_INVALID, nType, sVarName, sTag, FALSE));
}

// GetPersistent* ------------------------------------------------------------------

int GetPersistentInt(string sVarName)
{
    sqlquery q = _PrepareVariableSelect(OBJECT_INVALID, VARIABLE_TYPE_INT, sVarName, FALSE);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

float GetPersistentFloat(string sVarName)
{
    sqlquery q = _PrepareVariableSelect(OBJECT_INVALID, VARIABLE_TYPE_FLOAT, sVarName, FALSE);
    return SqlStep(q) ? SqlGetFloat(q, 0) : 0.0;
}

string GetPersistentString(string sVarName)
{
    sqlquery q = _PrepareVariableSelect(OBJECT_INVALID, VARIABLE_TYPE_STRING, sVarName, FALSE);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

object GetPersistentObject(string sVarName)
{
    sqlquery q = _PrepareVariableSelect(OBJECT_INVALID, VARIABLE_TYPE_OBJECT, sVarName, FALSE);
    return SqlStep(q) ? StringToObject(SqlGetString(q, 0)) : OBJECT_INVALID;
}

object GetPersistentSerialized(string sVarName, location l, object oTarget = OBJECT_INVALID)
{
    sqlquery q = _PrepareVariableSelect(OBJECT_INVALID, VARIABLE_TYPE_SERIALIZED, sVarName, FALSE);
    return SqlStep(q) ? JsonToObject(SqlGetJson(q, 0), l, oTarget, TRUE) : OBJECT_INVALID;
}

location GetPersistentLocation(string sVarName)
{
    sqlquery q = _PrepareVariableSelect(OBJECT_INVALID, VARIABLE_TYPE_LOCATION, sVarName, FALSE);
    return SqlStep(q) ? JsonToLocation(SqlGetJson(q, 0)) : LOCATION_INVALID;
}

vector GetPersistentVector(string sVarName)
{
    sqlquery q = _PrepareVariableSelect(OBJECT_INVALID, VARIABLE_TYPE_VECTOR, sVarName, FALSE);
    return SqlStep(q) ? JsonToVector(SqlGetJson(q, 0)) : Vector();
}

json GetPersistentJson(string sVarName)
{
    sqlquery q = _PrepareVariableSelect(OBJECT_INVALID, VARIABLE_TYPE_JSON, sVarName, FALSE);
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();
}

string GetPersistentVariableTag(int nType, string sVarName)
{
    sqlquery q = _PrepareTagSelect(OBJECT_INVALID, nType, sVarName, FALSE);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

json GetPersistentVariablesByPattern(int nType = VARIABLE_TYPE_ALL, string sVarName = "",
                                 string sTag = "", int nTime = 0)
{
    sqlquery q = _PrepareComplexVariableSelect(OBJECT_INVALID, nType, sVarName, sTag, nTime, FALSE);
    return _GetVariablesByPattern(q);
}

// DeletePersistent* ---------------------------------------------------------------

int DeletePersistentInt(string sVarName)
{
    sqlquery q = _PrepareSimpleVariableDelete(OBJECT_INVALID, VARIABLE_TYPE_INT, sVarName, FALSE);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

float DeletePersistentFloat(string sVarName)
{
    sqlquery q = _PrepareSimpleVariableDelete(OBJECT_INVALID, VARIABLE_TYPE_FLOAT, sVarName, FALSE);
    return SqlStep(q) ? SqlGetFloat(q, 0) : 0.0;
}

string DeletePersistentString(string sVarName)
{
    sqlquery q = _PrepareSimpleVariableDelete(OBJECT_INVALID, VARIABLE_TYPE_STRING, sVarName, FALSE);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

object DeletePersistentObject(string sVarName)
{
    sqlquery q = _PrepareSimpleVariableDelete(OBJECT_INVALID, VARIABLE_TYPE_OBJECT, sVarName, FALSE);
    return SqlStep(q) ? StringToObject(SqlGetString(q, 0)) : OBJECT_INVALID;
}

void DeletePersistentSerialized(string sVarName)
{
    SqlStep(_PrepareSimpleVariableDelete(OBJECT_INVALID, VARIABLE_TYPE_SERIALIZED, sVarName, FALSE));
}

location DeletePersistentLocation(string sVarName)
{
    sqlquery q = _PrepareSimpleVariableDelete(OBJECT_INVALID, VARIABLE_TYPE_LOCATION, sVarName, FALSE);
    return SqlStep(q) ? JsonToLocation(SqlGetJson(q, 0)) : LOCATION_INVALID;
}

vector DeletePersistentVector(string sVarName)
{
    sqlquery q = _PrepareSimpleVariableDelete(OBJECT_INVALID, VARIABLE_TYPE_VECTOR, sVarName, FALSE);
    return SqlStep(q) ? JsonToVector(SqlGetJson(q, 0)) : Vector();
}

json DeletePersistentJson(string sVarName)
{
    sqlquery q = _PrepareSimpleVariableDelete(OBJECT_INVALID, VARIABLE_TYPE_JSON, sVarName, FALSE);
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();
}

void DeletePersistentVariables()
{
    SqlStep(_PrepareComplexVariableDelete(OBJECT_INVALID, 0, "*", "*", 0, FALSE));
}

void DeletePersistentVariablesByName(string sVarName)
{
    SqlStep(_PrepareComplexVariableDelete(OBJECT_INVALID, 0, sVarName, "", 0, FALSE));
}

void DeletePersistentVariablesByTag(string sTag)
{
    SqlStep(_PrepareComplexVariableDelete(OBJECT_INVALID, 0, "", sTag, 0, FALSE));
}

void DeletePersistentVariablesByType(int nType)
{
    SqlStep(_PrepareComplexVariableDelete(OBJECT_INVALID, nType, "", "", 0, FALSE));
}

void DeletePersistentVariablesBefore(int nTime)
{
    SqlStep(_PrepareComplexVariableDelete(OBJECT_INVALID, 0, "", "", -nTime, FALSE));
}

void DeletePersistentVariablesAfter(int nTime)
{
    SqlStep(_PrepareComplexVariableDelete(OBJECT_INVALID, 0, "", "", abs(nTime), FALSE));
}

void DeletePersistentVariablesByPattern(int nType = VARIABLE_TYPE_NONE, string sVarName = "",
                                    string sTag = "", int nTime = 0)
{
    SqlStep(_PrepareComplexVariableDelete(OBJECT_INVALID, nType, sVarName, sTag, nTime, FALSE));
}

int IncrementPersistentInt(string sVarName, int nIncrement = 1, string sTag = "")
{
    sqlquery q = _PrepareVariableIncrement(OBJECT_INVALID, VARIABLE_TYPE_INT, sVarName, sTag, FALSE);
    SqlBindInt(q, "@value", nIncrement);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

int DecrementPersistentInt(string sVarName, int nDecrement = -1, string sTag = "")
{
    if      (nDecrement == 0) return GetPersistentInt(sVarName);
    else if (nDecrement > 0) nDecrement *= -1;

    return IncrementPersistentInt(sVarName, nDecrement, sTag);
}

float IncrementPersistentFloat(string sVarName, float fIncrement = 1.0, string sTag = "")
{
    sqlquery q = _PrepareVariableIncrement(OBJECT_INVALID, VARIABLE_TYPE_FLOAT, sVarName, sTag, FALSE);
    SqlBindFloat(q, "@value", fIncrement);
    return SqlStep(q) ? SqlGetFloat(q, 0) : 0.0;
}

float DecrementPersistentFloat(string sVarName, float fDecrement = -1.0, string sTag = "")
{
    if      (fDecrement == 0.0) return GetPersistentFloat(sVarName);
    else if (fDecrement > 0.0) fDecrement *= -1.0;

    return IncrementPersistentFloat(sVarName, fDecrement, sTag);
}

string AppendPersistentString(string sVarName, string sAppend, string sTag = "")
{
    sqlquery q = _PrepareVariableAppend(OBJECT_INVALID, sVarName, sTag, FALSE);
    SqlBindString(q, "@value", sAppend);
    SqlBindInt   (q, "@type", VARIABLE_TYPE_STRING);

    return SqlStep(q) ? SqlGetString(q, 0) : "";
}
