// -----------------------------------------------------------------------------
//    File: util_i_strings.nss
//  System: Utilities (include script)
//     URL: https://github.com/squattingmonk/nwn-core-framework
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// This file holds utility functions for manipulating strings.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

const string CHARSET_NUMERIC = "0123456789";
const string CHARSET_ALPHA = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
const string CHARSET_ALPHA_LOWER = "abcdefghijklmnopqrstuvwxyz";
const string CHARSET_ALPHA_UPPER = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< GetSubStringCount >---
// ---< util_i_strings >---
// Returns the number of occurrences of sSubString within sString.
int GetSubStringCount(string sString, string sSubString);

// ---< FindSubStringN >---
// ---< util_i_strings >---
// Returns the position of the nNth occurrence of sSubString within sString. If
// the substring was not found at least nNth + 1 times, returns -1.
int FindSubStringN(string sString, string sSubString, int nNth = 0);

// ---< GetChar >---
// ---< util_i_strings >---
// Returns the character at index nPos in sString.
string GetChar(string sString, int nPos);

// ---< GetStringSlice >---
// ---< util_i_strings >---
// Returns a substring of sString from index nStart to nEnd. If nEnd is -1, will
// return to the end of the string. Basically a convenience wrapper around
// GetSubString().
string GetStringSlice(string sString, int nStart, int nEnd = -1);

// ---< ReplaceSubString >---
// ---< util_i_strings >---
// Replaces the characters in sString from index nStart to nEnd with sSub.
string ReplaceSubString(string sString, string sSub, int nStart, int nEnd);

// ---< HasSubString >---
// ---< util_i_strings >---
// Returns whether sString contains sSubString after nStart chars.
int HasSubString(string sString, string sSubString, int nStart = 0);

// ---< GetAnyCharsInSet >---
// ---< util_i_strings >---
// Returns whether any characters in sSet are in sString
int GetAnyCharsInSet(string sString, string sSet);

// ---< GetAllCharsInSet >---
// ---< util_i_strings >---
// Returns whether all characters in sString are in sSet.
int GetAllCharsInSet(string sString, string sSet);

// ---< GetIsUpperCase >---
// ---< util_i_strings >---
// Returns whether all letters in sString are upper-case.
int GetIsUpperCase(string sString);

// ---< GetIsLowerCase >---
// ---< util_i_strings >---
// Returns whether all letters x in sString are lower-case.
int GetIsLowerCase(string sString);

// ---< GetIsAlpha >---
// ---< util_i_strings >---
// Returns whether all characters in sString are letters.
int GetIsAlpha(string sString);

// ---< GetIsNumeric >---
// ---< util_i_strings >---
// Returns whether all characters in sString are digits.
int GetIsNumeric(string sString);

// ---< GetIsAlphaNumeric >---
// ---< util_i_strings >---
// Returns whether all characters in sString are letter or digits.
int GetIsAlphaNumeric(string sString);

// ---< TrimStringLeft >---
// ---< util_i_strings >---
// Trims any characters in sRemove from the left side of sString.
string TrimStringLeft(string sString, string sRemove = " ");

// ---< TrimStringRight >---
// ---< util_i_strings >---
// Trims any characters in sRemove from the right side of sString.
string TrimStringRight(string sString, string sRemove = " ");

// ---< TrimString >---
// ---< util_i_strings >---
// Trims any characters in sRemove from the left and right side of sString. This
// can be used to remove leading and trailing whitespace.
string TrimString(string sString, string sRemove = " ");

// ---< FormatValues >---
// ---< util_i_strings >---
// Formats the values in the json array jArray as a string using sFormat. The
// conversion is done using the sqlite printf() function. The number of elements
// in jArray must match the number of format specifiers in sFormat. Only float,
// int, or string elements are allowed. For details on format specifiers, see
// https://sqlite.org/printf.html.
//
// Example:
//   FormatValues(JsonParse("[\"Blue\", 255]"), "%s: #%06X"); // "Blue: #0000FF"
string FormatValues(json jArray, string sFormat);

// ---< FormatFloat >---
// ---< util_i_strings >---
// Formats f as a string using sFormat. The conversion is done using the sqlite
// printf() function. f will be passed as an argument to the query as many times
// as necessary to cover all format specifiers. For details on format
// specifiers, see https://sqlite.org/printf.html.
//
// Examples:
//   FormatFloat(15.0, "%d"); // "15"
//   FormatFloat(15.0, "%.2f"); // "15.00"
//   FormatFloat(15.0, "%05.1f"); // "015.0"
string FormatFloat(float f, string sFormat);

// ---< FormatInt >---
// ---< util_i_strings >---
// Formats n as a string using sFormat. The conversion is done using the sqlite
// printf() function. n will be passed as an argument to the query as many times
// as necessary to cover all format specifiers. For details on format
// specifiers, see https://sqlite.org/printf.html.
//
// Examples:
//   FormatInt(15, "%d"); // "15"
//   FormatInt(15, "%04d"); // "0015"
//   FormatInt(15, "In hexadecimal, %d is %#x"); // "In hexadecimal, 15 is 0xf"
//   FormatInt(1000, "%,d"); // "1,000"
string FormatInt(int n, string sFormat);

// ---< FormatString >---
// ---< util_i_strings >---
// Formats s as a string using sFormat. The conversion is done using the sqlite
// printf() function. s will be passed as an argument to the query as many times
// as necessary to cover all format specifiers. For details on format
// specifiers, see https://sqlite.org/printf.html.
//
// Examples:
//   FormatString("foo", "%sbar"); // "foobar"
//   FormatString("foo", "%5sbar"); // "  foobar"
//   FormatString("foo", "%-5sbar"); // "foo  bar"
string FormatString(string s, string sFormat);

/// @brief Return whether a string is a pattern.
/// @param sString The string to test.
/// @return TRUE if the string contains any of the pattern matchers expected by
///     TestStringAgainstPattern(); FALSE otherwise.
int GetIsPattern(string sString);

// -----------------------------------------------------------------------------
//                           Function Implementations
// -----------------------------------------------------------------------------

int GetSubStringCount(string sString, string sSubString)
{
    if (sString == "" || sSubString == "")
        return 0;

    int nLength = GetStringLength(sSubString);
    int nCount, nPos = FindSubString(sString, sSubString);

    while (nPos != -1)
    {
        nCount++;
        nPos = FindSubString(sString, sSubString, nPos + nLength);
    }

    return nCount;
}

int FindSubStringN(string sString, string sSubString, int nNth = 0)
{
    if (nNth < 0 || sString == "" || sSubString == "")
        return -1;

    int nLength = GetStringLength(sSubString);
    int nPos = FindSubString(sString, sSubString);

    while (--nNth >= 0 && nPos != -1)
        nPos = FindSubString(sString, sSubString, nPos + nLength);

    return nPos;
}

string GetChar(string sString, int nPos)
{
    return GetSubString(sString, nPos, 1);
}

string GetStringSlice(string sString, int nStart, int nEnd = -1)
{
    int nLength = GetStringLength(sString);
    if (nEnd < 0 || nEnd > nLength)
        nEnd = nLength;

    if (nStart < 0 || nStart >= nLength || nStart >= nEnd)
        return "";

    return GetSubString(sString, nStart, nEnd - nStart);
}

string ReplaceSubString(string sString, string sSub, int nStart, int nEnd)
{
    int nLength = GetStringLength(sString);
    if (nStart < 0 || nStart >= nLength || nStart >= nEnd)
        return sString;

    return GetSubString(sString, 0, nStart) + sSub +
           GetSubString(sString, nEnd, nLength - nEnd);
}

int HasSubString(string sString, string sSubString, int nStart = 0)
{
    return FindSubString(sString, sSubString, nStart) >= 0;
}

int GetAnyCharsInSet(string sString, string sSet)
{
    int i, nLength = GetStringLength(sString);
    for (i = 0; i < nLength; i++)
    {
        if (HasSubString(sSet, GetChar(sString, i)))
            return TRUE;
    }
    return FALSE;
}

int GetAllCharsInSet(string sString, string sSet)
{
    int i, nLength = GetStringLength(sString);
    for (i = 0; i < nLength; i++)
    {
        if (!HasSubString(sSet, GetChar(sString, i)))
            return FALSE;
    }
    return TRUE;
}

int GetIsUpperCase(string sString)
{
    return GetAllCharsInSet(sString, CHARSET_ALPHA_UPPER + CHARSET_NUMERIC);
}

int GetIsLowerCase(string sString)
{
    return GetAllCharsInSet(sString, CHARSET_ALPHA_LOWER + CHARSET_NUMERIC);
}

int GetIsAlpha(string sString)
{
    return GetAllCharsInSet(sString, CHARSET_ALPHA);
}

int GetIsNumeric(string sString)
{
    return GetAllCharsInSet(sString, CHARSET_NUMERIC);
}

int GetIsAlphaNumeric(string sString)
{
    return GetAllCharsInSet(sString, CHARSET_ALPHA + CHARSET_NUMERIC);
}

string TrimStringLeft(string sString, string sRemove = " ")
{
    while (FindSubString(sRemove, GetStringLeft(sString, 1)) != -1)
        sString = GetStringRight(sString, GetStringLength(sString) - 1);

    return sString;
}

string TrimStringRight(string sString, string sRemove = " ")
{
    while (FindSubString(sRemove, GetStringRight(sString, 1)) != -1)
        sString = GetStringLeft(sString, GetStringLength(sString) - 1);

    return sString;
}

string TrimString(string sString, string sRemove = " ")
{
    return TrimStringRight(TrimStringLeft(sString, sRemove), sRemove);
}

string FormatValues(json jArray, string sFormat)
{
    if (JsonGetType(jArray) != JSON_TYPE_ARRAY)
        return "";

    string sArgs;
    int i, nLength = JsonGetLength(jArray);
    for (i = 0; i < nLength; i++)
        sArgs += ", @" + IntToString(i);

    sqlquery q = SqlPrepareQueryObject(GetModule(), "SELECT printf(@format" + sArgs + ");");
    SqlBindString(q, "@format", sFormat);
    for (i = 0; i < nLength; i++)
    {
        string sParam = "@" + IntToString(i);
        json jValue = JsonArrayGet(jArray, i);
        switch (JsonGetType(jValue))
        {
            case JSON_TYPE_FLOAT:   SqlBindFloat (q, sParam, JsonGetFloat (jValue)); break;
            case JSON_TYPE_INTEGER: SqlBindInt   (q, sParam, JsonGetInt   (jValue)); break;
            case JSON_TYPE_STRING:  SqlBindString(q, sParam, JsonGetString(jValue)); break;
            default: break;
        }
    }
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

string FormatFloat(float f, string sFormat)
{
    json jArray = JsonArray();
    int i, nCount = GetSubStringCount(sFormat, "%");
    for (i = 0; i < nCount; i++)
        jArray = JsonArrayInsert(jArray, JsonFloat(f));
    return FormatValues(jArray, sFormat);
}

string FormatInt(int n, string sFormat)
{
    json jArray = JsonArray();
    int i, nCount = GetSubStringCount(sFormat, "%");
    for (i = 0; i < nCount; i++)
        jArray = JsonArrayInsert(jArray, JsonInt(n));
    return FormatValues(jArray, sFormat);
}

string FormatString(string s, string sFormat)
{
    json jArray = JsonArray();
    int i, nCount = GetSubStringCount(sFormat, "%");
    for (i = 0; i < nCount; i++)
        jArray = JsonArrayInsert(jArray, JsonString(s));
    return FormatValues(jArray, sFormat);
}

int GetIsPattern(string sString)
{
    return (HasSubString(sString, "**") ||
            HasSubString(sString, "*w") ||
            HasSubString(sString, "*n") ||
            HasSubString(sString, "*p") ||
            HasSubString(sString, "*a") ||
            HasSubString(sString, "|"));
}
