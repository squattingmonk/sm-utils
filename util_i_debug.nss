// -----------------------------------------------------------------------------
//    File: util_i_debug.nss
//  System: Utilities (include script)
//     URL: https://github.com/squattingmonk/sm-utils
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// This file holds utility functions for generating debug messages.
// -----------------------------------------------------------------------------

// 1.69 string manipulation library
#include "x3_inc_string"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

// Debug mode
const string DEBUG_LEVEL = "DEBUG_LEVEL";

// Debug levels
const int DEBUG_LEVEL_CRITICAL = 0;
const int DEBUG_LEVEL_ERROR    = 1;
const int DEBUG_LEVEL_WARNING  = 2;
const int DEBUG_LEVEL_NOTICE   = 3;

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< GetDebugLevel >---
// ---< util_i_debug >---
// Returns the minimum level of debug messages that will be logged for oTarget.
// If the module is set to have more verbosity than oTarget, will return the
// module's verbosity instead.
int GetDebugLevel(string sSystem = "", object oTarget = OBJECT_SELF);

// ---< SetDebugLevel >---
// ---< util_i_debug >---
// Sets the minimum level of debug messages that will be logged for oTarget.
void SetDebugLevel(int nLevel, string sSystem = "", object oTarget = OBJECT_SELF);

// ---< Debugging >---
// ---< util_i_debug >---
// Returns whether oTarget or the module is set to display debug messages of
// nLevel or higher for sSystem. Useful for avoiding spending cycles compiling
// extra information if it will not be shown.
// Parameters:
// - nLevel: The error level of the message.
//   Possible values:
//   - DEBUG_LEVEL_CRITICAL: errors severe enough to stop the script
//   - DEBUG_LEVEL_ERROR: indicates the script malfunctioned in some way
//   - DEBUG_LEVEL_WARNING: indicates that unexpected behavior may occur
//   - DEBUG_LEVEL_NOTICE: information to track the flow of the function
// - sSystem: checks the given system to see whether debug calls of this level
//   should fire. Allows you to keep some systems silent while debugging others.
// - oTarget: The object to debug. If invalid, defaults to GetModule().
int Debugging(int nLevel, string sSystem = "", object oTarget = OBJECT_SELF);

// ---< Debug >---
// ---< util_i_debug >---
// If oTarget has a debug level of nLevel or higher for sSystem, sends sMessage
// to all online DMs, the log, and the first PC (if playing in single-player
// mode).
// Parameters:
// - sMessage: The string to print.
// - nLevel: The error level of the message.
//   Possible values:
//   - DEBUG_LEVEL_CRITICAL: errors severe enough to stop the script
//   - DEBUG_LEVEL_ERROR: indicates the script malfunctioned in some way
//   - DEBUG_LEVEL_WARNING: indicates that unexpected behavior may occur
//   - DEBUG_LEVEL_NOTICE: information to track the flow of the function
// - sSystem: checks the given system to see whether debug calls of this level
//   should fire. Allows you to keep some systems silent while debugging others.
// - oTarget: The object to debug. If invalid, defaults to GetModule().
void Debug(string sMessage, int nLevel = DEBUG_LEVEL_NOTICE, string sSystem = "", object oTarget = OBJECT_SELF);


// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

int GetDebugLevel(string sSystem = "", object oTarget = OBJECT_SELF)
{
    object oModule = GetModule();
    int nModuleGlobal = GetLocalInt(oModule, DEBUG_LEVEL);
    int nModuleSystem = GetLocalInt(oModule, DEBUG_LEVEL + sSystem);
    int nModule = (nModuleGlobal > nModuleSystem ? nModuleGlobal : nModuleSystem);

    if (oTarget == oModule || !GetIsObjectValid(oTarget))
        return nModule;

    int nTargetGlobal = GetLocalInt(oTarget, DEBUG_LEVEL);
    int nTargetSystem = GetLocalInt(oTarget, DEBUG_LEVEL + sSystem);
    int nTarget = (nTargetGlobal > nTargetSystem ? nTargetGlobal : nTargetSystem);

    return (nModule > nTarget ? nModule : nTarget);
}

void SetDebugLevel(int nLevel, string sSystem = "", object oTarget = OBJECT_SELF)
{
    if (!GetIsObjectValid(oTarget))
        oTarget = GetModule();

    SetLocalInt(oTarget, DEBUG_LEVEL + sSystem, nLevel);
}

int Debugging(int nLevel, string sSystem = "", object oTarget = OBJECT_SELF)
{
    return (nLevel <= GetDebugLevel(sSystem, oTarget));
}

void Debug(string sMessage, int nLevel = DEBUG_LEVEL_NOTICE, string sSystem = "", object oTarget = OBJECT_SELF)
{
    if (Debugging(nLevel, sSystem, oTarget))
    {
        string sPrefix, sColor;
        if (sSystem != "")
            sPrefix = "[" + sSystem + "] ";

        switch (nLevel)
        {
            case DEBUG_LEVEL_CRITICAL: sColor = "700"; sPrefix += "Critical Error: "; break;
            case DEBUG_LEVEL_ERROR:    sColor = "720"; sPrefix += "Error: ";          break;
            case DEBUG_LEVEL_WARNING:  sColor = "740"; sPrefix += "Warning: ";        break;
            default:                   sColor = "770";                                break;
        }

        sMessage = sPrefix + sMessage;
        WriteTimestampedLogEntry(sMessage);

        sMessage = StringToRGBString(sMessage, sColor);
        SendMessageToAllDMs(sMessage);

        object oPC = GetFirstPC();
        if (GetPCPublicCDKey(oPC, TRUE) != "")
            SendMessageToPC(oPC, sMessage);
    }
}
