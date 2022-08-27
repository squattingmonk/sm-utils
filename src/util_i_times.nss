/// ----------------------------------------------------------------------------
/// @file   util_i_times.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Functions for managing times, dates, and durations.
/// ----------------------------------------------------------------------------
/// @details
/// # Concepts
/// - Duration: a float value representing an *amount of time* in seconds. A
///   duration can be easily passed to many game functions that expect a time,
///   such as `DelayCommand()`, `PlayAnimation()`, etc.
/// - Time: a struct value representing a particular *moment in time* as
///   measured using the game calendar and clock. A Time has a field for the
///   year, month, day, hour, minute, second, and millisecond. Note that the
///   month and day count from 1, while all other units count from 0 (including
///   years, since NWN allows year 0). A Time also has a field to set the
///   minutes-per-hour (defaults to the module setting, which defaults to 2).
/// - Game Time: a Time with a minutes-per-hour setting of 60. This allows you
///   to convert the time shown by the game clock into a time that matches how
///   the characters in the game would perceive it. For example, with the
///   default minutes-per-hour setting of 2, the Time "13:01" would correspond
///   to a Game Time of "13:30".
/// - Normalizing Times: You can normalize a Time to ensure none of its units
///   are overflowing their bounds. For example, a Time with a Minute field of 0
///   and Second field of 90 would be normalized to a Minute of 1 and a Second
///   of 30. When normalizing a Time, you can also change the minutes-per-hour
///   setting. This is how the functions in this file convert between Time and
///   Game Time.
/// ----------------------------------------------------------------------------
/// # Usage
///
/// ## Creating a Time
/// You can create a Time using `GetTime()`:
/// ```nwscript
/// struct Time t = GetTime(1372, 6, 1, 13);
/// ```
///
/// You could also parse an ISO 8601 time string into a Time:
/// ```nwscript
/// struct Time t = StringToTime("1372-06-01 13:00:00:000");
/// ```
///
/// You can also create a Time manually by declaring a Time struct and setting
/// the fields independently:
///
/// ```nwscript
/// struct Time t;
/// t.Year = 1372;
/// t.Month = 6;
/// t.Day = 1;
/// t.Hour = 13;
/// // ...
/// ```
///
/// When not using the `GetTime()` function, it's a good idea to normalize the
/// resultant Time to distribute the field values correctly:
/// ```nwscript
/// struct Time t;
/// t.Second = 90;
///
/// t = NormalizeTime(t);
/// Assert(t.Minute == 1);
/// Assert(t.Second == 30);
/// ```
///
/// ## Converting Between Time and Game Time
///
/// ```nwscript
/// // Assuming the default module setting of 2 minutes per hour
/// struct Time tTime = StringToTime("1372-06-01 13:01:00:000");
/// Assert(tTime.Hour == 13);
/// Assert(tTime.Minute == 1);
///
/// struct Time tGame = TimeToGameTime(tTime);
/// Assert(tGame.Hour == 13);
/// Assert(tGame.Minute == 30);
///
/// struct tBack = GameTimeToTime(tGame);
/// Assert(tTime == tBack);
/// ```
///
/// ## Getting the Current Time
/// ```nwscript
/// struct Time tTime = GetCurrentTime();
/// struct Time tGame = GetCurrentGameTime();
/// ```
///
/// ## Setting the Current Time
/// @note You can only set the time forward in NWN.
///
/// ```nwscript
/// struct Time t = StringToTime("2022-08-25 13:00:00:000");
/// SetCurrentTime(t);
/// ```
///
/// Alternatively, you can advance Time by a duration:
/// ```nwscript
/// AdvanceCurrentTime(120.0);
/// ```
///
/// ## Dropping units from a Time
/// You can reduce the precision of a time:
/// ```nwscript
/// struct Time a = GetTime(1372, 6, 1, 13);
/// struct Time b = GetTime(1372, 6, 1);
/// struct Time c = GetPrecisionTime(a, TIME_UNIT_DAY);
/// Assert(a != b);
/// Assert(b == c);
/// ```
///
/// ## Saving a Time
/// The easiest way to save a time and get it later is to use the
/// `SetLocalTime()` and `GetLocalTime()` functions. These functions convert a
/// Time into json and save it as a local variable.
///
/// In this example, we save the server start time OnModuleLoad and then get it
/// later:
/// ```nwscript
/// // OnModuleLoad
/// SetLocalTime(GetModule(), "ServerStart", GetCurrentTime());
///
/// // later on...
/// struct Time tServerStart = GetLocalTime(GetModule(), "ServerStart");
/// ```
///
/// If you want to store a Time in a database, you can convert it into json or
/// into a string before passing it to a query. The json method is preferable
/// for persistent storage, since it is guaranteed to be correct if the module's
/// minutes-per-hour setting changes after the value is stored:
/// ```nwscript
/// struct Time tTime = GetCurrentTime();
/// json jTime = TimeToJson(tTime);
/// string sSql = "INSERT INTO data (varname, value) VALUES ("ServerTime", @time);";
/// sqlquery q = SqlPrepareQueryCampaign("mydb", sSql);
/// SqlBindJson(q, "@time", jTime);
/// SqlStep(q);
/// ```
///
/// You can then convert the json back into a Time:
/// ```nwscript
/// string Time tTime;
/// string sSql = "SELECT value FROM data WHERE varname='ServerTime';";
/// sqlquery q = SqlPrepareQueryCampaign("mydb", sSql);
/// if (SqlStep(q))
///     tTime = JsonToTime(SqlGetJson(q, 0));
/// ```
///
/// For simpler applications (such as saving to the module's volatile database),
/// converting to a string works fine and could even be preferable since you can
/// use sqlite's `<`, `>`, and `=` operators to check if one time is before,
/// after, or equal to another.
/// ```nwscript
/// struct Time tTime = GetCurrentTime();
/// string sTime = TimeToString();
/// string sSql = "INSERT INTO data (varname, value) VALUES ("ServerTime", @time);";
/// sqlquery q = SqlPrepareQueryCampaign("mydb", sSql);
/// SqlBindString(q, "@time", sTime);
/// SqlStep(q);
/// ```
///
/// ## Comparing Times
/// To check the amount of time between two Times:
/// ```nwscript
/// struct Time a = StringToTime("1372-06-01 13:00:00:000");
/// struct Time b = StringToTime("1372-06-01 13:01:30:500");
/// float fDur = GetDuration(a, b);
/// Assert(fDur == 90.5);
/// ```
///
/// To check if one time is before or after another:
/// ```nwscript
/// struct Time a = StringToTime("1372-06-01 13:00:00:000");
/// struct Time b = StringToTime("1372-06-01 13:01:30:500");
/// Assert(GetIsTimeBefore(a, b));
/// Assert(!GetIsTimeAfter(a, b));
/// ```
///
/// To check if two times are equal:
/// ```nwscript
/// struct Time a = StringToTime("1372-06-01 13:00:00:000");
/// struct Time b = StringToTime("1372-06-01 13:01:00:000");
/// struct Time c = TimeToGameTime(b);
///
/// Assert(!GetIsTimeEqual(a, b));
/// Assert(GetTimeIsEqual(b, c));
/// Assert(b != c);
/// ```
///
/// To check if a duration has passed since a Time:
/// ```nwscript
/// int CheckForMinRestTime(object oPC, float fMinTime)
/// {
///     struct Time tLast = GetLocalTime(oPC, "LastRest");
///     return GetDurationSince(tSince) >= fMinTime;
/// }
/// ```
///
/// To calculate the duration until a Time is reached:
/// ```nwscript
/// struct Time tMidnight = GetTime(GetCalendarYear(), GetCalendarMonth(), GetCalendarDay() + 1);
/// float fDurToMidnight = GetDurationUntil(tMidnight);
/// ```
/// ----------------------------------------------------------------------------

#include "util_i_math"
#include "util_i_strings"
#include "util_i_debug"

// -----------------------------------------------------------------------------
//                                     Types
// -----------------------------------------------------------------------------

/// @struct Time
/// @brief A datatype holding a calendar date and clock time.
/// @note Since this represents a calendar date, the month and day count from 1,
///     but the year still counts from 0 (since NWN allows year 0).
struct Time
{
    int Year;        ///< 0..32000
    int Month;       ///< 1..12
    int Day;         ///< 1..28
    int Hour;        ///< 0..23
    int Minute;      ///< 0.._MinsPerHour
    int Second;      ///< 0..59
    int Millisecond; ///< 0..999
    int MinsPerHour; ///< The minutes per hour setting: 1..60
};

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

// These are the units in a valid time.
const int TIME_UNIT_YEAR        = 0;
const int TIME_UNIT_MONTH       = 1;
const int TIME_UNIT_DAY         = 2;
const int TIME_UNIT_HOUR        = 3;
const int TIME_UNIT_MINUTE      = 4;
const int TIME_UNIT_SECOND      = 5;
const int TIME_UNIT_MILLISECOND = 6;

// Prefix for local times to avoid collision
const string TIME_PREFIX = "*Time: ";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ----- Conversions -----------------------------------------------------------

/// @brief Convert years to a duration in seconds.
/// @param nYears The number of years to convert
float Years(int nYears);

/// @brief Convert months to a duration in seconds.
/// @param nMonths The number of months to convert
float Months(int nMonths);

/// @brief Convert days to a duration in seconds.
/// @param nDays The number of days to convert
float Days(int nDays);

/// @brief Convert hours to a duration in seconds.
/// @param nHours The number of hours to convert
float Hours(int nHours);

/// @brief Convert minutes to a duration in seconds.
/// @param nMinutes The number of minutes to convert
float Minutes(int nMinutes);

/// @brief Convert seconds to a duration in seconds.
/// @param nSeconds The number of seconds to convert
float Seconds(int nSeconds);

/// @brief Convert milliseconds to a duration in seconds.
/// @param nYears The number of milliseconds to convert
float Milliseconds(int nMilliseconds);

/// @brief Convert hours to minutes.
/// @param nHours The number of hours to convert
/// @note The return value varies depending on the module's time settings
int HoursToMinutes(int nHours = 1);

// ----- Times -----------------------------------------------------------------

/// @brief Distribute units in a time, optionally converting minutes per hour.
/// @details Units that overflow their range have the excess added to the next
///     highest unit (e.g., 1500 msec -> 1 sec, 500 msec). If `nMinsPerHour`
///     does not match `t.MinsPerHour`, the minutes, seconds, and milliseconds
///     will be recalculated to match the new setting.
/// @param t The Time to normalize
/// @param nMinsPerHour The number of minutes per hour to normalize with. If 0,
///     will use `t.MinsPerHour`.
/// @note If any unit in `t` falls outside the bounds after normalization, an
///     invalid time is returned. You can check for this using GetIsTimeValid().
struct Time NormalizeTime(struct Time t, int nMinsPerHour = 0);

/// @brief Check if any unit in a normalized time is outside its range.
/// @param t The Time to validate
/// @param bNormalize Whether to normalize the time before checking You should
///     only set this to FALSE if you know `t` is already normalized and want to
///     save cycles.
/// @returns TRUE if valid, FALSE otherwise.
int GetIsTimeValid(struct Time t, int bNormalize = TRUE);

/// @brief Generate a Time.
/// @param nYear The year (0..32000)
/// @param nMonth The month of the year (1..12)
/// @param nDay The day of the month (1..28)
/// @param nHour The hour (0..23)
/// @param nMinute The minute (0..nMinsPerHour)
/// @param nSecond The second (1..60)
/// @param nMillisecond The millisecond (0..1000)
/// @param nMinsPerHour The number of minutes per hour (1..60). If 0, will use
///     the module's default setting.
/// @returns A normalized Time
struct Time GetTime(int nYear = 0, int nMonth = 1, int nDay = 1, int nHour = 0, int nMinute = 0, int nSecond = 0, int nMillisecond = 0, int nMinsPerHour = 0);

/// @brief Convert a Time to an in-game time.
/// @param t The Time to convert
/// @note Alias for NormalizeTime(t, 60).
struct Time TimeToGameTime(struct Time t);

/// @brief Convert an in-game time to a Time.
/// @param t The Time to convert
/// @note Alias for NormalizeTime(t, HoursToMinutes()).
struct Time GameTimeToTime(struct Time t);

/// @brief Get a Time representing the current calendar date and clock time.
/// @returns A Time with a `MinsPerHour` equivalent to the module's setting.
struct Time GetCurrentTime();

/// @brief Get a Time representing the current calendar date and in-game time.
/// @returns A Time with a `MinsPerHour` of 60.
/// @note Alias for TimeToGameTime(GetCurrentTime()).
struct Time GetCurrentGameTime();

/// @brief Set the current calendar date and clock time
/// @param t The time to set the calendar and clock to. Must be a valid Time
///     that is after the current time.
void SetCurrentTime(struct Time t);

/// @brief Set the current calendar date and clock time forwards by a duration.
/// @param fSeconds A duration in seconds by which to advance the time. Must be
///     positive.
void AdvanceCurrentTime(float fSeconds);

/// @brief Drop smaller units from a Time.
/// @param t The time to modify
/// @param nUnit A TIME_UNIT_* constant representing the maximum precision.
///     Units more precise than this are set to their lowest value.
struct Time GetPrecisionTime(struct Time t, int nUnit);

// ----- Durations -------------------------------------------------------------

/// @brief Get the duration of an interval between two times.
/// @param a The Time at the start of interval
/// @param b The Time at the end of the interval
/// @param bNormalize Whether to normalize a and b to use the module's minutes
///     per hour setting. Only set this to FALSE if you know a and b are both
///     normalized and use the module's setting.
/// @returns A duration in seconds. If a is after b, will return a negative
///     number. If a == b, will return 0.0.
/// @note The returned duration is always in a module's clock seconds,
///     regardless of the MinsPerHour setting of either a or b. This means
///     values obtained with this function may be passed directly to game
///     functions that expect a duration (like DelayCommand() or spell effects).
float GetDuration(struct Time a, struct Time b, int bNormalize = TRUE);

/// @brief Get the duration of the interval between a time and the current time.
/// @param tSince The Time at the start of the interval.
/// @param bNormalize Whether to normalize tSince to use the module's minutes
///     per hour setting. Only set this to FALSE if you know tSince is already
///     normalized and uses the module's setting.
/// @returns A duration in seconds. If tSince is after the current time, will
///     return a negative number. If tSince is equal to the current time, will
///     return 0.0.
float GetDurationSince(struct Time tSince, int bNormalize = TRUE);

/// @brief Get the duration of the interval between the current time and a time.
/// @param tUntil The Time at the end of the interval.
/// @param bNormalize Whether to normalize tUntil to use the module's minutes
///     per hour setting. Only set this to FALSE if you know tUntil is already
///     normalized and uses the module's setting.
/// @returns A duration in seconds. If tUntil is before the current time, will
///     return a negative number. If tUntil is equal to the current time, will
///     return 0.0.
float GetDurationUntil(struct Time tUntil, int bNormalize = TRUE);

/// @brief Check whether a time is after another time.
/// @param a The Time to check
/// @param b The Time to check against
/// @param bNormalize Whether to normalize a and b to use the same minutes per
///     hour setting. Only set this to FALSE if you know a and b are both
///     normalized and use the same minutes per hour setting.
/// @returns TRUE if a is after b, FALSE otherwise
int GetIsTimeAfter(struct Time a, struct Time b, int bNormalize = TRUE);

/// @brief Check whether a time is after another time.
/// @param a The Time to check
/// @param b The Time to check against
/// @param bNormalize Whether to normalize a and b to use the same minutes per
///     hour setting. Only set this to FALSE if you know a and b are both
///     normalized and use the same minutes per hour setting.
/// @returns TRUE if a is before b, FALSE otherwise
int GetIsTimeBefore(struct Time a, struct Time b, int bNormalize = TRUE);

/// @brief Check whether a time is equal to another time.
/// @param a The Time to check
/// @param b The Time to check against
/// @param bNormalize Whether to normalize a and b to use the same minutes per
///     hour setting. Only set this to FALSE if you know a and b are both
///     normalized and use the same minutes per hour setting.
/// @returns TRUE if a is equivalent to b, FALSE otherwise
/// @note This checks if the normalized times are equal. If you want to instead
///     check if two Time structs are exactly equal, use `a == b`.
int GetIsTimeEqual(struct Time a, struct Time b, int bNormalize = TRUE);

/// @brief Increase time by a duration
/// @param t The Time to increase
/// @param fDur The duration in seconds to increase by
/// @note If fDur is negative, will actually decrease the time.
struct Time IncreaseTime(struct Time t, float fDur);

/// @brief Decrease time by a duration
/// @param t The Time to decrease
/// @param fDur The duration in seconds to decrease by
/// @note If fDur is negative, will actually increase the time.
struct Time DecreaseTime(struct Time t, float fDur);

// ----- Json Conversion -------------------------------------------------------

/// @brief Convert a Time into a json object.
/// @details The json object will be have a key for each field of the Time
///     struct. Since this includes the minutes per hour setting, this object is
///     safe to be stored in a database if it is possible the module's minutes
///     per hour setting will change. The object can be converted back using
///     JsonToTime().
/// @param t The Time to convert
/// @param bNormalize Whether to normalize the time before converting
json TimeToJson(struct Time t, int bNormalize = TRUE);

/// @brief Convert a json object into a Time.
/// @param j The json object to convert
/// @param bNormalize Whether to normalize the time after converting
struct Time JsonToTime(json j, int bNormalize = TRUE);

/// @brief Return a Time from a local variable.
/// @param oObject The object to get the local variable from
/// @param sVarName The varname for the local variable
struct Time GetLocalTime(object oObject, string sVarName);

/// @brief Store a Time as a local variable.
/// @param oObject The object to store the local variable on
/// @param sVarName The varname for the local variable
/// @param tValue The Time to store
void SetLocalTime(object oObject, string sVarName, struct Time tValue);

/// @brief Delete a Time from a local variable.
/// @param oObject The object to delete the local variable from
/// @param sVarName The varname for the local variable
void DeleteLocalTime(object oObject, string sVarName);

// ----- String Conversions ----------------------------------------------------

/// @brief Convert a Time into a string.
/// @param t The Time to convert.
/// @param bNormalize Whether to normalize the time before converting.
/// @returns An ISO 8601 formatted datetime, e.g., "1372-06-01 13:00:00:000".
string TimeToString(struct Time t, int bNormalize = TRUE);

/// @brief Convert an ISO 8601 formatted datetime string into a Time.
/// @param sTime The string to convert.
/// @param nMinsPerHour The number of minutes per hour expected in the time. If
///     0, will use the module setting.
/// @note The returned Time is not normalized.
struct Time StringToTime(string sTime, int nMinsPerHour = 0);

/// @brief Convert a duration to a string.
/// @param fDur A duration in seconds.
string DurationToString(float fDur);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

// ----- Conversions -----------------------------------------------------------

float Years(int nYears)
{
    return HoursToSeconds(nYears * 12 * 28 * 24);
}

float Months(int nMonths)
{
    return HoursToSeconds(nMonths * 28 * 24);
}

float Days(int nDays)
{
    return HoursToSeconds(nDays * 24);
}

float Hours(int nHours)
{
    return HoursToSeconds(nHours);
}

float Minutes(int nMinutes)
{
    return nMinutes * 60.0;
}

float Seconds(int nSeconds)
{
    return IntToFloat(nSeconds);
}

float Milliseconds(int nMilliseconds)
{
    return nMilliseconds / 1000.0;
}

int HoursToMinutes(int nHours = 1)
{
    return FloatToInt(HoursToSeconds(nHours)) / 60;
}

// ----- Times -----------------------------------------------------------------

struct Time NormalizeTime(struct Time t, int nMinsPerHour = 0)
{
    struct Time tInvalid;

    // If the conversion factor was not set, we assume it's using the module's
    if (t.MinsPerHour <= 0)
        t.MinsPerHour = HoursToMinutes();

    // If this is > 0, we will adjust the time's conversion factor to match the
    // requested value. Otherwise, assume we're using the same conversion factor
    // and just prettifying units.
    nMinsPerHour = nMinsPerHour > 0 ? clamp(nMinsPerHour, 1, 60) : t.MinsPerHour;

    // Convert time units if needed
    if (t.MinsPerHour != nMinsPerHour)
    {
        // Everything less than 1 hour is converted to milliseconds, then the
        // milliseconds are converted to the new time.
        t.Millisecond += (t.Second * 1000) + (t.Minute * 60000);
        t.Millisecond = t.Millisecond * nMinsPerHour / t.MinsPerHour;
        t.Second = 0;
        t.Minute = 0;
        t.MinsPerHour = nMinsPerHour;
    }

    // Normalize each unit. Units bigger than the bounds are added to the next
    // highest unit. Units smaller than the bound borrow from the next largest
    // unit.
    int nFactor;
    if (t.Millisecond >= (nFactor = 1000))
    {
        t.Second += t.Millisecond / nFactor;
        t.Millisecond %= nFactor;
    }
    else if (t.Millisecond < 0)
    {
        t.Second += t.Millisecond / nFactor - 1;
        t.Millisecond = nFactor + (t.Millisecond % nFactor);
    }

    if (t.Second >= (nFactor = 60))
    {
        t.Minute += t.Second / nFactor;
        t.Second %= nFactor;
    }
    else if (t.Second < 0)
    {
        t.Minute += t.Second / nFactor - 1;
        t.Second = nFactor + (t.Second % nFactor);
    }

    if (t.Minute >= (nFactor = t.MinsPerHour))
    {
        t.Hour += t.Minute / nFactor;
        t.Minute %= nFactor;
    }
    else if (t.Minute < 0)
    {
        t.Hour += t.Minute / nFactor - 1;
        t.Minute = nFactor + (t.Minute % nFactor);
    }

    if (t.Hour >= (nFactor = 24))
    {
        t.Day += t.Hour / nFactor;
        t.Hour %= nFactor;
    }
    else if (t.Hour < 0)
    {
        t.Day += t.Hour / nFactor - 1;
        t.Hour = nFactor + (t.Hour % nFactor);
    }

    if (t.Day > (nFactor = 28))
    {
        t.Month += t.Day / nFactor;
        t.Day %= nFactor;
    }
    else if (t.Day < 1)
    {
        t.Month += t.Day / nFactor - 1;
        t.Day = nFactor + (t.Day % nFactor);
    }

    if (t.Month > (nFactor = 12))
    {
        t.Year += t.Month / nFactor;
        t.Month %= nFactor;
    }
    else if (t.Month < 1)
    {
        t.Year += t.Month / nFactor - 1;
        t.Month = nFactor + (t.Month % nFactor);
    }

    // Everything should be positive, so if the year is negative, we borrowed
    // more time than was available, making this a negative time. In this case
    // we return "0000-00-00 00:00:00:000".
    if (t.Year < 0 || t.Year > 32000)
        return tInvalid;
    return t;
}

int GetIsTimeValid(struct Time t, int bNormalize = TRUE)
{
    struct Time tInvalid;
    if (bNormalize)
        t = NormalizeTime(t);
    return t != tInvalid;
}

struct Time GetTime(int nYear = 0, int nMonth = 1, int nDay = 1, int nHour = 0, int nMinute = 0, int nSecond = 0, int nMillisecond = 0, int nMinsPerHour = 0)
{
    struct Time t;
    t.Year        = nYear;
    t.Month       = nMonth;
    t.Day         = nDay;
    t.Hour        = nHour;
    t.Minute      = nMinute;
    t.Second      = nSecond;
    t.Millisecond = nMillisecond;
    t.MinsPerHour = nMinsPerHour <= 0 ? HoursToMinutes() : clamp(nMinsPerHour, 1, 60);
    return NormalizeTime(t);
}

struct Time TimeToGameTime(struct Time t)
{
    return NormalizeTime(t, 60);
}

struct Time GameTimeToTime(struct Time t)
{
    return NormalizeTime(t, HoursToMinutes());
}

struct Time GetCurrentTime()
{
    struct Time t;
    t.Year        = GetCalendarYear();
    t.Month       = GetCalendarMonth();
    t.Day         = GetCalendarDay();
    t.Hour        = GetTimeHour();
    t.Minute      = GetTimeMinute();
    t.Second      = GetTimeSecond();
    t.Millisecond = GetTimeMillisecond();
    t.MinsPerHour = HoursToMinutes();
    return t;
}

struct Time GetCurrentGameTime()
{
    return TimeToGameTime(GetCurrentTime());
}

void SetCurrentTime(struct Time t)
{
    t = NormalizeTime(t, HoursToMinutes());
    struct Time tCurrent = GetCurrentTime();
    if (GetIsTimeAfter(t, tCurrent))
    {
        SetTime(t.Hour, t.Minute, t.Second, t.Millisecond);
        SetCalendar(t.Year, t.Month, t.Day);
    }
    else
    {
        CriticalError("Cannot set time to " + TimeToString(t, FALSE) + " " +
                      "because it is after " + TimeToString(tCurrent));
    }
}

void AdvanceCurrentTime(float fSeconds)
{
    if (fSeconds > 0.0)
    {
        struct Time t = IncreaseTime(GetCurrentTime(), fSeconds);
        SetTime(t.Hour, t.Minute, t.Second, t.Millisecond);
        SetCalendar(t.Year, t.Month, t.Day);
    }
    else if (fSeconds < 0.0)
    {
        CriticalError("Cannot advance time by a negative amount (" +
                      FloatToString(fSeconds, 0, 3) + " seconds)");
    }
}

struct Time GetPrecisionTime(struct Time t, int nUnit)
{
    while (nUnit < TIME_UNIT_MILLISECOND)
    {
        switch (++nUnit)
        {
            case TIME_UNIT_YEAR:        t.Year        = 0; break;
            case TIME_UNIT_MONTH:       t.Month       = 1; break;
            case TIME_UNIT_DAY:         t.Day         = 1; break;
            case TIME_UNIT_HOUR:        t.Hour        = 0; break;
            case TIME_UNIT_MINUTE:      t.Minute      = 0; break;
            case TIME_UNIT_SECOND:      t.Second      = 0; break;
            case TIME_UNIT_MILLISECOND: t.Millisecond = 0; break;
        }
    }

    return t;
}

// ----- Durations -------------------------------------------------------------

float GetDuration(struct Time a, struct Time b, int bNormalize = TRUE)
{
    // Durations always use real seconds, so we normalize time to the game clock
    if (bNormalize)
    {
        a = NormalizeTime(a, HoursToMinutes());
        b = NormalizeTime(b, HoursToMinutes());
    }

    float f;
    f += Years       (b.Year        - a.Year);
    f += Months      (b.Month       - a.Month);
    f += Days        (b.Day         - a.Day);
    f += Hours       (b.Hour        - a.Hour);
    f += Minutes     (b.Minute      - a.Minute);
    f += Seconds     (b.Second      - a.Second);
    f += Milliseconds(b.Millisecond - a.Millisecond);
    return f;
}

float GetDurationSince(struct Time tSince, int bNormalize = TRUE)
{
    if (bNormalize)
        tSince = NormalizeTime(tSince, HoursToMinutes());
    return GetDuration(tSince, GetCurrentTime(), FALSE);
}

float GetDurationUntil(struct Time tUntil, int bNormalize = TRUE)
{
    if (bNormalize)
        tUntil = NormalizeTime(tUntil, HoursToMinutes());
    return GetDuration(tUntil, GetCurrentTime(), FALSE);
}

int GetIsTimeAfter(struct Time a, struct Time b, int bNormalize = TRUE)
{
    return GetIsTimeValid(b) && GetDuration(a, b, bNormalize) < 0.0;
}

int GetIsTimeBefore(struct Time a, struct Time b, int bNormalize = TRUE)
{
    return GetIsTimeValid(a) && GetDuration(a, b, bNormalize) > 0.0;
}

int GetIsTimeEqual(struct Time a, struct Time b, int bNormalize = TRUE)
{
    if (bNormalize)
    {
        a = NormalizeTime(a, a.MinsPerHour);
        b = NormalizeTime(b, a.MinsPerHour);
    }
    return a == b;
}

struct Time IncreaseTime(struct Time t, float fAdd)
{
    // Durations are always in real seconds, so we need to ensure our time is
    // using the same conversion factor.
    int nMinsPerHour = HoursToMinutes();

    t.Millisecond += FloatToInt(frac(fAdd) * 1000) * t.MinsPerHour / nMinsPerHour;
    t.Second      += FloatToInt(fmod(fAdd, 60.0)) * t.MinsPerHour / nMinsPerHour;
    t.Minute      += FloatToInt(fAdd / 60.0) % HoursToMinutes() * t.MinsPerHour / nMinsPerHour;
    t.Hour        += FloatToInt(fAdd / HoursToSeconds(1));
    return NormalizeTime(t);
}

struct Time DecreaseTime(struct Time t, float fSub)
{
    return IncreaseTime(t, fSub * -1);
}

// ----- Json Conversion -------------------------------------------------------

json TimeToJson(struct Time t, int bNormalize = TRUE)
{
    if (bNormalize)
        t = NormalizeTime(t);

    json j = JsonObject();
    j = JsonObjectSet(j, "Year",        JsonInt(t.Year));
    j = JsonObjectSet(j, "Month",       JsonInt(t.Month));
    j = JsonObjectSet(j, "Day",         JsonInt(t.Day));
    j = JsonObjectSet(j, "Hour",        JsonInt(t.Hour));
    j = JsonObjectSet(j, "Minute",      JsonInt(t.Minute));
    j = JsonObjectSet(j, "Second",      JsonInt(t.Second));
    j = JsonObjectSet(j, "Millisecond", JsonInt(t.Millisecond));
    j = JsonObjectSet(j, "MinsPerHour", JsonInt(t.MinsPerHour));
    return j;
}

struct Time JsonToTime(json j, int bNormalize = TRUE)
{
    struct Time t;
    if (JsonGetType(j) != JSON_TYPE_OBJECT)
        return t;

    t.Year        = JsonGetInt(JsonObjectGet(j, "Year"));
    t.Month       = JsonGetInt(JsonObjectGet(j, "Month"));
    t.Day         = JsonGetInt(JsonObjectGet(j, "Day"));
    t.Hour        = JsonGetInt(JsonObjectGet(j, "Hour"));
    t.Minute      = JsonGetInt(JsonObjectGet(j, "Minute"));
    t.Second      = JsonGetInt(JsonObjectGet(j, "Second"));
    t.Millisecond = JsonGetInt(JsonObjectGet(j, "Millisecond"));
    t.MinsPerHour = JsonGetInt(JsonObjectGet(j, "MinsPerHour"));

    if (bNormalize)
        t = NormalizeTime(t);
    return t;
}

struct Time GetLocalTime(object oObject, string sVarName)
{
    return JsonToTime(GetLocalJson(oObject, TIME_PREFIX + sVarName));
}

void SetLocalTime(object oObject, string sVarName, struct Time tValue)
{
    SetLocalJson(oObject, TIME_PREFIX + sVarName, TimeToJson(tValue));
}

void DeleteLocalTime(object oObject, string sVarName)
{
    DeleteLocalJson(oObject, TIME_PREFIX + sVarName);
}

// ----- String Conversions ----------------------------------------------------

string TimeToString(struct Time t, int bNormalize = TRUE)
{
    if (bNormalize)
        t = NormalizeTime(t);

    json j = JsonArray();
    j = JsonArrayInsert(j, JsonInt(t.Year));
    j = JsonArrayInsert(j, JsonInt(t.Month));
    j = JsonArrayInsert(j, JsonInt(t.Day));
    j = JsonArrayInsert(j, JsonInt(t.Hour));
    j = JsonArrayInsert(j, JsonInt(t.Minute));
    j = JsonArrayInsert(j, JsonInt(t.Second));
    j = JsonArrayInsert(j, JsonInt(t.Millisecond));
    return FormatValues(j, "%04d-%02d-%02d %02d:%02d:%02d:%03d");
}

struct Time StringToTime(string sTime, int nMinsPerHour = 0)
{
    struct Time t, tInvalid;
    t.MinsPerHour = nMinsPerHour;

    string sDelims = "-- :::";
    int nUnit = TIME_UNIT_YEAR;
    int nPos, nLength = GetStringLength(sTime);

    while (nPos < nLength)
    {
        string sDelim, sToken, sChar;
        while (HasSubString(CHARSET_NUMERIC, (sChar = GetChar(sTime, nPos++))))
            sToken += sChar;

        if (GetStringLength(sToken) < 1)
            return tInvalid;

        int nToken = StringToInt(sToken);
        switch (nUnit)
        {
            case TIME_UNIT_YEAR:        t.Year        = nToken; break;
            case TIME_UNIT_MONTH:       t.Month       = nToken; break;
            case TIME_UNIT_DAY:         t.Day         = nToken; break;
            case TIME_UNIT_HOUR:        t.Hour        = nToken; break;
            case TIME_UNIT_MINUTE:      t.Minute      = nToken; break;
            case TIME_UNIT_SECOND:      t.Second      = nToken; break;
            case TIME_UNIT_MILLISECOND: t.Millisecond = nToken; break;
            default:
                return tInvalid;
        }

        // Check if we encountered a delimiter with no characters following.
        if (nPos == nLength && sChar != "")
            return tInvalid;

        // If we run out of characters before we've parsed all the units, we can
        // return the partial time. However, if we run into an unexpected
        // character, we should yield an invalid time.
        if (sChar != GetChar(sDelims, nUnit++))
        {
            if (sChar == "")
                return t;
            return tInvalid;
        }
    }

    return t;
}

string DurationToString(float fDur)
{
    return FormatFloat(fDur, "%.3f");
}
