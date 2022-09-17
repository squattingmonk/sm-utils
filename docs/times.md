# Core Utilities: Times

`util_i_times.nss` contains utilities for dealing with times, dates, and
durations. `util_i_times.nss` requires the following scripts:
- `util_i_debug.nss`
- `util_i_math.nss`
- `util_i_strings.nss`
- `util_i_color.nss`
- `util_c_color.nss`

`util_i_strftime.nss` contains advanced formatting functions for times; it
includes `util_c_strftime.nss` which contains configuration settings to help
with formatting times to your liking. `util_i_strftime.nss` includes the
following scripts:
- `util_i_debug.nss`
- `util_i_math.nss`
- `util_i_strings.nss`
- `util_i_color.nss`
- `util_c_color.nss`
- `util_i_csvlists.nss`
- `util_i_times.nss`
- `util_c_strftime.nss`

## Contents

- [Concepts](#concepts)
- [Usage](#usage)
  - [Creating a Time](#creating-a-time)
  - [Converting Between Time and Game Time](#converting-between-time-and-game-time)
  - [Getting the Current Time](#getting-the-current-time)
  - [Setting the Current Time](#setting-the-current-time)
  - [Dropping units from a Time](#dropping-units-from-a-time)
  - [Saving a Time](#saving-a-time)
  - [Comparing Times](#comparing-times)
- [Formatting](#formatting)
  - [Conversion Specifiers](#conversion-specifiers)
  - [Modifier Characters](#modifier-characters)
  - [Flag Characters](#flag-characters)
  - [Examples](#examples)
  - [Advanced Usage](#advanced-usage)
    - [Locales](#locales)
    - [Eras](#eras)

## Concepts

- **Time**: a struct value that may represent either a *calendar time* or a
  *duration*. A Time has a field for years, months, day, hours, minutes,
  seconds, and milliseconds. A Time also has a field to set the minutes per hour
  (defaults to the module setting, which defaults to 2).
- **Calendar Time**: A Time representing a particular *moment in time* as
  measured using the game calendar and clock. In a calendar Time, the month and
  day count from 1, while all other units count from 0 (including years, since
  NWN allows year 0). A calendar Time must always be positive.
- **Duration Time**: A Time representing an *amount of time*. All units in a
  duration Time count from 0. A duration Time may be negative, representing
  going back in time. This can be useful for calculations. A duration Time can
  be converted to seconds to pass it to game functions that expect a time, such
  as `DelayCommand()`, `PlayAnimation()`, etc.
- **Game Time**: a Time (either calendar Time or duration Time) with a minutes
  per hour setting of 60. This allows you to convert the time shown by the game
  clock into a time that matches how the characters in the game would perceive
  it. For example, with the default minutes per hour setting of 2, the Time
  "13:01" would correspond to a Game Time of "13:30".
- **Normalizing Times**: You can normalize a Time to ensure none of its units
  are overflowing their bounds. For example, a Time with a Minute field of 0 and
  Second field of 90 would be normalized to a Minute of 1 and a Second of 30.
  Normalizing a Time also causes all non-zero units to take the same sign
  (either positive or negative), so a Time with a Minute of 1 and a Second of
  -30 would normalize to a Second of 30. When normalizing a Time, you can also
  change the minutes per hour setting. This is how the functions in this file
  convert between Time and Game Time.

**Note**: For brevity, some functions have a `Time` variant and a `Duration`
variant. In these cases, the `Time` variant refers to a calendar Time (e.g.,
`StringToTime()` converts to a calendar Time while `StringToDuration()` refers
to a duration Time). If no `Duration` variant of the function is present, the
function may refer to a calendar Time *or* a duration Time (e.g.,
`TimeToString()` accepts both types).

## Usage

The scripts in this section only require `util_i_times.nss`.

### Creating a Time

You can create a calendar Time using `GetTime()` and a duration Time with
`GetDuration()`:
```nwscript
struct Time t = GetTime(1372, 6, 1, 13);
struct Time d = GetDuration(1372, 5, 0, 13);
```

You could also parse an ISO 8601 time string into a calendar Time or duration
Time:
```nwscript
struct Time tTime = StringToTime("1372-06-01 13:00:00:000");
struct Time tDur = StringToDuration("1372-05-00 13:00:00:000");

// Negative durations are allowed:
struct Time tNeg = StringToDuration("-1372-05-00 13:00:00:000");

// Missing units are assumed to be their lowest bound:
struct Time a = StringToTime("1372-06-01 00:00:00:000");
struct Time b = StringToTime("1372-06-01");
struct Time c = StringToTime("1372-06");
Assert(a == b);
Assert(b == c);
```

You can also create a Time manually by declaring a new Time struct and setting
the fields independently:
```nwscript
struct Time t;
t.Type  = TIME_TYPE_CALENDAR;
t.Year  = 1372;
t.Month = 6;
t.Day   = 1;
t.Hour  = 13;
// ...
```

When not using the `GetTime()` function, it's a good idea to normalize the
resultant Time to distribute the field values correctly:
```nwscript
struct Time t = NewTime();
t.Second = 90;

t = NormalizeTime(t);
Assert(t.Minute == 1);
Assert(t.Second == 30);
```

### Converting Between Time and Game Time

```nwscript
// Assuming the default module setting of 2 minutes per hour
struct Time tTime = StringToTime("1372-06-01 13:01:00:000");
Assert(tTime.Hour == 13);
Assert(tTime.Minute == 1);

struct Time tGame = TimeToGameTime(tTime);
Assert(tGame.Hour == 13);
Assert(tGame.Minute == 30);

struct tBack = GameTimeToTime(tGame);
Assert(tTime == tBack);
```

### Getting the Current Time
```nwscript
struct Time tTime = GetCurrentTime();
struct Time tGame = GetCurrentGameTime();
```

### Setting the Current Time
**Note:** You can only set the time forward in NWN.

```nwscript
struct Time t = StringToTime("2022-08-25 13:00:00:000");
SetCurrentTime(t);
```

Alternatively, you can advance the current Time by a duration Time:
```nwscript
AdvanceCurrentTime(FloatToDuration(120.0));
```

### Dropping units from a Time
You can reduce the precision of a Time. Units smaller than the precision limit
will be at their lower bound:
```nwscript
struct Time a = GetTime(1372, 6, 1, 13);
struct Time b = GetTime(1372, 6, 1);
struct Time c = GetPrecisionTime(a, TIME_UNIT_DAY);
struct Time d = GetPrecisionTime(a, TIME_UNIT_MONTH);
Assert(a != b);
Assert(b == c);
Assert(b == d);
```

### Saving a Time
The easiest way to save a Time and get it later is to use the `SetLocalTime()`
and `GetLocalTime()` functions. These functions convert a Time into json and
save it as a local variable.

In this example, we save the server start time OnModuleLoad and then get it
later:
```nwscript
// OnModuleLoad
SetLocalTime(GetModule(), "ServerStart", GetCurrentTime());

// later on...
struct Time tServerStart = GetLocalTime(GetModule(), "ServerStart");
```

If you want to store a Time in a database, you can convert it into json or into
a string before passing it to a query. The json method is preferable for
persistent storage, since it is guaranteed to be correct if the module's minutes
per hour setting changes after the value is stored:
```nwscript
struct Time tTime = GetCurrentTime();
json jTime = TimeToJson(tTime);
string sSql = "INSERT INTO data (varname, value) VALUES ('ServerTime', @time);";
sqlquery q = SqlPrepareQueryCampaign("mydb", sSql);
SqlBindJson(q, "@time", jTime);
SqlStep(q);
```

You can then convert the json back into a Time:
```nwscript
string Time tTime;
string sSql = "SELECT value FROM data WHERE varname='ServerTime';";
sqlquery q = SqlPrepareQueryCampaign("mydb", sSql);
if (SqlStep(q))
    tTime = JsonToTime(SqlGetJson(q, 0));
```

For simpler applications (such as saving to the module's volatile database),
converting to a string works fine and could even be preferable since you can use
sqlite's `<`, `>`, and `=` operators to check if one time is before, after, or
equal to another.
```nwscript
struct Time tTime = GetCurrentTime();
string sTime = TimeToString();
string sSql = "INSERT INTO data (varname, value) VALUES ('ServerTime', @time);";
sqlquery q = SqlPrepareQueryCampaign("mydb", sSql);
SqlBindString(q, "@time", sTime);
SqlStep(q);
```

### Comparing Times
To check if one time is before or after another:
```nwscript
struct Time a = StringToTime("1372-06-01 13:00:00:000");
struct Time b = StringToTime("1372-06-01 13:01:30:500");
Assert(GetIsTimeBefore(a, b));
Assert(!GetIsTimeAfter(a, b));
```

To check if two times are equal:
```nwscript
struct Time a = StringToTime("1372-06-01 13:00:00:000");
struct Time b = StringToTime("1372-06-01 13:01:00:000");
struct Time c = TimeToGameTime(b);

Assert(!GetIsTimeEqual(a, b));
Assert(GetIsTimeEqual(b, c));

// To check for exactly equal:
Assert(b != c);
```

To check the amount of time between two Times:
```nwscript
struct Time a = StringToTime("1372-06-01 13:00:00:000");
struct Time b = StringToTime("1372-06-01 13:01:30:500");
struct Time tDur = GetDurationBetween(a, b);
Assert(DurationToFloat(tDur) == 90.5);
```

To check if a duration has passed since a Time:
```nwscript
int CheckForMinRestTime(object oPC, float fMinTime)
{
    struct Time tSince = GetDurationSince(GetLocalTime(oPC, "LastRest"));
    return DurationToFloat(tSince) >= fMinTime;
}
```

To calculate the duration until a Time is reached:
```nwscript
struct Time tMidnight = GetTime(GetCalendarYear(), GetCalendarMonth(), GetCalendarDay() + 1);
struct Time tDurToMidnight = GetDurationUntil(tMidnight);
float fDurToMidnight = DurationToFloat(tDurToMidnight);
```

## Formatting

The `Format*()` functions require `util_i_strftime.nss` and
`util_c_strftime.nss`.

You can format a Time using the `strftime()` function. This function takes a
Time as the first parameter (`t`) and a *format specification string*
(`sFormat`) as the second parameter. The format specification string may contain
special character sequences called *conversion specifications*, each of which is
introduced by the `%` character and terminated by some other character known as
a *conversion specifier character*. All other character sequences are *ordinary
character sequences*.

The characters of ordinary character sequences are copied verbatim from
`sFormat` to the returned value. However, the characters of conversion
specifications are replaced as shown in the list below. Some sequences may have
their output customized using a *locale*, which can be passed using the third
parameter of `strftime()` (`sLocale`).

Several aliases for `strftime()` exist. `FormatTime()`, `FormatDate()`, and
`FormatDateTime()` each take a calendar Time and will default to formatting to a
locale-specific representation of the time, date, or date and time respectively.
`FormatDuration()` takes a duration Time and defaults to showing an ISO 8601
formatted datetime with a sign character before it.

### Conversion Specifiers

- `%a`: The abbreviated name of the weekday according to the current locale.
        The specific names used in the current locale can be set using the
        key `LOCALE_DAYS_ABBR`. If no abbreviated names are available in the
        locale, will fall back to the full day name.
- `%A`: The full name of the weekday according to the current locale.
        The specific names used in the current locale can be set using the
        key `LOCALE_DAYS`.
- `%b`: The abbreviated name of the month according to the current locale.
        The specific names used in the current locale can be set using the
        key `LOCALE_MONTHS_ABBR`. If no abbreviated names are available in
        the locale, will fall back to the full month name.
- `%B`: The full name of the month according to the current locale. The
        specific names used in the current locale can be set using the key
        `LOCALE_MONTHS`.
- `%c`: The preferred date and time representation for the current locale.
        The specific format used in the current locale can be set using the
        key `LOCALE_DATETIME_FORMAT` for the `%c` conversion specification
        and `ERA_DATETIME_FORMAT` for the `%Ec` conversion specification.
        With the default settings, this is equivalent to `%Y-%m-%d
        %H:%M:%S:%f`. This is the default value of `sFormat` for
        `FormatDateTime()`.
- `%C`: The century number (year / 100) as a 2-or-3-digit integer (00..320).
        (The `%EC` conversion specification corresponds to the name of the
        era, which can be set using the era key `ERA_NAME`.)
- `%d`: The day of the month as a 2-digit decimal number (01..28).
- `%D`: Equivalent to `%m/%d/%y`, the standard US time format. Note that
        this may be ambiguous and confusing for non-Americans.
- `%e`: The day of the month as a decimal number, but a leading zero is
        replaced by a space. Equivalent to `%_d`.
- `%E`: Modifier: use alternative "era-based" format (see below).
- `%f`: The millisecond as a 3-digit decimal number (000..999).
- `%F`: Equivalent to `%Y-%m-%d`, the ISO 8601 date format.
- `%H`: The hour (24-hour clock) as a 2-digit decimal number (00..23).
- `%I`: The hour (12-hour clock) as a 2-digit decimal number (01..12).
- `%j`: The day of the year as a 3-digit decimal number (000..336).
- `%k`: The hour (24-hour clock) as a decimal number (0..23). Single digits
        are preceded by a space. Equivalent to `%_H`.
- `%l`: The hour (12-hour clock) as a decimal number (1..12). Single digits
        are preceded by a space. Equivalent to `%_I`.
- `%m`: The month as a 2-digit decimal number (01..12).
- `%M`: The minute as a 2-digit decimal number (00..59, depending on
        `t.MinsPerHour`).
- `%O`: Modifier: use ordinal numbers (1st, 2nd, etc.) (see below).
- `%p`: Either "AM" or "PM" according to the given Time, or the
        corresponding values from the locale. The specific word used can be
        set for the current locale using the key `LOCALE_AMPM`.
- `%P`: Like `%p`, but lowercase. Yes, it's silly that it's not the other
        way around.
- `%r`: The preferred AM/PM time representation for the current locale. The
        specific format used in the current locale can be set using the key
        `LOCALE_AMPM_FORMAT`. With the default settings, this is equivalent
        to `%I:%M:%S %p`.
- `%R`: The time in 24-hour notation. Equivalent to `%H:%M`. For a version
        including seconds, see `%T`.
- `%S`: The second as a 2-digit decimal number (00..59).
- `%T`: The time in 24-hour notation. Equivalent to `%H:%M:%S`. For a
        version without seconds, see `%R`.
- `%u`: The day of the  week as a 1-indexed decimal (1..7).
- `%w`: The day of the week as a 0-indexed decimal (0..6).
- `%x`: The preferred date representation for the current locale without the
        time. The specific format used in the current locale can be set
        using the key `LOCALE_TIME_FORMAT` for the `%x` conversion
        specification and `ERA_TIME_FORMAT` for the `%Ex` conversion
        specification. With the default settings, this is equivalent to
        `%Y-%m-%d`. This is the default value of `sFormat` for
        `FomatDate()`.
- `%X`: The preferred time representation for the current locale without the
        date. The specific format used in the current locale can be set
        using the key `LOCALE_DATE_FORMAT` for the `%X` conversion
        specification and `ERA_DATE_FORMAT` for the `%EX` conversion
        specification. With the default settings, this is equivalent to
        `%H:%M:%S`. This is the default value of `sFormat` for
        `FormatTime()`.
- `%y`: The year as a 2-digit decimal number without the century (00..99).
        (The `%Ey` conversion specification corresponds to the year since
        the beginning of the era denoted by the `%EC` conversion
        specification.)
- `%Y`: The year as a decimal number including the century (0000..32000).
        (The `%EY` conversion specification corresponds to era key
        `ERA_FORMAT`; with the default era settings, this is equivalent to
        `%Ey %EC`.)
- `%%`: A literal `%` character.

### Modifier Characters

Some conversion specifications can be modified by preceding the conversion
specifier character by the `E` or `O` *modifier* to indicate that an alternative
format should be used. If the alternative format does not exist for the locale,
the behavior will be as if the unmodified conversion specification were used.

The `E` modifier signifies using an alternative era-based representation. The
following are valid: `%Ec`, `%EC`, `%Ex`, `%EX`, `%Ey`, and `%EY`.

The `O` modifier signifies representing numbers in ordinal form (e.g., 1st, 2nd,
etc.). The ordinal suffixes for each number can be set using the locale key
`LOCALE_ORDINAL_SUFFIXES`. The following are valid: `%Od`, `%Oe`, `%OH`, `%OI`,
`%Om`, `%OM`, `%OS`, `%Ou`, `%Ow`, `%Oy`, and `%OY`.

### Flag Characters

Between the `%` character and the conversion specifier character, an optional
*flag* and *field width* may be specified. (These should precede the `E` or `O`
characters, if present).

The following flag characters are permitted:
- `_`: (underscore) Pad a numeric result string with spaces.
- `-`: (dash) Do not pad a numeric result string.
- `0`: Pad a numeric result string with zeroes even if the conversion
       specifier character uses space-padding by default.
- `^`: Convert alphabetic characters in the result string to uppercase.
- `+`: Display a `-` before numeric values if the Time is negative, or a `+` if
       the Time is positive or 0.
- `,`: Add comma separators for long numeric values.

An optional decimal width specifier may follow the (possibly absent) flag. If
the natural size of the field is smaller than this width, the result string is
padded (on the left) to the specified width. The string is never truncated.

### Examples

```nwscript
struct Time t = StringToTime("1372-06-01 13:00:00:000");

// Default formatting
FormatDateTime(t); // "1372-06-01 13:00:00:000"
FormatDate(t); // "1372-06-01"
FormatTime(t); // "13:00:00:000"

// Using custom formats
FormatTime(t, "Today is %A, %B %Od."); // "Today is Monday, June 1st."
FormatTime(t, "%I:%M %p"); // "01:00 PM"
FormatTime(t, "%-I:%M %p"); // "1:00 PM"
```

### Advanced Usage

#### Locales

A locale is a json object that contains localization settings for formatting
functions. A default locale will be constructed using the configuration values
in `util_c_times.nss`, but you can also construct locales yourself. An
application for this might be having different areas in the module use different
month or day names, etc.

A locale is a simple json object:
```nwscript
json jLocale = JsonObject();
```

Alternatively, you can initialize a locale with the default values from
`util_c_times.nss`:
```nwscript
json jLocale = NewLocale();
```

Keys are then added using `SetLocaleString()`:
```nwscript
jLocale = SetLocaleString(jLocale, LOCALE_DAYS, "Moonday, Treeday, etc.");
```

Keys can be retrieved using `GetLocaleString()`, which takes an optional
default value if the key is not set:
```nwscript
string sDays     = GetLocaleString(jLocale, LOCALE_DAYS);
string sDaysAbbr = GetLocaleString(jLocale, LOCALE_DAYS_ABBR, sDays);
```

Locales can be saved with a name. That names can then be passed to
formatting functions:
```nwscript
json jLocale = JsonObject();
jLocale = SetLocaleString(jLocale, LOCALE_DAYS, "Moonday, Treeday, Heavensday, Valarday, Shipday, Starday, Sunday");
jLocale = SetLocaleString(jLocale, LOCALE_MONTHS, "Narvinye, Nenime, Sulime, Varesse, Lotesse, Narie, Cermie, Urime, Yavannie, Narquelie, Hisime, Ringare");
SetLocale(jLocale, "ME");
FormatTime(t, "Today is %A, %B %Od.");       // "Today is Monday, June 1st
FormatTime(t, "Today is %A, %B %Od.", "ME"); // "Today is Moonday, Narie 1st
```

You can change the default locale so that you don't have to pass the name
every time:
```nwscript
SetDefaultLocale("ME");
FormatTime(t, "Today is %A, %B %Od."); // "Today is Moonday, Narie 1st
```

The following keys are currently supported:
- `LOCALE_DAYS`: a CSV list of 7 weekday names. Accessed by `%A`.
- `LOCALE_DAYS_ABBR`: a CSV list of 7 abbreviated weekday names. If not set,
   the `FormatTime()` function will use `LOCALE_DAYS` instead. Accessed by
   `%a`.
- `LOCALE_MONTHS`: a CSV list of 12 month names. Accessed by `%B`.
- `LOCALE_MONTHS_ABBR`: a CSV list of 12 abbreviated month names. If not
  set, the `FormatTime()` function will use `LOCALE_MONTHS` instead.
  Accessed by `%b`.
- `LOCALE_AMPM`: a CSV list of 2 AM/PM elements. Accessed by `%p` and `%P`.
- `LOCALE_ORDINAL_SUFFIXES`: a CSV list of suffixes for constructing ordinal
  numbers. See `util_c_times.nss`'s documentation of `DEFAULT_ORDINAL_SUFFIXES`
  for details.
- `LOCALE_DATETIME_FORMAT`: a date and time format string. Aliased by `%c`.
- `LOCALE_DATE_FORMAT`: a date format string. Aliased by `%x`.
- `LOCALE_TIME_FORMAT`: a time format string. Aliased by `%X`.
- `LOCALE_AMPM_FORMAT`: a time format string using AM/PM form. Aliased
  by `%r`.
- `ERA_DATETIME_FORMAT`: a format string to display the date and time. If
  not set, will fall back to `LOCALE_DATETIME_FORMAT`. Aliased by `%Ec`.
- `ERA_DATE_FORMAT`: a format string to display the date without the time.
  If not set, will fall back to `LOCALE_DATE_FORMAT`. Aliased by `%Ex`.
- `ERA_TIME_FORMAT`: a format string to display the time without the date.
  If not set, will fall back to `LOCALE_TIME_FORMAT`. Aliased by `%EX`.
- `ERA_YEAR_FORMAT`: a format string to display the year. If not set, will
  display the year. Aliased by `%EY`.
- `ERA_NAME`: the name of an era. If not set and no era matches the current
  year, will display the century. Aliased by `%EC`.

#### Eras

Locales can also hold an array of eras. Eras are json objects which name a time
range. When formatting using the `%E` modifier, the start Times of each era in
the array are compared to the Time to be formatted; the era with the latest
start that is still before the Time is selected. Format codes can then refer to
the era's name, year relative to the era start, and other era-specific formats.

An era can be created using `DefineEra()`. This function takes a name and a
start Time. See the documentation for `DefineEra()` for further info:
```nwscript
// Create an era that begins at the first possible calendar time
json jFirst = DefineEra("First Age", GetTime());

// Create an era that begins on a particular year
json jSecond = DefineEra("Second Age", GetTime(590));
```

The `{Get/Set}LocaleString()` functions also apply to eras:
```nwscript
jSecond = SetLocaleString(jSecond, ERA_DATETIME_FORMAT, "%B %Od, %EY");
jSecond = SetLocaleString(jSecond, ERA_YEAR_FORMAT, "%EY 2E");
```

You can add an era to a locale using `AddEra()`:
```nwscript
json jLocale = GetLocale("ME");
jLocale = SetLocaleString(jLocale, LOCALE_DAYS, "Moonday, Treeday, Heavensday, Valarday, Shipday, Starday, Sunday");
jLocale = SetLocaleString(jLocale, LOCALE_MONTHS, "Narvinye, Nenime, Sulime, Varesse, Lotesse, Narie, Cermie, Urime, Yavannie, Narquelie, Hisime, Ringare");
jLocale = AddEra(jLocale, jFirst);
jLocale = AddEra(jLocale, jSecond);
SetLocale(jLocale, "ME");
```

You can then access the era settings using the `%E` modifier:
```nwscript
FormatTime(t, "Today is %A, %B %Od, %EY.", "ME"); // "Today is Moonday, Narie 1st, 783 2E."

// You can combine the `%E` and `%O` modifiers
FormatTime(t, "It is the %EOy year of the %EC.", "ME"); // "It is the 783rd year of the Second Age."
```

The following keys are available to eras:
- `ERA_NAME`: the name of the era. Aliased by `%EC`.
- `ERA_DATETIME_FORMAT`: a format string to display the date and time. If not
  set, will fall back to the value on the locale. Aliased by `%Ec`.
- `ERA_DATE_FORMAT`: a format string to display the date without the time. If
  not set, will fall back to the value on the locale. Aliased by `%Ex`.
- `ERA_TIME_FORMAT`: a format string to display the time without the date. If
  not set, will fall back to the value on the locale. Aliased by `%EX`.
- `ERA_YEAR_FORMAT`: a format string to display the year. Defaults to `%Ey %EC`.
  If not set, will fall back to the value on the locale. Aliased by `%EY`.
