/// ----------------------------------------------------------------------------
/// @file   util_i_strftime.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Functions for formatting times.
/// ----------------------------------------------------------------------------
/// @details This file contains an implementation of C's strftime() in nwscript.
///
/// # Formatting
///
/// You can format a Time using the `strftime()` function. This function takes
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
/// third parameter of `strftime()` (`sLocale`).
///
/// Several aliases for `strftime()` exist. `FormatTime()`, `FormatDate()`, and
/// `FormatDateTime()` each take a calendar Time and will default to formatting
/// to a locale-specific representation of the time, date, or date and time
/// respectively. `FormatDuration()` takes a duration Time and defaults to
/// showing an ISO 8601 formatted datetime with a sign character before it.
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
/// - `+`: Display a `-` before numeric values if the Time is negative, or a `+`
///        if the Time is positive or 0.
/// - `,`: Add comma separators for long numeric values.
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

#include "util_i_times"
#include "util_i_csvlists"
#include "util_c_strftime"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

// These are the characters used as flags in time format codes.
const string TIME_FLAG_CHARS = "EO^,+-_0123456789";

const int TIME_FLAG_ERA       = 0x01; ///< `E`: use era-based formatting
const int TIME_FLAG_ORDINAL   = 0x02; ///< `O`: use ordinal numbers
const int TIME_FLAG_UPPERCASE = 0x04; ///< `^`: use uppercase letters
const int TIME_FLAG_COMMAS    = 0x08; ///< `,`: add comma separators
const int TIME_FLAG_SIGN      = 0x10; ///< `+`: prefix with sign character
const int TIME_FLAG_NO_PAD    = 0x20; ///< `-`: do not pad numbers
const int TIME_FLAG_SPACE_PAD = 0x40; ///< `_`: pad numbers with spaces
const int TIME_FLAG_ZERO_PAD  = 0x80; ///< `0`: pad numbers with zeros

// These are the characters allowed in time format codes.
const string TIME_FORMAT_CHARS = "aAbBpPIljwuCyYmdeHkMSfDFRTcxXr%";

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
const int TIME_FORMAT_YEAR_CENTURY       = 11; ///< `%C`: 0..320
const int TIME_FORMAT_YEAR_SHORT         = 12; ///< `%y`: 00..99
const int TIME_FORMAT_YEAR_LONG          = 13; ///< `%Y`: 0..320000
const int TIME_FORMAT_MONTH              = 14; ///< `%m`: 01..12
const int TIME_FORMAT_DAY                = 15; ///< `%d`: 01..28
const int TIME_FORMAT_DAY_SPACE_PAD      = 16; ///< `%e`: alias for %_d
const int TIME_FORMAT_HOUR_24            = 17; ///< `%H`: 00..23
const int TIME_FORMAT_HOUR_24_SPACE_PAD  = 18; ///< `%k`: alias for %_H
const int TIME_FORMAT_MINUTE             = 19; ///< `%M`: 00..59 (depending on conversion factor)
const int TIME_FORMAT_SECOND             = 20; ///< `%S`: 00..59
const int TIME_FORMAT_MILLISECOND        = 21; ///< `%f`: 000...999
const int TIME_FORMAT_DATE_US            = 22; ///< `%D`: 06/01/72
const int TIME_FORMAT_DATE_ISO           = 23; ///< `%F`: 1372-06-01
const int TIME_FORMAT_TIME_US            = 24; ///< `%R`: 13:00
const int TIME_FORMAT_TIME_ISO           = 25; ///< `%T`: 13:00:00
const int TIME_FORMAT_LOCALE_DATETIME    = 26; ///< `%c`: locale-specific date and time
const int TIME_FORMAT_LOCALE_DATE        = 27; ///< `%x`: locale-specific date
const int TIME_FORMAT_LOCALE_TIME        = 28; ///< `%X`: locale-specific time
const int TIME_FORMAT_LOCALE_TIME_AMPM   = 29; ///< `%r`: locale-specific AM/PM time
const int TIME_FORMAT_PERCENT            = 30; ///< `%%`: %

// Time format codes with an index less than this number are not valid for
// durations.
const int DURATION_FORMAT_OFFSET = TIME_FORMAT_YEAR_CENTURY;

// ----- VarNames --------------------------------------------------------------

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

/// @brief Convert an integer into an ordinal number (e.g., 1 -> 1st, 2 -> 2nd).
/// @param n The number to convert.
/// @param sSuffixes A CSV list of suffixes for each integer, starting at 0. If
///     the n <= the length of the list, only the last digit will be checked. If
///     "", will use the suffixes provided by the locale instead.
/// @param sLocale The name of the locale to use when formatting the number. If
///     "", will use the default locale.
string IntToOrdinalString(int n, string sSuffixes = "", string sLocale = "");

/// @brief Format a Time into a string.
/// @param t A calendar or duration Time to format. No conversion is performed.
/// @param sFormat A string containing format codes to control the output.
/// @param sLocale The name of the locale to use when formatting the time. If
///     "", will use the default locale.
/// @note See the documentation at the top of this file for the list of possible
///     format codes.
string strftime(struct Time t, string sFormat, string sLocale = "");

/// @brief Format a calendar Time into a string.
/// @param t A calendar Time to format. If not a calendar Time, will be
///     converted into one.
/// @param sFormat A string containing format codes to control the output. The
///     default value is equivalent to "%H:%M:%S".
/// @param sLocale The name of the locale to use when formatting the time. If
///     "", will use the default locale.
/// @note This function differs only from FormatTime() in the default value of
///     sFormat. Character codes that apply to calendar Times are still valid.
/// @note See the documentation at the top of this file for the list of possible
///     format codes.
string FormatTime(struct Time t, string sFormat = "%X", string sLocale = "");

/// @brief Format a calendar Time into a string.
/// @param t A calendar Time to format. If not a calendar Time, will be
///     converted into one.
/// @param sFormat A string containing format codes to control the output. The
///     default value is equivalent to "%Y-%m-%d".
/// @param sLocale The name of the locale to use when formatting the date. If
///     "", will use the default locale.
/// @note This function differs only from FormatTime() in the default value of
///     sFormat. Character codes that apply to calendar Times are still valid.
/// @note See the documentation at the top of this file for the list of possible
///     format codes.
string FormatDate(struct Time t, string sFormat = "%x", string sLocale = "");

/// @brief Format a calendar Time into a string.
/// @param t A calendar Time to format. If not a calendar Time, will be
///     converted into one.
/// @param sFormat A string containing format codes to control the output. The
///     default value is equivalent to "%Y-%m-%d %H:%M:%S:%f".
/// @param sLocale The name of the locale to use when formatting the Time. If
///     "", will use the default locale.
/// @note This function differs only from FormatTime() in the default value of
///     sFormat. Character codes that apply to calendar Times are still valid.
/// @note See the documentation at the top of this file for the list of possible
///     format codes.
string FormatDateTime(struct Time t, string sFormat = "%c", string sLocale = "");

/// @brief Format a duration Time into a string.
/// @param t The duration Time to format. If not a duration Time, will be
///     converted into one.
/// @param sFormat A string containing format codes to control the output. The
///     default value is equivalent to ISO 8601 format preceded by the sign of
///     t (`-` if negative, `+` otherwise).
/// @param sLocale The name of the locale to use when formatting the duration.
///     If "", will use the default locale.
/// @note See the documentation at the top of this file for the list of possible
///     format codes.
string FormatDuration(struct Time t, string sFormat = "%+Y-%m-%d %H:%M:%S:%f", string sLocale = "");

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

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

    return JsonObjectSet(j, LOCALE_ERAS, JsonArray());
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
    return JsonObjectSet(jEra, ERA_OFFSET,      JsonInt(nOffset));
}

json AddEra(json jLocale, json jEra)
{
    json jEras = JsonObjectGet(jLocale, LOCALE_ERAS);
    if (JsonGetType(jEras) != JSON_TYPE_ARRAY)
        jEras = JsonArray();

    jEras = JsonArrayInsert(jEras, jEra);
    return JsonObjectSet(jLocale, LOCALE_ERAS, jEras);
}

json GetEra(json jLocale, struct Time t)
{
    if (t.Type == TIME_TYPE_DURATION)
        return JsonNull();

    json  jEras = JsonObjectGet(jLocale, LOCALE_ERAS);
    json  jEra; // The closest era to the Time
    struct Time tEra; // The start Time of jEra
    int i, nLength = JsonGetLength(jEras);

    for (i = 0; i < nLength; i++)
    {
        json jCmp = JsonArrayGet(jEras, i);
        struct Time tCmp = JsonToTime(JsonObjectGet(jCmp, ERA_START));
        switch (CompareTime(t, tCmp))
        {
            case 0: return jCmp;
            case 1:
            {
                if (CompareTime(tCmp, tEra) >= 0)
                {
                    tEra = tCmp;
                    jEra = jCmp;
                }
            }
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

string strftime(struct Time t, string sFormat, string sLocale)
{
    int  nOffset, nPos;
    int  nSign   = GetTimeSign(t);
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
        // this is a calendar Time or duration Time. Durations cannot use time
        // codes that only make sense in the context of a calendar Time.
        int nFormat = FindSubString(TIME_FORMAT_CHARS, sChar, t.Type ? 0 : DURATION_FORMAT_OFFSET);
        switch (nFormat)
        {
            case -1:
            {
                string sError = GetStringSlice(sFormat, nOffset, nPos);
                string sColored = GetStringSlice(sFormat, 0, nOffset - 1) +
                                  HexColorString(sError, COLOR_RED) +
                                  GetStringSlice(sFormat, nPos + 1);
                Error("Illegal time format \"" + sError + "\": " + sColored);
                sFormat = ReplaceSubString(sFormat, "%" + sError, nOffset, nPos);
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
                        sFormat = ReplaceSubString(sFormat, sValue, nOffset, nPos);
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
                sFormat = ReplaceSubString(sFormat, "%m/%d/%y", nOffset, nPos);
                continue;
            case TIME_FORMAT_DATE_ISO: // %F
                sFormat = ReplaceSubString(sFormat, "%Y-%m-%d", nOffset, nPos);
                continue;
            case TIME_FORMAT_TIME_US: // %R
                sFormat = ReplaceSubString(sFormat, "%H:%M", nOffset, nPos);
                continue;
            case TIME_FORMAT_TIME_ISO: // %T
                sFormat = ReplaceSubString(sFormat, "%H:%M:%S", nOffset, nPos);
                continue;
            case TIME_FORMAT_LOCALE_DATETIME: // %c, %Ec
                if (nFlags & TIME_FLAG_ERA)
                    sValue = GetEraString(jEra, jLocale, ERA_DATETIME_FORMAT);
                else
                    sValue = GetLocaleString(jLocale, LOCALE_DATETIME_FORMAT, DEFAULT_DATETIME_FORMAT);
                sFormat = ReplaceSubString(sFormat, sValue, nOffset, nPos);
                continue;
            case TIME_FORMAT_LOCALE_DATE: // %x, %Ex
                if (nFlags & TIME_FLAG_ERA)
                    sValue = GetEraString(jEra, jLocale, ERA_DATE_FORMAT);
                else
                    sValue = GetLocaleString(jLocale, LOCALE_DATE_FORMAT, DEFAULT_DATE_FORMAT);
                sFormat = ReplaceSubString(sFormat, sValue, nOffset, nPos);
                continue;
            case TIME_FORMAT_LOCALE_TIME: // %c, %Ec
                if (nFlags & TIME_FLAG_ERA)
                    sValue = GetEraString(jEra, jLocale, ERA_TIME_FORMAT);
                else
                    sValue = GetLocaleString(jLocale, LOCALE_TIME_FORMAT, DEFAULT_TIME_FORMAT);
                sFormat = ReplaceSubString(sFormat, sValue, nOffset, nPos);
                continue;
            case TIME_FORMAT_LOCALE_TIME_AMPM: // %r
                sValue = GetLocaleString(jLocale, LOCALE_AMPM_FORMAT, DEFAULT_AMPM_FORMAT);
                sFormat = ReplaceSubString(sFormat, sValue, nOffset, nPos);
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
            sFormat = ReplaceSubString(sFormat, "%" + sPadding + "s", nOffset, nPos);
        }
        else
        {
            if (nFlags & TIME_FLAG_SIGN)
                sValue = nSign < 0 ? "-" : "+";

            if (nFlags & TIME_FLAG_COMMAS)
                sPadding = "," + sPadding;

            jValues = JsonArrayInsert(jValues, JsonInt(abs(nValue)));
            sFormat = ReplaceSubString(sFormat, sValue + "%" + sPadding + "d", nOffset, nPos);
        }

        // Continue parsing from the end of the format string
        nOffset = nPos + GetStringLength(sPadding);
    }

    // Interpolate the values
    return FormatValues(jValues, sFormat);
}

string FormatTime(struct Time t, string sFormat = "%X", string sLocale = "")
{
    return strftime(DurationToTime(t), sFormat, sLocale);
}

string FormatDate(struct Time t, string sFormat = "%x", string sLocale = "")
{
    return strftime(DurationToTime(t), sFormat, sLocale);
}

string FormatDateTime(struct Time t, string sFormat = "%c", string sLocale = "")
{
    return strftime(DurationToTime(t), sFormat, sLocale);
}

string FormatDuration(struct Time t, string sFormat = "%+Y-%m-%d %H:%M:%S:%f", string sLocale = "")
{
    return strftime(TimeToDuration(t), sFormat, sLocale);
}
