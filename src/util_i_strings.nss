/// ----------------------------------------------------------------------------
/// @file   util_i_strings.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Functions for manipulating strings
/// ----------------------------------------------------------------------------
/// @details This file holds utility functions for manipulating strings.
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

const string CHARSET_NUMERIC     = "0123456789";
const string CHARSET_ALPHA       = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
const string CHARSET_ALPHA_LOWER = "abcdefghijklmnopqrstuvwxyz";
const string CHARSET_ALPHA_UPPER = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Return the number of occurrences of a substring within a string.
/// @param sString The string to search.
/// @param sSubString The substring to search for.
int GetSubStringCount(string sString, string sSubString);

/// @brief Return the position of a given occurrence of a substring within a
///     string.
/// @param sString The string to search.
/// @param sSubString The substring to search for.
/// @param nNth The occurrence to search for. Uses a zero-based index.
/// @returns The position of the start of the nNth occurrence of the substring,
///     or -1 if the substring did not occur at least nNth + 1 times.
int FindSubStringN(string sString, string sSubString, int nNth = 0);

/// @brief Return the character at a position in a string.
/// @param sString The string to search.
/// @param nPos The position to check.
/// @returns "" if sString is not nPos + 1 characters long.
string GetChar(string sString, int nPos);

/// @brief Return the substring of a string bounded by a start and end position.
/// @param sString The string to search.
/// @param nStart The starting position of the substring to return.
/// @param nEnd The ending position of the substring to return. If -1, will
///     return to the end of the string.
/// @returns "" if nStart is not at least nStart + 1 characters long or if nEnd
///     is < nStart and not -1.
/// @note Both nStart and nEnd are inclusive, so if nStart == nEnd, the
///     character at that index will be returned.
string GetStringSlice(string sString, int nStart, int nEnd = -1);

/// @brief Replace the substring bounded by a string slice with another string.
/// @param sString The string to search.
/// @param sSub The substring to replace with.
/// @param nStart The starting position in sString of the substring to replace.
/// @param nEnd The ending position in sString of the substring to replace.
string ReplaceSubString(string sString, string sSub, int nStart, int nEnd);

/// @brief Replace a substring in a string with another string.
/// @param sString The string to search.
/// @param sToken The substring to search for.
/// @param sSub The substring to replace with.
string SubstituteSubString(string sString, string sToken, string sSub);

/// @brief Replace all substrings in a string with another string.
/// @param sString The string to search.
/// @param sToken The substring to search for.
/// @param sSub The substring to replace with.
string SubstituteSubStrings(string sString, string sToken, string sSub);

/// @brief Return whether a string contains a substring.
/// @param sString The string to search.
/// @param sSubString The substring to search for.
/// @param nStart The position in sString to begin searching from (0-based).
/// @returns TRUE if sSubString is in sString, FALSE otherwise.
int HasSubString(string sString, string sSubString, int nStart = 0);

/// @brief Return whether any of a string's characters are in a character set.
/// @param sString The string to search.
/// @param sSet The set of characters to search for.
/// @returns TRUE if any characters are in the set; FALSE otherwise.
int GetAnyCharsInSet(string sString, string sSet);

/// @brief Return whether all of a string's characters are in a character set.
/// @param sString The string to search.
/// @param sSet The set of characters to search for.
/// @returns TRUE if all characters are in the set; FALSE otherwise.
int GetAllCharsInSet(string sString, string sSet);

/// @brief Return whether all letters in a string are upper-case.
/// @param sString The string to check.
int GetIsUpperCase(string sString);

/// @brief Return whether all letters in a string are lower-case.
/// @param sString The string to check.
int GetIsLowerCase(string sString);

/// @brief Return whether all characters in sString are letters.
/// @param sString The string to check.
int GetIsAlpha(string sString);

/// @brief Return whether all characters in sString are digits.
/// @param sString The string to check.
int GetIsNumeric(string sString);

/// @brief Return whether all characters in sString are letters or digits.
/// @param sString The string to check.
int GetIsAlphaNumeric(string sString);

/// @brief Trim characters from the left side of a string.
/// @param sString The string to trim.
/// @param sRemove The set of characters to remove.
string TrimStringLeft(string sString, string sRemove = " ");

/// @brief Trim characters from the right side of a string.
/// @param sString The string to trim.
/// @param sRemove The set of characters to remove.
string TrimStringRight(string sString, string sRemove = " ");

/// @brief Trim characters from both sides of a string.
/// @param sString The string to trim.
/// @param sRemove The set of characters to remove.
string TrimString(string sString, string sRemove = " ");

/// @brief Interpolate values from a json array into a string using sqlite's
///     printf().
/// @param jArray A json array containing float, int, or string elements to
///     interpolate. The number of elements must match the number of format
///     specifiers in sFormat.
/// @param sFormat The string to interpolate the values into. Must contain
///     format specifiers that correspond to the elements in jArray. For details
///     on format specifiers, see https://sqlite.org/printf.html.
/// @example
///   FormatValues(JsonParse("[\"Blue\", 255]"), "%s: #%06X"); // "Blue: #0000FF"
string FormatValues(json jArray, string sFormat);

/// @brief Interpolate a float into a string using sqlite's printf().
/// @param f A float to interpolate. Will be passed as an argument to the query
///     as many times as necessary to cover all format specifiers.
/// @param sFormat The string to interpolate the value into. For details on
///     format specifiers, see https://sqlite.org/printf.html.
/// @example
///   FormatFloat(15.0, "%d"); // "15"
///   FormatFloat(15.0, "%.2f"); // "15.00"
///   FormatFloat(15.0, "%05.1f"); // "015.0"
string FormatFloat(float f, string sFormat);

/// @brief Interpolate an int into a string using sqlite's printf().
/// @param n An int to interpolate. Will be passed as an argument to the query
///     as many times as necessary to cover all format specifiers.
/// @param sFormat The string to interpolate the value into. For details on
///     format specifiers, see https://sqlite.org/printf.html.
/// @example
///   FormatInt(15, "%d"); // "15"
///   FormatInt(15, "%04d"); // "0015"
///   FormatInt(15, "In hexadecimal, %d is %#x"); // "In hexadecimal, 15 is 0xf"
///   FormatInt(1000, "%,d"); // "1,000"
string FormatInt(int n, string sFormat);

/// @brief Interpolate a string into another string using sqlite's printf().
/// @param s A string to interpolate. Will be passed as an argument to the query
///     as many times as necessary to cover all format specifiers.
/// @param sFormat The string to interpolate the value into. For details on
///     format specifiers, see https://sqlite.org/printf.html.
/// @example
///   FormatString("foo", "%sbar"); // "foobar"
///   FormatString("foo", "%5sbar"); // "  foobar"
///   FormatString("foo", "%-5sbar"); // "foo  bar"
string FormatString(string s, string sFormat);

/// @brief Substitute tokens in a string with values from a json array.
/// @param s The string to interpolate the values into. Should have tokens wich
///     contain sDesignator followed by a number denoting the position of the
///     value in jArray (1-based index).
/// @param jArray An array of values to interpolate. May be any combination of
///     strings, floats, decimals, or booleans.
/// @param sDesignator The character denoting the beginning of a token.
/// @example
///   // Assumes jArray = ["Today", 34, 2.5299999999, true];
///   SubstituteString("$1, I ran $2 miles.", jArray);        // "Today, I ran 34 miles."
///   SubstituteString("The circle's radius is $3.", jArray); // "The circle's radius is 2.53."
///   SubstituteString("The applicant answered: $4", jArray); // "The applicant answered: true"
string SubstituteString(string s, json jArray, string sDesignator = "$");

/// @brief Repeats a string multiple times.
/// @param s The string to repeat.
/// @param n The number of times to repeat s.
/// @returns The repeated string.
string RepeatString(string s, int n);

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

    if (nStart < 0 || nStart > nEnd)
        return "";

    return GetSubString(sString, nStart, nEnd - nStart + 1);
}

string ReplaceSubString(string sString, string sSub, int nStart, int nEnd)
{
    int nLength = GetStringLength(sString);
    if (nStart < 0 || nStart >= nLength || nStart > nEnd)
        return sString;

    return GetSubString(sString, 0, nStart) + sSub +
           GetSubString(sString, nEnd + 1, nLength - nEnd);
}

string SubstituteSubString(string sString, string sToken, string sSub)
{
    int nPos;
    if ((nPos = FindSubString(sString, sToken)) == -1)
        return sString;

    return ReplaceSubString(sString, sSub, nPos, nPos + GetStringLength(sToken) - 1);
}

string SubstituteSubStrings(string sString, string sToken, string sSub)
{
    while (FindSubString(sString, sToken) >= 0)
        sString = SubstituteSubString(sString, sToken, sSub);

    return sString;
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
    return RegExpReplace("^(?:" + sRemove + ")*", sString, "");
}

string TrimStringRight(string sString, string sRemove = " ")
{
    return RegExpReplace("(:?" + sRemove + ")*$", sString, "");
}

string TrimString(string sString, string sRemove = " ")
{
    return RegExpReplace("^(:?" + sRemove + ")*|(?:" + sRemove + ")*$", sString, "");
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
        JsonArrayInsertInplace(jArray, JsonFloat(f));
    return FormatValues(jArray, sFormat);
}

string FormatInt(int n, string sFormat)
{
    json jArray = JsonArray();
    int i, nCount = GetSubStringCount(sFormat, "%");
    for (i = 0; i < nCount; i++)
        JsonArrayInsertInplace(jArray, JsonInt(n));
    return FormatValues(jArray, sFormat);
}

string FormatString(string s, string sFormat)
{
    json jArray = JsonArray();
    int i, nCount = GetSubStringCount(sFormat, "%");
    for (i = 0; i < nCount; i++)
        JsonArrayInsertInplace(jArray, JsonString(s));
    return FormatValues(jArray, sFormat);
}

string SubstituteString(string s, json jArray, string sDesignator = "$")
{
    if (JsonGetType(jArray) != JSON_TYPE_ARRAY)
        return s;

    int n; for (n = JsonGetLength(jArray) - 1; n >= 0; n--)
    {
        string sValue;
        json jValue = JsonArrayGet(jArray, n);
        int nType = JsonGetType(jValue);
        if      (nType == JSON_TYPE_STRING)  sValue = JsonGetString(jValue);
        else if (nType == JSON_TYPE_INTEGER) sValue = IntToString(JsonGetInt(jValue));
        else if (nType == JSON_TYPE_FLOAT)   sValue = FormatFloat(JsonGetFloat(jValue), "%!f");
        else if (nType == JSON_TYPE_BOOL)    sValue = JsonGetInt(jValue) == 1 ? "true" : "false";
        else continue;

        s = SubstituteSubStrings(s, sDesignator + IntToString(n + 1), sValue);
    }

    return s;
}

string RepeatString(string s, int n)
{
    string sResult;
    while (n-- > 0)
        sResult += s;

    return sResult;
}
