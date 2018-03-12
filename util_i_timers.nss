// -----------------------------------------------------------------------------
//    File: util_i_timers.nss
//  System: Utilities (include script)
//     URL: https://github.com/squattingmonk/sm-utils
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// Timer utilities functions. These functions are used to call scripts at
// regular intervals on an object. These scripts can be regular scripts or a
// list of library scripts. They can be started, stopped, or reset at any point,
// even in the script from which they are called.
//
// These functions have been adapted from those found in Edward Beck's HRC2.
//
// ----- Usage -----------------------------------------------------------------
// - A timer is created using CreateTimer(). This returns a unqiue ID for the
//   timer. A timer will not run unless it is started.
// - A created timer can be started with StartTimer(). If the second parameter
//   of StartTimer() is TRUE, the script to be executed will fire immediately.
//   This counts towards the number of iterations of the timer.
// - A timer can be paused with StopTimer(). It can be restarted later using
//   StartTimer().
// - A timer can be deleted using KillTimer(). The script will not be run again.
// - A timer can have its iterations reset using ResetTimer().
// - A running script can check to see if it has been started by a timer using
//   GetCurrentTimer().
//
// ----- Examples -------------------------------------------------------------
// In the following example, we have a library script that applies fire damage
// and a VFX to the calling target. We want the script to fire once per round
// 1d6 times:
//
//      int nTimerID = CreateTimer(oPC, "FireDamage", 6.0, d6());
//      SetLocalInt(oPC, "FireDamageTimer", nTimerID);
//      StartTimer(nTimerID);
//
// This will call the script on the PC instantly and again 1d6 - 1 more times.
//
// Now suppose we made a water bucket item that should douse the fire when used
// on the PC. We can add this to its script:
//
//      int nTimerID = GetLocalInt(oPC, "FireDamageTimer");
//      if (GetIsTimerValid(nTimerID)
//      {
//          DeleteLocalInt(oPC, "FireDamageTimer");
//          KillTimer(nTimerID);
//      }
//
// Remember to clean up the "FireDamageTimer" variable, since the timer ID may
// be re-used again by a later script.
// -----------------------------------------------------------------------------

#include "util_i_debug"
#include "util_i_csvlists"
#include "util_i_varlists"
#include "util_i_datapoint"
#include "util_i_libraries"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

// Variable names for timer management
const string TIMER_CURRENT    = "TIMER_CURRENT";    // The ID of the timer currently running on the object
const string TIMER_EXISTS     = "TIMER_EXISTS";     // Denotes that a timer with the given ID exists
const string TIMER_IDS        = "TIMER_IDS";        // A list of timer IDs to recycle
const string TIMER_INTERVAL   = "TIMER_INTERVAL";   // The interval between execution of the timer's script
const string TIMER_ITERATIONS = "TIMER_ITERATIONS"; // The number of times the timer will run
const string TIMER_JITTER     = "TIMER_JITTER";     // An amount of variance on the timer's delay
const string TIMER_NEXT_ID    = "TIMER_NEXT_ID";    // The ID for the next timer
const string TIMER_REMAINING  = "TIMER_REMAINING";  // The number of iterations remaining
const string TIMER_RUNNING    = "TIMER_RUNNING";    // Whether the timer is currently running
const string TIMER_SCRIPT     = "TIMER_SCRIPT";     // The script(s) to execute when the timer elapses
const string TIMER_TARGET     = "TIMER_TARGET";     // The object on which the timer's script will run
const string TIMER_TARGETS_PC = "TIMER_TARGETS_PC"; // Whether the timer's target is a PC

// -----------------------------------------------------------------------------
//                               Global Variables
// -----------------------------------------------------------------------------

// Timers system datapoint
object TIMERS = GetDatapoint("TIMERS");

// The ID of the currently executing timer. We declare this in global scope so
// that timer scripts which themselves create timers don't get messed up by
// their child scripts.
int CURRENT_TIMER = GetLocalInt(OBJECT_SELF, TIMER_CURRENT);

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< CreateTimer >---
// ---< util_i_timers >---
// Creates a timer and returns an integer representing its unique ID. After a
// timer is created you will need to start it to get it to run. You cannot
// create a timer on an invalid oScriptObject or with a non-positive interval
// value. A returned timer ID of 0 means the timer was not created.
// Parameters:
// - oTarget: the object sScriptName will run on.
// - sScript: the script that will fire when the set time has elapsed (can
//   either be a list of library scripts or a standalone script).
// - fInterval: the number of seconds before sScript executes.
// - nIterations: the number of times to the timer can elapse. 0 means no limit.
//   If this is 0, fInterval must be greater than 6.0.
// - nJitter: add a bit of randomness to how often a timer executes. A random
//   number of seconds between 0 and nJitter will  be added to fInterval each
//   time the script runs. Leave this at the default value of 0 for no jitter.
// Note: Save the returned timer ID somewhere so that it can be accessed and
// used to stop, start, or kill the timer later. If oScriptObject has become
// invalid or if oScriptObject was a PC and that PC has logged off, then
// instead of executing the timer script, it will kill the timer.
int CreateTimer(object oTarget, string sScript, float fInterval, int nIterations = 0, int nJitter = 0);

// ---< GetIsTimerValid >---
// ---< util_i_timers >---
// Returns whether the timer with ID nTimerID exists.
int GetIsTimerValid(int nTimerID);

// ---< StartTimer >---
// ---< util_i_timers >---
// Starts a timer, executing its script immediately if bInstant is TRUE, and
// again each interval period until finished iterating, stopped, or killed.
void StartTimer(int nTimerID, int bInstant = TRUE);

// ---< StopTimer >---
// ---< util_i_timers >---
// Suspends execution of the timer script associated with the value of nTimerID.
// This does not kill the timer, only stops its script from being executed.
void StopTimer(int nTimerID);

// ---< KillTimer >---
// ---< util_i_timers >---
// Kills the timer associated with the value of nTimerID. This results in all
// information about the given timer ID being deleted. Since the information is
// gone, the script associated with that timer ID will not get executed again.
void KillTimer(int nTimerID);

// ---< ResetTimer >---
// ---< util_i_timers >---
// Resets the number of remaining iterations on the timer associated with
// nTimerID.
void ResetTimer(int nTimerID);

// ---< GetCurrentTimer >---
// ---< util_i_timers >---
// Returns the ID of the timer executing the current script. Useful if you want
// to be able to reset or stop the timer that triggered the script.
int GetCurrentTimer();


// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

int CreateTimer(object oTarget, string sScript, float fInterval, int nIterations = 0, int nJitter = 0)
{
    Debug("Creating timer " + sScript + " on " + GetName(oTarget) +
          ": fInterval="   + FloatToString(fInterval) +
          ", nIterations=" + IntToString(nIterations) +
          ", nJitter="     + IntToString(nJitter));

    // Sanity checks: don't create the timer if...
    // 1. the target is invalid
    // 2. the interval is not greater than 0.0
    // 3. the number of iterations is non-positive
    // 4. the interval is more than once per round and the timer is infinite
    string sError;
    if (!GetIsObjectValid(oTarget))
        sError = "oTarget is invalid";
    else if (fInterval <= 0.0)
        sError = "fInterval is negative";
    else if (nIterations < 0)
        sError = "nIterations is negative";
    else if (fInterval < 6.0 && !nIterations)
        sError = "fInterval is too short for infinite executions";

    if (sError != "")
    {
        Debug("Cannot create timer " + sScript + ": " + sError, DEBUG_LEVEL_CRITICAL);
        return 0;
    }

    // Get a new timer ID. When an old timer is killed, we add its ID to a list
    // of IDs to recycle. This way long-running PWs overusing timers won't run
    // out of timer IDs.
    int nTimerID;
    int nCount = CountIntList(TIMERS, TIMER_IDS);
    if (nCount)
    {
        nTimerID = nCount - 1;
        DeleteListInt(TIMERS, nTimerID, TIMER_IDS);
    }
    else
    {
        nTimerID = GetLocalInt(TIMERS, TIMER_NEXT_ID);
        SetLocalInt(TIMERS, TIMER_NEXT_ID, nTimerID + 1);
    }

    string sTimerID = IntToString(nTimerID);

    SetLocalString(TIMERS, TIMER_SCRIPT      + sTimerID, sScript);
    SetLocalObject(TIMERS, TIMER_TARGET      + sTimerID, oTarget);
    SetLocalFloat (TIMERS, TIMER_INTERVAL    + sTimerID, fInterval);
    SetLocalInt   (TIMERS, TIMER_JITTER      + sTimerID, abs(nJitter));
    SetLocalInt   (TIMERS, TIMER_ITERATIONS  + sTimerID, nIterations);
    SetLocalInt   (TIMERS, TIMER_REMAINING   + sTimerID, nIterations);
    SetLocalInt   (TIMERS, TIMER_TARGETS_PC  + sTimerID, GetIsPC(oTarget));
    SetLocalInt   (TIMERS, TIMER_EXISTS      + sTimerID, TRUE);

    Debug("Successfully created new timer with ID=" + sTimerID);
    return nTimerID;
}

int GetIsTimerValid(int nTimerID)
{
    // Timer IDs less than or equal to 0 are always invalid.
    return (nTimerID > 0) && GetLocalInt(TIMERS, TIMER_EXISTS + IntToString(nTimerID));
}

// Private function used by StartTimer().
void _TimerElapsed(int nTimerID, int bFirstRun = FALSE)
{
    string sError, sTimerID = IntToString(nTimerID);
    object oTarget = GetLocalObject(TIMERS, TIMER_TARGET + sTimerID);
    Debug("Timer elapsed: nTimerID=" + sTimerID + " bFirstRun=" + IntToString(bFirstRun));

    // Sanity checks: make sure...
    // 1. the timer still exists
    // 2. the timer has been started
    // 3. the timer target is still valid
    // 4. the timer target is still a PC if it was originally (usually this only
    //    changes due to a PC logging out.
    if (!GetLocalInt(TIMERS, TIMER_EXISTS + sTimerID))
        sError = "Timer no longer exists. Running cleanup...";
    else if (!GetLocalInt(TIMERS, TIMER_RUNNING + sTimerID))
        sError = "Timer has not been started";
    else if (!GetIsObjectValid(oTarget))
        sError = "Timer target is no longer valid. Running cleanup...";
    else if (GetLocalInt(TIMERS, TIMER_TARGETS_PC + sTimerID) && !GetIsPC(oTarget))
        sError = "Timer target used to be a PC but now is not";

    if (sError != "")
    {
        string sScript = GetLocalString(TIMERS, TIMER_SCRIPT + sTimerID);
        Debug("Cannot execute timer " + sScript + ": " + sError, DEBUG_LEVEL_WARNING);
        KillTimer(nTimerID);
    }

    // Check how many more times the timer should be run
    int nIterations = GetLocalInt(TIMERS, TIMER_ITERATIONS + sTimerID);
    int nRemaining  = GetLocalInt(TIMERS, TIMER_REMAINING  + sTimerID);

    // If we're running infinitely or we have more runs remaining...
    if (!nIterations || nRemaining)
    {
        if (!bFirstRun)
        {
            // If we're not running an infinite number of times, decrement the
            // number of iterations we have remaining
            if (nIterations)
                SetLocalInt(TIMERS, TIMER_REMAINING + sTimerID, nRemaining - 1);

            // Execute the timer scripts, dipatching to a library as needed.
            string sScript;
            string sScripts = GetLocalString(TIMERS, TIMER_SCRIPT + sTimerID);
            int i, nCount = CountList(sScripts);
            for (i = 0; i < nCount; i++)
            {
                // Check to see Let the script know the calling timer ID so it
                // can cancel the timer if it needs to. We do this each time in
                // case the script we call creates its own instant run timers.
                SetLocalInt(oTarget, TIMER_CURRENT, nTimerID);

                sScript = GetListItem(sScripts, i);
                RunLibraryScript(sScript, oTarget);

                // Check to see if we're still valid. If not, the script we just
                // ran killed us. We should abort.
                if (!GetLocalInt(TIMERS, TIMER_EXISTS + sTimerID))
                    break;
            }

            DeleteLocalInt(oTarget, TIMER_CURRENT);

            // In case one of those scripts we just called reset the timer...
            if (nIterations)
                nRemaining = GetLocalInt(TIMERS, TIMER_REMAINING  + sTimerID);
        }

        // If we have runs left, call our timer's next iteration.
        if (!nIterations || nRemaining)
        {
            // Account for any jitter
            int   nJitter        = GetLocalInt  (TIMERS, TIMER_JITTER);
            float fTimerInterval = GetLocalFloat(TIMERS, TIMER_INTERVAL + sTimerID) +
                                   IntToFloat(Random(nJitter + 1));

            if (IsDebugging(DEBUG_LEVEL_NOTICE))
            {
                Debug("Calling next iteration of timer " + sTimerID + " in " +
                      FloatToString(fTimerInterval) + " seconds. Runs remaining: " +
                      (nIterations ? IntToString(nRemaining) : "Infinite"));
            }

            DelayCommand(fTimerInterval, _TimerElapsed(nTimerID));
            return;
        }
    }

    // We have no more runs left! Kill the timer to clean up.
    Debug("No more runs remaining on timer " + sTimerID + ". Running cleanup...");
    KillTimer(nTimerID);
}

void StartTimer(int nTimerID, int bInstant = TRUE)
{
    string sTimerID = IntToString(nTimerID);

    if (GetLocalInt(TIMERS, TIMER_RUNNING + sTimerID))
    {
        Debug("Could not start timer " + sTimerID + " because it was already started.");
        return;
    }

    SetLocalInt(TIMERS, TIMER_RUNNING + sTimerID, TRUE);
    _TimerElapsed(nTimerID, !bInstant);
}

void StopTimer(int nTimerID)
{
    string sTimerID = IntToString(nTimerID);
    DeleteLocalInt(TIMERS, TIMER_RUNNING + sTimerID);
}

void ResetTimer(int nTimerID)
{
    string sTimerID = IntToString(nTimerID);
    int nRemaining  = GetLocalInt(TIMERS, TIMER_ITERATIONS + sTimerID);
                      SetLocalInt(TIMERS, TIMER_REMAINING  + sTimerID, nRemaining);

    Debug("Resetting remaining iterations of timer " + sTimerID +
          " to " + IntToString(nRemaining));
}

// Private function for KillTimer(). Adds the timer ID to a list of IDs to
// recycle. We cast this into a void-returning function so it can be delayed.
void _RecycleTimerID(int nTimerID)
{
    AddListInt(TIMERS, nTimerID, TIMER_IDS);
}

void KillTimer(int nTimerID)
{
    string sTimerID = IntToString(nTimerID);

    // Cleanup the local variables
    DeleteLocalString(TIMERS, TIMER_SCRIPT      + sTimerID);
    DeleteLocalObject(TIMERS, TIMER_TARGET      + sTimerID);
    DeleteLocalFloat (TIMERS, TIMER_INTERVAL    + sTimerID);
    DeleteLocalInt   (TIMERS, TIMER_ITERATIONS  + sTimerID);
    DeleteLocalInt   (TIMERS, TIMER_REMAINING   + sTimerID);
    DeleteLocalInt   (TIMERS, TIMER_TARGETS_PC  + sTimerID);
    DeleteLocalInt   (TIMERS, TIMER_RUNNING     + sTimerID);
    DeleteLocalInt   (TIMERS, TIMER_EXISTS      + sTimerID);

    // Add the ID to a list of timer IDs to reuse. Do this on a delay to avoid
    // funkyness when processing a list of timer scripts that could be trying to
    // kill the active timer.
    DelayCommand(0.0, _RecycleTimerID(nTimerID));
}

int GetCurrentTimer()
{
    return CURRENT_TIMER;
}
