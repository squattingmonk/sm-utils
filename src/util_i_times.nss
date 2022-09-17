/// ----------------------------------------------------------------------------
/// @file   util_i_times.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Functions for managing times, dates, and durations.
/// ----------------------------------------------------------------------------
/// @details
/// # Concepts
/// - Time: a struct value that may represent either a *calendar time* or a
///   *duration*. A Time has a field for years, months, day, hours, minutes,
///   seconds, and milliseconds. A Time also has a field to set the minutes per
///   hour (defaults to the module setting, which defaults to 2).
/// - Calendar Time: A Time representing a particular *moment in time* as
///   measured using the game calendar and clock. In a calendar Time, the month
///   and day count from 1, while all other units count from 0 (including
///   years, since NWN allows year 0). A calendar Time must always be positive.
/// - Duration Time: A Time representing an *amount of time*. All units in a
///   duration Time count from 0. A duration Time may be negative, representing
///   going back in time. This can be useful for calculations. A duration Time
///   can be converted to seconds to pass it to game functions that expect a
///   time, such as `DelayCommand()`, `PlayAnimation()`, etc.
/// - Game Time: a Time (either calendar Time or duration Time) with a minutes
///   per hour setting of 60. This allows you to convert the time shown by the
///   game clock into a time that matches how the characters in the game would
///   perceive it. For example, with the default minutes per hour setting of 2,
///   the Time "13:01" would correspond to a Game Time of "13:30".
/// - Normalizing Times: You can normalize a Time to ensure none of its units
///   are overflowing their bounds. For example, a Time with a Minute field of 0
///   and Second field of 90 would be normalized to a Minute of 1 and a Second
///   of 30. Normalizing a Time also causes all non-zero units to take the same
///   sign (either positive or negative), so a Time with a Minute of 1 and a
///   Second of -30 would normalize to a Second of 30. When normalizing a Time,
///   you can also change the minutes per hour setting. This is how the
///   functions in this file convert between Time and Game Time.
///
/// **Note**: For brevity, some functions have a `Time` variant and a
/// `Duration` variant. In these cases, the `Time` variant refers to a
/// calendar Time (e.g., `StringToTime()` converts to a calendar Time while
/// `StringToDuration()` refers to a duration Time). If no `Duration` variant
/// of the function is present, the function may refer to a calendar Time *or* a
/// duration Time (e.g., `TimeToString()` accepts both types).
/// ----------------------------------------------------------------------------
/// # Usage
///
/// ## Creating a Time
/// You can create a calendar Time using `GetTime()` and a duration Time with
/// `GetDuration()`:
/// ```nwscript
/// struct Time t = GetTime(1372, 6, 1, 13);
/// struct Time d = GetDuration(1372, 5, 0, 13);
/// ```
///
/// You could also parse an ISO 8601 time string into a calendar Time or
/// duration Time:
/// ```nwscript
/// struct Time tTime = StringToTime("1372-06-01 13:00:00:000");
/// struct Time tDur = StringToDuration("1372-05-00 13:00:00:000");
///
/// // Negative durations are allowed:
/// struct Time tNeg = StringToDuration("-1372-05-00 13:00:00:000");
///
/// // Missing units are assumed to be their lowest bound:
/// struct Time a = StringToTime("1372-06-01 00:00:00:000");
/// struct Time b = StringToTime("1372-06-01");
/// struct Time c = StringToTime("1372-06");
/// Assert(a == b);
/// Assert(b == c);
/// ```
///
/// You can also create a Time manually by declaring a new Time struct and
/// setting the fields independently:
/// ```nwscript
/// struct Time t;
/// t.Type  = TIME_TYPE_CALENDAR;
/// t.Year  = 1372;
/// t.Month = 6;
/// t.Day   = 1;
/// t.Hour  = 13;
/// // ...
/// ```
///
/// When not using the `GetTime()` function, it's a good idea to normalize the
/// resultant Time to distribute the field values correctly:
/// ```nwscript
/// struct Time t = NewTime();
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
/// Alternatively, you can advance the current Time by a duration Time:
/// ```nwscript
/// AdvanceCurrentTime(FloatToDuration(120.0));
/// ```
///
/// ## Dropping units from a Time
/// You can reduce the precision of a Time. Units smaller than the precision
/// limit will be at their lower bound:
/// ```nwscript
/// struct Time a = GetTime(1372, 6, 1, 13);
/// struct Time b = GetTime(1372, 6, 1);
/// struct Time c = GetPrecisionTime(a, TIME_UNIT_DAY);
/// struct Time d = GetPrecisionTime(a, TIME_UNIT_MONTH);
/// Assert(a != b);
/// Assert(b == c);
/// Assert(b == d);
/// ```
///
/// ## Saving a Time
/// The easiest way to save a Time and get it later is to use the
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
/// minutes per hour setting changes after the value is stored:
/// ```nwscript
/// struct Time tTime = GetCurrentTime();
/// json jTime = TimeToJson(tTime);
/// string sSql = "INSERT INTO data (varname, value) VALUES ('ServerTime', @time);";
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
/// string sSql = "INSERT INTO data (varname, value) VALUES ('ServerTime', @time);";
/// sqlquery q = SqlPrepareQueryCampaign("mydb", sSql);
/// SqlBindString(q, "@time", sTime);
/// SqlStep(q);
/// ```
///
/// ## Comparing Times
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
/// Assert(GetIsTimeEqual(b, c));
///
/// // To check for exactly equal:
/// Assert(b != c);
/// ```
///
/// To check the amount of time between two Times:
/// ```nwscript
/// struct Time a = StringToTime("1372-06-01 13:00:00:000");
/// struct Time b = StringToTime("1372-06-01 13:01:30:500");
/// struct Time tDur = GetDurationBetween(a, b);
/// Assert(DurationToFloat(tDur) == 90.5);
/// ```
///
/// To check if a duration has passed since a Time:
/// ```nwscript
/// int CheckForMinRestTime(object oPC, float fMinTime)
/// {
///     struct Time tSince = GetDurationSince(GetLocalTime(oPC, "LastRest"));
///     return DurationToFloat(tSince) >= fMinTime;
/// }
/// ```
///
/// To calculate the duration until a Time is reached:
/// ```nwscript
/// struct Time tMidnight = GetTime(GetCalendarYear(), GetCalendarMonth(), GetCalendarDay() + 1);
/// struct Time tDurToMidnight = GetDurationUntil(tMidnight);
/// float fDurToMidnight = DurationToFloat(tDurToMidnight);
/// ```
/// ----------------------------------------------------------------------------

#include "util_i_strings"
#include "util_i_debug"

// -----------------------------------------------------------------------------
//                                     Types
// -----------------------------------------------------------------------------

/// @struct Time
/// @brief A datatype representing either an amount of time or a moment in time.
/// @note Times with a Type field of TIME_TYPE_DURATION represent an amount of
///     time as represented on a stopwatch. All duration units count from 0.
/// @note Times with a Type field of TIME_TYPE_CALENDAR represent a moment in
///     time as represented on a calendar. This means the month and day count
///     from 1, but all other units count from 0 (including the year, since NWN
///     allows year 0).
struct Time
{
    int Type;        ///< TIME_TYPE_DURATION || TIME_TYPE_CALENDAR
    int Year;        ///< 0..32000
    int Month;       ///< 0..11 for duration Times, 1..12 for calendar Times
    int Day;         ///< 0..27 for duration Times, 1..28 for calendar Times
    int Hour;        ///< 0..23
    int Minute;      ///< 0..MinsPerHour
    int Second;      ///< 0..59
    int Millisecond; ///< 0..999
    int MinsPerHour; ///< The minutes per hour setting: 1..60
};

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

// These are the units in a valid Time.
const int TIME_UNIT_YEAR        = 0;
const int TIME_UNIT_MONTH       = 1;
const int TIME_UNIT_DAY         = 2;
const int TIME_UNIT_HOUR        = 3;
const int TIME_UNIT_MINUTE      = 4;
const int TIME_UNIT_SECOND      = 5;
const int TIME_UNIT_MILLISECOND = 6;

// These are the types of Times.
const int TIME_TYPE_DURATION = 0; ///< Represents an amount of time
const int TIME_TYPE_CALENDAR = 1; ///< Represents a moment in time

// Prefix for local variables to avoid collision
const string TIME_PREFIX = "*Time: ";

// These are field names for json objects
const string TIME_TYPE        = "Type";
const string TIME_YEAR        = "Year";
const string TIME_MONTH       = "Month";
const string TIME_DAY         = "Day";
const string TIME_HOUR        = "Hour";
const string TIME_MINUTE      = "Minute";
const string TIME_SECOND      = "Second";
const string TIME_MILLISECOND = "Millisecond";
const string TIME_MINSPERHOUR = "MinsPerHour";

/// Uninitialized Time value. Can be compared to Times returned from functions
/// to see if the Time is valid.
struct Time TIME_INVALID;

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Convert hours to minutes.
/// @param nHours The number of hours to convert.
/// @note The return value varies depending on the module's time settings.
int HoursToMinutes(int nHours = 1);

// ----- Times -----------------------------------------------------------------

/// @brief Return whether any unit in a Time is less than its lower bound.
/// @param t The Time to check.
int GetAnyTimeUnitNegative(struct Time t);

/// @brief Return whether any unit in a Time is greater than its lower bound.
/// @param t The Time to check.
int GetAnyTimeUnitPositive(struct Time t);

/// @brief Return the sign of a Time.
/// @param t The Time to check.
/// @returns 0 if all units equal the lower bound, -1 if any unit is less than
///     the lower bound, or 1 if any unit is greater than the lower bound.
/// @note The Time must be normalized to yield an acurate result.
int GetTimeSign(struct Time t);

/// @brief Create a new calendar Time.
/// @param nMinsPerHour The number of minutes per hour (1..60). If 0, will use
///     the module's default setting.
struct Time NewTime(int nMinsPerHour = 0);

/// @brief Create a new duration Time.
/// @param nMinsPerHour The number of minutes per hour (1..60). If 0, will use
///     the module's default setting.
struct Time NewDuration(int nMinsPerHour = 0);

/// @brief Convert a calendar Time into a duration Time.
/// @note This is safe to call on a duration Time.
struct Time TimeToDuration(struct Time t);

/// @brief Convert a duration Time into a calendar Time.
/// @note This is safe to call on a calendar Time.
struct Time DurationToTime(struct Time d);

/// @brief Distribute units in a Time, optionally converting minutes per hour.
/// @details Units that overflow their range have the excess added to the next
///     highest unit (e.g., 1500 msec -> 1 sec, 500 msec). If `nMinsPerHour`
///     does not match `t.MinsPerHour`, the minutes, seconds, and milliseconds
///     will be recalculated to match the new setting.
/// @param t The Time to normalize.
/// @param nMinsPerHour The number of minutes per hour to normalize with. If 0,
///     will use `t.MinsPerHour`.
/// @note If `t` is a duration Time, all non-zero units will be either positive
///     or negative (i.e., not a mix of both).
/// @note If `t` is a calendar Time and any unit in `t` falls outside the bounds
///     after normalization, an invalid Time is returned. You can check for this
///     using GetIsTimeValid().
struct Time NormalizeTime(struct Time t, int nMinsPerHour = 0);

/// @brief Check if any unit in a normalized time is outside its range.
/// @param t The Time to validate.
/// @param bNormalize Whether to normalize the time before checking. You should
///     only set this to FALSE if you know `t` is already normalized and want to
///     save cycles.
/// @returns TRUE if valid, FALSE otherwise.
int GetIsTimeValid(struct Time t, int bNormalize = TRUE);

/// @brief Create a duration Time, representing an amount of time.
/// @note All units count from 0. Negative numbers are allowed.
/// @param nYear The number of years (0..32000).
/// @param nMonth The number of month (0..11).
/// @param nDay The number of day (0..27).
/// @param nHour The number of hours (0..23).
/// @param nMinute The number of minutes (0..nMinsPerHour).
/// @param nSecond The number of seconds (0..59).
/// @param nMillisecond The number of milliseconds (0..999).
/// @param nMinsPerHour The number of minutes per hour (1..60). If 0, will use
///     the module's default setting.
/// @returns A normalized duration Time.
struct Time GetDuration(int nYears = 0, int nMonths = 0, int nDays = 0, int nHours = 0, int nMinutes = 0, int nSeconds = 0, int nMilliseconds = 0, int nMinsPerHour = 0);

/// @brief Create a calendar Time, representing a moment in time.
/// @param nYear The year (0..32000).
/// @param nMonth The month of the year (1..12).
/// @param nDay The day of the month (1..28).
/// @param nHour The hour (0..23).
/// @param nMinute The minute (0..nMinsPerHour).
/// @param nSecond The second (0..59).
/// @param nMillisecond The millisecond (0..999).
/// @param nMinsPerHour The number of minutes per hour (1..60). If 0, will use
///     the module's default setting.
/// @returns A normalized calendar Time.
struct Time GetTime(int nYear = 0, int nMonth = 1, int nDay = 1, int nHour = 0, int nMinute = 0, int nSecond = 0, int nMillisecond = 0, int nMinsPerHour = 0);

/// @brief Convert a Time to an in-game time (i.e., 60 minutes per hour).
/// @param t The Time to convert.
/// @note Alias for NormalizeTime(t, 60).
struct Time TimeToGameTime(struct Time t);

/// @brief Convert an in-game time (i.e., 60 minutes per hour) to a Time.
/// @param t The Time to convert.
/// @note Alias for NormalizeTime(t, HoursToMinutes()).
struct Time GameTimeToTime(struct Time t);

/// @brief Add a Time to another.
/// @param a The Time to modify.
/// @param b The Time to add.
/// @returns A Time of the same type and minutes per hour as `a`.
/// @note You can safely mix calendar or duration Times, as well as Times with
///     different minutes per hour settings.
struct Time AddTime(struct Time a, struct Time b);

/// @brief Subtract a Time from another.
/// @param a The Time to modify.
/// @param b The Time to subtract.
/// @returns A Time of the same type and minutes per hour as `a`.
/// @note You can safely mix calendar or duration Times, as well as Times with
///     different minutes per hour settings.
struct Time SubtractTime(struct Time a, struct Time b);

/// @brief Get the current calendar date and clock time as a calendar Time.
/// @note A calendar Time with a `MinsPerHour` matching to the module's setting.
struct Time GetCurrentTime();

/// @brief Get the current calendar date and in-game time as a calendar Time.
/// @returns A calendar Time with a `MinsPerHour` of 60.
/// @note Alias for TimeToGameTime(GetCurrentTime()).
struct Time GetCurrentGameTime();

/// @brief Set the current calendar date and clock time.
/// @param t The time to set the calendar and clock to. Must be a valid calendar
///     Time that is after the current time.
void SetCurrentTime(struct Time t);

/// @brief Set the current calendar date and clock time forwards.
/// @param d A duration Time by which to advance the time. Must be positive.
void AdvanceCurrentTime(struct Time d);

/// @brief Drop smaller units from a Time.
/// @param t The Time to modify.
/// @param nUnit A TIME_UNIT_* constant representing the maximum precision.
///     Units more precise than this are set to their lowest value.
struct Time GetPrecisionTime(struct Time t, int nUnit);

/// @brief Get the duration of the interval between two Times.
/// @param a The calendar Time at the start of interval.
/// @param b The calendar Time at the end of the interval.
/// @returns A normalized duration Time. The duration will be negative if a is
///     after b and positive if b is after a. If the times are equivalent, the
///     duration will equal 0.
struct Time GetDurationBetween(struct Time tStart, struct Time tEnd);

/// @brief Get the duration of the interval between a Time and the current time.
/// @param tSince The Time at the start of the interval.
/// @returns A normalized duration Time. The duration will be negative if a is
///     after b and positive if b is after a. If the times are equivalent, the
///     duration will equal 0.
struct Time GetDurationSince(struct Time tSince);

/// @brief Get the duration of the interval between the current time and a Time.
/// @param tUntil The Time at the end of the interval.
/// @returns A normalized duration Time. The duration will be negative if a is
///     after b and positive if b is after a. If the times are equivalent, the
///     duration will equal 0.
struct Time GetDurationUntil(struct Time tUntil);

/// @brief Compare two Times and find which is later.
/// @param a The Time to check.
/// @param b The Time to check against.
/// @returns 0 if a == b, -1 if a < b, and 1 if a > b.
int CompareTime(struct Time a, struct Time b);

/// @brief Check whether a Time is after another Time.
/// @param a The Time to check.
/// @param b The Time to check against.
/// @returns TRUE if a is after b, FALSE otherwise
int GetIsTimeAfter(struct Time a, struct Time b);

/// @brief Check whether a Time is before another Time.
/// @param a The Time to check.
/// @param b The Time to check against.
/// @returns TRUE if a is before b, FALSE otherwise
int GetIsTimeBefore(struct Time a, struct Time b);

/// @brief Check whether a Time is equal to another Time.
/// @param a The Time to check.
/// @param b The Time to check against.
/// @returns TRUE if a is equivalent to b, FALSE otherwise.
/// @note This checks if the normalized Times represent equal moments in time.
///     If you want to instead check if two Time structs are exactly equal, use
///     `a == b`.
int GetIsTimeEqual(struct Time a, struct Time b);

// ----- Float Conversion ------------------------------------------------------

/// @brief Convert years to seconds.
/// @param nYears The number of years to convert.
float Years(int nYears);

/// @brief Convert months to seconds.
/// @param nMonths The number of months to convert.
float Months(int nMonths);

/// @brief Convert days to seconds.
/// @param nDays The number of days to convert.
float Days(int nDays);

/// @brief Convert hours to seconds.
/// @param nHours The number of hours to convert.
float Hours(int nHours);

/// @brief Convert minutes to seconds.
/// @param nMinutes The number of minutes to convert.
float Minutes(int nMinutes);

/// @brief Convert seconds to seconds.
/// @param nSeconds The number of seconds to convert.
float Seconds(int nSeconds);

/// @brief Convert milliseconds to seconds.
/// @param nYears The number of milliseconds to convert.
float Milliseconds(int nMilliseconds);

/// @brief Convert a duration Time to a float.
/// @param d The duration Time to convert.
/// @returns A float representing the number of seconds in `t`. Always has a
///     minutes per hour setting equal to the module's.
/// @note Use this function to pass a Time to a function like DelayCommand().
/// @note Long durations may lose precision when converting. Use with caution.
float DurationToFloat(struct Time d);

/// @brief Convert a float to a duration Time.
/// @param fDur A float representing a number of seconds.
/// @returns A duration Time with a minutes per hour setting equal to the
///     module's.
struct Time FloatToDuration(float fDur);

// ----- Json Conversion -------------------------------------------------------

/// @brief Convert a Time into a json object.
/// @details The json object will have a key for each field of the Time struct.
///     Since this includes the minutes per hour setting, this object is safe to
///     be stored in a database if it is possible the module's minutes per hour
///     setting will change. The object can be converted back using
///     JsonToTime().
/// @param t The Time to convert
json TimeToJson(struct Time t);

/// @brief Convert a json object into a Time.
/// @param j The json object to convert.
struct Time JsonToTime(json j);

// ----- Local Variables -------------------------------------------------------

/// @brief Return a Time from a local variable.
/// @param oObject The object to get the local variable from.
/// @param sVarName The varname for the local variable.
struct Time GetLocalTime(object oObject, string sVarName);

/// @brief Store a Time as a local variable.
/// @param oObject The object to store the local variable on.
/// @param sVarName The varname for the local variable.
/// @param tValue The Time to store.
void SetLocalTime(object oObject, string sVarName, struct Time tValue);

/// @brief Delete a Time from a local variable.
/// @param oObject The object to delete the local variable from.
/// @param sVarName The varname for the local variable.
void DeleteLocalTime(object oObject, string sVarName);

// ----- String Conversions ----------------------------------------------------

/// @brief Convert a Time into a string.
/// @param t The Time to convert.
/// @param bNormalize Whether to normalize the Time before converting.
/// @returns An ISO 8601 formatted datetime, e.g., "1372-06-01 13:00:00:000".
/// @note If `t` is a duration Time and is negative, the returned value will be
///     preceded by a `-` character.
string TimeToString(struct Time t, int bNormalize = TRUE);

/// @brief Convert an ISO 8601 formatted datetime string into a calendar Time.
/// @param sTime The string to convert.
/// @param nMinsPerHour The number of minutes per hour expected in the Time. If
///     0, will use the module setting.
/// @note The returned Time is not normalized.
/// @note If the first character in `sTime` is a `-`, all values will be treated
///     as negative. This will make the returned Time invalid when normalized.
struct Time StringToTime(string sTime, int nMinsPerHour = 0);

/// @brief Convert an ISO 8601 formatted datetime string into a duration Time.
/// @param sTime The string to convert.
/// @param nMinsPerHour The number of minutes per hour expected in the Time. If
///     0, will use the module setting.
/// @note The returned Time is not normalized.
/// @note If the first character in `sTime` is a `-`, all values will be treated
///     as negative.
struct Time StringToDuration(string sTime, int nMinsPerHour = 0);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

int HoursToMinutes(int nHours = 1)
{
    return FloatToInt(HoursToSeconds(nHours)) / 60;
}

// ----- Times -----------------------------------------------------------------

int GetAnyTimeUnitNegative(struct Time t)
{
    return t.Year < 0 || t.Month < t.Type || t.Day < t.Type ||
           t.Hour < 0 || t.Minute < 0 || t.Second < 0 || t.Millisecond < 0;
}

int GetAnyTimeUnitPositive(struct Time t)
{
    return t.Year > 0 || t.Month > t.Type || t.Day > t.Type ||
           t.Hour > 0 || t. Minute > 0 || t.Second > 0 || t.Millisecond > 0;
}

int GetTimeSign(struct Time t)
{
    return GetAnyTimeUnitNegative(t) ? -1 : GetAnyTimeUnitPositive(t) ? 1 : 0;
}

struct Time NewTime(int nMinsPerHour = 0)
{
    struct Time t;
    t.Type = TIME_TYPE_CALENDAR;
    t.MinsPerHour = nMinsPerHour <= 0 ? HoursToMinutes() : clamp(nMinsPerHour, 1, 60);
    t.Month = 1;
    t.Day   = 1;
    return t;
}

struct Time NewDuration(int nMinsPerHour = 0)
{
    struct Time t;
    t.Type = TIME_TYPE_DURATION;
    t.MinsPerHour = nMinsPerHour <= 0 ? HoursToMinutes() : clamp(nMinsPerHour, 1, 60);
    return t;
}

struct Time TimeToDuration(struct Time t)
{
    t.Day   -= t.Type;
    t.Month -= t.Type;
    t.Type   = TIME_TYPE_DURATION;
    return t;
}

struct Time DurationToTime(struct Time d)
{
    d.Day   += (1 - d.Type);
    d.Month += (1 - d.Type);
    d.Type   = TIME_TYPE_CALENDAR;
    return d;
}

struct Time NormalizeTime(struct Time t, int nMinsPerHour = 0)
{
    // Convert everything to a duration for ease of calculation
    int nType = t.Type;
    t = TimeToDuration(t);

    // If the conversion factor was not set, we assume it's using the module's.
    if (t.MinsPerHour <= 0)
        t.MinsPerHour = HoursToMinutes();

    // If this is > 0, we will adjust the time's conversion factor to match the
    // requested value. Otherwise, assume we're using the same conversion factor
    // and just prettifying units.
    nMinsPerHour = nMinsPerHour > 0 ? clamp(nMinsPerHour, 1, 60) : t.MinsPerHour;

    if (t.MinsPerHour != nMinsPerHour)
    {
        // Convert everything to milliseconds so we don't lose precision when
        // converting to a smaller mins-per-hour.
        t.Millisecond += (t.Minute * 60 + t.Second) * 1000;
        t.Millisecond = t.Millisecond * nMinsPerHour / t.MinsPerHour;
        t.Second = 0;
        t.Minute = 0;
        t.MinsPerHour = nMinsPerHour;
    }

    // Distribute units.
    int nFactor;
    if (abs(t.Millisecond) >= (nFactor = 1000))
    {
        t.Second += t.Millisecond / nFactor;
        t.Millisecond %= nFactor;
    }

    if (abs(t.Second) >= (nFactor = 60))
    {
        t.Minute += t.Second / nFactor;
        t.Second %= nFactor;
    }

    if (abs(t.Minute) >= (nFactor = t.MinsPerHour))
    {
        t.Hour += t.Minute / nFactor;
        t.Minute %= nFactor;
    }

    if (abs(t.Hour) >= (nFactor = 24))
    {
        t.Day += t.Hour / nFactor;
        t.Hour %= nFactor;
    }

    if (abs(t.Day) >= (nFactor = 28))
    {
        t.Month += t.Day / nFactor;
        t.Day %= nFactor;
    }

    if (abs(t.Month) >= (nFactor = 12))
    {
        t.Year += t.Month / nFactor;
        t.Month %= nFactor;
    }

    // A mix of negative and positive units means we need to consolidate and
    // re-normalize.
    if (GetAnyTimeUnitPositive(t) && GetAnyTimeUnitNegative(t))
    {
        struct Time d = NewDuration(t.MinsPerHour);
        d.Millisecond = (t.Minute * 60 + t.Second) * 1000 + t.Millisecond;
        d.Hour = ((t.Year * 12 + t.Month) * 28 + t.Day) * 24 + t.Hour;

        // If that didn't fix it, borrow a unit
        if ((d.Millisecond >= 0) != (d.Hour >= 0))
        {
            d.Millisecond += sign(d.Hour) * 1000 * 60 * d.MinsPerHour;
            d.Hour -= sign(d.Hour);
        }

        t = NormalizeTime(d);
    }

    // Convert back to a calendar Time if needed.
    if (nType)
    {
        if (GetAnyTimeUnitNegative(t))
            return TIME_INVALID;

        return DurationToTime(t);
    }

    return t;
}

int GetIsTimeValid(struct Time t, int bNormalize = TRUE)
{
    if (bNormalize)
        t = NormalizeTime(t);
    return t != TIME_INVALID;
}

struct Time GetDuration(int nYears = 0, int nMonths = 0, int nDays = 0, int nHours = 0, int nMinutes = 0, int nSeconds = 0, int nMilliseconds = 0, int nMinsPerHour = 0)
{
    struct Time d = NewDuration(nMinsPerHour);
    d.Year        = nYears;
    d.Month       = nMonths;
    d.Day         = nDays;
    d.Hour        = nHours;
    d.Minute      = nMinutes;
    d.Second      = nSeconds;
    d.Millisecond = nMilliseconds;
    return NormalizeTime(d);
}

struct Time GetTime(int nYear = 0, int nMonth = 1, int nDay = 1, int nHour = 0, int nMinute = 0, int nSecond = 0, int nMillisecond = 0, int nMinsPerHour = 0)
{
    struct Time t = NewTime(nMinsPerHour);
    t.Year        = nYear;
    t.Month       = nMonth;
    t.Day         = nDay;
    t.Hour        = nHour;
    t.Minute      = nMinute;
    t.Second      = nSecond;
    t.Millisecond = nMillisecond;
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

struct Time AddTime(struct Time a, struct Time b)
{
    // Convert everything to a duration to ensure even comparison
    int nType = a.Type;
    a = NormalizeTime(TimeToDuration(a));
    b = NormalizeTime(TimeToDuration(b), a.MinsPerHour);

    a.Year        += b.Year;
    a.Month       += b.Month;
    a.Day         += b.Day;
    a.Hour        += b.Hour;
    a.Minute      += b.Minute;
    a.Second      += b.Second;
    a.Millisecond += b.Millisecond;

    // Convert back to calendar time if needed
    if (nType)
        a = DurationToTime(a);

    return NormalizeTime(a);
}

struct Time SubtractTime(struct Time a, struct Time b)
{
    // Convert everything to a duration to ensure even comparison
    int nType = a.Type;
    a = NormalizeTime(TimeToDuration(a));
    b = NormalizeTime(TimeToDuration(b), a.MinsPerHour);

    a.Year        -= b.Year;
    a.Month       -= b.Month;
    a.Day         -= b.Day;
    a.Hour        -= b.Hour;
    a.Minute      -= b.Minute;
    a.Second      -= b.Second;
    a.Millisecond -= b.Millisecond;

    // Convert back to calendar time if needed
    if (nType)
        a = DurationToTime(a);

    return NormalizeTime(a);
}

struct Time GetCurrentTime()
{
    struct Time t = NewTime();
    t.Year        = GetCalendarYear();
    t.Month       = GetCalendarMonth();
    t.Day         = GetCalendarDay();
    t.Hour        = GetTimeHour();
    t.Minute      = GetTimeMinute();
    t.Second      = GetTimeSecond();
    t.Millisecond = GetTimeMillisecond();
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
                      "because it is before " + TimeToString(tCurrent));
    }
}

void AdvanceCurrentTime(struct Time d)
{
    int nSign = GetTimeSign(d);
    if (nSign > 0)
    {
        d = AddTime(GetCurrentTime(), d);
        SetTime(d.Hour, d.Minute, d.Second, d.Millisecond);
        SetCalendar(d.Year, d.Month, d.Day);
    }
    else if (nSign < 0)
        CriticalError("Cannot advance time by a negative amount");
}

struct Time GetPrecisionTime(struct Time t, int nUnit)
{
    while (nUnit < TIME_UNIT_MILLISECOND)
    {
        switch (++nUnit)
        {
            case TIME_UNIT_YEAR:        t.Year        = 0;           break;
            case TIME_UNIT_MONTH:       t.Month       = 0  + t.Type; break;
            case TIME_UNIT_DAY:         t.Day         = 0  + t.Type; break;
            case TIME_UNIT_HOUR:        t.Hour        = 0;           break;
            case TIME_UNIT_MINUTE:      t.Minute      = 0;           break;
            case TIME_UNIT_SECOND:      t.Second      = 0;           break;
            case TIME_UNIT_MILLISECOND: t.Millisecond = 0;           break;
        }
    }

    return t;
}

struct Time GetDurationBetween(struct Time tStart, struct Time tEnd)
{
    // Convert to duration before passing to ensure we get a duration back
    return SubtractTime(TimeToDuration(tEnd), tStart);
}

struct Time GetDurationSince(struct Time tSince)
{
    return GetDurationBetween(tSince, GetCurrentTime());
}

struct Time GetDurationUntil(struct Time tUntil)
{
    return GetDurationBetween(tUntil, GetCurrentTime());
}

int CompareTime(struct Time a, struct Time b)
{
    return GetTimeSign(GetDurationBetween(b, a));
}

int GetIsTimeAfter(struct Time a, struct Time b)
{
    return CompareTime(a, b) > 0;
}

int GetIsTimeBefore(struct Time a, struct Time b)
{
    return CompareTime(a, b) < 0;
}

int GetIsTimeEqual(struct Time a, struct Time b)
{
    return !CompareTime(a, b);
}

// ----- Float Conversion ------------------------------------------------------

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

float DurationToFloat(struct Time d)
{
    d = NormalizeTime(TimeToDuration(d), HoursToMinutes());
    return Years(d.Year) + Months(d.Month) + Days(d.Day) + Hours(d.Hour) +
        Minutes(d.Minute) + Seconds(d.Second) + Milliseconds(d.Millisecond);
}

struct Time FloatToDuration(float fDur)
{
    struct Time t = NewDuration(HoursToMinutes());
    t.Millisecond = FloatToInt(frac(fDur) * 1000);
    t.Second      = FloatToInt(fmod(fDur, 60.0));
    t.Minute      = FloatToInt(fDur / 60) % t.MinsPerHour;
    int nHours    = FloatToInt(fDur / HoursToSeconds(1));
    t.Hour        = nHours % 24;
    t.Day         = (nHours / 24) % 28;
    t.Month       = (nHours / 24 / 28) % 12;
    t.Year        = (nHours / 24 / 28 / 12);
    return t;
}

// ----- Json Conversion -------------------------------------------------------

json TimeToJson(struct Time t)
{
    json j = JsonObject();
    j = JsonObjectSet(j, TIME_TYPE,        JsonInt(t.Type));
    j = JsonObjectSet(j, TIME_YEAR,        JsonInt(t.Year));
    j = JsonObjectSet(j, TIME_MONTH,       JsonInt(t.Month));
    j = JsonObjectSet(j, TIME_DAY,         JsonInt(t.Day));
    j = JsonObjectSet(j, TIME_HOUR,        JsonInt(t.Hour));
    j = JsonObjectSet(j, TIME_MINUTE,      JsonInt(t.Minute));
    j = JsonObjectSet(j, TIME_SECOND,      JsonInt(t.Second));
    j = JsonObjectSet(j, TIME_MILLISECOND, JsonInt(t.Millisecond));
    j = JsonObjectSet(j, TIME_MINSPERHOUR, JsonInt(t.MinsPerHour));
    return j;
}

struct Time JsonToTime(json j)
{
    if (JsonGetType(j) != JSON_TYPE_OBJECT)
        return TIME_INVALID;

    struct Time t;
    t.Type        = JsonGetInt(JsonObjectGet(j, TIME_TYPE));
    t.Year        = JsonGetInt(JsonObjectGet(j, TIME_YEAR));
    t.Month       = JsonGetInt(JsonObjectGet(j, TIME_MONTH));
    t.Day         = JsonGetInt(JsonObjectGet(j, TIME_DAY));
    t.Hour        = JsonGetInt(JsonObjectGet(j, TIME_HOUR));
    t.Minute      = JsonGetInt(JsonObjectGet(j, TIME_MINUTE));
    t.Second      = JsonGetInt(JsonObjectGet(j, TIME_SECOND));
    t.Millisecond = JsonGetInt(JsonObjectGet(j, TIME_MILLISECOND));
    t.MinsPerHour = JsonGetInt(JsonObjectGet(j, TIME_MINSPERHOUR));
    return t;
}

// ----- Local Variables -------------------------------------------------------

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
    j = JsonArrayInsert(j, JsonString(t.Type || GetTimeSign(t) >= 0 ? "" : "-"));
    j = JsonArrayInsert(j, JsonInt(abs(t.Year)));
    j = JsonArrayInsert(j, JsonInt(abs(t.Month)));
    j = JsonArrayInsert(j, JsonInt(abs(t.Day)));
    j = JsonArrayInsert(j, JsonInt(abs(t.Hour)));
    j = JsonArrayInsert(j, JsonInt(abs(t.Minute)));
    j = JsonArrayInsert(j, JsonInt(abs(t.Second)));
    j = JsonArrayInsert(j, JsonInt(abs(t.Millisecond)));
    return FormatValues(j, "%s%04d-%02d-%02d %02d:%02d:%02d:%03d");
}

struct Time _StringToTime(string sTime, struct Time t)
{
    if (sTime == "")
        return TIME_INVALID;

    string sDelims = "-- :::";
    int nUnit = TIME_UNIT_YEAR;
    int nPos, nLength = GetStringLength(sTime);
    int nSign = 1;

    // Strip off an initial "-"
    if (GetChar(sTime, 0) == "-")
    {
        nSign = -1;
        nPos++;
    }

    while (nPos < nLength)
    {
        string sDelim, sToken, sChar;
        while (HasSubString(CHARSET_NUMERIC, (sChar = GetChar(sTime, nPos++))))
            sToken += sChar;

        if (GetStringLength(sToken) < 1)
            return TIME_INVALID;

        // If the first character was a -, all subsequent values are negative
        int nToken = StringToInt(sToken) * nSign;
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
                return TIME_INVALID;
        }

        // Check if we encountered a delimiter with no characters following.
        if (nPos == nLength && sChar != "")
            return TIME_INVALID;

        // If we run out of characters before we've parsed all the units, we can
        // return the partial time. However, if we run into an unexpected
        // character, we should yield an invalid time.
        if (sChar != GetChar(sDelims, nUnit++))
        {
            if (sChar == "")
                return t;
            return TIME_INVALID;
        }
    }

    return t;
}

struct Time StringToTime(string sTime, int nMinsPerHour = 0)
{
    return _StringToTime(sTime, NewTime(nMinsPerHour));
}

struct Time StringToDuration(string sTime, int nMinsPerHour = 0)
{
    return _StringToTime(sTime, NewDuration(nMinsPerHour));
}
