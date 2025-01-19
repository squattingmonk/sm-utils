/// ----------------------------------------------------------------------------
/// @file   util_i_debug.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Functions for generating debug messages.
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

// VarNames
const string DEBUG_COLOR    = "DEBUG_COLOR";
const string DEBUG_LEVEL    = "DEBUG_LEVEL";
const string DEBUG_LOG      = "DEBUG_LOG";
const string DEBUG_OVERRIDE = "DEBUG_OVERRIDE";
const string DEBUG_PREFIX   = "DEBUG_PREFIX";
const string DEBUG_DISPATCH = "DEBUG_DISPATCH";
const string DEBUG_LOGFILE  = "DEBUG_LOGFILE";

// Debug levels
const int DEBUG_LEVEL_NONE     = 0; ///< No debug level set
const int DEBUG_LEVEL_CRITICAL = 1; ///< Errors severe enough to stop the script
const int DEBUG_LEVEL_ERROR    = 2; ///< Indicates the script malfunctioned in some way
const int DEBUG_LEVEL_WARNING  = 3; ///< Indicates that unexpected behavior may occur
const int DEBUG_LEVEL_NOTICE   = 4; ///< Information to track the flow of the function
const int DEBUG_LEVEL_DEBUG    = 5; ///< Data dumps used for debugging

// Debug logging
const int DEBUG_LOG_NONE = 0x0; ///< Do not log debug messages
const int DEBUG_LOG_FILE = 0x1; ///< Send debug messages to the log file
const int DEBUG_LOG_DM   = 0x2; ///< Send debug messages to online DMs
const int DEBUG_LOG_PC   = 0x4; ///< Send debug messages to the first PC
const int DEBUG_LOG_LIST = 0x8; ///< Send debug messages to the dispatch list
const int DEBUG_LOG_ALL  = 0xf; ///< Send messages to the log file, DMs, and first PC or dispatch list

#include "util_c_debug"
#include "util_i_color"
#include "util_i_varlists"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Temporarily override the debug level for all objects.
/// @param nLevel The maximum verbosity of messages to show. Use FALSE to stop
///     overriding the debug level.
void OverrideDebugLevel(int nLevel);

/// @brief Return the verbosity of debug messages displayed for an object.
/// @param oTarget The object to check the debug level of. If no debug level has
///     been set on oTarget, will use the module instead.
/// @returns A `DEBUG_LEVEL_*` constant representing the maximum verbosity of
///     messages that will be displayed when debugging oTarget.
int GetDebugLevel(object oTarget = OBJECT_SELF);

/// @brief Set the verbosity of debug messages displayed for an object.
/// @param nLevel A `DEBUG_LEVEL_*` constant representing the maximum verbosity
///     of messages that will be displayed when debugging oTarget. If set to
///     `DEBUG_LEVEL_NONE`, oTarget will use the module's debug level instead.
/// @param oTarget The object to set the debug level of. If no debug level has
///     been set on oTarget, will use the module instead.
void SetDebugLevel(int nLevel, object oTarget = OBJECT_SELF);

/// @brief Get the verbosity of debug messages that will be sent to the game's
///     logfile.  Logfile verbosity level will always be greater than or equal
///     to the verbosity of the current debug target object.
int GetLogfileDebugLevel(object oTarget = OBJECT_SELF);

/// @brief Set the verbosity of debug messages that will be sent to the game's
///     logfile, regardless of the debug settings for the module or target
///     object.  This setting will be ignored if debug logging does not
///     include DEBUG_LOG_FILE.
/// @param nLevel A `DEBUG_LEVEL_*` constant representing the maximum verbosity
///     of messages that will be sent to the game's logfile.
void SetLogfileDebugLevel(int nLevel);

/// @brief Return the color of debug messages of a given level.
/// @param nLevel A `DEBUG_LEVEL_*` constant representing the verbosity of debug
///     messsages to get the color for.
/// @returns A color code (in <cRGB> form).
string GetDebugColor(int nLevel);

/// @brief Set the color of debug messages of a given level.
/// @param nLevel A `DEBUG_LEVEL_*` constant representing the verbosity of debug
///     messsages to get the color for.
/// @param sColor A color core (in <cRBG> form) for the debug messages. If "",
///     will use the default color code for the level.
void SetDebugColor(int nLevel, string sColor = "");

/// @brief Return the prefix an object uses before its debug messages.
/// @param oTarget The target to check for a prefix.
/// @returns The user-defined prefix if one has been set. If it has not, will
///     return the object's tag (or name, if the object has no tag) in square
///     brackets.
string GetDebugPrefix(object oTarget = OBJECT_SELF);

/// @brief Set the prefix an object uses before its debug messages.
/// @param sPrefix The prefix to set. You can include color codes in the prefix,
///     but you can also set thedefault color code for all prefixes using
///     `SetDebugColor(DEBUG_COLOR_NONE, sColor);`.
/// @param oTarget The target to set the prefix for.
void SetDebugPrefix(string sPrefix, object oTarget = OBJECT_SELF);

/// @brief Return the enabled debug logging destinations.
/// @returns A bitmask of `DEBUG_LOG_*` values.
int GetDebugLogging();

/// @brief Set the enabled debug logging destinations.
/// @param nEnabled A bitmask of `DEBUG_LOG_*` destinations to enable.
void SetDebugLogging(int nEnabled);

/// @brief Add a player object to the debug message dispatch list.  Player
///     objects on the dispatch list will receive debug messages if the
///     module's DEBUG_LOG_LEVEL includes DEBUG_LOG_LIST.
/// @param oPC Player object to add.
void AddDebugLoggingPC(object oPC);

/// @brief Remove a player object from the debug dispatch list.
/// @param oPC Player object to remove.
void RemoveDebugLoggingPC(object oPC);

/// @brief Return whether debug messages of a given level will be logged on a
///     target. Useful for avoiding spending cycles computing extra debug
///     information if it will not be shown.
/// @param nLevel A `DEBUG_LEVEL_*` constant representing the message verbosity.
/// @param oTarget The object that would be debugged.
/// @returns TRUE if messages of nLevel would be logged on oTarget; FALSE
///     otherwise.
int IsDebugging(int nLevel, object oTarget = OBJECT_SELF);

/// If oTarget has a debug level of nLevel or higher, logs sMessages to all
/// destinations set with SetDebugLogging(). If no debug level is set on
/// oTarget,
/// will debug using the module's debug level instead.
/// @brief Display a debug message.
/// @details If the target has a debug level of nLevel or higher, sMessage will
///     be sent to all destinations enabled by SetDebugLogging(). If no debug
///     level is set on oTarget, will debug using the module's debug level
///     instead.
/// @param sMessage The message to display.
/// @param nLevel A `DEBUG_LEVEL_*` constant representing the message verbosity.
/// @param oTarget The object originating the message.
void Debug(string sMessage, int nLevel = DEBUG_LEVEL_DEBUG, object oTarget = OBJECT_SELF);

/// @brief Display a general notice message. Alias for Debug().
/// @param sMessage The message to display.
/// @param oTarget The object originating the message.
void Notice(string sMessage, object oTarget = OBJECT_SELF);

/// @brief Display a warning message. Alias for Debug().
/// @param sMessage The message to display.
/// @param oTarget The object originating the message.
void Warning(string sMessage, object oTarget = OBJECT_SELF);

/// @brief Display an error message. Alias for Debug().
/// @param sMessage The message to display.
/// @param oTarget The object originating the message.
void Error(string sMessage, object oTarget = OBJECT_SELF);

/// @brief Display a critical error message. Alias for Debug().
/// @param sMessage The message to display.
/// @param oTarget The object originating the message.
void CriticalError(string sMessage, object oTarget = OBJECT_SELF);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void OverrideDebugLevel(int nLevel)
{
    nLevel = clamp(nLevel, DEBUG_LEVEL_NONE, DEBUG_LEVEL_DEBUG);
    SetLocalInt(GetModule(), DEBUG_OVERRIDE, nLevel);
}

int GetDebugLevel(object oTarget = OBJECT_SELF)
{
    object oModule = GetModule();
    int nOverride = GetLocalInt(oModule, DEBUG_OVERRIDE);
    if (nOverride)
        return nOverride;

    int nModule = GetLocalInt(oModule, DEBUG_LEVEL);
    if (oTarget == oModule || !GetIsObjectValid(oTarget))
        return nModule;

    int nLevel = GetLocalInt(oTarget, DEBUG_LEVEL);
    return (nLevel ? nLevel : nModule ? nModule : DEBUG_LEVEL_CRITICAL);
}

void SetDebugLevel(int nLevel, object oTarget = OBJECT_SELF)
{
    SetLocalInt(oTarget, DEBUG_LEVEL, nLevel);
}

int GetLogfileDebugLevel(object oTarget = OBJECT_SELF)
{
    return max(GetLocalInt(GetModule(), DEBUG_LOGFILE), GetDebugLevel(oTarget));
}

void SetLogfileDebugLevel(int nLevel)
{
    SetLocalInt(GetModule(), DEBUG_LOGFILE, nLevel);
}

string GetDebugColor(int nLevel)
{
    string sColor = GetLocalString(GetModule(), DEBUG_COLOR + IntToString(nLevel));

    if (sColor == "")
    {
        int nColor;
        switch (nLevel)
        {
            case DEBUG_LEVEL_CRITICAL: nColor = COLOR_RED;          break;
            case DEBUG_LEVEL_ERROR:    nColor = COLOR_ORANGE_DARK;  break;
            case DEBUG_LEVEL_WARNING:  nColor = COLOR_ORANGE_LIGHT; break;
            case DEBUG_LEVEL_NOTICE:   nColor = COLOR_YELLOW;       break;
            case DEBUG_LEVEL_NONE:     nColor = COLOR_GREEN_LIGHT;  break;
            default:                   nColor = COLOR_GRAY_LIGHT;   break;
        }

        sColor = HexToColor(nColor);
        SetDebugColor(nLevel, sColor);
    }

    return sColor;
}

void SetDebugColor(int nLevel, string sColor = "")
{
    SetLocalString(GetModule(), DEBUG_COLOR + IntToString(nLevel), sColor);
}

string GetDebugPrefix(object oTarget = OBJECT_SELF)
{
    string sColor = GetDebugColor(DEBUG_LEVEL_NONE);
    string sPrefix = GetLocalString(oTarget, DEBUG_PREFIX);
    if (sPrefix == "")
    {
        if (!GetIsObjectValid(oTarget))
        {
            sColor = GetDebugColor(DEBUG_LEVEL_WARNING);
            sPrefix = "Invalid Object: #" + ObjectToString(oTarget);
        }
        else
            sPrefix = (sPrefix = GetTag(oTarget)) == "" ?  GetName(oTarget) : sPrefix;

        sPrefix = "[" + sPrefix + "]";
    }

    return ColorString(sPrefix, sColor);
}

void SetDebugPrefix(string sPrefix, object oTarget = OBJECT_SELF)
{
    SetLocalString(oTarget, DEBUG_PREFIX, sPrefix);
}

int GetDebugLogging()
{
    return GetLocalInt(GetModule(), DEBUG_LOG);
}

void SetDebugLogging(int nEnabled)
{
    SetLocalInt(GetModule(), DEBUG_LOG, nEnabled);
}

void AddDebugLoggingPC(object oPC)
{
    if (GetIsPC(oPC))
        AddListObject(GetModule(), oPC, DEBUG_DISPATCH, TRUE);
}

void RemoveDebugLoggingPC(object oPC)
{
    RemoveListObject(GetModule(), oPC, DEBUG_DISPATCH);
}

int IsDebugging(int nLevel, object oTarget = OBJECT_SELF)
{
    return (nLevel <= GetDebugLevel(oTarget) || nLevel <= GetLogfileDebugLevel());
}

void Debug(string sMessage, int nLevel = DEBUG_LEVEL_DEBUG, object oTarget = OBJECT_SELF)
{
    if (IsDebugging(nLevel, oTarget))
    {
        string sColor = GetDebugColor(nLevel);
        string sPrefix = GetDebugPrefix(oTarget) + " ";

        switch (nLevel)
        {
            case DEBUG_LEVEL_CRITICAL: sPrefix += "[Critical Error] "; break;
            case DEBUG_LEVEL_ERROR:    sPrefix += "[Error] ";          break;
            case DEBUG_LEVEL_WARNING:  sPrefix += "[Warning] ";        break;
        }

        if (!HandleDebug(sPrefix, sMessage, nLevel, oTarget))
            return;

        sMessage = sPrefix + sMessage;
        int nLogging = GetDebugLogging();
        
        if (nLogging & DEBUG_LOG_FILE)
            WriteTimestampedLogEntry(UnColorString(sMessage));

        if (nLevel > GetDebugLevel(oTarget))
        {
            if (between(nLevel, DEBUG_LEVEL_CRITICAL, DEBUG_LEVEL_WARNING))
                sMessage = ColorString(sPrefix, sColor) + "logged; see logfile";
            else
                return;
        }
        else
            sMessage = ColorString(sMessage, sColor);

        if (nLogging & DEBUG_LOG_DM)
            SendMessageToAllDMs(sMessage);

        if (nLogging & DEBUG_LOG_PC)
            SendMessageToPC(GetFirstPC(), sMessage);

        if (nLogging & DEBUG_LOG_LIST)
        {
            json jDispatchList = GetObjectList(GetModule(), DEBUG_DISPATCH);
            int n; for (n; n < JsonGetLength(jDispatchList); n++)
            {
                object oPC = GetListObject(GetModule(), n, DEBUG_DISPATCH);
                if (GetIsPC(oPC) && !((nLogging & DEBUG_LOG_PC) && oPC == GetFirstPC()))
                    SendMessageToPC(oPC, sMessage);
            }
        }
    }
}

void Notice(string sMessage, object oTarget = OBJECT_SELF)
{
    Debug(sMessage, DEBUG_LEVEL_NOTICE, oTarget);
}

void Warning(string sMessage, object oTarget = OBJECT_SELF)
{
    Debug(sMessage, DEBUG_LEVEL_WARNING, oTarget);
}

void Error(string sMessage, object oTarget = OBJECT_SELF)
{
    Debug(sMessage, DEBUG_LEVEL_ERROR, oTarget);
}

void CriticalError(string sMessage, object oTarget = OBJECT_SELF)
{
    Debug(sMessage, DEBUG_LEVEL_CRITICAL, oTarget);
}
