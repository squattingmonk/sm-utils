/// ----------------------------------------------------------------------------
/// @file   util_i_timers.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Functions for running scripts on an interval.
/// ----------------------------------------------------------------------------
/// @details
/// ## Concept
/// Timers are a way of running a script repeatedly on an interval. A timer can
/// be created on an object. Once started, it will continue to run until it is
/// finished iterating or until killed manually. Each time the timer elapses,
/// its action will run. By default, this action is to simply run a script.
///
/// ## Basic Usage
///
/// ### Creating a Timer
/// You can create a timer using `CreateTimer()`. This function takes the object
/// that should run the timer, the script that should execute when the timer
/// elapses, the interval between ticks, and the total number of iterations. It
/// returns the ID for the timer, which is used to reference it in the database.
/// You should save this timer for later use.
///
/// ```nwscript
/// // The following creates a timer on oPC that will run the script "foo" every
/// // 6 seconds for 4 iterations.
/// int nTimerID = CreateTimer(oPC, "foo", 6.0, 4);
/// ```
///
/// A timer created with 0 iterations will run until stopped or killed.
///
/// ## Starting a Timer
/// Timers will not run until they are started wiuth `StartTimer()`. This
/// function takes the ID of the timer returned from `CreateTimer()`. If the
/// second parameter, `bInstant`, is TRUE, the timer will elapse immediately;
/// otherwise, it will elapse when its interval is complete:
///
/// ```nwscript
/// StartTimer(nTimerID);
/// ```
///
/// ### Stopping a Timer
/// Stopping a timer with `StopTimer()` will suspend its execution:
/// ```nwscript
/// StopTimer(nTimerID);
/// ```
/// You can restart the timer later using `StartTimer()` to resume any remaining
/// iterations. If you want to start again from the beginning, you can call
/// `ResetTimer()` first:
/// ```nwscript
/// ResetTimer(nTimerID);
/// StartTimer(nTimerID);
/// ```
///
/// ### Destroying a Timer
/// Calling `KillTimer()` will clean up all data associated with the timer. A
/// timer cannot be restarted after it is killed; you will have to create and
/// start a new one.
/// ```nwscript
/// KillTimer(nTimerID);
/// ```
///
/// Timers automatically kill themselves when they are finished iterating or
/// when the object they are executed on is no longer valid. You only need to
/// use `KillTimer()` if you want to destroy it before it is done iterating or
/// if the timer is infinite.
///
/// ## Advanced Usage
/// By default, timer actions are handled by passing them to `ExecuteScript()`.
/// However, the final parameter of the `CreateTimer()` function allows you to
/// specify a handler script. If this parameter is not blank, the handler will
/// be called using `ExecuteScript()` and the action will be available to it as
/// a script parameter.
///
/// For example, the Core Framework allows timers to run event hooks by calling
/// the handler script `core_e_timerhook`, which is as follows:
/// ```nwscript
/// #include "core_i_framework"
///
/// void main()
/// {
///     string sEvent  = GetScriptParam(TIMER_ACTION);
///     string sSource = GetScriptParam(TIMER_SOURCE);
///     object oSource = StringToObject(sSource);
///     RunEvent(sEvent, oSource);
/// }
/// ```
///
/// To make this easier, `core_i_framework` contains an alias to `CreateTimer()`
/// called `CreateEventTimer()` that sets the handler script. You can create
/// your own aliases in the same way.

#include "util_i_sqlite"
#include "util_i_debug"
#include "util_i_datapoint"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

const string TIMER_DATAPOINT = "*Timers";
const string TIMER_INIT      = "*TimersInitialized";
const string TIMER_LAST      = "*TimerID";
const string TIMER_ACTION    = "*TimerAction";
const string TIMER_SOURCE    = "*TimerSource";

// -----------------------------------------------------------------------------
//                               Global Variables
// -----------------------------------------------------------------------------

// Running timers are AssignCommand()'ed to this datapoint. This ensures that
// even if the object that issued the StartTimer() becomes invalid, the timer
// will continue to run.
object TIMERS = GetDatapoint(TIMER_DATAPOINT, GetModule(), FALSE);

// -----------------------------------------------------------------------------
//                         Public Function Declarations
// -----------------------------------------------------------------------------

/// @brief Create a table for timers in the module's volatile database.
/// @param bReset If TRUE, will drop the existing timers table.
/// @note This function will be run automatically the first timer one of the
///     functions in this file is called. You only need to call this if you need
///     the table created earlier (e.g., because another table references it).
void CreateTimersTable(int bReset = FALSE);

/// @brief Create a timer that fires on a target at regular intervals.
/// @details After a timer is created, you will need to start it to get it to
///     run. You cannot create a timer on an invalid target or with a
///     non-positive interval value.
/// @param oTarget The object the action will run on.
/// @param sAction The action to execute when the timer elapses.
/// @param fInterval The number of seconds between iterations.
/// @param nIterations the number of times the timer can elapse. 0 means no
///     limit. If nIterations is 0, fInterval must be greater than or equal to
///     6.0.
/// @param fJitter A random number of seconds between 0.0 and fJitter to add to
///     fInterval between executions. Leave at 0.0 for no jitter.
/// @param sHandler A handler script to execute sAction. If "", sAction will be
///     called using ExecuteScript() instead.
/// @returns the ID of the timer. Save this so it can be used to start, stop, or
///     kill the timer later.
int CreateTimer(object oTarget, string sAction, float fInterval, int nIterations = 0, float fJitter = 0.0, string sHandler = "");

/// @brief Return if a timer exists.
/// @param nTimerID The ID of the timer in the database.
int GetIsTimerValid(int nTimerID);

/// @brief Start a timer, executing its action each interval until finished
///     iterating, stopped, or killed.
/// @param nTimerID The ID of the timer in the database.
/// @param bInstant If TRUE, execute the timer's action immediately.
void StartTimer(int nTimerID, int bInstant = TRUE);

/// @brief Suspend execution of a timer.
/// @param nTimerID The ID of the timer in the database.
/// @note This does not destroy the timer, only stops it from iterating or
///     executing its action.
void StopTimer(int nTimerID);

/// @brief Reset the number or remaining iterations on a timer.
/// @param nTimerID The ID of the timer in the database.
void ResetTimer(int nTimerID);

/// @brief Delete a timer.
/// @details This results in all information about the given timer being
///     deleted. Since the information is gone, the action associated with that
///     timer ID will not get executed again.
/// @param nTimerID The ID of the timer in the database.
void KillTimer(int nTimerID);

/// @brief Return whether a timer will run infinitely.
/// @param nTimerID The ID of the timer in the database.
int GetIsTimerInfinite(int nTimerID);

/// @brief Return the remaining number of iterations for a timer.
/// @details If called during a timer script, will not include the current
///     iteration. Returns -1 if nTimerID is not a valid timer ID. Returns 0 if
///     the timer is set to run indefinitely, so be sure to check for this with
///     GetIsTimerInfinite().
/// @param nTimerID The ID of the timer in the database.
int GetTimerRemaining(int nTimerID);

/// @brief Sets the remaining number of iterations for a timer.
/// @param nTimerID The ID of the timer in the database.
/// @param nRemaining The remaining number of iterations.
void SetTimerRemaining(int nTimerID, int nRemaining);

// -----------------------------------------------------------------------------
//                       Private Function Implementations
// -----------------------------------------------------------------------------

// Private function used by StartTimer().
void _TimerElapsed(int nTimerID, int nRunID, int bFirstRun = FALSE)
{
    // Timers are fired on a delay, so it's possible that the timer was stopped
    // and restarted before the delayed call could fail due to the timer being
    // stopped. We increment the run_id whenever the timer is started and pass
    // it along to the delayed calls so they can check if they are still valid.
    sqlquery q = SqlPrepareQueryModule("SELECT * FROM timers " +
        "WHERE timer_id = @timer_id AND run_id = @run_id AND running = 1;");
    SqlBindInt(q, "@timer_id", nTimerID);
    SqlBindInt(q, "@run_id", nRunID);

    // The timer was killed or stopped
    if (!SqlStep(q))
        return;

    string sTimerID    = IntToString(nTimerID);
    string sAction     = SqlGetString(q,  3);
    string sHandler    = SqlGetString(q,  4);
    string sTarget     = SqlGetString(q,  5);
    string sSource     = SqlGetString(q,  6);
    float  fInterval   = SqlGetFloat (q,  7);
    float  fJitter     = SqlGetFloat (q,  8);
    int    nIterations = SqlGetInt   (q,  9);
    int    nRemaining  = SqlGetInt   (q, 10);
    int    bIsPC       = SqlGetInt   (q, 11);
    object oTarget     = StringToObject(sTarget);
    object oSource     = StringToObject(sSource);

    string sMsg =
        "\n    Target: " + sTarget +
            " (" + (GetIsObjectValid(oTarget) ? GetName(oTarget) : "INVALID") + ")" +
        "\n    Source: " + sSource +
            " (" + (GetIsObjectValid(oTarget) ? GetName(oSource) : "INVALID") + ")" +
        "\n    Action: " + sAction +
        "\n    Handler: " + sHandler;

    if (!GetIsObjectValid(oTarget) || (bIsPC && !GetIsPC(oTarget)))
    {
        Warning("Target for timer " + sTimerID + " no longer valid:" + sMsg);
        KillTimer(nTimerID);
        return;
    }

    // If we're running infinitely or we have more runs remaining...
    if (!nIterations || nRemaining)
    {
        string sIterations = (nIterations ? IntToString(nIterations) : "Infinite");
        if (!bFirstRun)
        {
            Notice("Timer " + sTimerID + " elapsed" + sMsg +
                "\n    Iteration: " +
                    (nIterations ? IntToString(nIterations - nRemaining + 1) : "INFINITE") +
                    "/" + sIterations);

            // If we're not running an infinite number of times, decrement the
            // number of iterations we have remaining
            if (nIterations)
                SetTimerRemaining(nTimerID, nRemaining - 1);

            // Run the timer handler
            SetScriptParam(TIMER_LAST,   IntToString(nTimerID));
            SetScriptParam(TIMER_ACTION, sAction);
            SetScriptParam(TIMER_SOURCE, sSource);
            ExecuteScript(sHandler != "" ? sHandler : sAction, oTarget);

            // In case one of those scripts we just called reset the timer...
            if (nIterations)
                nRemaining = GetTimerRemaining(nTimerID);
        }

        // If we have runs left, call our timer's next iteration.
        if (!nIterations || nRemaining)
        {
            // Account for any jitter
            fJitter = IntToFloat(Random(FloatToInt(fJitter * 10) + 1)) / 10.0;
            fInterval += fJitter;

            Notice("Scheduling next iteration for timer " + sTimerID + ":" + sMsg +
                "\n    Delay: " + FloatToString(fInterval, 0, 1) +
                "\n    Remaining: " +
                    (nIterations ? (IntToString(nRemaining)) : "INFINITE") +
                    "/" + sIterations);

            DelayCommand(fInterval, _TimerElapsed(nTimerID, nRunID));
            return;
        }
    }

    // We have no more runs left! Kill the timer to clean up.
    Debug("Timer " + sTimerID + " expired:" + sMsg);
    KillTimer(nTimerID);
}

// -----------------------------------------------------------------------------
//                        Public Function Implementations
// -----------------------------------------------------------------------------

void CreateTimersTable(int bReset = FALSE)
{
    if (GetLocalInt(TIMERS, TIMER_INIT) && !bReset)
        return;

    // StartTimer() assigns the timer tick to TIMERS, so by deleting it, we are
    // able to cancel all currently running timers.
    DestroyObject(TIMERS);

    SqlCreateTableModule("timers",
        "timer_id INTEGER PRIMARY KEY AUTOINCREMENT, " +
        "run_id INTEGER NOT NULL DEFAULT 0, " +
        "running BOOLEAN NOT NULL DEFAULT 0, " +
        "action TEXT NOT NULL, " +
        "handler TEXT NOT NULL, " +
        "target TEXT NOT NULL, " +
        "source TEXT NOT NULL, " +
        "interval REAL NOT NULL, " +
        "jitter REAL NOT NULL, " +
        "iterations INTEGER NOT NULL, " +
        "remaining INTEGER NOT NULL, " +
        "is_pc BOOLEAN NOT NULL DEFAULT 0", bReset);

    TIMERS = CreateDatapoint(TIMER_DATAPOINT);
    SetDebugPrefix(HexColorString("[Timers]", COLOR_CYAN), TIMERS);
    SetLocalInt(TIMERS, TIMER_INIT, TRUE);
}

int CreateTimer(object oTarget, string sAction, float fInterval, int nIterations = 0, float fJitter = 0.0, string sHandler = "")
{
    string sSource = ObjectToString(OBJECT_SELF);
    string sTarget = ObjectToString(oTarget);
    string sDebug =
        "\n    OBJECT_SELF: " + sSource + " (" + GetName(OBJECT_SELF) + ")" +
        "\n    oTarget: " + sTarget +
            " (" + (GetIsObjectValid(oTarget) ? GetName(oTarget) : "INVALID") + ")" +
        "\n    sAction: " + sAction +
        "\n    sHandler: " + sHandler +
        "\n    nIterations: " + (nIterations ? IntToString(nIterations) : "Infinite") +
        "\n    fInterval: " + FloatToString(fInterval, 0, 1) +
        "\n    fJitter: " + FloatToString(fJitter, 0, 1);

    // Sanity checks: don't create the timer if...
    // 1. the target is invalid
    // 2. the interval is not greater than 0.0
    // 3. the number of iterations is non-positive
    // 4. the interval is more than once per round and the timer is infinite
    string sError;
    if (!GetIsObjectValid(oTarget))
        sError = "oTarget is invalid";
    else if (fInterval <= 0.0)
        sError = "fInterval must be positive";
    else if (fInterval + fJitter <= 0.0)
        sError = "fJitter is too low for fInterval";
    else if (nIterations < 0)
        sError = "nIterations is negative";
    else if (fInterval < 6.0 && !nIterations)
        sError = "fInterval is too short for infinite executions";

    if (sError != "")
    {
        CriticalError("CreateTimer() failed:\n    Error: " + sError + sDebug);
        return 0;
    }

    CreateTimersTable();
    sqlquery q = SqlPrepareQueryModule("INSERT INTO timers " +
        "(action, handler, target, source, interval, jitter, iterations, remaining, is_pc) " +
        "VALUES (@action, @handler, @target, @source, @interval, @jitter, @iterations, @remaining, @is_pc) " +
        "RETURNING timer_id;");
    SqlBindString(q, "@action",     sAction);
    SqlBindString(q, "@handler",    sHandler);
    SqlBindString(q, "@target",     sTarget);
    SqlBindString(q, "@source",     sSource);
    SqlBindFloat (q, "@interval",   fInterval);
    SqlBindFloat (q, "@jitter",     fJitter);
    SqlBindInt   (q, "@iterations", nIterations);
    SqlBindInt   (q, "@remaining",  nIterations);
    SqlBindInt   (q, "@is_pc",      GetIsPC(oTarget));

    int nTimerID = SqlStep(q) ? SqlGetInt(q, 0) : 0;
    if (nTimerID > 0)
        Notice("Created timer " + IntToString(nTimerID) + sDebug);

    return nTimerID;
}

int GetIsTimerValid(int nTimerID)
{
    // Timer IDs less than or equal to 0 are always invalid.
    if (nTimerID <= 0)
        return FALSE;

    CreateTimersTable();
    sqlquery q = SqlPrepareQueryModule(
        "SELECT 1 FROM timers WHERE timer_id = @timer_id;");
    SqlBindInt(q, "@timer_id", nTimerID);
    return SqlStep(q) ? SqlGetInt(q, 0) : FALSE;
}

void StartTimer(int nTimerID, int bInstant = TRUE)
{
    CreateTimersTable();
    sqlquery q = SqlPrepareQueryModule(
        "UPDATE timers SET running = 1, run_id = run_id + 1 " +
        "WHERE timer_id = @timer_id AND running = 0 RETURNING run_id;");
    SqlBindInt(q, "@timer_id", nTimerID);

    if (SqlStep(q))
    {
        Notice("Started timer " + IntToString(nTimerID));
        AssignCommand(TIMERS, _TimerElapsed(nTimerID, SqlGetInt(q, 0), !bInstant));
    }
    else
    {
        string sDebug = "StartTimer(" + IntToString(nTimerID) + ")";
        if (GetIsTimerValid(nTimerID))
            Error(sDebug + "failed: timer is already running");
        else
            Error(sDebug + " failed: timer id does not exist");
    }
}

void StopTimer(int nTimerID)
{
    CreateTimersTable();
    sqlquery q = SqlPrepareQueryModule(
        "UPDATE timers SET running = 0 " +
        "WHERE timer_id = @timer_id RETURNING 1;");
    SqlBindInt(q, "@timer_id", nTimerID);
    if (SqlStep(q))
        Notice("Stopping timer " + IntToString(nTimerID));
}

void ResetTimer(int nTimerID)
{
    CreateTimersTable();
    sqlquery q = SqlPrepareQueryModule(
        "UPDATE timers SET remaining = timers.iterations " +
        "WHERE timer_id = @timer_id AND iterations > 0 RETURNING remaining;");
    SqlBindInt(q, "@timer_id", nTimerID);
    if (SqlStep(q))
    {
        Notice("ResetTimer(" + IntToString(nTimerID) + ") successful: " +
                IntToString(SqlGetInt(q, 0)) + " iterations remaining");
    }
}

void KillTimer(int nTimerID)
{
    CreateTimersTable();
    sqlquery q = SqlPrepareQueryModule(
        "DELETE FROM timers WHERE timer_id = @timer_id RETURNING 1;");
    SqlBindInt(q, "@timer_id", nTimerID);
    if (SqlStep(q))
        Notice("Killing timer " + IntToString(nTimerID));
}

int GetIsTimerInfinite(int nTimerID)
{
    CreateTimersTable();
    sqlquery q = SqlPrepareQueryModule(
        "SELECT iterations FROM timers WHERE timer_id = @timer_id;");
    SqlBindInt(q, "@timer_id", nTimerID);
    return SqlStep(q) ? !SqlGetInt(q, 0) : FALSE;
}

int GetTimerRemaining(int nTimerID)
{
    CreateTimersTable();
    sqlquery q = SqlPrepareQueryModule(
        "SELECT remaining FROM timers WHERE timer_id = @timer_id;");
    SqlBindInt(q, "@timer_id", nTimerID);
    return SqlStep(q) ? SqlGetInt(q, 0) : -1;
}

void SetTimerRemaining(int nTimerID, int nRemaining)
{
    CreateTimersTable();
    sqlquery q = SqlPrepareQueryModule(
        "UPDATE timers SET remaining = @remaining " +
        "WHERE timer_id = @timer_id AND iterations > 0;");
    SqlBindInt(q, "@timer_id",  nTimerID);
    SqlBindInt(q, "@remaining", nRemaining);
    SqlStep(q);
}
