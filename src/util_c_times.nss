// -----------------------------------------------------------------------------
//    File: util_c_times.nss
//  System: Utilities (configuration script)
//     URL: https://github.com/squattingmonk/sm-utils
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// This script contains configuration settings for util_i_times.nss.
//
// You can change the values of any of constants below, but do not change the
// names of the constants themselves. You can also add your own constants for
// use in your module.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                                     Names
// -----------------------------------------------------------------------------

// This is a 12-element comma-separated list of month names. `%B` evaluates to
// the item at index `(month - 1) % 12`.
const string DEFAULT_MONTHS = "January, February, March, April, May, June, July, August, September, October, November, December";

// This is a 12-element comma-separated list of abbreviated month names. `%b`
// evaluates to the item at index `(month - 1) % 12`.
const string DEFAULT_MONTHS_ABBR = "Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec";

// This is a 7-element comma-separated list of weekday names. `%A` evaluates to
// the item at index `(day - 1) % 7`.
const string DEFAULT_DAYS = "Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday";

// This is a 7-element comma-separated list of abbreviated day names. `%a`
// evaluates to the item at index `(day - 1) % 7`.
const string DEFAULT_DAYS_ABBR = "Mon, Tue, Wed, Thu, Fri, Sat, Sun";

// This is a 2-element comma-separated list with the preferred representation of
// AM/PM. Noon is treated as PM and midnight is treated as AM. Evaluated by `%p`
// (uppercase) and `%P` (lowercase).
const string DEFAULT_AMPM = "AM, PM";

// -----------------------------------------------------------------------------
//                                  Formatting
// -----------------------------------------------------------------------------
// These are strings that are used to format dates and times. Refer to the
// comments on `FormatTime()` in util_i_times for the meaning of format codes.
// Some codes are aliases for these values, so take care to avoid using those
// codes in these values to prevent an infinite loop.
// -----------------------------------------------------------------------------

// This is a string used to format a date and time. Aliased by `%c`.
const string DEFAULT_FORMAT_DATETIME = "%Y-%m-%d %H:%M:%S:%f";

// This is a string used to format a date without the time. Aliased by `%x`.
const string DEFAULT_FORMAT_DATE = "%Y-%m-%d";

// This is a string used to format a time without the date. Aliased by `%X`.
const string DEFAULT_FORMAT_TIME = "%H:%M:%S";

// This is a string used to format a time using AM/PM. Aliased by `%r`.
const string DEFAULT_FORMAT_TIME_AMPM = "%I:%M:%S %p";




const string DEFAULT_LOCALE = "en";
