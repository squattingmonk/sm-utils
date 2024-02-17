
/// ----------------------------------------------------------------------------
/// @file   util_i_argstack.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Functions for manipulating an argument stack.
/// @details
/// An argument stack provides a method for library functions to send values
///     to other functions without being able to call them directly.  This allows
///     library functions to abstract away the connection layer and frees the
///     builder to design plug-and-play systems that don't break when unrelated
///     systems are removed or replaced.
///
/// Stacks work on a last in - first out basis and are split by variable type.
///     Popping a value will delete and return the last entered value of the
///     specified type stack.  Other variable types will not be affected.
///
/// ```nwscript
/// PushInt(30);
/// PushInt(40);
/// PushInt(50);
/// PushString("test");
///
/// int nPop = PopInt();       // nPop = 50
/// string sPop = PopString(); // sPop = "test";
/// ```nwscript
/// ----------------------------------------------------------------------------

#include "util_i_varlists"

const string ARGS_DEFAULT_STACK = "ARGS_DEFAULT_STACK";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Push as value onto the stack.
/// @param nValue Value to add to stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Count of values on the stack.
int PushInt(int nValue, string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Pop a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
int PopInt(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Peek a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
int PeekInt(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Retrieve the stack size.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns The number of values in the stack.
int CountIntStack(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Push as value onto the stack.
/// @param sValue Value to add to stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Count of values on the stack.
int PushString(string sValue, string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Pop a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
string PopString(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Peek a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
string PeekString(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Retrieve the stack size.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns The number of values in the stack.
int CountStringStack(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Push as value onto the stack.
/// @param fValue Value to add to stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Count of values on the stack.
int PushFloat(float fValue, string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Pop a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
float PopFloat(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Peek a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
float PeekFloat(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Retrieve the stack size.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns The number of values in the stack.
int CountFloatStack(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Push as value onto the stack.
/// @param oValue Value to add to stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Count of values on the stack.
int PushObject(object oValue, string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Pop a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
object PopObject(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Peek a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
object PeekObject(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Retrieve the stack size.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns The number of values in the stack.
int CountObjectStack(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Push as value onto the stack.
/// @param lValue Value to add to stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.getlistfloat
/// @returns Count of values on the stack.
int PushLocation(location lValue, string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Pop a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
location PopLocation(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Peek a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
location PeekLocation(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Retrieve the stack size.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns The number of values in the stack.
int CountLocationStack(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Push as value onto the stack.
/// @param vValue Value to add to stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Count of values on the stack.
int PushVector(vector vValue, string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Pop a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
vector PopVector(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Peek a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
vector PeekVector(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Retrieve the stack size.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns The number of values in the stack.
int CountVectorStack(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Push as value onto the stack.
/// @param jValue Value to add to stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Count of values on the stack.
int PushJson(json jValue, string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Pop a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
json PopJson(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Peek a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
json PeekJson(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Retrieve the stack size.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns The number of values in the stack.
int CountJsonStack(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Clear all stack values.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @note Use this function to ensure all stack values are cleared.
void ClearStacks(string sListName = "", object oTarget = OBJECT_INVALID);

// -----------------------------------------------------------------------------
//                              Function Definitions
// -----------------------------------------------------------------------------

string _GetListName(string s)
{
    return s == "" ? ARGS_DEFAULT_STACK : s;
}

object _GetTarget(object o)
{
    if (o == OBJECT_INVALID || GetIsObjectValid(o) == FALSE)
        return GetModule();
    return o;
}

int PushInt(int nValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    return InsertListInt(_GetTarget(oTarget), 0, nValue, _GetListName(sListName));
}

int PopInt(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return PopListInt(_GetTarget(oTarget), _GetListName(sListName));
}

int PeekInt(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return GetListInt(_GetTarget(oTarget), 0, _GetListName(sListName));
}

int CountIntStack(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return CountIntList(_GetTarget(oTarget), _GetListName(sListName));
}

int PushString(string sValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    return InsertListString(_GetTarget(oTarget), 0, sValue, _GetListName(sListName));
}

string PopString(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return PopListString(_GetTarget(oTarget), _GetListName(sListName));
}

string PeekString(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return GetListString(_GetTarget(oTarget), 0, _GetListName(sListName));
}

int CountStringStack(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return CountStringList(_GetTarget(oTarget), _GetListName(sListName));
}

int PushFloat(float fValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    return InsertListFloat(_GetTarget(oTarget), 0, fValue, _GetListName(sListName), FALSE);
}

float PopFloat(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return PopListFloat(_GetTarget(oTarget), _GetListName(sListName));
}

float PeekFloat(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return GetListFloat(_GetTarget(oTarget), 0, _GetListName(sListName));
}

int CountFloatStack(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return CountFloatList(_GetTarget(oTarget), _GetListName(sListName));
}

int PushObject(object oValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    return InsertListObject(_GetTarget(oTarget), 0, oValue, _GetListName(sListName));
}

object PopObject(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return PopListObject(_GetTarget(oTarget), _GetListName(sListName));
}

object PeekObject(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return GetListObject(_GetTarget(oTarget), 0, _GetListName(sListName));
}

int CountObjectStack(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return CountObjectList(_GetTarget(oTarget), _GetListName(sListName));
}

int PushLocation(location lValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    return InsertListLocation(_GetTarget(oTarget), 0, lValue, _GetListName(sListName));
}

location PopLocation(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return PopListLocation(_GetTarget(oTarget), _GetListName(sListName));
}

location PeekLocation(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return GetListLocation(_GetTarget(oTarget), 0, _GetListName(sListName));
}

int CountLocationStack(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return CountLocationList(_GetTarget(oTarget), _GetListName(sListName));
}

int PushVector(vector vValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    return InsertListVector(_GetTarget(oTarget), 0, vValue, _GetListName(sListName));
}

vector PopVector(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return PopListVector(_GetTarget(oTarget), _GetListName(sListName));
}

vector PeekVector(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return GetListVector(_GetTarget(oTarget), 0, _GetListName(sListName));
}

int CountVectorStack(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return CountVectorList(_GetTarget(oTarget), _GetListName(sListName));
}

int PushJson(json jValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    return InsertListJson(_GetTarget(oTarget), 0, jValue, _GetListName(sListName));
}

json PopJson(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return PopListJson(_GetTarget(oTarget), _GetListName(sListName));
}

json PeekJson(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return GetListJson(_GetTarget(oTarget), 0, _GetListName(sListName));
}

int CountJsonStack(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return CountJsonList(_GetTarget(oTarget), _GetListName(sListName));
}

void ClearStacks(string sListName = "", object oTarget = OBJECT_INVALID)
{
    sListName = _GetListName(sListName);
    oTarget = _GetTarget(oTarget);

    DeleteIntList(oTarget, sListName);
    DeleteStringList(oTarget, sListName);
    DeleteFloatList(oTarget, sListName);
    DeleteObjectList(oTarget, sListName);
    DeleteLocationList(oTarget, sListName);
    DeleteVectorList(oTarget, sListName);
    DeleteJsonList(oTarget, sListName);
}
