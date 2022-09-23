# Core Utilities: Timers

`util_i_timers.nss` contains functions for running scripts on an interval.
`util_i_timers.nss` requires the following scripts:
- `util_i_debug.nss`
- `util_c_debug.nss`
- `util_i_math.nss`
- `util_i_sqlite.nss`
- `util_i_datapoint.nss`
- `util_i_color.nss`
- `util_c_color.nss`

## Contents

- [Concept](#concept)
- [Basic Usage](#basic-usage)
  - [Creating a Timer](#creating-a-timer)
  - [Starting a Timer](#starting-a-timer)
  - [Stopping a Timer](#stopping-a-timer)
  - [Destroying a Timer](#destroying-a-timer)
- [Advanced Usage](#advanced-usage)

## Concept

Timers are a way of running a script repeatedly on an interval. A timer can be
created on an object. Once started, it will continue to run until it is finished
iterating or until killed manually. Each time the timer elapses, its action will
run. By default, this action is to simply run a script.

## Basic Usage

### Creating a Timer

You can create a timer using `CreateTimer()`. This function takes the object
that should run the timer, the script that should execute when the timer
elapses, the interval between ticks, and the total number of iterations. It
returns the ID for the timer, which is used to reference it in the database.
You should save this timer for later use.

```nwscript
// The following creates a timer on oPC that will run the script "foo" every
// 6 seconds for 4 iterations.
int nTimerID = CreateTimer(oPC, "foo", 6.0, 4);
```

A timer created with 0 iterations will run until stopped or killed.

## Starting a Timer
Timers will not run until they are started wiuth `StartTimer()`. This function
takes the ID of the timer returned from `CreateTimer()`. If the second
parameter, `bInstant`, is TRUE, the timer will elapse immediately; otherwise, it
will elapse when its interval is complete:

```nwscript
StartTimer(nTimerID);
```

### Stopping a Timer
Stopping a timer with `StopTimer()` will suspend its execution:
```nwscript
StopTimer(nTimerID);
```
You can restart the timer later using `StartTimer()` to resume any remaining
iterations. If you want to start again from the beginning, you can call
`ResetTimer()` first:
```nwscript
ResetTimer(nTimerID);
StartTimer(nTimerID);
```

### Destroying a Timer
Calling `KillTimer()` will clean up all data associated with the timer. A timer
cannot be restarted after it is killed; you will have to create and start a new
one.
```nwscript
KillTimer(nTimerID);
```

Timers automatically kill themselves when they are finished iterating or when
the object they are executed on is no longer valid. You only need to use
`KillTimer()` if you want to destroy it before it is done iterating or if the
timer is infinite.

## Advanced Usage
By default, timer actions are handled by passing them to `ExecuteScript()`.
However, the final parameter of the `CreateTimer()` function allows you to
specify a handler script. If this parameter is not blank, the handler will be
called using `ExecuteScript()` and the action will be available to it as a
script parameter.

For example, the Core Framework allows timers to run event hooks by calling the
handler script `core_e_timerhook`, which is as follows:
```nwscript
#include "core_i_framework"

void main()
{
    string sEvent  = GetScriptParam(TIMER_ACTION);
    string sSource = GetScriptParam(TIMER_SOURCE);
    object oSource = StringToObject(sSource);
    RunEvent(sEvent, oSource);
}
```

To make this easier, `core_i_framework` contains an alias to `CreateTimer()`
called `CreateEventTimer()` that sets the handler script. You can create your
own aliases in the same way.
