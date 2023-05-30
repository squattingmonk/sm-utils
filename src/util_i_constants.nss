/// ----------------------------------------------------------------------------
/// @file   util_i_constants.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Functions to retrieve the value of a constant from a script file.
/// @details
///
/// ## Example Usage
///
/// To retrieve the value of string constant `MODULE_EVENT_ON_NUI` from the Core
/// Framework file `core_i_constants`:
/// ```nwscript
/// struct CONSTANT c = GetConstantString("MODULE_EVENT_ON_NUI", "core_i_constants");
/// string sSetting = c.sValue;
/// ```
/// If successful, `sSetting` will contain the string value "OnNUI". If not
/// successful, `c.bError` will be TRUE, `c.sError` will contain the reason for
/// the error, and `c.sValue` will be set to an empty string ("").
///
/// To retrieve the value of integer constant `EVENT_STATE_OK`from the Core
/// Framework file `core_i_constants`:
/// ```nwscript
/// struct CONSTANT c = GetConstantInt("EVENT_STATE_OK", "core_i_constants");
/// int nState = c.bError ? -1 : c.nValue;
///
/// // or...
/// if (!c.bError)
/// {
///     int nState = c.nValue;
///     ...
/// }
/// ```
/// If successful, `nState` will contain the integer value 0. Since an error
/// value will also return 0, scripts should check `[struct].bError` before
/// using any constant that could return 0 as a valid value.
///
/// @note These functions require uncompiled `.nss` files, otherwise only base
///     nwscript constants will be retrievable. If you use a tool such as nasher
///     to build your module, ensure you do not filter out the `.nss` files when
///     building.
///
/// @note Based on clippy's code at
///     https://github.com/Finaldeath/nwscript_utility_scripts
/// ----------------------------------------------------------------------------

#include "util_i_debug"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

const string CONSTANTS_RESULT                   = "CONSTANTS_RESULT";
const string CONSTANTS_ERROR_FILE_NOT_FOUND     = "FILE NOT FOUND";
const string CONSTANTS_ERROR_CONSTANT_NOT_FOUND = "VARIABLE DEFINED WITHOUT TYPE";

// -----------------------------------------------------------------------------
//                                     Types
// -----------------------------------------------------------------------------

struct CONSTANT
{
    int    bError;
    string sError;

    string sValue;
    int    nValue;
    float  fValue;

    string sFile;
    string sConstant;
};

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Retrieves a constant string value from a script file
/// @param sConstant Name of the constant, must match case
/// @param sFile Optional: file to retrieve value from; if omitted, nwscript
///     is assumed
/// @returns a CONSTANT structure containing the following:
///     bError - TRUE if the constant could not be found
///     sError - The reason for the error, if any
///     sValue - The value of the constant retrieved, if successful, or ""
struct CONSTANT GetConstantString(string sConstant, string sFile = "");

/// @brief Retrieves a constant integer value from a script file
/// @param sConstant Name of the constant, must match case
/// @param sFile Optional: file to retrieve value from; if omitted, nwscript
///     is assumed
/// @returns a CONSTANT structure containing the following:
///     bError - TRUE if the constant could not be found
///     sError - The reason for the error, if any
///     nValue - The value of the constant retrieved, if successful, or 0
struct CONSTANT GetConstantInt(string sConstant, string sFile = "");

/// @brief Retrieves a constant float value from a script file
/// @param sConstant Name of the constant, must match case
/// @param sFile Optional: file to retrieve value from; if omitted, nwscript
///     is assumed
/// @returns a CONSTANT structure containing the following:
///     bError - TRUE if the constant could not be found
///     sError - The reason for the error, if any
///     fValue - The value of the constant retrieved, if successful, or 0.0
struct CONSTANT GetConstantFloat(string sConstant, string sFile = "");

/// @brief Find an constant name given the constant value.
/// @param sPrefix The prefix portion of the constant name being sought.
/// @param jValue The value of the sPrefix_* constant being sought.  This must be
///     a json value to simplify argument passage.  Create via a Json* function,
///     such as JsonInt(n), JsonString(s) or JsonFloat(f).
/// @param bSuffixOnly If TRUE, will only return the portion of the constant name
///     found after sPrefix, not including an intervening underscore.
/// @param sFile If passed, sFile will be searched for the appropriate constant name.
///     If not passed, `nwscript.nss` will be searched.
/// @note Does not work with nwscript TRUE/FALSE.  Floats that are affected by
///     floating point error, such as 1.67, will also fail to find the correct
///     constant name. Floats that end in .0, such as for DIRECTION_, work correctly.
/// @warning This function is primarily designed for debugging messages.  Using it
///     regularly can result in degraded performance.
string GetConstantName(string sPrefix, json jValue, int bSuffixOnly = FALSE, string sFile = "");

// -----------------------------------------------------------------------------
//                               Private Functions
// -----------------------------------------------------------------------------

// Attempts to retrieve the value of sConstant from sFile.  If found, the
// appropriate fields in struct CONSTANT are populated.  If not, [struct].bError is
// set to TRUE and the reason for failure is populated into [struct].sError.  If the
// error cannot be determined, the error returned by ExecuteScriptChunk is
// populated directly into [struct].sError.
struct CONSTANT constants_RetrieveConstant(string sConstant, string sFile, string sType)
{
    int COLOR_KEY = COLOR_BLUE_LIGHT;
    int COLOR_VALUE = COLOR_SALMON;
    int COLOR_FAILED = COLOR_MESSAGE_FEEDBACK;

    struct CONSTANT c;
    string sError, sChunk = "SetLocal" + sType + "(GetModule(), \"" +
        CONSTANTS_RESULT + "\", " + sConstant + ");";

    c.sConstant = sConstant;
    c.sFile = sFile == "" ? "nwscript" : sFile;

    if (sFile != "")
        sChunk = "#include \"" + sFile + "\" void main() {" + sChunk + "}";

    if ((sError = ExecuteScriptChunk(sChunk, GetModule(), sFile == "")) != "")
    {
        c.bError = TRUE;

        if (FindSubString(sError, CONSTANTS_ERROR_FILE_NOT_FOUND) != -1)
            c.sError = "Unable to find file `" + c.sFile + ".nss`";
        else if (FindSubString(sError, CONSTANTS_ERROR_CONSTANT_NOT_FOUND) != -1)
            c.sError = "Constant `" + c.sConstant + "` not found in `" + c.sFile + ".nss`";
        else
            c.sError = sError;

        string sMessage = "[CONSTANTS] " + HexColorString("Failed", COLOR_FAILED) + " to retrieve constant value" +
            "\n   " + HexColorString("sConstant", COLOR_KEY) + "  " + HexColorString(sConstant, COLOR_VALUE) +
            "\n   " + HexColorString("sFile",     COLOR_KEY) + "  " + HexColorString(c.sFile,   COLOR_VALUE) +
            "\n   " + HexColorString("Reason",    COLOR_KEY) + "  " + HexColorString(c.sError,  COLOR_VALUE);
        Warning(sMessage);
    }

    return c;
}

// -----------------------------------------------------------------------------
//                        Public Function Implementations
// -----------------------------------------------------------------------------

struct CONSTANT GetConstantString(string sConstant, string sFile = "")
{
    struct CONSTANT c = constants_RetrieveConstant(sConstant, sFile, "String");
    if (!c.bError)
        c.sValue = GetLocalString(GetModule(), CONSTANTS_RESULT);

    return c;
}

struct CONSTANT GetConstantInt(string sConstant, string sFile = "")
{
    struct CONSTANT c = constants_RetrieveConstant(sConstant, sFile, "Int");
    if (!c.bError)
        c.nValue = GetLocalInt(GetModule(), CONSTANTS_RESULT);

    return c;
}

struct CONSTANT GetConstantFloat(string sConstant, string sFile = "")
{
    struct CONSTANT c = constants_RetrieveConstant(sConstant, sFile, "Float");
    if (!c.bError)
        c.fValue = GetLocalFloat(GetModule(), CONSTANTS_RESULT);

    return c;
}

string GetConstantName(string sPrefix, json jValue, int bSuffixOnly = FALSE, string sFile = "")
{
    if (sFile == "") sFile = "nwscript";

    sPrefix = GetStringUpperCase(bSuffixOnly ? sPrefix + "_?(" : "(" + sPrefix);
    json jMatch = RegExpMatch(sPrefix + ".*?)(?: |=).*?=\\s*(" +
        JsonDump(jValue) + ")\\s*;", ResManGetFileContents(sFile, RESTYPE_NSS));

    return jMatch != JsonArray() ? JsonGetString(JsonArrayGet(jMatch, 1)) : "";
}
