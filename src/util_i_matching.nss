/// ----------------------------------------------------------------------------
/// @file   util_i_matching.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Utilities for pattern matching.
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Return whether a string matches a glob pattern.
/// @param sString The string to check.
/// @param sPattern A glob pattern. Supported syntax:
///     - `*`: match zero or more characters
///     - `?`: match a single character
///     - `[abc]`: match any of a, b, or c
///     - `[a-z]`: match any character from a-z
///     - other text is matched literally
/// @returns TRUE if sString matches sPattern; FALSE otherwise.
int GetMatchesPattern(string sString, string sPattern);

/// @brief Return whether a string matches any of an array of glob patterns.
/// @param sString The string to check.
/// @param sPattern A json array of glob patterns.
/// @returns TRUE if sString matches sPattern; FALSE otherwise.
/// @see GetMatchesPattern() for supported glob syntax.
int GetMatchesPatterns(string sString, json jPatterns);

/// @brief Return if any element of a json array matches a glob pattern.
/// @param jArray A json array of strings to check.
/// @param sPattern A glob pattern.
/// @param bNot If TRUE, will invert the selection, returning whether any
///     element does not match the glob pattern.
/// @returns TRUE if any element of jArray matches sPattern; FALSE otherwise.
/// @see GetMatchesPattern() for supported glob syntax.
int GetAnyMatchesPattern(json jArray, string sPattern, int bNot = FALSE);

/// @brief Return if all elements of a json array match a glob pattern.
/// @param jArray A json array of strings to check.
/// @param sPattern A glob pattern.
/// @param bNot If TRUE, will invert the selection, returning whether all
///     elements do not match the glob pattern.
/// @returns TRUE if all elements of jArray match sPattern; FALSE otherwise.
/// @see GetMatchesPattern() for supported glob syntax.
int GetAllMatchesPattern(json jArray, string sPattern, int bNot = FALSE);

/// @brief Filter out all elements of an array that do not match a glob pattern.
/// @param jArray A json array of strings to filter.
/// @param sPattern A glob pattern.
/// @param bNot If TRUE, will invert the selection, only keeping elements that
///     do not match the glob pattern.
/// @returns A modified copy of jArray with all non-matching elements removed.
/// @see GetMatchesPattern() for supported glob syntax.
json FilterByPattern(json jArray, string sPattern, int bNot = FALSE);

/// @brief Filter out all elements of an array that do not match any of an array
///     of glob patterns.
/// @param jArray A json array of strings to filter.
/// @param jPatterns A json array of glob patterns.
/// @param bOrderByPatterns If TRUE, will order the results by the pattern they
///     matched with rather than by their placement in jArray.
/// @returns A modified copy of jArray with all non-matching elements removed.
/// @see GetMatchesPattern() for supported glob syntax.
json FilterByPatterns(json jArray, json jPatterns, int bOrderByPatterns = FALSE);

// -----------------------------------------------------------------------------
//                           Function Implementations
// -----------------------------------------------------------------------------

int GetMatchesPattern(string sString, string sPattern)
{
    sqlquery q = SqlPrepareQueryObject(GetModule(),
        "SELECT @string GLOB @pattern;");
    SqlBindString(q, "@string", sString);
    SqlBindString(q, "@pattern", sPattern);
    return SqlStep(q) ? SqlGetInt(q, 0) : FALSE;
}

int GetMatchesPatterns(string sString, json jPatterns)
{
    sqlquery q = SqlPrepareQueryObject(GetModule(),
        "SELECT 1 FROM json_each(@patterns) WHERE @value GLOB json_each.value;");
    SqlBindString(q, "@value", sString);
    SqlBindJson(q, "@patterns", jPatterns);
    return SqlStep(q) ? SqlGetInt(q, 0) : FALSE;
}

int GetAnyMatchesPattern(json jArray, string sPattern, int bNot = FALSE)
{
    jArray = FilterByPattern(jArray, sPattern, bNot);
    return JsonGetLength(jArray) != 0;
}

int GetAllMatchesPattern(json jArray, string sPattern, int bNot = FALSE)
{
    return jArray == FilterByPattern(jArray, sPattern, bNot);
}

json FilterByPattern(json jArray, string sPattern, int bNot = FALSE)
{
    if (!JsonGetLength(jArray))
        return jArray;

    sqlquery q = SqlPrepareQueryObject(GetModule(),
        "SELECT json_group_array(value) FROM json_each(@array) " +
        "WHERE value " + (bNot ? "NOT " : "") + "GLOB @pattern;");
    SqlBindJson(q, "@array", jArray);
    SqlBindString(q, "@pattern", sPattern);
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonArray();
}

json FilterByPatterns(json jArray, json jPatterns, int bOrderByPattern = FALSE)
{
    if (!JsonGetLength(jArray) || ! JsonGetLength(jPatterns))
        return jArray;

    sqlquery q = SqlPrepareQueryObject(GetModule(),
        "SELECT json_group_array(value) FROM " +
            "(SELECT DISTINCT v.key, v.value FROM " +
                "json_each(@values) v JOIN " +
                "json_each(@patterns) p " +
                "WHERE v.value GLOB p.value " +
                (bOrderByPattern ? "ORDER BY p.key);" : ");"));
    SqlBindJson(q, "@values", jArray);
    SqlBindJson(q, "@patterns", jPatterns);
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonArray();
}
