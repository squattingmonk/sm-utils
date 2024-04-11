/// ----------------------------------------------------------------------------
/// @file   util_i_variables.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Functions for managing database variables.
/// ----------------------------------------------------------------------------

/// @details The functions in this include are meant to complement and extend
/// the game's basic variable handling functions, such as GetLocalInt() and
/// SetLocalString().  These functions allow variable storage in the module's
/// volatile sqlite database, the module's persistent campaign database, and the
/// player's sqlite database, as well as movement of variables to and from game
/// objects and various databases.  Configuration options for this utility can be
/// set in `util_c_variables.nss`.
///
/// Concepts:
///     - Databases:  There are three sqlite database types available to store
///         variables:  a player's bic-based db, the module's volatile db and
///         the external/persistent campaign db.  When calling a function that
///         requires a database object reference (such as param oDatabase), it
///         must be a player object, DB_MODULE or DB_CAMPAIGN.  All other values
///         will result in the function failing with a message to the game's log.
///     - Tag: Any Set, Increment, Decrement or Append function allows a variable
///         to be tagged with a string value of any composition or length.  This
///         tag is designed to be used to group values for future delete or copy
///         operations, but may be used for any other purpose.  It is important
///         to understan that the tag field is part of the primary key, which makes
///         each record unique.  Although the tag is optional, if included, it must
///         be included in each subsequent call to ensure the correct variable
///         record is being operated on.
///     - Timestamp:  Any Set, Increment, Decrement or Append function updates
///         the time at which the variables was set or updated.  This time can be
///         be used in advanced query functions to copy or delete specific variables
///         by group.
///     - Glob/wildcard Syntax:  There are several functions which allow criteria
///         to be specified to retrieve or delete variables.  These criteria
///         allow the use of bitmasked types and glob syntax.  If the function
///         description specified this ability, the following syntax is allowed:
///             nType - Can be a single variable type, such as
///                 VARIABLE_TYPE_INT, or a bitmasked set of variable types,
///                 such as VARIABLE_TYPE_INT | VARIABLE_TYPE_FLOAT.  Other
///                 normal bitwise operators are also allowed.  To select
///                 all variables types except integer, the value can be
///                 passed as ~VARIABLE_TYPE_INT.  Pass VARIABLE_TYPE_ALL
///                 to ignore variable types.  Passing VARIABLE_TYPE_NONE will
///                 generally result in zero returned results.
///             sVarName - Can be an exact varname as previously set, or
///                 will accept any wildcards or sets allowed by glob:
///                     **Glob operations are case-senstive**
///                     * - 0 or more characters
///                     ? - Any single character
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
///                 match all variables set after nTime.  The easiest way to
///                 understand this concept is to determine the time you want
///                 to compare against (in Unix seconds), then pass that time
///                 as negative to seek variables set/updated before that time,
///                 or positive to seek variables set/updated after that time.
///                 Pass 0 to ignore timestamps.
///
/// Advanced Usage:
///     - Copying from Database to Locals:  `CopyDatabaseVariablesToObject()`
///         allows specified database variables to any valid game object.
///         Local variables do not allow additional fields that are retrieved
///         from the database, so the function `DatabaseToObjectVarName()` is
///         provided in `util_c_variables.nss` to allow users to construct
///         unique varnames for a copied database variable.  See glob/wildcard
///         syntax concept above for how to use parameters in this function.
///
///     - Copying from Locals to Database:  `CopyLocalVariablesToDatabase()`
///         allows specified local variables from any game object (except the
///         module object) to any database.  



///     - Copying from Locals to Database:  There are three functions which allow
///         variables which meet specific criteria to be copied from a game object
///         to a specified database.  Local variables do not have tags, however, a
///         tag can be supplied to these functions and the tag will be saved into
///         the database.  These methods may be useful to save current object
///         state into a persistent database to be later retrieved individually
///         of by mass copy with a database -> local copy method.
///
///     - Record uniqueness:  Module, Player and Persistent variables are stored
///         in sqlite databases.  Each record is unique based on variable type,
///         name and tag.  The variable tag is optional.  This behavior allows
///         multiple variables with the same type and name, but with different
///         tags.  If using tags, it is incumbent upon the user to include the
///         desired tag is in all functions calls to ensure the correct record
///         is operated on.

#include "util_i_debug"
#include "util_i_lists"
#include "util_i_matching"
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

const string VARIABLE_OBJECT   = "VARIABLE:OBJECT";
const string VARIABLE_CAMPAIGN = "VARIABLE:CAMPAIGN";

object DB_MODULE = GetModule();
object DB_CAMPAIGN = OBJECT_INVALID;

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Creates a variable table in oObject's database.
/// @param oObject Optional object reference.  If passed, should
///     be a PC object or a db object (DB_MODULE || DB_CAMPAIGN).
/// @note This function is never required to be called separately
///     during OnModuleLoad.  Table creation is handled during
///     the variable setting process.
void CreateVariableTable(object oObject);

// -----------------------------------------------------------------------------
//                               Local Variables
// -----------------------------------------------------------------------------

/// @brief Returns a json array of all local variables on oObject.
/// @param oObject Game object to get local variables from.  This method will
///     not work on the module object.
/// @param nType VARIABLE_TYPE_* constant for type of variable to retrieve.
///     Accepts bitmasked types such as VARIABLE_TYPE_INT | VARIABLE_TYPE_FLOAT.
/// @param sVarName Name of variable to retrieve.  Accepts glob wildcard and
///     set syntax.
/// @returns a JSON array of variables set on oObject.  The array will consist
///     of JSON objects with the following key:value pairs:
///         type: <type> {int} Reference to VARIABLE_TYPE_*
///         value: <value> {type} Type depends on type
///             -- objects will be returned as a string object id which
///                 can be used in StringToObject()
///         varname: <varname> {string}
json GetLocalVariables(object oObject, int nType = VARIABLE_TYPE_ALL, string sVarName = "*");

/// @brief Deletes local variables from oObject.
/// @param oObject Game object to get local variables from.  This method will
///     not work on the module object.
/// @param nType VARIABLE_TYPE_* constant for type of variable to delete.
///     Accepts bitmasked types such as VARIABLE_TYPE_INT | VARIABLE_TYPE_FLOAT.
/// @param sVarName Name of variable to delete.  Accepts glob wildcard and
///     set syntax.
void DeleteLocalVariables(object oObject, int nType = VARIABLE_TYPE_NONE, string sVarName = "");

/// @brief Copies local variables from oObject to another game object oTarget.
/// @param oSource Game object to get local variables from.  This method will
///     not work on the module object.
/// @param oTarget The game object to copy local variables to.
/// @param nType VARIABLE_TYPE_* constant for type of variable to copy.
///     Accepts bitmasked types such as VARIABLE_TYPE_INT | VARIABLE_TYPE_FLOAT.
/// @param sVarName Name of variable to copy.  Accepts glob wildcard and
///     set syntax.
/// @param bDelete If TRUE, deletes the local variables from oSource after they
///     are copied oTarget.
/// @note This method *can* be used to set variables onto the module object.
void CopyLocalVariablesToObject(object oSource, object oTarget, int nType = VARIABLE_TYPE_ALL,
                                string sVarName = "", int bDelete = TRUE);

/// @brief Copies local variables from oSource to oDatabase.
/// @param oSource Game object to get local variables from.  This method will
///     not work on the module object.
/// @param oDatabase Database to copy variables to (PC Object || DB_MODULE || DB_CAMPAIGN).
/// @param nType VARIABLE_TYPE_* constant for type of variable to copy.
///     Accepts bitmasked types such as VARIABLE_TYPE_INT | VARIABLE_TYPE_FLOAT.
/// @param sVarName Name of variable to copy.  Accepts glob wildcard and
///     set syntax.
/// @param sTag Optional tag reference.  All variables copied with this function
///     will have sTag applied.
/// @param bDelete If TRUE, deletes the local variables from oSource after they
///     are copied to the module database.
void CopyLocalVariablesToDatabase(object oSource, object oDatabase, int nType = VARIABLE_TYPE_ALL, 
                                  string sVarName = "", string sTag = "", int bDelete = TRUE);

/// @brief Copies variables from an sqlite database to a game object as local variables.
/// @param oDatabase Database to copy variables to (PC Object || DB_MODULE || DB_CAMPAIGN).
/// @param oTarget Game object to set local variables on.
/// @param nType VARIABLE_TYPE_* constant for type of variable to copy.
///     Accepts bitmasked types such as VARIABLE_TYPE_INT | VARIABLE_TYPE_FLOAT.
/// @param sVarName Name of variable to copy.  Accepts glob wildcard and
///     set syntax.
/// @param sTag Optional tag reference.  Accepts glob wildcard and set syntax.
/// @param nTime A positive value will filter for timestamps after
///     nTime, a negative value will filter for timestamps before nTime.
/// @param bDelete If TRUE, deletes the local variables from oObject after they
///     are copied to the module database.
/// @note This method *can* be used to set variables onto the module object.
void CopyDatabaseVariablesToObject(object oDatabase, object oTarget, int nType = VARIABLE_TYPE_ALL, 
                                   string sVarName = "", string sTag = "", int nTime = 0, int bDelete = TRUE);

/// @brief Copies variables from an sqlite database to another sqlite database.
/// @param oSource Database to copy variables from (PC Object || DB_MODULE || DB_CAMPAIGN).
/// @param oTarget Database to copy variables to (PC Object || DB_MODULE || DB_CAMPAIGN).
/// @param nType VARIABLE_TYPE_* constant for type of variable to copy.
///     Accepts bitmasked types such as VARIABLE_TYPE_INT | VARIABLE_TYPE_FLOAT.
/// @param sVarName Name of variable to copy.  Accepts glob wildcard and
///     set syntax.
/// @param sTag Optional tag reference.  Accepts glob wildcard and set syntax.
/// @param nTime A positive value will filter for timestamps after
///     nTime, a negative value will filter for timestamps before nTime.
/// @param bDelete If TRUE, deletes the local variables from oObject after they
///     are copied to the module database.
void CopyDatabaseVariablesToDatabase(object oSource, object oTarget, int nType = VARIABLE_TYPE_ALL,
                                     string sVarName = "", string sTag = "", int nTime = 0, int bDelete = TRUE);

/// @brief Determines whether a local variable has been set on oObject
/// @param oObject Game object to get local variables from.  This method will
///     not work on the module object.
/// @param sVarName Name of variable to retrieve.  This must be the exact varname,
///     glob wildcards and sets are not accepted.
int HasLocalInt(object oObject, string sVarName);

/// @brief Determines whether a local variable has been set on oObject
/// @param oObject Game object to get local variables from.  This method will
///     not work on the module object.
/// @param sVarName Name of variable to retrieve.  This must be the exact varname,
///     glob wildcards and sets are not accepted.
int HasLocalFloat(object oObject, string sVarName);

/// @brief Determines whether a local variable has been set on oObject
/// @param oObject Game object to get local variables from.  This method will
///     not work on the module object.
/// @param sVarName Name of variable to retrieve.  This must be the exact varname,
///     glob wildcards and sets are not accepted.
int HasLocalString(object oObject, string sVarName);

/// @brief Determines whether a local variable has been set on oObject
/// @param oObject Game object to get local variables from.  This method will
///     not work on the module object.
/// @param sVarName Name of variable to retrieve.  This must be the exact varname,
///     glob wildcards and sets are not accepted.
int HasLocalObject(object oObject, string sVarName);

/// @brief Determines whether a local variable has been set on oObject
/// @param oObject Game object to get local variables from.  This method will
///     not work on the module object.
/// @param sVarName Name of variable to retrieve.  This must be the exact varname,
///     glob wildcards and sets are not accepted.
int HasLocalLocation(object oObject, string sVarName);

/// @brief Determines whether a local variable has been set on oObject
/// @param oObject Game object to get local variables from.  This method will
///     not work on the module object.
/// @param sVarName Name of variable to retrieve.  This must be the exact varname,
///     glob wildcards and sets are not accepted.
int HasLocalJson(object oObject, string sVarName);

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
/// @param sTag Optional tag reference.
/// @param sNewTag New tag to assign.
void SetModuleVariableTag(int nType, string sVarName, string sTag = "", string sNewTag = "");

/// @brief Retrieve a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise 0.
/// @param sTag Optional tag reference.
int GetModuleInt(string sVarName, string sTag = "");

/// @brief Retrieve a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise 0.0.
/// @param sTag Optional tag reference.
float GetModuleFloat(string sVarName, string sTag = "");

/// @brief Retrieve a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise "".
/// @param sTag Optional tag reference.
string GetModuleString(string sVarName, string sTag = "");

/// @brief Retrieve a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise OBJECT_INVALID.
/// @param sTag Optional tag reference.
object GetModuleObject(string sVarName, string sTag = "");

/// @brief Retrieve and create a serialized object from the module's
///     volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param sTag Tag reference.
/// @param l Location to create the deserialized object.
/// @param oTarget Target object on which to create the deserialized object.
/// @returns The requested serialized object, if found, otherwise
///     OBJECT_INVALID.
/// @note If oTarget is passed and has inventory, the retrieved object
///     will be created in oTarget's inventory, otherwise it will be created
///     at location l.
object GetModuleSerialized(string sVarName, string sTag, location l, object oTarget = OBJECT_INVALID);

/// @brief Retrieve a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise LOCATION_INVALID.
/// @param sTag Optional tag reference.
location GetModuleLocation(string sVarName, string sTag = "");

/// @brief Retrieve a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise Vector().
/// @param sTag Optional tag reference.
vector GetModuleVector(string sVarName, string sTag = "");

/// @brief Retrieve a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise JsonNull().
/// @param sTag Optional tag reference.
json GetModuleJson(string sVarName, string sTag = "");

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
/// @param sTag Optional tag reference.
int DeleteModuleInt(string sVarName, string sTag = "");

/// @brief Delete a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
float DeleteModuleFloat(string sVarName, string sTag = "");

/// @brief Delete a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
string DeleteModuleString(string sVarName, string sTag = "");

/// @brief Delete a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
object DeleteModuleObject(string sVarName, string sTag = "");

/// @brief Delete a serialized object from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
void DeleteModuleSerialized(string sVarName, string sTag = "");

/// @brief Delete a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
location DeleteModuleLocation(string sVarName, string sTag = "");

/// @brief Delete a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
vector DeleteModuleVector(string sVarName, string sTag = "");

/// @brief Delete a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
json DeleteModuleJson(string sVarName, string sTag = "");

/// @brief Deletes all variables from the module's volatile sqlite database.
/// @warning Calling this method will result in all variables in the module's
///     volatile sqlite database being deleted without additional warning.
void DeleteModuleVariables();

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
                                    string sTag = "*", int nTime = 0);

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
void SetPlayerVariableTag(object oPlayer, int nType, string sVarName, string sTag = "", string sNewTag = "");

/// @brief Retrieve a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise 0.
/// @param sTag Optional tag reference.
int GetPlayerInt(object oPlayer, string sVarName, string sTag = "");

/// @brief Retrieve a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise 0.0.
/// @param sTag Optional tag reference.
float GetPlayerFloat(object oPlayer, string sVarName, string sTag = "");

/// @brief Retrieve a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise "".
/// @param sTag Optional tag reference.
string GetPlayerString(object oPlayer, string sVarName, string sTag = "");

/// @brief Retrieve a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise OBJECT_INVALID.
/// @param sTag Optional tag reference.
object GetPlayerObject(object oPlayer, string sVarName, string sTag = "");

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
object GetPlayerSerialized(object oPlayer, string sVarName, string sTag, location l, object oTarget = OBJECT_INVALID);

/// @brief Retrieve a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise LOCATION_INVALID.
/// @param sTag Optional tag reference.
location GetPlayerLocation(object oPlayer, string sVarName, string sTag = "");

/// @brief Retrieve a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise Vector().
/// @param sTag Optional tag reference.
vector GetPlayerVector(object oPlayer, string sVarName, string sTag = "");

/// @brief Retrieve a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise JsonNull().
/// @param sTag Optional tag reference.
json GetPlayerJson(object oPlayer, string sVarName, string sTag = "");

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
/// @param sTag Optional tag reference.
int DeletePlayerInt(object oPlayer, string sVarName, string sTag = "");

/// @brief Delete a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
float DeletePlayerFloat(object oPlayer, string sVarName, string sTag = "");

/// @brief Delete a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
string DeletePlayerString(object oPlayer, string sVarName, string sTag = "");

/// @brief Delete a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
object DeletePlayerObject(object oPlayer, string sVarName, string sTag = "");

/// @brief Delete a serialized object from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
void DeletePlayerSerialized(object oPlayer, string sVarName, string sTag = "");

/// @brief Delete a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
location DeletePlayerLocation(object oPlayer, string sVarName, string sTag = "");

/// @brief Delete a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
vector DeletePlayerVector(object oPlayer, string sVarName, string sTag = "");

/// @brief Delete a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
json DeletePlayerJson(object oPlayer, string sVarName, string sTag = "");

/// @brief Deletes all variables from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @warning Calling this method will result in all variables in the module's
///     volatile sqlite database being deleted without additional warning.
void DeletePlayerVariables(object oPlayer);

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
/// @param sTag Optional tag reference.
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
/// @param sTag Optional tag reference.
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
/// @param sTag Optional tag reference.
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
/// @param sTag Optional tag reference.
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
/// @param sTag Optional tag reference.
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
void SetPersistentVariableTag(int nType, string sVarName, string sTag = "", string sNewTag = "");

/// @brief Retrieve a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise 0.
/// @param sTag Optional tag reference.
int GetPersistentInt(string sVarName, string sTag = "");

/// @brief Retrieve a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise 0.0.
/// @param sTag Optional tag reference.
float GetPersistentFloat(string sVarName, string sTag = "");

/// @brief Retrieve a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise "".
/// @param sTag Optional tag reference.
string GetPersistentString(string sVarName, string sTag = "");

/// @brief Retrieve a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise OBJECT_INVALID.
/// @param sTag Optional tag reference.
object GetPersistentObject(string sVarName, string sTag = "");

/// @brief Retrieve and create a serialized object from the campaign database.
/// @param sVarName Name of the variable.
/// @param l Location to create the deserialized object.
/// @param oTarget Target object on which to create the deserialized object.
/// @returns The requested serialized object, if found, otherwise
///     OBJECT_INVALID.
/// @note If oTarget is passed and has inventory, the retrieved object
///     will be created in oTarget's inventory, otherwise it will be created
///     at location l.
object GetPersistentSerialized(string sVarName, string sTag, location l, object oTarget = OBJECT_INVALID);

/// @brief Retrieve a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise LOCATION_INVALID.
/// @param sTag Optional tag reference.
location GetPersistentLocation(string sVarName, string sTag = "");

/// @brief Retrieve a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise Vector().
/// @param sTag Optional tag reference.
vector GetPersistentVector(string sVarName, string sTag = "");

/// @brief Retrieve a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise JsonNull().
/// @param sTag Optional tag reference.
json GetPersistentJson(string sVarName, string sTag = "");

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
json GetPersistentVariablesByPattern(int nType = VARIABLE_TYPE_ALL, string sVarName = "*",
                                     string sTag = "*", int nTime = 0);

/// @brief Delete a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
int DeletePersistentInt(string sVarName, string sTag = "");

/// @brief Delete a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
float DeletePersistentFloat(string sVarName, string sTag = "");

/// @brief Delete a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
string DeletePersistentString(string sVarName, string sTag = "");

/// @brief Delete a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
object DeletePersistentObject(string sVarName, string sTag = "");

/// @brief Delete a serialized object from the campaign database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
void DeletePersistentSerialized(string sVarName, string sTag = "");

/// @brief Delete a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
location DeletePersistentLocation(string sVarName, string sTag = "");

/// @brief Delete a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
vector DeletePersistentVector(string sVarName, string sTag = "");

/// @brief Delete a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
json DeletePersistentJson(string sVarName, string sTag = "");

/// @brief Deletes all variables from the campaign database.
/// @warning Calling this method will result in all variables in the campaign
///     database being deleted without additional warning.
void DeletePersistentVariables();

/// @brief Deletes all variables from the campaign database that match the
///     parameter criteria.
/// @param nType Bitwise VARIABLE_TYPE_*.
/// @param sVarName Variable name pattern, accepts glob patterns, sets
///     and wildcards.
/// @param sTag Tag pattern, accepts glob patterns, sets and wildcards.
/// @param nTime A positive value will filter for timestamps after
///     nTime, a negative value will filter for timestamps before nTime.
/// @note If no parameters are passed, no variables will be deleted.
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

/// @private Returns the variable type as a string
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

/// @private Converts an NWN type to a VARIABLE_TYPE_*
int _TypeToVariableType(json jType)
{
    int nType = JsonGetInt(jType);

    if      (nType == 1) return VARIABLE_TYPE_INT;
    else if (nType == 2) return VARIABLE_TYPE_FLOAT;
    else if (nType == 3) return VARIABLE_TYPE_STRING;
    else if (nType == 4) return VARIABLE_TYPE_OBJECT;
    else if (nType == 5) return VARIABLE_TYPE_LOCATION;
    else if (nType == 7) return VARIABLE_TYPE_JSON;
    return                      VARIABLE_TYPE_NONE;
}

/// @private Converts VARIABLE_TYPE_* bitmask to IN
string _VariableTypeToArray(int nTypes)
{
    if      (nTypes == VARIABLE_TYPE_NONE) return "";
    else if (nTypes == VARIABLE_TYPE_ALL)  return "1,2,3,4,5,6,7";

    string sArray;    
    if (nTypes & VARIABLE_TYPE_INT)       sArray = AddListItem(sArray, "1");
    if (nTypes & VARIABLE_TYPE_FLOAT)     sArray = AddListItem(sArray, "2");
    if (nTypes & VARIABLE_TYPE_STRING)    sArray = AddListItem(sArray, "3");
    if (nTypes & VARIABLE_TYPE_OBJECT)    sArray = AddListItem(sArray, "4");
    if (nTypes & VARIABLE_TYPE_LOCATION)  sArray = AddListItem(sArray, "5");
    if (nTypes & VARIABLE_TYPE_JSON)      sArray = AddListItem(sArray, "7");
    
    return sArray;
}

/// @private Deletes a single local variable
void _DeleteLocalVariable(object oObject, string sVarName, int nType)
{
    if      (nType == VARIABLE_TYPE_INT)       DeleteLocalInt(oObject, sVarName);
    else if (nType == VARIABLE_TYPE_FLOAT)     DeleteLocalFloat(oObject, sVarName);
    else if (nType == VARIABLE_TYPE_STRING)    DeleteLocalString(oObject, sVarName);
    else if (nType == VARIABLE_TYPE_OBJECT)    DeleteLocalObject(oObject, sVarName);
    else if (nType == VARIABLE_TYPE_LOCATION)  DeleteLocalLocation(oObject, sVarName);
    else if (nType == VARIABLE_TYPE_JSON)      DeleteLocalJson(oObject, sVarName);
}

/// @private Sets a single local variable
void _SetLocalVariable(object oObject, string sVarName, int nType, json jValue)
{
    if      (nType == VARIABLE_TYPE_INT)       SetLocalInt(oObject, sVarName, JsonGetInt(jValue));
    else if (nType == VARIABLE_TYPE_FLOAT)     SetLocalFloat(oObject, sVarName, JsonGetFloat(jValue));
    else if (nType == VARIABLE_TYPE_STRING)    SetLocalString(oObject, sVarName, JsonGetString(jValue));
    else if (nType == VARIABLE_TYPE_OBJECT)    SetLocalObject(oObject, sVarName, StringToObject(JsonGetString(jValue)));
    else if (nType == VARIABLE_TYPE_LOCATION)  SetLocalLocation(oObject, sVarName, JsonToLocation(jValue));
    else if (nType == VARIABLE_TYPE_JSON)      SetLocalJson(oObject, sVarName, jValue);
}

/// @private Prepares an query against an object (module/player).  Ensures
///     appropriate tables have been created before attempting query.
sqlquery _PrepareQueryObject(object oObject, string sQuery)
{
    CreateVariableTable(oObject);
    return SqlPrepareQueryObject(oObject, sQuery);
}

/// @private Prepares an query against an campaign database.  Ensures
///     appropriate tables have been created before attempting query.
sqlquery _PrepareQueryCampaign(string sQuery)
{
    CreateVariableTable(DB_CAMPAIGN);
    return SqlPrepareQueryCampaign(VARIABLE_CAMPAIGN_DATABASE, sQuery);
}

/// @private Prepares a select query to retrieve a variable value stored
///     in any database.
sqlquery _PrepareVariableSelect(object oObject, int nType, string sVarName, string sTag)
{
    int bPC       = GetIsPC(oObject);
    int bCampaign = oObject == DB_CAMPAIGN;
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;

    string s = "SELECT value FROM " + sTable + " WHERE type = @type " +
                    "AND varname GLOB @varname AND tag GLOB @tag;";

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    SqlBindInt   (q, "@type", nType);
    SqlBindString(q, "@varname", sVarName);
    SqlBindString(q, "@tag", sTag);
    return q;
}

/// @private Prepares an insert query to stored a variable in any database.
sqlquery _PrepareVariableInsert(object oObject, int nType, string sVarName, string sTag)
{
    int bPC       = GetIsPC(oObject);
    int bCampaign = oObject == DB_CAMPAIGN;
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;

    string s =  "INSERT INTO " + sTable + " (type, varname, value, tag, timestamp) " +
                "VALUES (@type, @varname, IIF(json_valid(@value), @value ->> '$', @value), " +
                "@tag, strftime('%s', 'now')) ON CONFLICT (type, varname, tag) DO UPDATE " +
                "SET value = IIF(json_valid(@value), @value ->> '$', @value), tag = @tag, " +
                "timestamp = strftime('%s', 'now');";

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    SqlBindInt   (q, "@type", nType);
    SqlBindString(q, "@varname", sVarName);
    SqlBindString(q, "@tag", sTag);
    return q;
}

/// @private Prepares an update query to modify the tag assicated with a variable.
sqlquery _PrepareTagUpdate(object oObject, int nType, string sVarName, string sTag1, string sTag2)
{
    int bPC       = GetIsPC(oObject);
    int bCampaign = oObject == DB_CAMPAIGN;
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;

    string s =  "UPDATE " + sTable + " SET tag = @tag2 WHERE type = @type " +
                    "AND varname GLOB @varname AND tag GLOB tag1;";

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    SqlBindInt   (q, "@type", nType);
    SqlBindString(q, "@varname", sVarName);
    SqlBindString(q, "@tag1", sTag1);
    SqlBindString(q, "@tag2", sTag2);
    return q;    
}

/// @private Prepares an delete query to remove a variable stored in any database.
sqlquery _PrepareSimpleVariableDelete(object oObject, int nType, string sVarName, string sTag)
{
    int bPC       = GetIsPC(oObject);
    int bCampaign = oObject == DB_CAMPAIGN;
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;

    string s =  "DELETE FROM " + sTable + " WHERE type = @type " +
                    "AND varname GLOB @varname AND tag GLOB @tag " +
                "RETURNING value;";

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    SqlBindInt   (q, "@type", nType);
    SqlBindString(q, "@varname", sVarName);
    SqlBindString(q, "@tag", sTag);
    return q;
}

/// @private Prepares a complex delete query to remove multiple variables by criteria.
/// @param nType Bitwise VARIABLE_TYPE_*.
/// @param sVarName Variable name pattern, accept glob patterns, sets and wildcards.
/// @param sTag Tag pattern, accepts glob patterns, sets and wildcards.
/// @param nTime A positive value will filter for timestamps after
///     nTime, a negative value will filter for timestamps before nTime.
sqlquery _PrepareComplexVariableDelete(object oObject, int nType, string sVarName, string sTag, int nTime)
{
    int n, bPC    = GetIsPC(oObject);
    int bCampaign = oObject == DB_CAMPAIGN;
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;

    string sWhere =  (sVarName == "" ? "" : " $" + IntToString(++n) + " varname GLOB @varname");
           sWhere += (sTag == ""     ? "" : " $" + IntToString(++n) + " tag GLOB @tag");
           sWhere += (nType <= 0     ? "" : " $" + IntToString(++n) + " (type & @type) > 0");
           sWhere += (nTime == 0     ? "" : " $" + IntToString(++n) + " timestamp " + (nTime > 0 ? ">" : "<") + " @time");

    json jKeyWords = ListToJson("WHERE,AND,AND,AND");
    string s = SubstituteString("DELETE FROM " + sTable + sWhere + ";", jKeyWords);

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    if (sVarName != "") SqlBindString(q, "@varname", sVarName);
    if (sTag != "")     SqlBindString(q, "@tag", sTag);
    if (nType > 0)      SqlBindInt   (q, "@type", nType);
    if (nTime != 0)     SqlBindInt   (q, "@time", abs(nTime));
    return q;
}

/// @private Retrieves variables from database associated with oObject and returns
///     selected variables in a json array containing variable metadata and value.
/// @param nType Bitwise VARIABLE_TYPE_*
/// @param sVarName Variable name pattern, accept glob patterns, sets and wildcards
/// @param sTag Tag pattern, accepts glob patterns, sets and wildcards
/// @param nTime A positive value will filter for timestamps after
///     nTime, a negative value will filter for timestamps before nTime.
/// @warning If no parameters are passed, this query will result in no variables being
///     retrieved.
json _DatabaseVariablesToJson(object oObject, int nType, string sVarName, string sTag, int nTime)
{
    int n, bPC    = GetIsPC(oObject);
    int bCampaign = oObject == DB_CAMPAIGN;
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;

    string sWhere =  (sVarName == "" ? "" : " $" + IntToString(++n) + " varname GLOB @varname");
           sWhere += (sTag == ""     ? "" : " $" + IntToString(++n) + " tag GLOB @tag");
           sWhere += (nType <= 0     ? "" : " $" + IntToString(++n) + " (type & @type) > 0");
           sWhere += (nTime == 0     ? "" : " $" + IntToString(++n) + " timestamp " + (nTime > 0 ? ">" : "<") + " @time");

    json jKeyWords = ListToJson("WHERE,AND,AND,AND");
    string s = "WITH json_variables AS (SELECT json_object('type', type, 'varname', varname, " +
                    "'tag', tag, 'value', value, 'timestamp', timestamp) AS variable_object " +
                    "FROM " + sTable + sWhere + ") " +
                "SELECT json_group_array(json(variable_object)) FROM json_variables;";
    s = SubstituteString(s, jKeyWords);

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    if (sVarName != "") SqlBindString(q, "@varname", sVarName);
    if (sTag != "")     SqlBindString(q, "@tag", sTag);
    if (nType > 0)      SqlBindInt   (q, "@type", nType);
    if (nTime != 0)     SqlBindInt   (q, "@time", abs(nTime));

    return SqlStep(q) ? SqlGetJson(q, 0) : JsonArray();
}

json _LocalVariablesToJson(object oObject, int nType, string sVarName)
{
    if (!GetIsObjectValid(oObject) || oObject == DB_MODULE)
        return JsonArray();

    json jVarTable = JsonPointer(ObjectToJson(oObject, TRUE), "/VarTable/value");
    if (!JsonGetLength(jVarTable))
        return JsonArray();

    int n;
    string sWhere =  (sVarName == "" ? "" : " $" + IntToString(++n) + " variable_object ->> 'varname' GLOB @varname");
           sWhere += (nType <= 0     ? "" : " $" + IntToString(++n) + " variable_object ->> 'type' IN (" + _VariableTypeToArray(nType) + ")"); 
    
    json jKeyWords = ListToJson("WHERE,AND");
    string s = "WITH local_variables AS (SELECT json_object('type', v.value -> 'Type.value', " +
                    "'varname', v.value -> 'Name.value', 'value', v.value -> 'Value.value') " +
                    "as variable_object FROM json_each(@vartable) as v) " +
                "SELECT json_group_array(json(variable_object)) FROM local_variables " + sWhere + ";";
    s = SubstituteString(s, jKeyWords);

    sqlquery q = SqlPrepareQueryObject(DB_MODULE, s);
    SqlBindJson(q, "@vartable", jVarTable);
    SqlBindString(q, "@varname", sVarName);

    return SqlStep(q) ? SqlGetJson(q, 0) : JsonArray();
}

/// @private Increments/Decremenst an existing variable (int/float).  If the variable
///     does not exist, creates variable, then increments/decrements.
sqlquery _PrepareVariableIncrement(object oObject, int nType, string sVarName, string sTag)
{
    int bPC       = GetIsPC(oObject);
    int bCampaign = oObject == DB_CAMPAIGN;
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;

    string s =  "INSERT INTO " + sTable + " (type, varname, value, tag, timestamp) " +
                "VALUES (@type, @varname, @value, @tag, strftime('%s','now')) " +
                "ON CONFLICT (type, varname, tag) DO UPDATE SET value = value + @value, " +
                    "timestamp = strftime('%s','now') RETURNING value;";

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    SqlBindInt   (q, "@type", nType);
    SqlBindString(q, "@varname", sVarName);
    SqlBindString(q, "@tag", sTag);
    return q;
}

/// @private Appends a string to an existing variable.  If the variables does not
///     exist, creates the variable, then appends.
sqlquery _PrepareVariableAppend(object oObject, string sVarName, string sTag)
{
    int bPC       = GetIsPC(oObject);
    int bCampaign = oObject == DB_CAMPAIGN;
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;

    string s =  "INSERT INTO " + sTable + " " +
                    "(type, varname, value, tag, timestamp) " +
                "VALUES (@type, @varname, @value, @tag, strftime('%s', 'now')) " +
                "ON CONFLICT (type, varname, tag) " +
                    "DO UPDATE SET value = value || @value, " +
                        "timestamp = strftime('%s', 'now') " +
                "RETURNING value;";

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    SqlBindString(q, "@varname", sVarName);
    SqlBindString(q, "@tag", sTag);
    return q;
}

/// @private Opens an sqlite transaction
void _BeginSQLTransaction(object oObject)
{
    int bPC       = GetIsPC(oObject);
    int bCampaign = oObject == DB_CAMPAIGN;

    string s = "BEGIN TRANSACTION;";
    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    SqlStep(q);
}

/// @private Commits an open sqlite transaction
void _CommitSQLTransaction(object oObject)
{
    int bPC       = GetIsPC(oObject);
    int bCampaign = oObject == DB_CAMPAIGN;

    string s = "COMMIT TRANSACTION;";
    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    SqlStep(q);   
}

/// @private Copies specified variables from oSource (game object) to oTarget (db).
void _CopyVariablesToDatabase(object oSource, object oDatabase, int nTypes,
                              string sVarNames, string sTag, int bDelete)
{
    if (oSource == GetModule())
        return;

    if (!GetIsPC(oDatabase) && oDatabase != DB_MODULE && oDatabase != DB_CAMPAIGN)
    {
        if (IsDebugging(DEBUG_LEVEL_NOTICE))
            Notice("Attempt to copy local variables to database failed:" +
                "\n  oSource -> " + GetName(oSource) +
                "\n  oDatabase -> " + GetName(oDatabase) +
                "\n  nTypes -> " + IntToHexString(nTypes) +
                "\n  sVarName -> " + sVarNames +
                "\n  sTag -> " + sTag +
                "\n  bDelete -> " + (bDelete ? "TRUE" : "FALSE"));
        return;
    }

    json jVariables = GetLocalVariables(oSource, nTypes, sVarNames);
    int nCount = JsonGetLength(jVariables);

    if (!nCount)
        return;
    
    _BeginSQLTransaction(oDatabase);
    int n; for (n; n < nCount; n++)
    {
        json   jVariable = JsonPointer(jVariables, "/" + IntToString(n));
        int    nType     = JsonGetInt(JsonPointer(jVariable, "/type"));
        string sVarName  = JsonGetString(JsonPointer(jVariable, "/varname"));
        json   jValue    = JsonPointer(jVariable, "/value");

        sVarName = ObjectToDatabaseVarName(oSource, oDatabase, sVarName, nType, sTag);
        sTag     = ObjectToDatabaseTag(oSource, oDatabase, sVarName, nType, sTag);

        sqlquery q = _PrepareVariableInsert(oDatabase, nType, sVarName, sTag);
        SqlBindJson(q, "@value", jValue);
        SqlStep(q);

        if (bDelete)
            _DeleteLocalVariable(oSource, sVarName, nType);
    }
    _CommitSQLTransaction(oDatabase);
}

/// @private Copies specified variables from oSource (db) to oTarget (game object).
void _CopyVariablesToObject(object oDatabase, object oTarget, int nTypes, string sVarNames,
                            string sTag, int nTime, int bDelete)
{
    if (!GetIsPC(oDatabase) && oDatabase != DB_MODULE && oDatabase != DB_CAMPAIGN)
    {
        if (IsDebugging(DEBUG_LEVEL_NOTICE))
            Notice("Attempt to copy database variables to game object failed:" +
                "\n  oDatabase -> " + GetName(oDatabase) +
                "\n  oTarget -> " + GetName(oTarget) +
                "\n  nTypes -> " + IntToHexString(nTypes) +
                "\n  sVarName -> " + sVarNames +
                "\n  sTag -> " + sTag +
                "\n  nTime -> " + IntToString(nTime) +
                "\n  bDelete -> " + (bDelete ? "TRUE" : "FALSE"));
        return;
    }

    json jVariables = _DatabaseVariablesToJson(oDatabase, nTypes, sVarNames, sTag, nTime);
    int nCount = JsonGetLength(jVariables);

    if (!nCount)
        return;

    int n; for (n; n < nCount; n++)
    {
        json   jVariable = JsonPointer(jVariables, "/" + IntToString(n));
        int    nType     = JsonGetInt(JsonPointer(jVariable, "/type"));
        string sVarName  = JsonGetString(JsonPointer(jVariable, "/varname"));
        string sTag      = JsonGetString(JsonPointer(jVariables, "/tag"));
        json   jValue    = JsonPointer(jVariable, "/value");

        _SetLocalVariable(oTarget, DatabaseToObjectVarName(oDatabase, oTarget, sVarName, sTag, nType), nType, jValue);
    }

    if (bDelete)
        SqlStep(_PrepareComplexVariableDelete(oDatabase, nTypes, sVarNames, sTag, nTime));
}

void _CopyDatabaseVariablesToDatabase(object oSource, object oTarget, int nTypes, string sVarNames,
                                      string sTag, int nTime, int bDelete)
{
    if ((!GetIsPC(oSource) && oSource != DB_MODULE && oSource != DB_CAMPAIGN) ||
        (!GetIsPC(oTarget) && oTarget != DB_MODULE && oTarget != DB_CAMPAIGN) ||
        (oSource == oTarget))
    {
        if (IsDebugging(DEBUG_LEVEL_NOTICE))
            Notice("Attempt to copy variables between databases failed:" +
                "\n  oSource -> " + GetName(oSource) +
                "\n  oTarget -> " + GetName(oTarget) +
                "\n  nTypes -> " + IntToHexString(nTypes) +
                "\n  sVarName -> " + sVarNames +
                "\n  sTag -> " + sTag +
                "\n  nTime -> " + IntToString(nTime) +
                "\n  bDelete -> " + (bDelete ? "TRUE" : "FALSE"));
        return;
    }

    json jVariables = _DatabaseVariablesToJson(oSource, nTypes, sVarNames, sTag, nTime);

    int bPC       = GetIsPC(oTarget);
    int bCampaign = oTarget == DB_CAMPAIGN;
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;

    string s = "INSERT INTO " + sTable + " (type, varname, value, tag, timestamp) " +
        "SELECT value ->> '$.type', value ->> '$.varname', value ->> '$.value', " +
        "value ->> '$.tag', strftime('%s','now') FROM (SELECT value FROM json_each(@variables));";

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oTarget, s) : _PrepareQueryCampaign(s);
    SqlBindJson(q, "@variables", jVariables);
    SqlStep(q);

    if (bDelete)
        SqlStep(_PrepareComplexVariableDelete(oSource, nTypes, sVarNames, sTag, nTime));
}

void _CopyLocalVariablesToObject(object oSource, object oTarget, int nTypes,
                                 string sVarNames, int bDelete)
{
    if (oSource == GetModule())
    {
        Notice("Attempt to copy variables between objects failed; " +
            "cannot copy from the module object");
        return;
    }
    else if (oSource == oTarget)
        return;

    json jVariables = _LocalVariablesToJson(oSource, nTypes, sVarNames);
    int nCount = JsonGetLength(jVariables);

    if (!nCount)
        return;

    int n; for (n; n < nCount; n++)
    {
        json   jVariable = JsonPointer(jVariables, "/" + IntToString(n));
        int    nType     = JsonGetInt(JsonPointer(jVariable, "/type"));
        string sVarName  = JsonGetString(JsonPointer(jVariable, "/varname"));
        json   jValue    = JsonPointer(jVariable, "/value");

        _SetLocalVariable(oTarget, sVarName, nType, jValue);

        if (bDelete)
            _DeleteLocalVariable(oSource, sVarName, nType);
    }
}

// -----------------------------------------------------------------------------
//                             Public Functions
// -----------------------------------------------------------------------------

void CreateVariableTable(object oObject)
{
    string sVarName = VARIABLE_OBJECT;
    string sTable   = VARIABLE_TABLE_MODULE;
    int bCampaign   = oObject == DB_CAMPAIGN;

    if (bCampaign)
    {
        sVarName = VARIABLE_CAMPAIGN;
        oObject = DB_MODULE;
    }
    else if (GetIsPC(oObject))
        sTable = VARIABLE_TABLE_PC;
    else if (oObject != DB_MODULE)
        return;

    if (GetLocalInt(oObject, sVarName))
        return;

    string s = "CREATE TABLE IF NOT EXISTS " + sTable + " (" +
        "type INTEGER, " +
        "varname TEXT, " +
        "tag TEXT, " +
        "value TEXT, " +
        "timestamp INTEGER, " +
        "PRIMARY KEY (type, varname, tag));";

    sqlquery q;
    if (bCampaign)
        q = SqlPrepareQueryCampaign(VARIABLE_CAMPAIGN_DATABASE, s);
    else
        q = SqlPrepareQueryObject(oObject, s);

    SqlStep(q);
    SetLocalInt(oObject, sVarName, TRUE);
}

// -----------------------------------------------------------------------------
//                               Local Variables
// -----------------------------------------------------------------------------

json GetLocalVariables(object oObject, int nType = VARIABLE_TYPE_ALL, string sVarName = "*")
{
    if (oObject == DB_MODULE)
        return JsonArray();

    json jVariables = _LocalVariablesToJson(oObject, nType, sVarName);
    int nCount = JsonGetLength(jVariables);

    if (!nCount)
        return JsonArray();

    int n; for (n; n < nCount; n++)
    {
        json j = JsonArrayGet(jVariables, n);
             j = JsonObjectSet(j, "type", JsonInt(_TypeToVariableType(JsonObjectGet(j, "type"))));

        jVariables = JsonArraySet(jVariables, n, j);
    }

    return jVariables;
}

void DeleteLocalVariables(object oObject, int nTypes = VARIABLE_TYPE_NONE, string sVarNames = "")
{
    json jVariables = GetLocalVariables(oObject, nTypes, sVarNames);
    int n; for (n; n < JsonGetLength(jVariables); n++)
    {
        json   jVariable = JsonArrayGet(jVariables, n);
        int    nType     = JsonGetInt(JsonObjectGet(jVariable, "type"));
        string sName     = JsonGetString(JsonObjectGet(jVariable, "varname"));

        _DeleteLocalVariable(oObject, sName, nType);
    }
}

void CopyLocalVariablesToObject(object oSource, object oTarget, int nType = VARIABLE_TYPE_ALL,
                                string sVarName = "", int bDelete = TRUE)
{
    _CopyLocalVariablesToObject(oSource, oTarget, nType, sVarName, bDelete);
}

void CopyLocalVariablesToDatabase(object oSource, object oDatabase, int nType = VARIABLE_TYPE_ALL,
                                  string sVarName = "", string sTag = "", int bDelete = TRUE)
{
    _CopyVariablesToDatabase(oSource, oDatabase, nType, sVarName, sTag, bDelete);
}

void CopyDatabaseVariablesToObject(object oDatabase, object oTarget, int nType = VARIABLE_TYPE_ALL, 
                                   string sVarName = "", string sTag = "", int nTime = 0, int bDelete = TRUE)
{
    _CopyVariablesToObject(oDatabase, oTarget, nType, sVarName, sTag, nTime, bDelete);
}

void CopyDatabaseVariablesToDatabase(object oSource, object oTarget, int nType = VARIABLE_TYPE_ALL,
                                     string sVarName = "", string sTag = "", int nTime = 0, int bDelete = TRUE)
{
    _CopyDatabaseVariablesToDatabase(oSource, oTarget, nType, sVarName, sTag, nTime, bDelete);
}

int HasLocalInt(object oObject, string sVarName)
{
    return JsonGetLength(_LocalVariablesToJson(oObject, VARIABLE_TYPE_INT, sVarName));
}

int HasLocalFloat(object oObject, string sVarName)
{
    return JsonGetLength(_LocalVariablesToJson(oObject, VARIABLE_TYPE_FLOAT, sVarName));
}

int HasLocalString(object oObject, string sVarName)
{
    return JsonGetLength(_LocalVariablesToJson(oObject, VARIABLE_TYPE_STRING, sVarName));
}

int HasLocalObject(object oObject, string sVarName)
{
    return JsonGetLength(_LocalVariablesToJson(oObject, VARIABLE_TYPE_OBJECT, sVarName));
}

int HasLocalLocation(object oObject, string sVarName)
{
    return JsonGetLength(_LocalVariablesToJson(oObject, VARIABLE_TYPE_LOCATION, sVarName));
}

int HasLocalJson(object oObject, string sVarName)
{
    return JsonGetLength(_LocalVariablesToJson(oObject, VARIABLE_TYPE_JSON, sVarName));
}

// SetModule* ------------------------------------------------------------------

void SetModuleInt(string sVarName, int nValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_MODULE, VARIABLE_TYPE_INT, sVarName, sTag);
    SqlBindInt(q, "@value", nValue);
    SqlStep(q);
}

void SetModuleFloat(string sVarName, float fValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_MODULE, VARIABLE_TYPE_FLOAT, sVarName, sTag);
    SqlBindFloat(q, "@value", fValue);
    SqlStep(q);
}

void SetModuleString(string sVarName, string sValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_MODULE, VARIABLE_TYPE_STRING, sVarName, sTag);
    SqlBindString(q, "@value", sValue);
    SqlStep(q);
}

void SetModuleObject(string sVarName, object oValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_MODULE, VARIABLE_TYPE_OBJECT, sVarName, sTag);
    SqlBindString(q, "@value", ObjectToString(oValue));
    SqlStep(q);
}

void SetModuleSerialized(string sVarName, object oValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_MODULE, VARIABLE_TYPE_SERIALIZED, sVarName, sTag);
    SqlBindJson(q, "@value", ObjectToJson(oValue, TRUE));
    SqlStep(q);
}

void SetModuleLocation(string sVarName, location lValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_MODULE, VARIABLE_TYPE_LOCATION, sVarName, sTag);
    SqlBindJson(q, "@value", LocationToJson(lValue));
    SqlStep(q);
}

void SetModuleVector(string sVarName, vector vValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_MODULE, VARIABLE_TYPE_VECTOR, sVarName, sTag);
    SqlBindJson(q, "@value", VectorToJson(vValue));
    SqlStep(q);
}

void SetModuleJson(string sVarName, json jValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_MODULE, VARIABLE_TYPE_JSON, sVarName, sTag);
    SqlBindJson(q, "@value", jValue);
    SqlStep(q);
}

void SetModuleVariableTag(int nType, string sVarName, string sTag = "", string sNewTag = "")
{
    SqlStep(_PrepareTagUpdate(DB_MODULE, nType, sVarName, sTag, sNewTag));
}

// GetModule* ------------------------------------------------------------------

int GetModuleInt(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_MODULE, VARIABLE_TYPE_INT, sVarName, sTag);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

float GetModuleFloat(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_MODULE, VARIABLE_TYPE_FLOAT, sVarName, sTag);
    return SqlStep(q) ? SqlGetFloat(q, 0) : 0.0;
}

string GetModuleString(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_MODULE, VARIABLE_TYPE_STRING, sVarName, sTag);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

object GetModuleObject(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_MODULE, VARIABLE_TYPE_OBJECT, sVarName, sTag);
    return SqlStep(q) ? StringToObject(SqlGetString(q, 0)) : OBJECT_INVALID;
}

object GetModuleSerialized(string sVarName, string sTag, location l, object oTarget = OBJECT_INVALID)
{
    sqlquery q = _PrepareVariableSelect(DB_MODULE, VARIABLE_TYPE_SERIALIZED, sVarName, sTag);
    return SqlStep(q) ? JsonToObject(SqlGetJson(q, 0), l, oTarget, TRUE) : OBJECT_INVALID;
}

location GetModuleLocation(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_MODULE, VARIABLE_TYPE_LOCATION, sVarName, sTag);
    return SqlStep(q) ? JsonToLocation(SqlGetJson(q, 0)) : Location(OBJECT_INVALID, Vector(), 0.0);
}

vector GetModuleVector(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_MODULE, VARIABLE_TYPE_VECTOR, sVarName, sTag);

    vector v;
    if (SqlStep(q)) v = JsonToVector(SqlGetJson(q, 0));
    else            v = Vector();

    return v;
}

json GetModuleJson(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_MODULE, VARIABLE_TYPE_JSON, sVarName, sTag);
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();
}

json GetModuleVariablesByPattern(int nType = VARIABLE_TYPE_ALL, string sVarName = "",
                                 string sTag = "", int nTime = 0)
{
    return _DatabaseVariablesToJson(DB_MODULE, nType, sVarName, sTag, nTime);
}

// DeleteModule* ---------------------------------------------------------------

int DeleteModuleInt(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_MODULE, VARIABLE_TYPE_INT, sVarName, sTag);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

float DeleteModuleFloat(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_MODULE, VARIABLE_TYPE_FLOAT, sVarName, sTag);
    return SqlStep(q) ? SqlGetFloat(q, 0) : 0.0;
}

string DeleteModuleString(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_MODULE, VARIABLE_TYPE_STRING, sVarName, sTag);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

object DeleteModuleObject(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_MODULE, VARIABLE_TYPE_OBJECT, sVarName, sTag);
    return SqlStep(q) ? StringToObject(SqlGetString(q, 0)) : OBJECT_INVALID;
}

void DeleteModuleSerialized(string sVarName, string sTag = "")
{
    SqlStep(_PrepareSimpleVariableDelete(DB_MODULE, VARIABLE_TYPE_SERIALIZED, sVarName, sTag));
}

location DeleteModuleLocation(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_MODULE, VARIABLE_TYPE_LOCATION, sVarName, sTag);
    return SqlStep(q) ? JsonToLocation(SqlGetJson(q, 0)) : Location(OBJECT_INVALID, Vector(), 0.0);
}

vector DeleteModuleVector(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_MODULE, VARIABLE_TYPE_VECTOR, sVarName, sTag);

    vector v;
    if (SqlStep(q)) v = JsonToVector(SqlGetJson(q, 0));
    else            v = Vector();

    return v;
}

json DeleteModuleJson(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_MODULE, VARIABLE_TYPE_JSON, sVarName, sTag);
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();
}

void DeleteModuleVariables()
{
    SqlStep(_PrepareComplexVariableDelete(DB_MODULE, VARIABLE_TYPE_NONE, "*", "*", 0));
}

void DeleteModuleVariablesByPattern(int nType = VARIABLE_TYPE_NONE, string sVarName = "",
                                    string sTag = "*", int nTime = 0)
{
    SqlStep(_PrepareComplexVariableDelete(DB_MODULE, nType, sVarName, sTag, nTime));
}

int IncrementModuleInt(string sVarName, int nIncrement = 1, string sTag = "")
{
    sqlquery q = _PrepareVariableIncrement(DB_MODULE, VARIABLE_TYPE_INT, sVarName, sTag);
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
    sqlquery q = _PrepareVariableIncrement(DB_MODULE, VARIABLE_TYPE_FLOAT, sVarName, sTag);
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
    sqlquery q = _PrepareVariableAppend(DB_MODULE, sVarName, sTag);
    SqlBindString(q, "@value", sAppend);
    SqlBindInt   (q, "@type", VARIABLE_TYPE_STRING);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

// Player Database -------------------------------------------------------------

void SetPlayerInt(object oPlayer, string sVarName, int nValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(oPlayer, VARIABLE_TYPE_INT, sVarName, sTag);
    SqlBindInt(q, "@value", nValue);
    SqlStep(q);
}

void SetPlayerFloat(object oPlayer, string sVarName, float fValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(oPlayer, VARIABLE_TYPE_FLOAT, sVarName, sTag);
    SqlBindFloat(q, "@value", fValue);
    SqlStep(q);
}

void SetPlayerString(object oPlayer, string sVarName, string sValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(oPlayer, VARIABLE_TYPE_STRING, sVarName, sTag);
    SqlBindString(q, "@value", sValue);
    SqlStep(q);
}

void SetPlayerObject(object oPlayer, string sVarName, object oValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(oPlayer, VARIABLE_TYPE_OBJECT, sVarName, sTag);
    SqlBindString(q, "@value", ObjectToString(oValue));
    SqlStep(q);
}

void SetPlayerSerialized(object oPlayer, string sVarName, object oValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(oPlayer, VARIABLE_TYPE_SERIALIZED, sVarName, sTag);
    SqlBindJson(q, "@value", ObjectToJson(oValue, TRUE));
    SqlStep(q);
}

void SetPlayerLocation(object oPlayer, string sVarName, location lValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(oPlayer, VARIABLE_TYPE_LOCATION, sVarName, sTag);
    SqlBindJson(q, "@value", LocationToJson(lValue));
    SqlStep(q);
}

void SetPlayerVector(object oPlayer, string sVarName, vector vValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(oPlayer, VARIABLE_TYPE_VECTOR, sVarName, sTag);
    SqlBindJson(q, "@value", VectorToJson(vValue));
    SqlStep(q);
}

void SetPlayerJson(object oPlayer, string sVarName, json jValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(oPlayer, VARIABLE_TYPE_JSON, sVarName, sTag);
    SqlBindJson(q, "@value", jValue);
    SqlStep(q);
}

// GetPlayer* ------------------------------------------------------------------

int GetPlayerInt(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(oPlayer, VARIABLE_TYPE_INT, sVarName, sTag);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

float GetPlayerFloat(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(oPlayer, VARIABLE_TYPE_FLOAT, sVarName, sTag);
    return SqlStep(q) ? SqlGetFloat(q, 0) : 0.0;
}

string GetPlayerString(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(oPlayer, VARIABLE_TYPE_STRING, sVarName, sTag);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

object GetPlayerObject(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(oPlayer, VARIABLE_TYPE_OBJECT, sVarName, sTag);
    return SqlStep(q) ? StringToObject(SqlGetString(q, 0)) : OBJECT_INVALID;
}

object GetPlayerSerialized(object oPlayer, string sVarName, string sTag, location l, object oTarget = OBJECT_INVALID)
{
    sqlquery q = _PrepareVariableSelect(oPlayer, VARIABLE_TYPE_SERIALIZED, sVarName, sTag);
    return SqlStep(q) ? JsonToObject(SqlGetJson(q, 0), l, oTarget, TRUE) : OBJECT_INVALID;
}

location GetPlayerLocation(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(oPlayer, VARIABLE_TYPE_LOCATION, sVarName, sTag);
    return SqlStep(q) ? JsonToLocation(SqlGetJson(q, 0)) : Location(OBJECT_INVALID, Vector(), 0.0);
}

vector GetPlayerVector(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(oPlayer, VARIABLE_TYPE_VECTOR, sVarName, sTag);

    vector v;
    if (SqlStep(q)) v = JsonToVector(SqlGetJson(q, 0));
    else            v = Vector();

    return v;
}

json GetPlayerJson(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(oPlayer, VARIABLE_TYPE_JSON, sVarName, sTag);
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();
}

json GetPlayerVariablesByPattern(object oPlayer, int nType = VARIABLE_TYPE_ALL,
                                 string sVarName = "", string sTag = "", int nTime = 0)
{
    return _DatabaseVariablesToJson(oPlayer, nType, sVarName, sTag, nTime);
}

// DeletePlayer* ---------------------------------------------------------------

int DeletePlayerInt(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(oPlayer, VARIABLE_TYPE_INT, sVarName, sTag);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

float DeletePlayerFloat(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(oPlayer, VARIABLE_TYPE_FLOAT, sVarName, sTag);
    return SqlStep(q) ? SqlGetFloat(q, 0) : 0.0;
}

string DeletePlayerString(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(oPlayer, VARIABLE_TYPE_STRING, sVarName, sTag);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

object DeletePlayerObject(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(oPlayer, VARIABLE_TYPE_OBJECT, sVarName, sTag);
    return SqlStep(q) ? StringToObject(SqlGetString(q, 0)) : OBJECT_INVALID;
}

void DeletePlayerSerialized(object oPlayer, string sVarName, string sTag = "")
{
    SqlStep(_PrepareSimpleVariableDelete(oPlayer, VARIABLE_TYPE_SERIALIZED, sVarName, sTag));
}

location DeletePlayerLocation(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(oPlayer, VARIABLE_TYPE_LOCATION, sVarName, sTag);
    return SqlStep(q) ? JsonToLocation(SqlGetJson(q, 0)) : Location(OBJECT_INVALID, Vector(), 0.0);
}

vector DeletePlayerVector(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(oPlayer, VARIABLE_TYPE_VECTOR, sVarName, sTag);

    vector v;
    if (SqlStep(q)) v = JsonToVector(SqlGetJson(q, 0));
    else            v = Vector();

    return v;
}

json DeletePlayerJson(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(oPlayer, VARIABLE_TYPE_JSON, sVarName, sTag);
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();
}

void DeletePlayerVariables(object oPlayer)
{
    SqlStep(_PrepareComplexVariableDelete(oPlayer, 0, "*", "*", 0));
}

void DeletePlayerVariablesByPattern(object oPlayer, int nType = VARIABLE_TYPE_NONE,
                                    string sVarName = "", string sTag = "", int nTime = 0)
{
    SqlStep(_PrepareComplexVariableDelete(oPlayer, nType, sVarName, sTag, nTime));
}

int IncrementPlayerInt(object oPlayer, string sVarName, int nIncrement = 1, string sTag = "")
{
    sqlquery q = _PrepareVariableIncrement(oPlayer, VARIABLE_TYPE_INT, sVarName, sTag);
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
    sqlquery q = _PrepareVariableIncrement(oPlayer, VARIABLE_TYPE_FLOAT, sVarName, sTag);
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
    sqlquery q = _PrepareVariableAppend(oPlayer, sVarName, sTag);
    SqlBindString(q, "@value", sAppend);
    SqlBindInt   (q, "@type", VARIABLE_TYPE_STRING);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

// SetPersistent* ------------------------------------------------------------------

void SetPersistentInt(string sVarName, int nValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_CAMPAIGN, VARIABLE_TYPE_INT, sVarName, sTag);
    SqlBindInt(q, "@value", nValue);
    SqlStep(q);
}

void SetPersistentFloat(string sVarName, float fValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_CAMPAIGN, VARIABLE_TYPE_FLOAT, sVarName, sTag);
    SqlBindFloat(q, "@value", fValue);
    SqlStep(q);
}

void SetPersistentString(string sVarName, string sValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_CAMPAIGN, VARIABLE_TYPE_STRING, sVarName, sTag);
    SqlBindString(q, "@value", sValue);
    SqlStep(q);
}

void SetPersistentObject(string sVarName, object oValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_CAMPAIGN, VARIABLE_TYPE_OBJECT, sVarName, sTag);
    SqlBindString(q, "@value", ObjectToString(oValue));
    SqlStep(q);
}

void SetPersistentSerialized(string sVarName, object oValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_CAMPAIGN, VARIABLE_TYPE_SERIALIZED, sVarName, sTag);
    SqlBindJson(q, "@value", ObjectToJson(oValue, TRUE));
    SqlStep(q);
}

void SetPersistentLocation(string sVarName, location lValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_CAMPAIGN, VARIABLE_TYPE_LOCATION, sVarName, sTag);
    SqlBindJson(q, "@value", LocationToJson(lValue));
    SqlStep(q);
}

void SetPersistentVector(string sVarName, vector vValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_CAMPAIGN, VARIABLE_TYPE_VECTOR, sVarName, sTag);
    SqlBindJson(q, "@value", VectorToJson(vValue));
    SqlStep(q);
}

void SetPersistentJson(string sVarName, json jValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_CAMPAIGN, VARIABLE_TYPE_JSON, sVarName, sTag);
    SqlBindJson(q, "@value", jValue);
    SqlStep(q);
}

void SetPersistentVariableTag(int nType, string sVarName, string sTag = "", string sNewTag = "")
{
    SqlStep(_PrepareTagUpdate(DB_CAMPAIGN, nType, sVarName, sTag, sNewTag));
}

// GetPersistent* ------------------------------------------------------------------

int GetPersistentInt(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_CAMPAIGN, VARIABLE_TYPE_INT, sVarName, sTag);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

float GetPersistentFloat(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_CAMPAIGN, VARIABLE_TYPE_FLOAT, sVarName, sTag);
    return SqlStep(q) ? SqlGetFloat(q, 0) : 0.0;
}

string GetPersistentString(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_CAMPAIGN, VARIABLE_TYPE_STRING, sVarName, sTag);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

object GetPersistentObject(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_CAMPAIGN, VARIABLE_TYPE_OBJECT, sVarName, sTag);
    return SqlStep(q) ? StringToObject(SqlGetString(q, 0)) : OBJECT_INVALID;
}

object GetPersistentSerialized(string sVarName, string sTag, location l, object oTarget = OBJECT_INVALID)
{
    sqlquery q = _PrepareVariableSelect(DB_CAMPAIGN, VARIABLE_TYPE_SERIALIZED, sVarName, sTag);
    return SqlStep(q) ? JsonToObject(SqlGetJson(q, 0), l, oTarget, TRUE) : OBJECT_INVALID;
}

location GetPersistentLocation(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_CAMPAIGN, VARIABLE_TYPE_LOCATION, sVarName, sTag);
    return SqlStep(q) ? JsonToLocation(SqlGetJson(q, 0)) : Location(OBJECT_INVALID, Vector(), 0.0);
}

vector GetPersistentVector(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_CAMPAIGN, VARIABLE_TYPE_VECTOR, sVarName, sTag);

    vector v;
    if (SqlStep(q)) v = JsonToVector(SqlGetJson(q, 0));
    else            v = Vector();

    return v;
}

json GetPersistentJson(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_CAMPAIGN, VARIABLE_TYPE_JSON, sVarName, sTag);
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();
}

json GetPersistentVariablesByPattern(int nType = VARIABLE_TYPE_ALL, string sVarName = "*",
                                     string sTag = "*", int nTime = 0)
{
    return _DatabaseVariablesToJson(DB_CAMPAIGN, nType, sVarName, sTag, nTime);
}

// DeletePersistent* ---------------------------------------------------------------

int DeletePersistentInt(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_CAMPAIGN, VARIABLE_TYPE_INT, sVarName, sTag);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

float DeletePersistentFloat(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_CAMPAIGN, VARIABLE_TYPE_FLOAT, sVarName, sTag);
    return SqlStep(q) ? SqlGetFloat(q, 0) : 0.0;
}

string DeletePersistentString(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_CAMPAIGN, VARIABLE_TYPE_STRING, sVarName, sTag);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

object DeletePersistentObject(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_CAMPAIGN, VARIABLE_TYPE_OBJECT, sVarName, sTag);
    return SqlStep(q) ? StringToObject(SqlGetString(q, 0)) : OBJECT_INVALID;
}

void DeletePersistentSerialized(string sVarName, string sTag = "")
{
    SqlStep(_PrepareSimpleVariableDelete(DB_CAMPAIGN, VARIABLE_TYPE_SERIALIZED, sVarName, sTag));
}

location DeletePersistentLocation(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_CAMPAIGN, VARIABLE_TYPE_LOCATION, sVarName, sTag);
    return SqlStep(q) ? JsonToLocation(SqlGetJson(q, 0)) : Location(OBJECT_INVALID, Vector(), 0.0);
}

vector DeletePersistentVector(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_CAMPAIGN, VARIABLE_TYPE_VECTOR, sVarName, sTag);

    vector v;
    if (SqlStep(q)) v = JsonToVector(SqlGetJson(q, 0));
    else            v = Vector();

    return v;
}

json DeletePersistentJson(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_CAMPAIGN, VARIABLE_TYPE_JSON, sVarName, sTag);
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();
}

void DeletePersistentVariables()
{
    SqlStep(_PrepareComplexVariableDelete(DB_CAMPAIGN, 0, "*", "*", 0));
}

void DeletePersistentVariablesByPattern(int nType = VARIABLE_TYPE_NONE, string sVarName = "",
                                    string sTag = "", int nTime = 0)
{
    SqlStep(_PrepareComplexVariableDelete(DB_CAMPAIGN, nType, sVarName, sTag, nTime));
}

int IncrementPersistentInt(string sVarName, int nIncrement = 1, string sTag = "")
{
    sqlquery q = _PrepareVariableIncrement(DB_CAMPAIGN, VARIABLE_TYPE_INT, sVarName, sTag);
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
    sqlquery q = _PrepareVariableIncrement(DB_CAMPAIGN, VARIABLE_TYPE_FLOAT, sVarName, sTag);
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
    sqlquery q = _PrepareVariableAppend(DB_CAMPAIGN, sVarName, sTag);
    SqlBindString(q, "@value", sAppend);
    SqlBindInt   (q, "@type", VARIABLE_TYPE_STRING);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}
