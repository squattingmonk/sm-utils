// -----------------------------------------------------------------------------
//    File: util_c_debug.nss
//  System: Utilities (configuration script)
//     URL: https://github.com/squattingmonk/sm-utils
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// This file holds utility functions for generating debug messages.
// -----------------------------------------------------------------------------
// This file contains functions and constants called by util_i_debug.nss.  The
// functions in this file are meant to be customized by the user, if desired,
// to achieve specific, custom debugging functionality.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

/// @brief this constant defines the debug level at which a user-defined
///     event will be triggered.  This is the minimum debug level to trigger
///     the event.  For example, setting this constant to DEBUG_LEVEL_ERROR
///     means the user-defined event will be triggered only for debug statements
///     marked as DEBUG_LEVEL_ERROR and DEBUG_LEVEL_CRITICAL.  If set to 
///     DEBUG_LEVEL_NONE, the user-defined event will never be triggered.
/// @warning It is not recommended to set this level to DEBUG_LEVEL_NOTICE or
///     DEBUG_LEVEL_DEBUG as this could create high message traffic rates.
const int DEBUG_LEVEL_EVENT_TRIGGER = DEBUG_LEVEL_ERROR;

// Script parameter definition -- do not modify

const string DEBUG_PARAM_PREFIX  = "DEBUG_PARAM_PREFIX";
const string DEBUG_PARAM_MESSAGE = "DEBUG_PARAM_MESSAGE";
const string DEBUG_PARAM_LEVEL   = "DEBUG_PARAM_LEVEL";
const string DEBUG_PARAM_TARGET  = "DEBUG_PARAM_TARGET";

// -----------------------------------------------------------------------------
//                              Function Definitions
// -----------------------------------------------------------------------------

/// @brief Called from Debug() in util_i_debug.nss when a debug event qualified
///     by the value of DEBUG_LEVEL_EVENT_TRIGGER is detected.  This function
///     provides a user-definable hook into the debug notification system.
/// @param sPrefix the debug message source as created by GetDebugPrefix()
/// @param sMessage the debug message as provided to Debug()
/// @param nLevel the debug level of the message as provided to Debug(); will 
///     always be less than or equal to DEBUG_LEVEL_EVENT_TRIGGER and should
///     never be 0.
/// @param oTarget the game object the debug statement was sourced from as
///     provided to Debug()
/// @returns TRUE or FALSE, used by Debug() to determine if the normal messaging
///     (logs, DMs, etc.) is accomplished.
int PublishDebugEvent(string sPrefix, string sMessage, int nLevel, object oTarget)
{
    // This function allows a user-definable hook into the debug messaging
    //  system.  For example, a module can use this hook to execute any
    //  script that may be able to handle module-specific error handling or
    //  messaging.  The following example code allows an external script to
    //  handle the event with access to the appropriate script parameters.
    //  Optionally, all event handling can be accomplished directly in this
    //  function.
    /*
    SetScriptParam(DEBUG_PARAM_PREFIX, sPrefix);
    SetScriptParam(DEBUG_PARAM_MESSAGE, sMessage);
    SetScriptParam(DEBUG_PARAM_LEVEL, IntToString(nLevel));
    SetScriptParam(DEBUG_PARAM_TARGET, ObjectToString(oTarget));
    ExecuteScript("mydebugscript", oTarget);
    */

    return TRUE;
}