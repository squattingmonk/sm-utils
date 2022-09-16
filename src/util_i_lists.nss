// -----------------------------------------------------------------------------
//    File: util_i_lists.nss
//  System: Utilities (include script)
//     URL: https://github.com/squattingmonk/sm-utils
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// This file holds compatibility functions for converting between CSV and
// localvar lists. It can be used as a master include for list functions.
// -----------------------------------------------------------------------------
// Acknowledgements: these functions are adapted from those in Memetic AI.
// -----------------------------------------------------------------------------

#include "util_i_csvlists"
#include "util_i_varlists"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

// Acceptable values for nListType in SplitList() and JoinList().
const int LIST_TYPE_FLOAT  = 0;
const int LIST_TYPE_INT    = 1;
const int LIST_TYPE_STRING = 2;

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Splits a comma-separated value list into a local variable list of the
///     given type.
/// @param oTarget Object on which to create the list
/// @param sList Source CSV list
/// @param sListName Name of the list to create or add to
/// @param bAddUnique If TRUE, prevents duplicate list items
/// @param nListType Type of list to create
///     LIST_TYPE_STRING (default)
///     LIST_TYPE_FLOAT
///     LIST_TYPE_INT
/// @returns JSON array of split CSV list
json SplitList(object oTarget, string sList, string sListName = "", int bAddUnique = FALSE, int nListType = LIST_TYPE_STRING);

/// @brief Joins a local variable list of a given type into a comma-separated
///     value list
/// @param oTarget Object from which to source the local variable list
/// @param sListName Name of the local variable list
/// @param bAddUnique If TRUE, prevents duplicate list items
/// @param nListType Type of local variable list
///     LIST_TYPE_STRING (default)
///     LIST_TYPE_FLOAT
///     LIST_TYPE_INT
/// @returns Joined CSV list of local variable list
string JoinList(object oTarget, string sListName = "", int bAddUnique = FALSE, int nListType = LIST_TYPE_STRING);

// -----------------------------------------------------------------------------
//                           Function Implementations
// -----------------------------------------------------------------------------

json SplitList(object oTarget, string sList, string sListName = "", int bAddUnique = FALSE, int nListType = LIST_TYPE_STRING)
{
    json jList = JsonArray();

    if (nListType == LIST_TYPE_STRING)
    {
        int n, nCount = CountList(sList);
        for (n = 0; n < nCount; n++)
        {
            string sListItem = GetListItem(sList, n);
            jList = JsonArrayInsert(jList, JsonString(TrimString(sListItem)));
        }
    }
    else
        jList = JsonParse("[" + sList + "]");

    string sListType = (nListType == LIST_TYPE_STRING ? VARLIST_TYPE_STRING :
                        nListType == LIST_TYPE_INT ?    VARLIST_TYPE_INT :
                                                        VARLIST_TYPE_FLOAT);

    if (bAddUnique == TRUE)
        jList = JsonArrayTransform(jList, JSON_ARRAY_UNIQUE);

    if (oTarget != OBJECT_INVALID)
        _SetList(oTarget, sListType, sListName, jList);

    return jList;
}

string JoinList(object oTarget, string sListName = "", int bAddUnique = FALSE, int nListType = LIST_TYPE_STRING)
{
    string sListType = (nListType == LIST_TYPE_STRING ? VARLIST_TYPE_STRING :
                        nListType == LIST_TYPE_INT ?    VARLIST_TYPE_INT :
                                                        VARLIST_TYPE_FLOAT);

    json jList = _GetList(oTarget, sListType, sListName);
    if (jList == JsonNull() || JsonGetLength(jList) == 0)
        return "";

    if (bAddUnique == TRUE)
        jList = JsonArrayTransform(jList, JSON_ARRAY_UNIQUE);

    string sList;
    if (nListType == LIST_TYPE_STRING)
    {
        int n, nCount = JsonGetLength(jList);
        for (n = 0; n < nCount; n++)
            sList = AddListItem(sList, JsonGetString(JsonArrayGet(jList, n)));
    }
    else
    {
        sList = JsonDump(jList);
        sList = GetStringSlice(sList, 1, GetStringLength(sList) - 2);
    }

    return sList;
}
