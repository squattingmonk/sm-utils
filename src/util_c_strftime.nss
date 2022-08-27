/// ----------------------------------------------------------------------------
/// @file   util_c_strftime.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Configuration settings for util_i_strftime.nss.
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                                    Locale
// -----------------------------------------------------------------------------
// A locale is a group of localization settings stored as key-value pairs on a
// json object which is then stored on the module and accessed by a name. Some
// functions can take a locale name as an optional parameter so they can access
// those settings. If no name is provided, those functions will use the default
// locale instead.
// -----------------------------------------------------------------------------

/// This is the name for the default locale. All settings below will apply to
/// this locale.
const string DEFAULT_LOCALE = "EN_US";

// -----------------------------------------------------------------------------
//                                 Translations
// -----------------------------------------------------------------------------

/// This is a 12-element comma-separated list of month names. `%B` evaluates to
/// the item at index `(month - 1) % 12`.
const string DEFAULT_MONTHS = "January, February, March, April, May, June, July, August, September, October, November, December";

/// This is a 12-element comma-separated list of abbreviated month names. `%b`
/// evaluates to the item at index `(month - 1) % 12`.
const string DEFAULT_MONTHS_ABBR = "Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec";

/// This is a 7-element comma-separated list of weekday names. `%A` evaluates to
/// the item at index `(day - 1) % 7`.
const string DEFAULT_DAYS = "Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday";

/// This is a 7-element comma-separated list of abbreviated day names. `%a`
/// evaluates to the item at index `(day - 1) % 7`.
const string DEFAULT_DAYS_ABBR = "Mon, Tue, Wed, Thu, Fri, Sat, Sun";

/// This is a 2-element comma-separated list with the preferred representation
/// of AM/PM. Noon is treated as PM and midnight is treated as AM. Evaluated by
/// `%p` (uppercase) and `%P` (lowercase).
const string DEFAULT_AMPM = "AM, PM";

/// This is a comma-separated list of suffixes for ordinal numbers. The list
/// should start with the suffix for 0. When formatting using the ordinal flag
/// (e.g., "Today is the %Od day of %B"), the number being formatted is used as
/// an index into this list. If the last two digits of the number are greater
/// than or equal to the length of the list, only the last digit of the number
/// is used. The default value will handle all integers in English.
const string DEFAULT_ORDINAL_SUFFIXES = "th, st, nd, rd, th, th, th, th, th, th, th, th, th, th";
//                                       0   1   2   3   4   5   6   7   8   9   10  11  12  13

// -----------------------------------------------------------------------------
//                                  Formatting
// -----------------------------------------------------------------------------
// These are strings that are used to format dates and times. Refer to the
// comments in `util_i_strftime.nss` for the meaning of format codes. Some codes
// are aliases for these values, so take care to avoid using those codes in
// these values to prevent an infinite loop.
// -----------------------------------------------------------------------------

/// This is a string used to format a date and time. Aliased by `%c`.
const string DEFAULT_DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S:%f";

/// This is a string used to format a date without the time. Aliased by `%x`.
const string DEFAULT_DATE_FORMAT = "%Y-%m-%d";

/// This is a string used to format a time without the date. Aliased by `%X`.
const string DEFAULT_TIME_FORMAT = "%H:%M:%S";

/// This is a string used to format a time using AM/PM. Aliased by `%r`.
const string DEFAULT_AMPM_FORMAT = "%I:%M:%S %p";

/// This is a string used to format a date and time when era-based formatting is
/// used. If "", will fall back to DEFAULT_DATETIME_FORMAT. Aliased by `%Ec`.
const string DEFAULT_ERA_DATETIME_FORMAT = "";

/// This is a string used to format a date without the time when era-based
/// formatting is used. If "", will fall back to DEFAULT_DATE_FORMAT. Aliased by
/// `%Ex`.
const string DEFAULT_ERA_DATE_FORMAT = "";

/// This is a string used to format a time without the date when era-based
/// formatting is used. If "", will fall back to DEFAULT_TIME_FORMAT. Aliased by
/// `%EX`.
const string DEFAULT_ERA_TIME_FORMAT = "";

/// This is a string used to format years when era-based formatting is used. If
/// "", will always use the current year. Aliased by `%EY`.
const string DEFAULT_ERA_YEAR_FORMAT = "%Ey %EC";

/// This is a string used to format the era name when era-based formatting is
/// used. Normally, each era has its own name, but setting this can allow you
/// to display an era name even if you don't set up any eras for your locale.
const string DEFAULT_ERA_NAME = "";
