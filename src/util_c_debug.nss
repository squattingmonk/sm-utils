/// ----------------------------------------------------------------------------
/// @file   util_c_debug.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Configuration file for util_i_debug.nss.
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                        Helper Constants and Functions
// -----------------------------------------------------------------------------
// If you need custom constants, functions, or #includes, you may add them here.
// Since this file is included by util_i_debug.nss, you do not need to #include
// it to use its constants.
// -----------------------------------------------------------------------------

/*
// These constants are used by the example code below. Uncomment if you want to
// use them.

/// @brief This is the minimum debug level required to trigger custom handling.
/// @details Setting this to DEBUG_LEVEL_ERROR means OnDebug() will handle only
///     messages marked as DEBUG_LEVEL_ERROR and DEBUG_LEVEL_CRITICAL. If set to
///     DEBUG_LEVEL_NONE, the user-defined event will never be triggered.
/// @warning It is not recommended to set this level to DEBUG_LEVEL_NOTICE or
///     DEBUG_LEVEL_DEBUG as this could create high message traffic rates.
const int DEBUG_EVENT_TRIGGER_LEVEL = DEBUG_LEVEL_ERROR;

// These are varnames for script parameters
const string DEBUG_PARAM_PREFIX  = "DEBUG_PARAM_PREFIX";
const string DEBUG_PARAM_MESSAGE = "DEBUG_PARAM_MESSAGE";
const string DEBUG_PARAM_LEVEL   = "DEBUG_PARAM_LEVEL";
const string DEBUG_PARAM_TARGET  = "DEBUG_PARAM_TARGET";
*/

// -----------------------------------------------------------------------------
//                                 Debug Handler
// -----------------------------------------------------------------------------
// You may alter the contents of this function, but do not alter its signature.
// -----------------------------------------------------------------------------

/// @brief Custom debug event handler
/// @details This is a customizable function that runs before a message is shown
///     using Debug(). This function provides a user-definable hook into the
///     debug notification system. For example, a module can use this hook to
///     execute a script that may be able to handle module-specific error
///     handling or messaging.
/// @param sPrefix the debug message source provided by GetDebugPrefix()
/// @param sMessage the debug message provided to Debug()
/// @param nLevel the debug level of the message provided to Debug()
/// @param oTarget the game object being debugged as provided to Debug()
/// @returns TRUE if the message should be sent as normal; FALSE if no message
///     should be sent.
/// @note This function will never fire if oTarget is not debugging messages of
///     nLevel.
/// @warning Do not call Debug() or its aliases Notice(), Warning(), Error(), or
///     CriticalError() from this function; that would cause an infinite loop.
int HandleDebug(string sPrefix, string sMessage, int nLevel, object oTarget)
{
    /*
    // The following example code allows an external script to handle the event
    // with access to the appropriate script parameters. Optionally, all event
    // handling can be accomplished directly in this function.

    // Only do custom handling if the debug level is error or critical error.
    if (!nLevel || nLevel > DEBUG_EVENT_TRIGGER_LEVEL)
        return TRUE;

    SetScriptParam(DEBUG_PARAM_PREFIX,  sPrefix);
    SetScriptParam(DEBUG_PARAM_MESSAGE, sMessage);
    SetScriptParam(DEBUG_PARAM_LEVEL,   IntToString(nLevel));
    SetScriptParam(DEBUG_PARAM_TARGET,  ObjectToString(oTarget));
    ExecuteScript("mydebugscript", oTarget);
    return FALSE;
    */

    return TRUE;
}
