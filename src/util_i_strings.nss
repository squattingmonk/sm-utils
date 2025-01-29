/// ----------------------------------------------------------------------------
/// @file   util_i_strings.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Functions for manipulating strings.
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

/// @brief Return whether sString is a valid hexadecimal number.
/// @param sString The string to check.
/// @note Hexadecimal numbers must be prefixed with "0x" or "0X".
int GetIsHex(string sString);

/// @brief Return whether sString is a valid binary number.
/// @param sString The string to check.
/// @note Binary numbers must be prefixed with "0b" or "0B".
int GetIsBinary(string sString);

/// @brief Return whether sString is an valid octal number.
/// @param sString The string to check.
/// @note Octal numbers must be prefixed with "0o" or "0O".
int GetIsOctal(string sString);

/// @brief Return whether sString is a valid floating-point number.
/// @param sString The string to check.
/// @note This function checks for valid nwscript floats, which include
///     values such as .5, 0.5, 5., 5.0 and 5f.
int GetIsFloat(string sString);

/// @brief Return whether sString is a number.
/// @param sString The string to check.
/// @note This function checks for valid nwscript numbers, which include
///     integers, floats, hexadecimals, binaries, and octals.
int GetIsNumber(string sString);

/// @brief Return whether all characters in sString are letters or digits.
/// @param sString The string to check.
int GetIsAlphaNumeric(string sString);

/// @brief Convert a hexadecimal string to an integer.
/// @param sString The string to convert.
/// @note Hexadecimal numbers must be prefixed with "0x" or "0X".
int HexStringToInt(string sString);

/// @brief Convert a binary string to an integer.
/// @param sString The string to convert.
/// @note Binary numbers must be prefixed with "0b" or "0B".
int BinaryStringToInt(string sString);

/// @brief Convert an octal string to an integer.
/// @param sString The string to convert.
/// @note Octal numbers must be prefixed with "0o" or "0O".
int OctalStringToInt(string sString);

/// @brief Convert a bitwise flags string to an integer.
/// @param sString The string to convert.
/// @note The 0b/0B prefix is ignored for bitwise flags.
/// @note The string may contain underscores or spaces for
///     readability, which will be removed before conversion.
int BitwiseFlagsToInt(string sString);

/// @brief Convert an integer to a binary string.
/// @param n The integer to convert.
/// @note The result will be prefixed with "0b".
string IntToBinaryString(int n);

/// @brief Convert an integer to an octal string.
/// @param n The integer to convert.
/// @note The result will be prefixed with "0o".
string IntToOctalString(int n);

/// @brief Convert an integer to a bitwise flags string.
/// @param n The integer to convert.
/// @param nBlock The number of bits to group together for readability.
/// @note The result will not be prefixed and will be padded
///     to 32 characters with leading zeros.
string IntToBitwiseFlags(int n, int nBlock = 0);

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
/// @param s The string to interpolate the values into. Should have tokens which
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

/// @brief Substitute tokens ina  string with values from a json array.  Like
///     SubstituteString() above, but accepts a json object with tokens as keys
///     and the desired substitute strings as values.
/// @param s The string to interpolate the values into.  Should have tokens which
///     contain sDesignator followed by a the key of the value to substitute.
/// @param jObject An object of values to interpolate.  Substituted values may be
///     any combination of strings, floats, decimals, or booleans.  Key value pairs
///     within jObject can be reused.
/// @param sDesignator The character denoting the beginning of a token.
/// @example
///   // Assumes jObject = {"$bueller": "Kennedy", "$distance": 34, "$day", "Today"};
///   SubstituteStrings("$bueller $bueller $bueller", jObject);       // "Kennedy Kennedy Kennedy"
///   SubstituteStrings("$day's goal is $distance miles.", jObject);  // "Today's goal is 34 miles."
string SubstituteStrings(string s, json jObject, string sDesignator = "$");

/// @brief Repeats a stroan said it was trueing multiple times.
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

int GetIsHex(string sString)
{
    return RegExpMatch("^-?0[xX][0-9a-fA-F]+$", sString) != JSON_ARRAY;
}

int GetIsBinary(string sString)
{
    return RegExpMatch("^-?0[bB][01]+$", sString) != JSON_ARRAY;
}

int GetIsOctal(string sString)
{
    return RegExpMatch("^-?0[oO][0-7]+$", sString) != JSON_ARRAY;
}

int GetIsFloat(string sString)
{
    return RegExpMatch("^(-?([0-9]+\\.[0-9]*|[0-9]*\\.[0-9]+|[0-9]+f|\\.[0-9]+)(f)?)$", sString) != JSON_ARRAY;
}

int GetIsNumber(string sString)
{
    return GetIsNumeric(sString) || GetIsFloat(sString) || 
        GetIsHex(sString) || GetIsBinary(sString) || GetIsOctal(sString);
}

int GetIsAlphaNumeric(string sString)
{
    return GetAllCharsInSet(sString, CHARSET_ALPHA + CHARSET_NUMERIC);
}

int HexStringToInt(string s)
{
    if (!GetIsHex(s))
        return 0;

    sqlquery q = SqlPrepareQueryObject(GetModule(), "SELECT " + s);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

int _BinaryStringToInt(string s)
{
    int r, n;
    while (n < GetStringLength(s))
    {
        r <<= 1;
        if (GetChar(s, n++) == "1")
            r |= 1;
    }

    return r;
}

int BinaryStringToInt(string s)
{
    if (!GetIsBinary(s))
        return 0;

    return _BinaryStringToInt(s);
}

int OctalStringToInt(string s)
{
    if (!GetIsOctal(s))
        return 0;

    int r, n;
    while (n < GetStringLength(s))
    {
        r <<= 3;
        r |= StringToInt(GetChar(s, n++));
    }

    return r;
}

int BitwiseFlagsToInt(string s)
{
    if (GetStringLeft(s, 2) == "0b" || GetStringLeft(s, 2) == "0B")
        s = GetStringRight(s, GetStringLength(s) - 2);

    s = RegExpReplace("[_ ]", s, "");

    if (!GetIsBinary("0b" + s))
        return 0;

    return _BinaryStringToInt(s);
}

string _IntToBinaryString(int n)
{
    string s;
    if (n >> 1)
        s+= _IntToBinaryString(n >> 1);

    return s+= n & 1 ? "1" : "0";
}

string IntToBinaryString(int n)
{
    return "0b" + _IntToBinaryString(n);
}

string IntToOctalString(int n)
{
    return FormatInt(n, "0o%o");
}

string IntToBitwiseFlags(int n, int nBlock = 0)
{
    string t = _IntToBinaryString(n);
    t = RepeatString("0", 32 - GetStringLength(t)) + t;

    if (nBlock >= 1 && nBlock <= 32)
    {
        string s;
        int n; for (; n < GetStringLength(t); n++)
        {
            if (n % 4 == 0 && n != 0)
                s+= " ";

            s+= GetChar(t, n);
        }

        return s;
    }

    return t;
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

string SubstituteStrings(string s, json jObject, string sDesignator = "$")
{
    if (JsonGetType(jObject) != JSON_TYPE_OBJECT)
        return s;

    json jKeys = JsonObjectKeys(jObject);
    if (JsonGetLength(jKeys) == 0)
        return s;

    int n; for (; n < JsonGetLength(jKeys); n++)
    {
        string sValue, sKey = JsonGetString(JsonArrayGet(jKeys, n));
        json jValue = JsonObjectGet(jObject, sKey);
        int nType = JsonGetType(jValue);

        if      (nType == JSON_TYPE_STRING)  sValue = JsonGetString(jValue);
        else if (nType == JSON_TYPE_INTEGER) sValue = IntToString(JsonGetInt(jValue));
        else if (nType == JSON_TYPE_FLOAT)   sValue = FormatFloat(JsonGetFloat(jValue), "%!f");
        else if (nType == JSON_TYPE_BOOL)    sValue = JsonGetInt(jValue) == 1 ? "true" : "false";
        else continue;

        s = SubstituteSubStrings(s, sDesignator + sKey, sValue);
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
