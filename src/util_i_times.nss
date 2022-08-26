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
/// # Formatting
///
/// You can format a Time using the `FormatTime()` function. This function takes
/// a Time as the first parameter (`t`) and a *format specification string*
/// (`sFormat`) as the second parameter. The format specification string may
/// contain special character sequences called *conversion specifications*, each
/// of which is introduced by the `%` character and terminated by some other
/// character known as a *conversion specifier character*. All other character
/// sequences are *ordinary character sequences*.
///
/// The characters of ordinary character sequences are copied verbatim from
/// `sFormat` to the returned value. However, the characters of conversion
/// specifications are replaced as shown in the list below. Some sequences may
/// have their output customized using a *locale*, which can be passed using the
/// third parameter of `FormatTime()` (`sLocale`).
///
/// ## Conversion Specifiers
/// - `%a`: The abbreviated name of the weekday according to the current locale.
///         The specific names used in the current locale can be set using the
///         key `LOCALE_DAYS_ABBR`. If no abbreviated names are available in the
///         locale, will fall back to the full day name.
/// - `%A`: The full name of the weekday according to the current locale.
///         The specific names used in the current locale can be set using the
///         key `LOCALE_DAYS`.
/// - `%b`: The abbreviated name of the month according to the current locale.
///         The specific names used in the current locale can be set using the
///         key `LOCALE_MONTHS_ABBR`. If no abbreviated names are available in
///         the locale, will fall back to the full month name.
/// - `%B`: The full name of the month according to the current locale. The
///         specific names used in the current locale can be set using the key
///         `LOCALE_MONTHS`.
/// - `%c`: The preferred date and time representation for the current locale.
///         The specific format used in the current locale can be set using the
///         key `LOCALE_DATETIME_FORMAT` for the `%c` conversion specification
///         and `ERA_DATETIME_FORMAT` for the `%Ec` conversion specification.
///         With the default settings, this is equivalent to `%Y-%m-%d
///         %H:%M:%S:%f`. This is the default value of `sFormat` for
///         `FormatDateTime()`.
/// - `%C`: The century number (year / 100) as a 2-or-3-digit integer (00..320).
///         (The `%EC` conversion specification corresponds to the name of the
///         era, which can be set using the era key `ERA_NAME`.)
/// - `%d`: The day of the month as a 2-digit decimal number (01..28).
/// - `%D`: Equivalent to `%m/%d/%y`, the standard US time format. Note that
///         this may be ambiguous and confusing for non-Americans.
/// - `%e`: The day of the month as a decimal number, but a leading zero is
///         replaced by a space. Equivalent to `%_d`.
/// - `%E`: Modifier: use alternative "era-based" format (see below).
/// - `%f`: The millisecond as a 3-digit decimal number (000..999).
/// - `%F`: Equivalent to `%Y-%m-%d`, the ISO 8601 date format.
/// - `%H`: The hour (24-hour clock) as a 2-digit decimal number (00..23).
/// - `%I`: The hour (12-hour clock) as a 2-digit decimal number (01..12).
/// - `%j`: The day of the year as a 3-digit decimal number (000..336).
/// - `%k`: The hour (24-hour clock) as a decimal number (0..23). Single digits
///         are preceded by a space. Equivalent to `%_H`.
/// - `%l`: The hour (12-hour clock) as a decimal number (1..12). Single digits
///         are preceded by a space. Equivalent to `%_I`.
/// - `%m`: The month as a 2-digit decimal number (01..12).
/// - `%M`: The minute as a 2-digit decimal number (00..59, depending on
///         `t.MinsPerHour`).
/// - `%O`: Modifier: use ordinal numbers (1st, 2nd, etc.) (see below).
/// - `%p`: Either "AM" or "PM" according to the given Time, or the
///         corresponding values from the locale. The specific word used can be
///         set for the current locale using the key `LOCALE_AMPM`.
/// - `%P`: Like `%p`, but lowercase. Yes, it's silly that it's not the other
///         way around.
/// - `%r`: The preferred AM/PM time representation for the current locale. The
///         specific format used in the current locale can be set using the key
///         `LOCALE_AMPM_FORMAT`. With the default settings, this is equivalent
///         to `%I:%M:%S %p`.
/// - `%R`: The time in 24-hour notation. Equivalent to `%H:%M`. For a version
///         including seconds, see `%T`.
/// - `%S`: The second as a 2-digit decimal number (00..59).
/// - `%T`: The time in 24-hour notation. Equivalent to `%H:%M:%S`. For a
///         version without seconds, see `%R`.
/// - `%u`: The day of the  week as a 1-indexed decimal (1..7).
/// - `%w`: The day of the week as a 0-indexed decimal (0..6).
/// - `%x`: The preferred date representation for the current locale without the
///         time. The specific format used in the current locale can be set
///         using the key `LOCALE_TIME_FORMAT` for the `%x` conversion
///         specification and `ERA_TIME_FORMAT` for the `%Ex` conversion
///         specification. With the default settings, this is equivalent to
///         `%Y-%m-%d`. This is the default value of `sFormat` for
///         `FomatDate()`.
/// - `%X`: The preferred time representation for the current locale without the
///         date. The specific format used in the current locale can be set
///         using the key `LOCALE_DATE_FORMAT` for the `%X` conversion
///         specification and `ERA_DATE_FORMAT` for the `%EX` conversion
///         specification. With the default settings, this is equivalent to
///         `%H:%M:%S`. This is the default value of `sFormat` for
///         `FormatTime()`.
/// - `%y`: The year as a 2-digit decimal number without the century (00..99).
///         (The `%Ey` conversion specification corresponds to the year since
///         the beginning of the era denoted by the `%EC` conversion
///         specification.)
/// - `%Y`: The year as a decimal number including the century (0000..32000).
///         (The `%EY` conversion specification corresponds to era key
///         `ERA_FORMAT`; with the default era settings, this is equivalent to
///         `%Ey %EC`.)
/// - `%+`: A literal `+` if the duration is positive or `-` if it is negative.
///         Only valid using `FormatDuration()`.
/// - `%%`: A literal `%` character.
///
/// ## Modifier Characters
/// Some conversion specifications can be modified by preceding the conversion
/// specifier character by the `E` or `O` *modifier* to indicate that an
/// alternative format should be used. If the alternative format does not exist
/// for the locale, the behavior will be as if the unmodified conversion
/// specification were used.
///
/// The `E` modifier signifies using an alternative era-based representation.
/// The following are valid: `%Ec`, `%EC`, `%Ex`, `%EX`, `%Ey`, and `%EY`.
///
/// The `O` modifier signifies representing numbers in ordinal form (e.g., 1st,
/// 2nd, etc.). The ordinal suffixes for each number can be set using the locale
/// key `LOCALE_ORDINAL_SUFFIXES`. The following are valid: `%Od`, `%Oe`, `%OH`,
/// `%OI`, `%Om`, `%OM`, `%OS`, `%Ou`, `%Ow`, `%Oy`, and `%OY`.
///
/// ## Flag Characters
/// Between the `%` character and the conversion specifier character, an
/// optional *flag* and *field width* may be specified. (These should precede
/// the `E` or `O` characters, if present).
///
/// The following flag characters are permitted:
/// - `_`: (underscore) Pad a numeric result string with spaces.
/// - `-`: (dash) Do not pad a numeric result string.
/// - `0`: Pad a numeric result string with zeroes even if the conversion
///        specifier character uses space-padding by default.
/// - `^`: Convert alphabetic characters in the result string to uppercase.
///
/// An optional decimal width specifier may follow the (possibly absent) flag.
/// If the natural size of the field is smaller than this width, the result
/// string is padded (on the left) to the specified width. The string is never
/// truncated.
///
/// ## Examples
///
/// ```nwscript
/// struct Time t = StringToTime("1372-06-01 13:00:00:000");
///
/// // Default formatting
/// FormatDateTime(t); // "1372-06-01 13:00:00:000"
/// FormatDate(t); // "1372-06-01"
/// FormatTime(t); // "13:00:00:000"
///
/// // Using custom formats
/// FormatTime(t, "Today is %A, %B %Od."); // "Today is Monday, June 1st."
/// FormatTime(t, "%I:%M %p"); // "01:00 PM"
/// FormatTime(t, "%-I:%M %p"); // "1:00 PM"
/// ```
/// ----------------------------------------------------------------------------
/// # Advanced Usage
///
/// ## Locales
///
/// A locale is a json object that contains localization settings for formatting
/// functions. A default locale will be constructed using the configuration
/// values in `util_c_times.nss`, but you can also construct locales yourself.
/// An application for this might be having different areas in the module use
/// different month or day names, etc.
///
/// A locale is a simple json object:
/// ```nwscript
/// json jLocale = JsonObject();
/// ```
///
/// Alternatively, you can initialize a locale with the default values from
/// util_c_times:
/// ```nwscript
/// json jLocale = NewLocale();
/// ```
///
/// Keys are then added using `SetLocaleString()`:
/// ```nwscript
/// jLocale = SetLocaleString(jLocale, LOCALE_DAYS, "Moonday, Treeday, etc.");
/// ```
///
/// Keys can be retrieved using `GetLocaleString()`, which takes an optional
/// default value if the key is not set:
/// ```nwscript
/// string sDays     = GetLocaleString(jLocale, LOCALE_DAYS);
/// string sDaysAbbr = GetLocaleString(jLocale, LOCALE_DAYS_ABBR, sDays);
/// ```
///
/// Locales can be saved with a name. That names can then be passed to
/// formatting functions:
/// ```nwscript
/// json jLocale = JsonObject();
/// jLocale = SetLocaleString(jLocale, LOCALE_DAYS, "Moonday, Treeday, Heavensday, Valarday, Shipday, Starday, Sunday");
/// jLocale = SetLocaleString(jLocale, LOCALE_MONTHS, "Narvinye, Nenime, Sulime, Varesse, Lotesse, Narie, Cermie, Urime, Yavannie, Narquelie, Hisime, Ringare");
/// SetLocale(jLocale, "ME");
/// FormatTime(t, "Today is %A, %B %Od.");       // "Today is Monday, June 1st
/// FormatTime(t, "Today is %A, %B %Od.", "ME"); // "Today is Moonday, Narie 1st
/// ```
///
/// You can change the default locale so that you don't have to pass the name
/// every time:
/// ```nwscript
/// SetDefaultLocale("ME");
/// FormatTime(t, "Today is %A, %B %Od."); // "Today is Moonday, Narie 1st
/// ```
///
/// The following keys are currently supported:
/// - `LOCALE_DAYS`: a CSV list of 7 weekday names. Accessed by `%A`.
/// - `LOCALE_DAYS_ABBR`: a CSV list of 7 abbreviated weekday names. If not set,
///    the `FormatTime()` function will use `LOCALE_DAYS` instead. Accessed by
///    `%a`.
/// - `LOCALE_MONTHS`: a CSV list of 12 month names. Accessed by `%B`.
/// - `LOCALE_MONTHS_ABBR`: a CSV list of 12 abbreviated month names. If not
///   set, the `FormatTime()` function will use `LOCALE_MONTHS` instead.
///   Accessed by `%b`.
/// - `LOCALE_AMPM`: a CSV list of 2 AM/PM elements. Accessed by `%p` and `%P`.
/// - `LOCALE_ORDINAL_SUFFIXES`: a CSV list of suffixes for constructing ordinal
///   numbers. See util_c_times's documentation of `DEFAULT_ORDINAL_SUFFIXES`
///   for details.
/// - `LOCALE_DATETIME_FORMAT`: a date and time format string. Aliased by `%c`.
/// - `LOCALE_DATE_FORMAT`: a date format string. Aliased by `%x`.
/// - `LOCALE_TIME_FORMAT`: a time format string. Aliased by `%X`.
/// - `LOCALE_AMPM_FORMAT`: a time format string using AM/PM form. Aliased
///   by `%r`.
/// - `ERA_DATETIME_FORMAT`: a format string to display the date and time. If
///   not set, will fall back to `LOCALE_DATETIME_FORMAT`. Aliased by `%Ec`.
/// - `ERA_DATE_FORMAT`: a format string to display the date without the time.
///   If not set, will fall back to `LOCALE_DATE_FORMAT`. Aliased by `%Ex`.
/// - `ERA_TIME_FORMAT`: a format string to display the time without the date.
///   If not set, will fall back to `LOCALE_TIME_FORMAT`. Aliased by `%EX`.
/// - `ERA_YEAR_FORMAT`: a format string to display the year. If not set, will
///   display the year. Aliased by `%EY`.
/// - `ERA_NAME`: the name of an era. If not set and no era matches the current
///   year, will display the century. Aliased by `%EC`.
///
/// ## Eras
/// Locales can also hold an array of eras. Eras are json objects which name a
/// time range. When formatting using the `%E` modifier, the start Times of each
/// era in the array are compared to the Time to be formatted; the era with the
/// latest start that is still before the Time is selected. Format codes can
/// then refer to the era's name, year relative to the era start, and other
/// era-specific formats.
///
/// An era can be created using `DefineEra()`. This function takes a name and a
/// start Time. See the documentation for `DefineEra()` for further info:
/// ```nwscript
/// // Create an era that begins at the first possible calendar time
/// json jFirst = DefineEra("First Age", GetTime());
///
/// // Create an era that begins on a particular year
/// json jSecond = DefineEra("Second Age", GetTime(590));
/// ```
///
/// The `{Get/Set}LocaleString()` functions also apply to eras:
/// ```nwscript
/// jSecond = SetLocaleString(jSecond, ERA_DATETIME_FORMAT, "%B %Od, %EY");
/// jSecond = SetLocaleString(jSecond, ERA_YEAR_FORMAT, "%EY 2E");
/// ```
///
/// You can add an era to a locale using `AddEra()`:
/// ```nwscript
/// json jLocale = GetLocale("ME");
/// jLocale = SetLocaleString(jLocale, LOCALE_DAYS, "Moonday, Treeday, Heavensday, Valarday, Shipday, Starday, Sunday");
/// jLocale = SetLocaleString(jLocale, LOCALE_MONTHS, "Narvinye, Nenime, Sulime, Varesse, Lotesse, Narie, Cermie, Urime, Yavannie, Narquelie, Hisime, Ringare");
/// jLocale = AddEra(jLocale, jFirst);
/// jLocale = AddEra(jLocale, jSecond);
/// SetLocale(jLocale, "ME");
/// ```
///
/// You can then access the era settings using the `%E` modifier:
/// ```nwscript
/// FormatTime(t, "Today is %A, %B %Od, %EY.", "ME"); // "Today is Moonday, Narie 1st, 783 2E."
///
/// // You can combine the `%E` and `%O` modifiers
/// FormatTime(t, "It is the %EOy year of the %EC.", "ME"); // "It is the 783rd year of the Second Age."
/// ```
///
/// The following keys are available to eras:
/// - `ERA_NAME`: the name of the era. Aliased by `%EC`.
/// - `ERA_DATETIME_FORMAT`: a format string to display the date and time. If
///   not set, will fall back to the value on the locale. Aliased by `%Ec`.
/// - `ERA_DATE_FORMAT`: a format string to display the date without the time.
///   If not set, will fall back to the value on the locale. Aliased by `%Ex`.
/// - `ERA_TIME_FORMAT`: a format string to display the time without the date.
///   If not set, will fall back to the value on the locale. Aliased by `%EX`.
/// - `ERA_YEAR_FORMAT`: a format string to display the year. Defaults to
///   `%Ey %EC`. If not set, will fall back to the value on the locale. Aliased
///   by `%EY`.
/// ----------------------------------------------------------------------------

#include "util_i_math"
#include "util_i_strings"
#include "util_i_csvlists"
#include "util_i_debug"

#include "util_c_times"

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

// These are the characters used as flags in time format codes.
const string TIME_FLAG_CHARS = "EO^-_0123456789";

const int TIME_FLAG_ERA       = 0x01; ///< `E`: use era-based formatting
const int TIME_FLAG_ORDINAL   = 0x02; ///< `O`: use ordinal numbers
const int TIME_FLAG_UPPERCASE = 0x04; ///< `^`: use uppercase letters
const int TIME_FLAG_NO_PAD    = 0x08; ///< `-`: do not pad numbers
const int TIME_FLAG_SPACE_PAD = 0x10; ///< `_`: pad numbers with spaces
const int TIME_FLAG_ZERO_PAD  = 0x20; ///< `0`: pad numbers with zeros

// These are the characters allowed in time format codes.
const string TIME_FORMAT_CHARS = "aAbBpPIljwu+CyYmdeHkMSfDFRTcxXr%";

// Begin time-only constants. It is an error to use these with a duration.
const int TIME_FORMAT_NAME_OF_DAY_ABBR   =  0; ///< `%a`: Mon..Sun
const int TIME_FORMAT_NAME_OF_DAY_LONG   =  1; ///< `%A`: Monday..Sunday
const int TIME_FORMAT_NAME_OF_MONTH_ABBR =  2; ///< `%b`: Jan..Dec
const int TIME_FORMAT_NAME_OF_MONTH_LONG =  3; ///< `%B`: January..December
const int TIME_FORMAT_AMPM_UPPER         =  4; ///< `%p`: AM..PM
const int TIME_FORMAT_AMPM_LOWER         =  5; ///< `%P`: am..pm
const int TIME_FORMAT_HOUR_12            =  6; ///< `%I`: 01..12
const int TIME_FORMAT_HOUR_12_SPACE_PAD  =  7; ///< `%l`: alias for %_I
const int TIME_FORMAT_DAY_OF_YEAR        =  8; ///< `%j`: 001..336
const int TIME_FORMAT_DAY_OF_WEEK_0_6    =  9; ///< `%w`: weekdays 0..6
const int TIME_FORMAT_DAY_OF_WEEK_1_7    = 10; ///< `%u`: weekdays 1..7
const int TIME_FORMAT_SIGN               = 11; ///< `%+`: "+" if duration positive, "-" if negative
const int TIME_FORMAT_YEAR_CENTURY       = 12; ///< `%C`: 0..320
const int TIME_FORMAT_YEAR_SHORT         = 13; ///< `%y`: 00..99
const int TIME_FORMAT_YEAR_LONG          = 14; ///< `%Y`: 0..320000
const int TIME_FORMAT_MONTH              = 15; ///< `%m`: 01..12
const int TIME_FORMAT_DAY                = 16; ///< `%d`: 01..28
const int TIME_FORMAT_DAY_SPACE_PAD      = 17; ///< `%e`: alias for %_d
const int TIME_FORMAT_HOUR_24            = 18; ///< `%H`: 00..23
const int TIME_FORMAT_HOUR_24_SPACE_PAD  = 19; ///< `%k`: alias for %_H
const int TIME_FORMAT_MINUTE             = 20; ///< `%M`: 00..59 (depending on conversion factor)
const int TIME_FORMAT_SECOND             = 21; ///< `%S`: 00..59
const int TIME_FORMAT_MILLISECOND        = 22; ///< `%f`: 000...999
const int TIME_FORMAT_DATE_US            = 23; ///< `%D`: 06/01/72
const int TIME_FORMAT_DATE_ISO           = 24; ///< `%F`: 1372-06-01
const int TIME_FORMAT_TIME_US            = 25; ///< `%R`: 13:00
const int TIME_FORMAT_TIME_ISO           = 26; ///< `%T`: 13:00:00
const int TIME_FORMAT_LOCALE_DATETIME    = 27; ///< `%c`: locale-specific date and time
const int TIME_FORMAT_LOCALE_DATE        = 28; ///< `%x`: locale-specific date
const int TIME_FORMAT_LOCALE_TIME        = 29; ///< `%X`: locale-specific time
const int TIME_FORMAT_LOCALE_TIME_AMPM   = 30; ///< `%r`: locale-specific AM/PM time
const int TIME_FORMAT_PERCENT            = 31; ///< `%%`: %

// Time format codes with an index less than this number are not valid for
// durations.
const int DURATION_FORMAT_OFFSET = TIME_FORMAT_SIGN;

// ----- VarNames --------------------------------------------------------------

// Prefix for local times to avoid collision
const string TIME_PREFIX = "*Time: ";

// Prefix for locale names stored on the module to avoid collision
const string LOCALE_PREFIX = "*Locale: ";

// Stores the default locale on the module
const string LOCALE_DEFAULT = "*DefaultLocale";

// Each of these keys stores a CSV list which is evaluated by a format code
const string LOCALE_DAYS        = "Days";       // day names (%A)
const string LOCALE_DAYS_ABBR   = "DaysAbbr";   // abbreviated day names (%a)
const string LOCALE_MONTHS      = "Months";     // month names (%B)
const string LOCALE_MONTHS_ABBR = "MonthsAbbr"; // abbreviated month names (%b)
const string LOCALE_AMPM        = "AMPM";       // AM/PM elements (%p and %P)

// This key stores a CSV list of suffixes used to convert integers to ordinals
// (e.g., 0th, 1st, etc.).
const string LOCALE_ORDINAL_SUFFIXES = "OrdinalSuffixes"; // %On

// Each of these keys stores a locale-specific format string which is aliased by
// a format code.
const string LOCALE_DATETIME_FORMAT  = "DateTimeFormat"; // %c
const string LOCALE_DATE_FORMAT      = "DateFormat";     // %x
const string LOCALE_TIME_FORMAT      = "TimeFormat";     // %X
const string LOCALE_AMPM_FORMAT      = "AMPMFormat";     // %r

// Each of these keys stores a locale-specific era-based format string which is
// aliased by a format code using the `E` modifier. If no string is stored at
// this key, it will resolve to the non-era based format above.
const string ERA_DATETIME_FORMAT = "EraDateTimeFormat"; // %Ec
const string ERA_DATE_FORMAT     = "EraDateFormat";     // %Ex
const string ERA_TIME_FORMAT     = "EraTimeFormat";     // %EX

// Key for Eras json array. Each element of the array is a json object having
// the three keys below.
const string LOCALE_ERAS = "Eras";

// Key for era name. Aliased by %EC.
const string ERA_NAME = "Name";

// Key for a format string for the year in the era. Aliased by %EY.
const string ERA_YEAR_FORMAT = "YearFormat";

// Key for the start of the era. Stored as a date in the form yyyy-mm-dd.
const string ERA_START = "Start";

// Key for the number of the year closest to the start date in an era. Used by
// %Ey to display the correct year. For example, if an era starts on 1372-01-01
// and the current date is 1372-06-01, an offset of 0 would make %Ey display 0,
// while an offset of 1 would make it display 1.
const string ERA_OFFSET = "Offset";

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

// ----- Locales ---------------------------------------------------------------

/// @brief Get the string at a given key in a locale object.
/// @param jLocale A json object containing the locale settings
/// @param sKey The key to return the value of (see the LOCALE_* constants)
/// @param sDefault A default value to return if sKey does not exist in jLocale.
string GetLocaleString(json jLocale, string sKey, string sSuffix = "");

/// @brief Set the string at a given key in a locale object.
/// @param jLocale A json object containing the locale settings
/// @param sKey The key to set the value of (see the LOCALE_* constants)
/// @param sValue The value to set the key to
/// @returns The updated locale object
json SetLocaleString(json j, string sKey, string sValue);

/// @brief Create a new locale object initialized with values from util_c_times.
/// @note If you do not want the default values, use JsonObject() instead.
json NewLocale();

/// @brief Get the name of the default locale for the module.
/// @returns The name of the default locale, or the value of DEFAULT_LOCALE from
///     util_c_times.nss if a locale is not set.
string GetDefaultLocale();

/// @brief Set the name of the default locale for the module.
/// @param sName The name of the locale (default: DEFAULT_LOCALE)
void SetDefaultLocale(string sName = DEFAULT_LOCALE);

/// @brief Get a locale object by name.
/// @param sLocale The name of the locale. Will return the default locale if "".
/// @param bInit If TRUE, will return an era with the default values from
///     util_c_times.nss if sLocale does not exist.
/// @returns A json object containing the locale settings, or JsonNull() if no
///     locale named sLocale exists.
json GetLocale(string sLocale = "", int bInit = TRUE);

/// @brief Save a locale object to a name.
/// @param jLocale A json object containing the locale settings.
/// @param sLocale The name of the locale. Will use the default local if "".
void SetLocale(json jLocale, string sLocale = "");

/// @brief Delete a locale by name.
/// @param sLocale The name of the locale. Will use the default local if "".
void DeleteLocale(string sLocale = "");

/// @brief Check if a locale exists.
/// @param sLocale The name of the locale. Will use the default local if "".
/// @returns TRUE if sLocale points to a valid json object, other FALSE.
int HasLocale(string sLocale = "");

/// @brief Get the name of a month given a locale.
/// @param nMonth The month of the year (1-indexed).
/// @param sMonths A CSV list of 12 month names to search through. If "", will
///     use the month list from a locale.
/// @param sLocale The name of a locale to check for month names if sMonths is
///     "". If sLocale is "", will use the default locale.
/// @returns The name of the month.
string MonthToString(int nMonth, string sMonths = "", string sLocale = "");

/// @brief Get the name of a day given a locale.
/// @param nDay The day of the week (1-indexed).
/// @param sDays A CSV list of 7 day names to search through. If "", will use
///     the day list from a locale.
/// @param sLocale The name of a locale to check for day names if sDays is "".
///     If sLocale is "", will use the default locale.
/// @returns The name of the day.
string DayToString(int nDay, string sDays = "", string sLocale = "");

// ----- Eras ------------------------------------------------------------------

/// @brief Create an era json object.
/// @param sName The name of the era.
/// @param tStart The Time marking the beginning of the era.
/// @param nOffset The number that represents the first year in an era. Used by
///     %Ey to display the correct year. For example, if an era starts on
///     1372-01-01 and the current date is 1372-06-01, an offset of 0 would make
///     %Ey display 0 while an offset of 1 would make %Ey display 1. The default
///     is 0 since NWN allows year 0.
/// @param sFormat The default format for an era-based year. The format code %EY
///     evaluates to this string for this era. With the default value, the 42nd
///     year of an era named "Foo" would be "4 Foo".
json DefineEra(string sName, struct Time tStart, int nOffset = 0, string sFormat = "%Ey %EC");

/// @brief Add an era to a locale.
/// @param jLocale A locale json object.
/// @param jEra An era json object.
/// @returns A modified copy of jLocale with jEra added to its era array.
json AddEra(json jLocale, json jEra);

/// @brief Get the era in which a time occurs.
/// @param jLocale A locale json object containing an array of eras.
/// @param t A Time to check the era for.
/// @returns A json object for the era in jLocale with the latest start time
///     earlier than t or JsonNull() if no such era is present.
json GetEra(json jLocale, struct Time t);

/// @brief Get the year of an era given an NWN calendar year.
/// @param jEra A json object matching an era.
/// @param nYear An NWN calendar year (0..32000)
/// @returns The number of the year in the era, or nYear if jEra is not valid.
int GetEraYear(json jEra, int nYear);

/// @brief Gets a string from an era, falling back to a locale if not set.
/// @param jEra The era to check
/// @param jLocale The locale to fall back to
/// @param sKey The key to get the string from
/// @note If sKey begins with "Era" and was not found on the era or the locale,
///     will check jLocale for sKey without the "Era" prefix.
string GetEraString(json jEra, json jLocale, string sKey);

// ----- Formatting ------------------------------------------------------------

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

/// @brief Convert an integer into an ordinal number (e.g., 1 -> 1st, 2 -> 2nd).
/// @param n The number to convert.
/// @param sSuffixes A CSV list of suffixes for each integer, starting at 0. If
///     the n <= the length of the list, only the last digit will be checked. If
///     "", will use the suffixes provided by the locale instead.
/// @param sLocale The name of the locale to use when formatting the number. If
///     "", will use the default locale.
string IntToOrdinalString(int n, string sSuffixes = "", string sLocale = "");

/// @brief Format a Time into a string.
/// @param t The Time to format.
/// @param sFormat A string containing format codes to control the output. The
///     default value is equivalent to "%H:%M:%S".
/// @param sLocale The name of the locale to use when formatting the time. If
///     "", will use the default locale.
/// @note This function differs only from FormatDateTime() in the default value
///     of sFormat. Character codes that apply to dates are still valid.
/// @note See the documentation at the top of this file for the list of possible
///     format codes.
string FormatTime(struct Time t, string sFormat = "%X", string sLocale = "");

/// @brief Format a Time into a string.
/// @param t The Time to format.
/// @param sFormat A string containing format codes to control the output. The
///     default value is equivalent to "%Y-%m-%d".
/// @param sLocale The name of the locale to use when formatting the date. If
///     "", will use the default locale.
/// @note This function differs only from FormatDateTime() in the default value
///     of sFormat. Character codes that apply to times are still valid.
/// @note See the documentation at the top of this file for the list of possible
///     format codes.
string FormatDate(struct Time t, string sFormat = "%x", string sLocale = "");

/// @brief Format a Time into a string.
/// @param t The Time to format.
/// @param sFormat A string containing format codes to control the output. The
///     default value is equivalent to "%Y-%m-%d %H:%M:%S:%f".
/// @param sLocale The name of the locale to use when formatting the Time. If
///     "", will use the default locale.
/// @note See the documentation at the top of this file for the list of possible
///     format codes.
string FormatDateTime(struct Time t, string sFormat = "%c", string sLocale = "");

/// @brief Format a duration into a string.
/// @param fDur A duration in seconds. May be negative.
/// @param sFormat A string containing format codes to control the output. The
///     default value is equivalent to ISO 8601 format preceded by the sign of
///     fDur (+ or -).
/// @param sLocale The name of the locale to use when formatting the duration.
///     If "", will use the default locale.
/// @note See the documentation at the top of this file for the list of possible
///     format codes.
string FormatDuration(float fDur, string sFormat = "%+%Y-%m-%d %H:%M:%S:%f", string sLocale = "");

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
    else
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

// ----- Locales ---------------------------------------------------------------

string GetLocaleString(json jLocale, string sKey, string sDefault = "")
{
    json jElem = JsonObjectGet(jLocale, sKey);
    if (JsonGetType(jElem) == JSON_TYPE_STRING && JsonGetString(jElem) != "")
        return JsonGetString(jElem);
    return sDefault;
}

json SetLocaleString(json j, string sKey, string sValue)
{
    return JsonObjectSet(j, sKey, JsonString(sValue));
}

json NewLocale()
{
    json j = JsonObject();
    j = SetLocaleString(j, LOCALE_ORDINAL_SUFFIXES, DEFAULT_ORDINAL_SUFFIXES);
    j = SetLocaleString(j, LOCALE_DAYS,             DEFAULT_DAYS);
    j = SetLocaleString(j, LOCALE_DAYS_ABBR,        DEFAULT_DAYS_ABBR);
    j = SetLocaleString(j, LOCALE_MONTHS,           DEFAULT_MONTHS);
    j = SetLocaleString(j, LOCALE_MONTHS_ABBR,      DEFAULT_MONTHS_ABBR);
    j = SetLocaleString(j, LOCALE_AMPM,             DEFAULT_AMPM);
    j = SetLocaleString(j, LOCALE_DATETIME_FORMAT,  DEFAULT_DATETIME_FORMAT);
    j = SetLocaleString(j, LOCALE_DATE_FORMAT,      DEFAULT_DATE_FORMAT);
    j = SetLocaleString(j, LOCALE_TIME_FORMAT,      DEFAULT_TIME_FORMAT);
    j = SetLocaleString(j, LOCALE_AMPM_FORMAT,      DEFAULT_AMPM_FORMAT);

    if (DEFAULT_ERA_DATETIME_FORMAT != "")
        j = SetLocaleString(j, ERA_DATETIME_FORMAT, DEFAULT_ERA_DATETIME_FORMAT);

    if (DEFAULT_ERA_DATE_FORMAT != "")
        j = SetLocaleString(j, ERA_DATE_FORMAT, DEFAULT_ERA_DATE_FORMAT);

    if (DEFAULT_ERA_TIME_FORMAT != "")
        j = SetLocaleString(j, ERA_TIME_FORMAT, DEFAULT_ERA_TIME_FORMAT);

    if (DEFAULT_ERA_NAME != "")
        j = SetLocaleString(j, ERA_NAME, DEFAULT_ERA_NAME);

    j = JsonObjectSet(j, LOCALE_ERAS, JsonArray());

    return j;
}

string GetDefaultLocale()
{
    string sLocale = GetLocalString(GetModule(), LOCALE_DEFAULT);
    return sLocale == "" ? DEFAULT_LOCALE : sLocale;
}

void SetDefaultLocale(string sName = DEFAULT_LOCALE)
{
    SetLocalString(GetModule(), LOCALE_DEFAULT, sName);
}

json GetLocale(string sLocale = "", int bInit = TRUE)
{
    if (sLocale == "")
        sLocale = GetDefaultLocale();
    json j = GetLocalJson(GetModule(), LOCALE_PREFIX + sLocale);
    if (bInit && JsonGetType(j) != JSON_TYPE_OBJECT)
        j = NewLocale();
    return j;
}

void SetLocale(json jLocale, string sLocale = "")
{
    if (sLocale == "")
        sLocale = GetDefaultLocale();
    SetLocalJson(GetModule(), LOCALE_PREFIX + sLocale, jLocale);
}

void DeleteLocale(string sLocale = "")
{
    if (sLocale == "")
        sLocale = GetDefaultLocale();
    DeleteLocalJson(GetModule(), LOCALE_PREFIX + sLocale);
}

int HasLocale(string sLocale = "")
{
    return JsonGetType(GetLocale(sLocale, FALSE)) == JSON_TYPE_OBJECT;
}

string MonthToString(int nMonth, string sMonths = "", string sLocale = "")
{
    if (sMonths == "")
        sMonths = GetLocaleString(GetLocale(sLocale), LOCALE_MONTHS);

    return GetListItem(sMonths, (nMonth - 1) % 12);
}

string DayToString(int nDay, string sDays = "", string sLocale = "")
{
    if (sDays == "")
        sDays = GetLocaleString(GetLocale(sLocale), LOCALE_DAYS);

    return GetListItem(sDays, (nDay - 1) % 7);
}

// ----- Eras ------------------------------------------------------------------

json DefineEra(string sName, struct Time tStart, int nOffset = 0, string sFormat = DEFAULT_ERA_YEAR_FORMAT)
{
    json jEra = JsonObject();
    jEra = JsonObjectSet(jEra, ERA_NAME,        JsonString(sName));
    jEra = JsonObjectSet(jEra, ERA_YEAR_FORMAT, JsonString(sFormat));
    jEra = JsonObjectSet(jEra, ERA_START,       TimeToJson(tStart));
    jEra = JsonObjectSet(jEra, ERA_OFFSET,      JsonInt(nOffset));
    return jEra;
}

json AddEra(json jLocale, json jEra)
{
    json jEras = JsonObjectGet(jLocale, LOCALE_ERAS);
    if (JsonGetType(jEras) != JSON_TYPE_ARRAY)
        jEras = JsonArray();

    jEras = JsonArrayInsert(jEras, jEra);
    jLocale = JsonObjectSet(jLocale, LOCALE_ERAS, jEras);
    return jLocale;
}

json GetEra(json jLocale, struct Time t)
{
    json  jEras = JsonObjectGet(jLocale, LOCALE_ERAS);
    json  jEra; // The closest era to the time
    float fEra; // The interval between the start of the closest era t
    int i, nLength = JsonGetLength(jEras);

    for (i = 0; i < nLength; i++)
    {
        json jCmp = JsonArrayGet(jEras, i);
        struct Time tCmp = JsonToTime(JsonObjectGet(jCmp, ERA_START));

        float fCmp = GetDuration(tCmp, t);
        if (fCmp == 0.0)
            return jCmp;
        if (fCmp > 0.0 && (fEra <= 0.0 || fCmp < fEra))
        {
            fEra = fCmp;
            jEra = jCmp;
        }
    }

    return jEra;
}

int GetEraYear(json jEra, int nYear)
{
    int nOffset = JsonGetInt(JsonObjectGet(jEra, ERA_OFFSET));
    struct Time tStart = JsonToTime(JsonObjectGet(jEra, ERA_START));
    return nYear - tStart.Year + nOffset;
}

string GetEraString(json jEra, json jLocale, string sKey)
{
    json jValue = JsonObjectGet(jEra, sKey);
    if (JsonGetType(jValue) != JSON_TYPE_STRING)
    {
        jValue = JsonObjectGet(jLocale, sKey);
        if (JsonGetType(jValue) != JSON_TYPE_STRING &&
           (GetStringSlice(sKey, 0, 2) == "Era"))
            jValue = JsonObjectGet(jLocale, GetStringSlice(sKey, 3));
    }

    return JsonGetString(jValue);
}

// ----- Formatting ------------------------------------------------------------

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

string IntToOrdinalString(int n, string sSuffixes = "", string sLocale = "")
{
    if (sSuffixes == "")
    {
        json jLocale = GetLocale(sLocale);
        sSuffixes = GetLocaleString(jLocale, LOCALE_ORDINAL_SUFFIXES, DEFAULT_ORDINAL_SUFFIXES);
    }

    int nIndex = abs(n) % 100;
    if (nIndex >= CountList(sSuffixes))
        nIndex = abs(n) % 10;

    return IntToString(n) + GetListItem(sSuffixes, nIndex);
}

// Private function for FormatTime() and FormatDuration(). To reduce code
// duplication, we convert everything to a Time when formatting. If we are
// actually trying to format a duration, we disable some format codes that only
// make sense in the context of a time.
string _FormatTime(struct Time t, string sFormat, string sLocale, int nDur = 0, int bDur = FALSE)
{
    int  nOffset, nPos;
    json jValues = JsonArray();
    json jLocale = GetLocale(sLocale);
    json jEra    = GetEra(jLocale, t);
    string sOrdinals = GetLocaleString(jLocale, LOCALE_ORDINAL_SUFFIXES, DEFAULT_ORDINAL_SUFFIXES);
    int nDigitsIndex = log2(TIME_FLAG_ZERO_PAD);

    while ((nPos = FindSubString(sFormat, "%", nOffset)) != -1)
    {
        nOffset = nPos;

        // Check for flags
        int nFlag, nFlags;
        string sPadding, sWidth, sChar;

        while ((nFlag = FindSubString(TIME_FLAG_CHARS, (sChar = GetChar(sFormat, ++nPos)))) != -1)
        {
            // If this character is not a digit after 0, we create a flag for it
            // and add it to our list of flags.
            if (nFlag < nDigitsIndex)
                nFlags |= (1 << nFlag);
            else
            {
                // The user has specified a width for the item. Parse all the
                // numbers.
                sWidth = ""; // in case the user added a width twice and separated with another flag.
                while (GetIsNumeric(sChar))
                {
                    sWidth += sChar;
                    sChar = GetChar(sFormat, ++nPos);
                }

                nPos--;
            }
        }

        string sValue;
        int nValue;
        int bAllowEmpty;
        int nPadding = 2; // Most numeric formats use this

        // We offset where we start looking for format codes based on whether
        // this is a Time or Duration. Durations cannot use time codes that only
        // make sense in the context of a Time.
        int nFormat = FindSubString(TIME_FORMAT_CHARS, sChar, bDur ? DURATION_FORMAT_OFFSET : 0);
        switch (nFormat)
        {
            case -1:
            {
                string sError = GetStringSlice(sFormat, nOffset, nPos + 1);
                string sColored = GetStringSlice(sFormat, 0, nOffset) +
                                  HexColorString(sError, COLOR_RED) +
                                  GetStringSlice(sFormat, nPos + 1);
                Error("Illegal time format \"" + sError + "\": " + sColored);
                sFormat = ReplaceSubString(sFormat, "%" + sError, nOffset, nPos + 1);
                continue;
            }

            // Note that some of these are meant to fall through
            case TIME_FORMAT_DAY_SPACE_PAD: // %e
                sPadding = " ";
            case TIME_FORMAT_DAY: // %d
                nValue = t.Day;
                break;
            case TIME_FORMAT_HOUR_24_SPACE_PAD: // %H
                sPadding = " ";
            case TIME_FORMAT_HOUR_24: // %H
                nValue = t.Hour;
                break;
            case TIME_FORMAT_HOUR_12_SPACE_PAD: // %l
                sPadding = " ";
            case TIME_FORMAT_HOUR_12: // %I
                nValue = t.Hour > 12 ? t.Hour % 12 : t.Hour;
                nValue = nValue ? nValue : 12;
                break;

            case TIME_FORMAT_SIGN: // %+
                sValue = nDur < 0 ? "-" : nDur > 0 ? "+" : "";
                bAllowEmpty = TRUE;
                break;
            case TIME_FORMAT_MONTH: // %m
                nValue = t.Month;
                break;
            case TIME_FORMAT_MINUTE: // %M
                nValue = t.Minute;
                break;
            case TIME_FORMAT_SECOND: // %S
                nValue = t.Second;
                break;
            case TIME_FORMAT_MILLISECOND: // %f
                nValue = t.Millisecond;
                nPadding = 3;
                break;
            case TIME_FORMAT_DAY_OF_YEAR: // %j
                nValue = t.Month * 28 + t.Day;
                nPadding = 3;
                break;
            case TIME_FORMAT_DAY_OF_WEEK_0_6: // %w
                nValue = t.Day % 7;
                nPadding = 1;
                break;
            case TIME_FORMAT_DAY_OF_WEEK_1_7: // %u
                nValue = (t.Day % 7) + 1;
                nPadding = 1;
                break;
            case TIME_FORMAT_AMPM_UPPER: // %p
            case TIME_FORMAT_AMPM_LOWER: // %P
                bAllowEmpty = TRUE;
                sValue = GetLocaleString(jLocale, LOCALE_AMPM);
                sValue = GetListItem(sValue, t.Hour % 24 >= 12);
                if (nFormat == TIME_FORMAT_AMPM_LOWER)
                    sValue = GetStringLowerCase(sValue);
                break;
            case TIME_FORMAT_NAME_OF_DAY_LONG: // %A
                bAllowEmpty = TRUE;
                sValue = GetLocaleString(jLocale, LOCALE_DAYS);
                sValue = DayToString(t.Day, sValue);
                break;
            case TIME_FORMAT_NAME_OF_DAY_ABBR: // %a
                bAllowEmpty = TRUE;
                sValue = GetLocaleString(jLocale, LOCALE_DAYS);
                sValue = GetLocaleString(jLocale, LOCALE_DAYS_ABBR, sValue);
                sValue = DayToString(t.Day, sValue);
                break;
            case TIME_FORMAT_NAME_OF_MONTH_LONG: // %B
                bAllowEmpty = TRUE;
                sValue = GetLocaleString(jLocale, LOCALE_MONTHS);
                sValue = MonthToString(t.Month, sValue);
                break;
            case TIME_FORMAT_NAME_OF_MONTH_ABBR: // %b
                bAllowEmpty = TRUE;
                sValue = GetLocaleString(jLocale, LOCALE_MONTHS);
                sValue = GetLocaleString(jLocale, LOCALE_MONTHS_ABBR, sValue);
                sValue = MonthToString(t.Month, sValue);
                break;

            // We handle literal % here instead of replacing it directly because
            // we want the user to be able to pad it if desired.
            case TIME_FORMAT_PERCENT: // %%
                sValue = "%";
                break;

            case TIME_FORMAT_YEAR_CENTURY: // %C, %EC
                if (nFlags & TIME_FLAG_ERA)
                    sValue = GetEraString(jEra, jLocale, ERA_NAME);
                nValue = t.Year / 100;
                break;
            case TIME_FORMAT_YEAR_SHORT: // %y, %Ey
                nValue = (nFlags & TIME_FLAG_ERA) ? GetEraYear(jEra, t.Year) : t.Year % 100;
                break;

            case TIME_FORMAT_YEAR_LONG: // %Y, %EY
                if (nFlags & TIME_FLAG_ERA)
                {
                    sValue = GetEraString(jEra, jLocale, ERA_YEAR_FORMAT);
                    if (sValue != "")
                    {
                        sFormat = ReplaceSubString(sFormat, sValue, nOffset, nPos + 1);
                        continue;
                    }
                }

                nValue = t.Year;
                nPadding = 4;
                break;

            // These codes are shortcuts to common operations. We replace the
            // parsed code with the substitution and re-parse from the same
            // offset.
            case TIME_FORMAT_DATE_US: // %D
                sFormat = ReplaceSubString(sFormat, "%m/%d/%y", nOffset, nPos + 1);
                continue;
            case TIME_FORMAT_DATE_ISO: // %F
                sFormat = ReplaceSubString(sFormat, "%Y-%m-%d", nOffset, nPos + 1);
                continue;
            case TIME_FORMAT_TIME_US: // %R
                sFormat = ReplaceSubString(sFormat, "%H:%M", nOffset, nPos + 1);
                continue;
            case TIME_FORMAT_TIME_ISO: // %T
                sFormat = ReplaceSubString(sFormat, "%H:%M:%S", nOffset, nPos + 1);
                continue;
            case TIME_FORMAT_LOCALE_DATETIME: // %c, %Ec
                if (nFlags & TIME_FLAG_ERA)
                    sValue = GetEraString(jEra, jLocale, ERA_DATETIME_FORMAT);
                else
                    sValue = GetLocaleString(jLocale, LOCALE_DATETIME_FORMAT, DEFAULT_DATETIME_FORMAT);
                sFormat = ReplaceSubString(sFormat, sValue, nOffset, nPos + 1);
                continue;
            case TIME_FORMAT_LOCALE_DATE: // %x, %Ex
                if (nFlags & TIME_FLAG_ERA)
                    sValue = GetEraString(jEra, jLocale, ERA_DATE_FORMAT);
                else
                    sValue = GetLocaleString(jLocale, LOCALE_DATE_FORMAT, DEFAULT_DATE_FORMAT);
                sFormat = ReplaceSubString(sFormat, sValue, nOffset, nPos + 1);
                continue;
            case TIME_FORMAT_LOCALE_TIME: // %c, %Ec
                if (nFlags & TIME_FLAG_ERA)
                    sValue = GetEraString(jEra, jLocale, ERA_TIME_FORMAT);
                else
                    sValue = GetLocaleString(jLocale, LOCALE_TIME_FORMAT, DEFAULT_TIME_FORMAT);
                sFormat = ReplaceSubString(sFormat, sValue, nOffset, nPos + 1);
                continue;
            case TIME_FORMAT_LOCALE_TIME_AMPM: // %r
                sValue = GetLocaleString(jLocale, LOCALE_AMPM_FORMAT, DEFAULT_AMPM_FORMAT);
                sFormat = ReplaceSubString(sFormat, sValue, nOffset, nPos + 1);
                continue;
        }

        if ((sValue == "" && !bAllowEmpty) && (nFlags & TIME_FLAG_ORDINAL))
            sValue = IntToOrdinalString(nValue, sOrdinals);

        if (nFlags & TIME_FLAG_NO_PAD)
            sPadding = "";
        else if (sValue != "" || bAllowEmpty)
            sPadding = " " + sWidth;
        else
        {
            if (nFlags & TIME_FLAG_SPACE_PAD)
                sPadding = " ";
            else if (nFlags & TIME_FLAG_ZERO_PAD || sPadding == "")
                sPadding = "0";

            sPadding += sWidth != "" ? sWidth : IntToString(nPadding);
        }

        if (sValue != "" || bAllowEmpty)
        {
            if (nFlags & TIME_FLAG_UPPERCASE)
                sValue = GetStringUpperCase(sValue);
            jValues = JsonArrayInsert(jValues, JsonString(sValue));
            sFormat = ReplaceSubString(sFormat, "%" + sPadding + "s", nOffset, nPos + 1);
        }
        else
        {
            jValues = JsonArrayInsert(jValues, JsonInt(nValue));
            sFormat = ReplaceSubString(sFormat, "%" + sPadding + "d", nOffset, nPos + 1);
        }

        // Continue parsing from the end of the format string
        nOffset = nPos + GetStringLength(sPadding);
    }

    // Interpolate the values
    return FormatValues(jValues, sFormat);
}

string FormatTime(struct Time t, string sFormat = "%X", string sLocale = "")
{
    return _FormatTime(t, sFormat, sLocale);
}

string FormatDate(struct Time t, string sFormat = "%x", string sLocale = "")
{
    return FormatTime(t, sFormat, sLocale);
}

string FormatDateTime(struct Time t, string sFormat = "%c", string sLocale = "")
{
    return FormatTime(t, sFormat, sLocale);
}

// Private function. Converts a duration in seconds to a time. This time will
// not be valid if fDur is < 0 and will not yield an expected number of days or
// months, so it is really only used internally as a convenience.
struct Time _DurationToTime(float fDur)
{
    struct Time t;
    int nHours    = FloatToInt(fDur / HoursToSeconds(1));
    t.Millisecond = FloatToInt(frac(fDur) * 1000);
    t.Second      = FloatToInt(fmod(fDur, 60.0));
    t.Minute      = FloatToInt(fDur / 60.0) % HoursToMinutes();
    t.Hour        = nHours % 24;
    t.Day         = nHours / 24 % 28;
    t.Month       = nHours / 24 / 28 % 12;
    t.Year        = nHours / 24 / 28 / 12;
    return t;
}

string FormatDuration(float fDur, string sFormat = "%+%Y-%m-%d %H:%M:%S:%f", string sLocale = "")
{
    return _FormatTime(_DurationToTime(fabs(fDur)), sFormat, sLocale, fsign(fDur), TRUE);
}
