#include "util_i_math"
#include "util_i_strings"
#include "util_i_lists"
#include "util_i_debug"

#include "util_c_times"

// -----------------------------------------------------------------------------
//                                     Types
// -----------------------------------------------------------------------------

/// @details This represents a calendar time, so the month and day count from 1.
/// Note that the year still counts from 0, since NWN allows year 0. If a unit
/// overflows it range, it is added to the next highest number. Negative numbers
/// are not allowed. After normalization, an invalid time will equal
/// "0000-00-00 00:00:000".
struct Time
{
    int Year;        // 0..32000
    int Month;       // 1..12
    int Day;         // 1..28
    int Hour;        // 0..23
    int Minute;      // 0.._MinsPerHour
    int Second;      // 0..59
    int Millisecond; // 0..999
    int MinsPerHour; // 1..60
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
const string TIME_FLAG_CHARS = "EO^-_ 0123456789";

// These are the characters allowed in time format codes.
const string TIME_FORMAT_CHARS = "aAbBpPIljwu+CyYmdeHkMSfDFRTcxXr%";

// Begin time-only constants. It is an error to use these with a duration.
const int TIME_FORMAT_NAME_OF_DAY_ABBR   = 0; // a: Mon..Sun
const int TIME_FORMAT_NAME_OF_DAY_LONG   = 1; // A: Monday..Sunday
const int TIME_FORMAT_NAME_OF_MONTH_ABBR = 2; // b: Jan..Dec
const int TIME_FORMAT_NAME_OF_MONTH_LONG = 3; // B: January..December
const int TIME_FORMAT_AMPM_UPPER         = 4; // p: AM..PM
const int TIME_FORMAT_AMPM_LOWER         = 5; // P: am..pm
const int TIME_FORMAT_HOUR_12            = 6; // I: 01..12
const int TIME_FORMAT_HOUR_12_SPACE_PAD  = 7; // l: alias for %_I
const int TIME_FORMAT_DAY_OF_YEAR        = 8; // j: 001..336
const int TIME_FORMAT_DAY_OF_WEEK_0_6    = 9; // w: weekdays 0..6
const int TIME_FORMAT_DAY_OF_WEEK_1_7    = 10; // u: weekdays 1..7
// End time-only constants. The following can be used with times or durations.
const int TIME_FORMAT_SIGN               = 11; // +: "+" if duration positive, "-" if negative
const int TIME_FORMAT_YEAR_CENTURY       = 12; // C: 0..320
const int TIME_FORMAT_YEAR_SHORT         = 13; // y: 00..99
const int TIME_FORMAT_YEAR_LONG          = 14; // Y: 0..320000
const int TIME_FORMAT_MONTH              = 15; // m: 01..12
const int TIME_FORMAT_DAY                = 16; // d: 01..28
const int TIME_FORMAT_DAY_SPACE_PAD      = 17; // e: alias for %_d
const int TIME_FORMAT_HOUR_24            = 18; // H: 00..23
const int TIME_FORMAT_HOUR_24_SPACE_PAD  = 19; // k: alias for %_H
const int TIME_FORMAT_MINUTE             = 20; // M: 00..59 (depending on conversion factor)
const int TIME_FORMAT_SECOND             = 21; // S: 00..59
const int TIME_FORMAT_MILLISECOND        = 22; // f: 000...999
const int TIME_FORMAT_DATE_US            = 23; // D: 06/01/72
const int TIME_FORMAT_DATE_ISO           = 24; // F: 1372-06-01
const int TIME_FORMAT_TIME_US            = 25; // R: 13:00
const int TIME_FORMAT_TIME_ISO           = 26; // T: 13:00:00
const int TIME_FORMAT_LOCALE_DATETIME    = 27; // c: locale-specific date and time
const int TIME_FORMAT_LOCALE_DATE        = 28; // x: locale-specific date
const int TIME_FORMAT_LOCALE_TIME        = 29; // X: locale-specific time
const int TIME_FORMAT_LOCALE_TIME_AMPM   = 30; // r: locale-specific AM/PM time
const int TIME_FORMAT_PERCENT            = 31; // %: %

// Time format codes with an index less than this number are not valid for
// durations.
const int DURATION_FORMAT_OFFSET = TIME_FORMAT_SIGN;

// ----- VarNames --------------------------------------------------------------

// Prefix for locale names stored on the module to avoid collision
const string LOCALE_PREFIX = "*Locale: ";

// Stores the default locale on the module
const string LOCALE_DEFAULT = "*DefaultLocale";

// Prefix for keys based on eras
const string LOCALE_ERA = "Era";

// Each of these keys stores a CSV list which is evaluated by a format code
const string LOCALE_DAYS        = "Days";       // day names (%A)
const string LOCALE_DAYS_ABBR   = "DaysAbbr";   // abbreviated day names (%a)
const string LOCALE_MONTHS      = "Months";     // month names (%B)
const string LOCALE_MONTHS_ABBR = "MonthsAbbr"; // abbreviated month names (%b)
const string LOCALE_AMPM        = "AMPM";       // AM/PM elements (%p and %P)

// Each of these keys stores a locale-specific format string which is aliased by
// a format code.
const string LOCALE_FORMAT_DATETIME  = "DateTimeFormat"; // %c
const string LOCALE_FORMAT_DATE      = "DateFormat";     // %x
const string LOCALE_FORMAT_TIME      = "TimeFormat";     // %X
const string LOCALE_FORMAT_TIME_AMPM = "TimeFormatAMPM"; // %r

// Each of these keys stores a locale-specific era-based format string which is
// aliased by a format code using the `E` modifier. If no string is stored at
// this key, it will resolve to the non-era based format above.
const string LOCALE_FORMAT_ERA_DATETIME = "EraDateTimeFormat"; // %Ec
const string LOCALE_FORMAT_ERA_DATE     = "EraDateFormat";     // %Ex
const string LOCALE_FORMAT_ERA_TIME     = "EraTimeFormat";     // %EX

// Key for Eras json array. Each element of the array is a json object having
// the three keys below.
const string LOCALE_ERAS = "Eras";

// Key for era name. Aliased by %EC.
const string ERA_NAME = "Name";

// Key for a format string for the year in the era. Aliased by %EY.
const string ERA_FORMAT = "Format";

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

int YearsToDays(int nYears);


int MonthsToDays(int nMonths);


float Years(int nYears = 1);


float Months(int nMonths = 1);


float Days(int nDays = 1);


float Hours(int nHours = 1);


float Minutes(int nMinutes = 1);


float Seconds(int nSeconds = 1);


float Milliseconds(int nMilliseconds = 1);


int HoursToMinutes(int nHours = 1);

// ----- Times -----------------------------------------------------------------

struct Time NormalizeTime(struct Time t, int nMinsPerHour = 0);


int GetIsTimeValid(struct Time t);


struct Time GetTime(int nYear = 0, int nMonth = 1, int nDay = 1, int nHour = 0, int nMinute = 0, int nSecond = 0, int nMillisecond = 0, int nMinsPerHour = 0);


struct Time TimeToGameTime(struct Time t);


struct Time GameTimeToTime(struct Time t);


struct Time GetCurrentTime();


struct Time GetCurrentGameTime();


void SetCurrentTime(struct Time t);


void AdvanceCurrentTime(float fSeconds);


struct Time GetPrecisionTime(struct Time t, int nUnit);


// ----- Durations -------------------------------------------------------------

struct Time DurationToTime(float fDur);


float GetTimeInterval(struct Time a, struct Time b, int bNormalize = TRUE);


float GetTimeSince(struct Time tSince, int bNormalize = TRUE);


float GetTimeUntil(struct Time tUntil, int bNormalize = TRUE);


int GetIsTimeAfter(struct Time a, struct Time b, int bNormalize = TRUE);


int GetIsTimeBefore(struct Time a, struct Time b, int bNormalize = TRUE);


int GetIsTimeEqual(struct Time a, struct Time b, int bNormalize = TRUE);


struct Time AddTime(struct Time t, float fAdd);


struct Time SubtractTime(struct Time t, float fSub);


// ----- Json Conversion -------------------------------------------------------

json TimeToJsonArray(struct Time t, int bNormalize = TRUE);

json TimeToJsonObject(struct Time t, int bNormalize = TRUE);

json TimeToJson(struct Time t, int bNormalize = TRUE);


struct Time JsonArrayToTime(json j, int bNormalize = TRUE);

struct Time JsonObjectToTime(json j, int bNormalize = TRUE);

struct Time JsonToTime(json j, int bNormalize = TRUE);

// ----- Locales ---------------------------------------------------------------

string GetLocaleString(json jLocale, string sKey, string sPrefix = "");


json SetLocaleString(json j, string sKey, string sValue);


json NewLocale();


string GetDefaultLocale();


void SetDefaultLocale(string sName = DEFAULT_LOCALE);


json GetLocale(string sLocale = "", int bInit = TRUE);


void SetLocale(json jLocale, string sLocale = "");


void DeleteLocale(string sLocale = "");


int HasLocale(string sLocale = "");


string MonthToString(int nMonth, string sMonths = "", string sLocale = "");


string DayToString(int nDay, string sDays = "", string sLocale = "");


// ----- Eras ------------------------------------------------------------------

json DefineEra(string sName, struct Time tStart, int nOffset = 0, string sFormat = "%Ey %EC");


json AddEra(json jLocale, json jEra);


json GetEra(json jLocale, struct Time t);


int GetEraYear(json jEra, int nYear);


// ----- Formatting ------------------------------------------------------------

string TimeToString(struct Time t, int bNormalize = TRUE);


string DurationToString(float fDur, int bShowSignIfPos = TRUE);


struct Time StringToTime(string sTime, int nMinsPerHour = 0);


string IntToOrdinalString(int n, string sSuffixes = "th, st, nd, rd, th, th, th, th, th, th, th, th, th, th");


string FormatTime(struct Time t, string sFormat = "%X", string sLocale = "");


string FormatDate(struct Time t, string sFormat = "%x", string sLocale = "");


string FormatDateTime(struct Time t, string sFormat = "%c", string sLocale = "");


string FormatDuration(float fDur, string sFormat = "%+%Y-%m-%d %H:%M:%S:%f", string sLocale = "");

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

// ----- Conversions -----------------------------------------------------------

int YearsToDays(int nYears)
{
    return nYears * 336;
}

int MonthsToDays(int nMonths)
{
    return nMonths * 28;
}

float Years(int nYears = 1)
{
    return HoursToSeconds(nYears * 12 * 28 * 24);
}

float Months(int nMonths = 1)
{
    return HoursToSeconds(nMonths * 28 * 24);
}

float Days(int nDays = 1)
{
    return HoursToSeconds(nDays * 24);
}

float Hours(int nHours = 1)
{
    return HoursToSeconds(nHours);
}

float Minutes(int nMinutes = 1)
{
    return nMinutes * 60.0;
}

float Seconds(int nSeconds = 1)
{
    return IntToFloat(nSeconds);
}

float Milliseconds(int nMilliseconds = 1)
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
    return (t.Year < 0 || t.Year > 32000) ? tInvalid : t;
}

int GetIsTimeValid(struct Time t)
{
    struct Time tInvalid;
    return NormalizeTime(t) != tInvalid;
}

struct Time GetTime(int nYear = 0, int nMonth = 1, int nDay = 1, int nHour = 0, int nMinute = 0, int nSecond = 0, int nMillisecond = 0, int nMinsPerHour = 0)
{
    if (nMinsPerHour <= 0)
        nMinsPerHour = HoursToMinutes();

    struct Time t;
    t.Year        = nYear;
    t.Month       = nMonth;
    t.Day         = nDay;
    t.Hour        = nHour;
    t.Minute      = nMinute;
    t.Second      = nSecond;
    t.Millisecond = nMillisecond;
    t.MinsPerHour = nMinsPerHour;
    return NormalizeTime(t, clamp(t.MinsPerHour, 1, 60));
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
        struct Time t = AddTime(GetCurrentTime(), fSeconds);
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
            case TIME_UNIT_MONTH:       t.Month       = 0; break;
            case TIME_UNIT_DAY:         t.Day         = 0; break;
            case TIME_UNIT_HOUR:        t.Hour        = 0; break;
            case TIME_UNIT_MINUTE:      t.Minute      = 0; break;
            case TIME_UNIT_SECOND:      t.Second      = 0; break;
            case TIME_UNIT_MILLISECOND: t.Millisecond = 0; break;
        }
    }

    return t;
}

// ----- Durations -------------------------------------------------------------

struct Time DurationToTime(float fDur)
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

float GetTimeInterval(struct Time a, struct Time b, int bNormalize = TRUE)
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

float GetTimeSince(struct Time tSince, int bNormalize = TRUE)
{
    return GetTimeInterval(tSince, GetCurrentTime(), bNormalize);
}

float GetTimeUntil(struct Time tUntil, int bNormalize = TRUE)
{
    // We do this backwards to ensure we normalize to tUntil.MinsPerHour
    return GetTimeInterval(tUntil, GetCurrentTime(), bNormalize) * -1;
}

int GetIsTimeAfter(struct Time a, struct Time b, int bNormalize = TRUE)
{
    return GetIsTimeValid(b) && GetTimeInterval(a, b, bNormalize) < 0.0;
}

int GetIsTimeBefore(struct Time a, struct Time b, int bNormalize = TRUE)
{
    return GetIsTimeValid(a) && GetTimeInterval(a, b, bNormalize) > 0.0;
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

struct Time AddTime(struct Time t, float fAdd)
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

struct Time SubtractTime(struct Time t, float fSub)
{
    return AddTime(t, fSub * -1);
}

// ----- Json Conversion -------------------------------------------------------

json TimeToJsonArray(struct Time t, int bNormalize = TRUE)
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
    return j;
}

struct Time JsonArrayToTime(json j, int bNormalize = TRUE)
{
    struct Time t;
    if (JsonGetType(j) != JSON_TYPE_ARRAY)
        return t;

    int i;
    t.Year        = JsonGetInt(JsonArrayGet(j, i++));
    t.Month       = JsonGetInt(JsonArrayGet(j, i++));
    t.Day         = JsonGetInt(JsonArrayGet(j, i++));
    t.Hour        = JsonGetInt(JsonArrayGet(j, i++));
    t.Minute      = JsonGetInt(JsonArrayGet(j, i++));
    t.Second      = JsonGetInt(JsonArrayGet(j, i++));
    t.Millisecond = JsonGetInt(JsonArrayGet(j, i++));
    return bNormalize ? NormalizeTime(t) : t;
}

json TimeToJsonObject(struct Time t, int bNormalize = TRUE)
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

struct Time JsonObjectToTime(json j, int bNormalize = TRUE)
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

    return bNormalize ? NormalizeTime(t) : t;
}

json TimeToJson(struct Time t, int bNormalize = TRUE)
{
    return TimeToJsonObject(t, bNormalize);
}

struct Time JsonToTime(json j, int bNormalize = TRUE)
{
    struct Time t;
    switch (JsonGetType(j))
    {
        case JSON_TYPE_OBJECT: return JsonObjectToTime(j, bNormalize);
        case JSON_TYPE_ARRAY:  return JsonArrayToTime (j, bNormalize);
    }

    return t;
}

// ----- Locales ---------------------------------------------------------------

string GetLocaleString(json jLocale, string sKey, string sPrefix = "")
{
    json jElem = JsonObjectGet(jLocale, sPrefix + sKey);
    if (JsonGetType(jElem) == JSON_TYPE_STRING && JsonGetString(jElem) != "")
        return JsonGetString(jElem);

    return JsonGetString(JsonObjectGet(jLocale, sKey));
}

json SetLocaleString(json j, string sKey, string sValue)
{
    return JsonObjectSet(j, sKey, JsonString(sValue));
}

json NewLocale()
{
    json j = JsonObject();
    j = SetLocaleString(j, LOCALE_DAYS,             DEFAULT_DAYS);
    j = SetLocaleString(j, LOCALE_DAYS_ABBR,        DEFAULT_DAYS_ABBR);
    j = SetLocaleString(j, LOCALE_MONTHS,           DEFAULT_MONTHS);
    j = SetLocaleString(j, LOCALE_MONTHS_ABBR,      DEFAULT_MONTHS_ABBR);
    j = SetLocaleString(j, LOCALE_AMPM,             DEFAULT_AMPM);
    j = SetLocaleString(j, LOCALE_FORMAT_DATETIME,  DEFAULT_FORMAT_DATETIME);
    j = SetLocaleString(j, LOCALE_FORMAT_DATE,      DEFAULT_FORMAT_DATE);
    j = SetLocaleString(j, LOCALE_FORMAT_TIME,      DEFAULT_FORMAT_TIME);
    j = SetLocaleString(j, LOCALE_FORMAT_TIME_AMPM, DEFAULT_FORMAT_TIME_AMPM);

    j = JsonObjectSet(j, LOCALE_ERAS, JsonArray());

    return j;
}

string GetDefaultLocale()
{
    string sLocale = GetLocalString(GetModule(), LOCALE_DEFAULT);
    if (sLocale == "")
    {
        sLocale = DEFAULT_LOCALE;
        SetLocalString(GetModule(), LOCALE_DEFAULT, sLocale);
    }

    return sLocale;
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
    {
        j = NewLocale();
        SetLocalJson(GetModule(), LOCALE_PREFIX + sLocale, j);
    }

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

json DefineEra(string sName, struct Time tStart, int nOffset = 0, string sFormat = "%Ey %EC")
{
    json jEra = JsonObject();
    jEra = JsonObjectSet(jEra, ERA_NAME,   JsonString(sName));
    jEra = JsonObjectSet(jEra, ERA_FORMAT, JsonString(sFormat));
    jEra = JsonObjectSet(jEra, ERA_START,  TimeToJson(tStart));
    jEra = JsonObjectSet(jEra, ERA_OFFSET, JsonInt(nOffset));
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

        float fCmp = GetTimeInterval(tCmp, t);
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

// ----- Formatting ------------------------------------------------------------

string TimeToString(struct Time t, int bNormalize = TRUE)
{
    json j = TimeToJsonArray(t, bNormalize);
    return FormatValues(j, "%04d-%02d-%02d %02d:%02d:%02d:%03d");
}

string DurationToString(float fDur, int bShowSignIfPos = TRUE)
{
    struct Time t = DurationToTime(fabs(fDur));
    return (fDur < 0.0 ? "-" : bShowSignIfPos ? "+" : "") + TimeToString(t, FALSE);
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
            return sChar == "" ? t : tInvalid;
    }

    return t;
}

string IntToOrdinalString(int n, string sSuffixes = "th, st, nd, rd, th, th, th, th, th, th, th, th, th, th")
{ //                                                 0   1   2   3   4   5   6   7   8   9   10  11  12  13
    int nIndex = abs(n) % 100;
    if (nIndex >= CountList(sSuffixes))
        nIndex = abs(n) % 10;

    return IntToString(n) + GetListItem(sSuffixes, nIndex);
}

// Private function for FormatTime() and FormatInterval(). To reduce code
// duplication, we convert everything to a Time when formatting. If we are
// actually trying to format a duration, we disable some format codes that only
// make sense in the context of a time.
string _FormatTime(struct Time t, string sFormat, string sLocale, int nDur = 0, int bDur = FALSE)
{
    int  nOffset, nPos;
    json jValues = JsonArray();
    json jLocale = GetLocale(sLocale);
    json jEra    = GetEra(jLocale, t);
    Notice("Era: " + JsonDump(jEra));

    while ((nPos = FindSubString(sFormat, "%", nOffset)) != -1)
    {
        // Notice("strftime sFormat=\"" + sFormat + "\" nOffset=" + IntToString(nOffset) + " nPos=" + IntToString(nPos));
        nOffset = nPos;

        // Check for flags
        int bEra, bOrdinal, bNoPad, bUpper, nFlag, bAllowEmpty;
        string sPadding, sWidth, sChar;

        while ((nFlag = FindSubString(TIME_FLAG_CHARS, (sChar = GetChar(sFormat, ++nPos)))) != -1)
        {
            // Notice("FormatTime sFormat=\"" + sFormat + "\" " +
            //        "nOffset=" + IntToString(nOffset) + " " +
            //        "nPos=" + IntToString(nPos) + " " +
            //        "sChar=\"" + sChar + "\" " +
            //        "nFlag=" + IntToString(nFlag));
            switch (nFlag)
            {
                case 0: bEra     = TRUE; break;
                case 1: bOrdinal = TRUE; break;
                case 2: bUpper   = TRUE; break;
                case 3: bNoPad   = TRUE; break;
                case 4:
                case 5: sPadding = " ";  break;
                case 6: sPadding = "0";  break;
                default:
                {
                    // The user has specified an amount of padding
                    while (GetIsNumeric(sChar))
                    {
                        sWidth += sChar;
                        sChar = GetChar(sFormat, ++nPos);
                        // Notice("FormatTime sFormat=\"" + sFormat + "\" " +
                        //        "nOffset=" + IntToString(nOffset) + " " +
                        //        "nPos=" + IntToString(nPos) + " " +
                        //        "sChar=\"" + sChar + "\" " +
                        //        "sWidth=\"" + sWidth + "\"");
                    }

                    nPos--;
                }
            }
        }

        string sValue;
        int nValue;
        int nPadding = 2; // Most numeric formats use this

        // We offset where we start looking for format codes based on whether
        // this is a Time or Duration. Durations cannot use time codes that only
        // make sense in the context of a Time.
        int nFormat = FindSubString(TIME_FORMAT_CHARS, sChar, bDur ? DURATION_FORMAT_OFFSET : 0);

        // Notice("Got char: " + sChar + " (" + IntToString(nFormat) +")");
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
                // sValue = nDur < 0 ? "-" : "+";
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
                sValue = GetLocaleString(jLocale, LOCALE_AMPM);
                sValue = GetListItem(sValue, t.Hour % 24 >= 12);
                if (nFormat == TIME_FORMAT_AMPM_LOWER)
                    sValue = GetStringLowerCase(sValue);
                break;
            case TIME_FORMAT_NAME_OF_DAY_LONG: // %A
                sValue = DayToString(t.Day, GetLocaleString(jLocale, LOCALE_DAYS));
                break;
            case TIME_FORMAT_NAME_OF_DAY_ABBR: // %a
                sValue = DayToString(t.Day, GetLocaleString(jLocale, LOCALE_DAYS_ABBR));
                break;
            case TIME_FORMAT_NAME_OF_MONTH_LONG: // %B
                sValue = MonthToString(t.Month, GetLocaleString(jLocale, LOCALE_MONTHS));
                break;
            case TIME_FORMAT_NAME_OF_MONTH_ABBR: // %b
                sValue = MonthToString(t.Month, GetLocaleString(jLocale, LOCALE_MONTHS_ABBR));
                break;

            // We handle literal % here instead of replacing it directly because
            // we want the user to be able to pad it if desired.
            case TIME_FORMAT_PERCENT: // %%
                sValue = "%";
                break;

            case TIME_FORMAT_YEAR_CENTURY: // %C, %EC
                if (bEra)
                    sValue = JsonGetString(JsonObjectGet(jEra, ERA_NAME));
                nValue = t.Year / 100;
                break;
            case TIME_FORMAT_YEAR_SHORT: // %y, %Ey
                nValue = bEra ? GetEraYear(jEra, t.Year) : t.Year % 100;
                break;

            case TIME_FORMAT_YEAR_LONG: // %Y, %EY
                if (bEra)
                {
                    sValue = JsonGetString(JsonObjectGet(jEra, ERA_FORMAT));
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
                sValue = GetLocaleString(jLocale, LOCALE_FORMAT_DATETIME, bEra ? LOCALE_ERA : "");
                sFormat = ReplaceSubString(sFormat, sValue, nOffset, nPos + 1);
                continue;
            case TIME_FORMAT_LOCALE_DATE: // %x, %Ex
                sValue = GetLocaleString(jLocale, LOCALE_FORMAT_DATE, bEra ? LOCALE_ERA : "");
                sFormat = ReplaceSubString(sFormat, sValue, nOffset, nPos + 1);
                continue;
            case TIME_FORMAT_LOCALE_TIME: // %c, %Ec
                sValue = GetLocaleString(jLocale, LOCALE_FORMAT_TIME, bEra ? LOCALE_ERA : "");
                sFormat = ReplaceSubString(sFormat, sValue, nOffset, nPos + 1);
                continue;
            case TIME_FORMAT_LOCALE_TIME_AMPM: // %r
                sValue = GetLocaleString(jLocale, LOCALE_FORMAT_TIME_AMPM);
                sFormat = ReplaceSubString(sFormat, sValue, nOffset, nPos + 1);
                continue;
        }

        if ((sValue == "" && !bAllowEmpty) && bOrdinal)
            sValue = IntToOrdinalString(nValue);

        if (bNoPad)
            sPadding = "";
        else if (sValue != "" || bAllowEmpty)
            sPadding = " " + sWidth;
        else
        {
            sPadding = sPadding != "" ? sPadding : "0";
            sPadding += sWidth != "" ? sWidth : IntToString(nPadding);
        }

        if (sValue != "" || bAllowEmpty)
        {
            if (bUpper)
                sValue = GetStringUpperCase(sValue);
            jValues = JsonArrayInsert(jValues, JsonString(sValue));
            sFormat = ReplaceSubString(sFormat, "%" + sPadding + "s", nOffset, nPos + 1);
        }
        else
        {
            jValues = JsonArrayInsert(jValues, JsonInt(nValue));
            sFormat = ReplaceSubString(sFormat, "%" + sPadding + "d", nOffset, nPos + 1);
        }

        // Notice("strftime post-loop sFormat=\"" + sFormat + "\" nOffset=" + IntToString(nOffset) + " nPos=" + IntToString(nPos));

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

string FormatDuration(float fDur, string sFormat = "%+%Y-%m-%d %H:%M:%S:%f", string sLocale = "")
{
    return _FormatTime(DurationToTime(fabs(fDur)), sFormat, sLocale, fsign(fDur), TRUE);
}
