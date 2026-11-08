/// ----------------------------------------------------------------------------
/// @file   util_e_unittest.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Test runner for unit test scripts written with util_i_unittest.
/// ----------------------------------------------------------------------------
/// @details
///
/// This script finds every compiled script in the module whose name matches one
/// of the glob patterns in UNITTEST_SCRIPT_PATTERNS (see util_c_unittest), runs
/// each one on the module, and writes a summary to the server log.
///
/// Usage:
/// - Set this script as the module's OnModuleLoad handler (this is what the
///   sm-utils `test` target does), or
/// - ExecuteScript("util_e_unittest", GetModule()) from an existing handler,
///   or
/// - Run it from the in-game console with `dm_runscript util_e_unittest`.
///
/// To run a different set of tests once, set the UNITTEST_SCRIPT_PATTERNS
/// script parameter before executing this script:
///
///   SetScriptParam("UNITTEST_SCRIPT_PATTERNS", "util_t_csvlists");
///   ExecuteScript("util_e_unittest", GetModule());
///
/// To also show the results in game, set UNITTEST_DISPLAY to a bitmask of
/// DEBUG_LOG_* destinations the same way (as a script parameter, a local int on
/// the module, or the constant in util_c_unittest):
///
///   SetScriptParam("UNITTEST_DISPLAY", IntToString(DEBUG_LOG_PC));
///   ExecuteScript("util_e_unittest", GetModule());
///
/// Log Output:
/// Lines written by the runner itself start with `[UNITTEST]` and are always
/// written to the log, regardless of debug settings. The final line has this
/// format and can be used by external tools to detect completion:
///
///   [UNITTEST] DONE scripts=2 groups_passed=10 groups_failed=1
///   tests_passed=0 tests_failed=1 failed_scripts=util_t_csvlists
///
/// (shown wrapped here; it is a single line in the log).
/// ----------------------------------------------------------------------------

#include "util_i_unittest"
#include "util_i_csvlists"
#include "util_i_matching"

const string UNITTEST_RUNNING        = "UNITTEST_RUNNING";
const string UNITTEST_SAVED_LOGFILE  = "UNITTEST_SAVED_LOGFILE";
const string UNITTEST_SAVED_LOGGING  = "UNITTEST_SAVED_LOGGING";
const string UNITTEST_SAVED_LEVEL    = "UNITTEST_SAVED_LEVEL";
const string UNITTEST_QUEUE          = "UNITTEST_QUEUE";
const string UNITTEST_FAILED_SCRIPTS = "UNITTEST_FAILED_SCRIPTS";
const string UNITTEST_LOG_PREFIX     = "[UNITTEST] ";

// -----------------------------------------------------------------------------
//                        Private Function Implementations
// -----------------------------------------------------------------------------

// Writes sMessage to the log file. If the tests are being displayed to other
// destinations (see _GetDisplayDestinations()), also sends it there.
void _Log(string sMessage)
{
    sMessage = UNITTEST_LOG_PREFIX + sMessage;
    WriteTimestampedLogEntry(sMessage);

    // Send to the other destinations without writing to the log file twice.
    int nLogging = GetDebugLogging();
    if (nLogging & ~DEBUG_LOG_FILE)
    {
        SetDebugLogging(nLogging & ~DEBUG_LOG_FILE);
        Notice(sMessage, GetModule());
        SetDebugLogging(nLogging);
    }
}

int _GetFailures()
{
    return GetTestCount(TRUE, FALSE) + GetTestCount(FALSE, FALSE);
}

// Returns the glob patterns to match test scripts against. In order of
// priority, these come from:
// 1. the script parameter UNITTEST_SCRIPT_PATTERNS (applies to this run only)
// 2. the local string UNITTEST_SCRIPT_PATTERNS on the module
// 3. the UNITTEST_SCRIPT_PATTERNS constant in util_c_unittest
string _GetTestPatterns()
{
    string sPatterns = GetScriptParam("UNITTEST_SCRIPT_PATTERNS");
    if (sPatterns == "")
        sPatterns = GetLocalString(GetModule(), "UNITTEST_SCRIPT_PATTERNS");
    return sPatterns == "" ? UNITTEST_SCRIPT_PATTERNS : sPatterns;
}

// Returns a bitmask of DEBUG_LOG_* destinations to send test output to in
// addition to the log file. In order of priority, this comes from:
// 1. the script parameter UNITTEST_DISPLAY (applies to this run only)
// 2. the local int UNITTEST_DISPLAY on the module
// 3. the UNITTEST_DISPLAY constant in util_c_unittest
int _GetDisplayDestinations()
{
    string sParam = GetScriptParam("UNITTEST_DISPLAY");
    if (sParam != "")
        return StringToInt(sParam);

    int nDisplay = GetLocalInt(GetModule(), "UNITTEST_DISPLAY");
    return nDisplay ? nDisplay : UNITTEST_DISPLAY;
}

// Returns a sorted json array of all compiled scripts in the module matching
// sPatterns, excluding this script. Only compiled scripts are considered since
// uncompiled ones (e.g., include files) cannot be executed.
json _FindTestScripts(string sPatterns)
{
    string sSelf = GetScriptName();
    json jScripts = JsonArray();

    int n = 1;
    string sScript = ResManFindPrefix("", RESTYPE_NCS, n);
    while (sScript != "")
    {
        if (sScript != sSelf)
            jScripts = JsonArrayInsert(jScripts, JsonString(sScript));
        sScript = ResManFindPrefix("", RESTYPE_NCS, ++n);
    }

    jScripts = FilterByPatterns(jScripts, ListToJson(sPatterns));
    jScripts = JsonArrayTransform(jScripts, JSON_ARRAY_UNIQUE);
    return JsonArrayTransform(jScripts, JSON_ARRAY_SORT_ASCENDING);
}

void _FinishTests(int nScripts)
{
    object oModule = GetModule();
    _Log("DONE" +
        " scripts="        + IntToString(nScripts) +
        " groups_passed="  + IntToString(GetTestCount(TRUE,  TRUE)) +
        " groups_failed="  + IntToString(GetTestCount(TRUE,  FALSE)) +
        " tests_passed="   + IntToString(GetTestCount(FALSE, TRUE)) +
        " tests_failed="   + IntToString(GetTestCount(FALSE, FALSE)) +
        " failed_scripts=" + GetLocalString(oModule, UNITTEST_FAILED_SCRIPTS));

    DeleteLocalJson(oModule, UNITTEST_QUEUE);
    DeleteLocalString(oModule, UNITTEST_FAILED_SCRIPTS);

    // Restore the debug settings in place before the tests ran.
    SetLocalInt(oModule, DEBUG_LOGFILE, GetLocalInt(oModule, UNITTEST_SAVED_LOGFILE));
    SetLocalInt(oModule, DEBUG_LEVEL,   GetLocalInt(oModule, UNITTEST_SAVED_LEVEL));
    SetDebugLogging(GetLocalInt(oModule, UNITTEST_SAVED_LOGGING));
    DeleteLocalInt(oModule, UNITTEST_SAVED_LOGFILE);
    DeleteLocalInt(oModule, UNITTEST_SAVED_LEVEL);
    DeleteLocalInt(oModule, UNITTEST_SAVED_LOGGING);
    DeleteLocalInt(oModule, UNITTEST_RUNNING);
}

void _RunTest(int n)
{
    json jQueue = GetLocalJson(GetModule(), UNITTEST_QUEUE);
    int nScripts = JsonGetLength(jQueue);
    if (n >= nScripts)
    {
        _FinishTests(nScripts);
        return;
    }

    // Each script runs in its own DelayCommand so that a script that errors
    // out or exceeds the instruction limit does not stop the remaining tests.
    // The next step is scheduled before running the script for the same
    // reason.
    DelayCommand(0.1, _RunTest(n + 1));

    string sScript = JsonGetString(JsonArrayGet(jQueue, n));
    _Log("RUN " + sScript);

    int nFailures = _GetFailures();
    ResetIndent();
    ExecuteScript(sScript, GetModule());

    if (_GetFailures() > nFailures)
    {
        string sFailed = GetLocalString(GetModule(), UNITTEST_FAILED_SCRIPTS);
        SetLocalString(GetModule(), UNITTEST_FAILED_SCRIPTS, AddListItem(sFailed, sScript));
    }
}

// -----------------------------------------------------------------------------
//                                  Main Script
// -----------------------------------------------------------------------------

void main()
{
    object oModule = GetModule();

    if (GetLocalInt(oModule, UNITTEST_RUNNING))
    {
        _Log("SKIPPED: tests are already running");
        return;
    }
    SetLocalInt(oModule, UNITTEST_RUNNING, TRUE);

    // Make sure test output reaches the log file. Only the logfile debug level
    // is raised so that other debug destinations (DMs, PCs) are not flooded with
    // notices while the tests run, unless the user asked to display the results
    // there. The original settings are restored when the tests finish.
    int nLogfile = GetLocalInt(oModule, DEBUG_LOGFILE);
    int nLevel   = GetLocalInt(oModule, DEBUG_LEVEL);
    int nLogging = GetDebugLogging();
    SetLocalInt(oModule, UNITTEST_SAVED_LOGFILE, nLogfile);
    SetLocalInt(oModule, UNITTEST_SAVED_LEVEL,   nLevel);
    SetLocalInt(oModule, UNITTEST_SAVED_LOGGING, nLogging);
    SetLogfileDebugLevel(max(nLogfile, DEBUG_LEVEL_NOTICE));

    // Display destinations are added to (not substituted for) the module's
    // existing ones so other debug messages still go where they normally would.
    int nDisplay = _GetDisplayDestinations() & ~DEBUG_LOG_FILE;
    if (nDisplay)
        SetDebugLevel(max(nLevel, DEBUG_LEVEL_NOTICE), oModule);
    SetDebugLogging(nLogging | nDisplay | DEBUG_LOG_FILE);

    ResetTestCounts();
    DeleteLocalString(oModule, UNITTEST_FAILED_SCRIPTS);

    string sPatterns = _GetTestPatterns();
    json jScripts = _FindTestScripts(sPatterns);
    SetLocalJson(oModule, UNITTEST_QUEUE, jScripts);
    _Log("FOUND " +
        IntToString(JsonGetLength(jScripts)) + " test script(s) matching \"" +
        sPatterns + "\": " + JsonDump(jScripts));

    // Run the tests from the module so DelayCommand() survives this script.
    AssignCommand(oModule, _RunTest(0));
}
