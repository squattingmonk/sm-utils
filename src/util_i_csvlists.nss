/// ----------------------------------------------------------------------------
/// @file   util_i_csvlists.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Functions for manipulating comma-separated value (CSV) lists.
/// @details
///
/// ## Usage:
///
/// ```nwscript
/// string sKnight, sKnights = "Lancelot, Galahad, Robin";
/// int i, nCount = CountList(sKnights);
/// for (i = 0; i < nCount; i++)
/// {
///     sKnight = GetListItem(sKnights, i);
///     SpeakString("Sir " + sKnight);
/// }
///
/// int bBedivere = HasListItem(sKnights, "Bedivere");
/// SpeakString("Bedivere " + (bBedivere ? "is" : "is not") + " in the party.");
///
/// sKnights = AddListItem(sKnights, "Bedivere");
/// bBedivere = HasListItem(sKnights, "Bedivere");
/// SpeakString("Bedivere " + (bBedivere ? "is" : "is not") + " in the party.");
///
/// int nRobin = FindListItem(sKnights, "Robin");
/// SpeakString("Robin is knight " + IntToString(nRobin) + " in the party.");
/// ```
/// ----------------------------------------------------------------------------

#include "x3_inc_string"
#include "util_i_math"
#include "util_i_strings"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Trim excess space around commas and, optionally, remove excess commas/
///     empty list items.
/// @param sList The CSV list to normalize.
/// @param bRemoveEmpty TRUE to remove empty items.
string NormalizeList(string sList, int bRemoveEmpty = TRUE);

/// @brief Return the number of items in a CSV list.
/// @param sList The CSV list to count.
int CountList(string sList);

/// @brief Add an item to a CSV list.
/// @param sList The CSV list to add the item to.
/// @param sListItem The item to add to sList.
/// @param bAddUnique If TRUE, will only add the item to the list if it is not
///     already there.
/// @returns A modified copy of sList with sListItem added.
string AddListItem(string sList, string sListItem, int bAddUnique = FALSE);

/// @brief Insert an item into a CSV list.
/// @param sList The CSV list to insert the item into.
/// @param sListItem The item to insert into sList.
/// @param nIndex The index of the item to insert (0-based).
/// @param bAddUnique If TRUE, will only insert the item to the list if it is not
///     already there.
/// @returns A modified copy of sList with sListItem inserted.
string InsertListItem(string sList, string sListItem, int nIndex = -1, int bAddUnique = FALSE);

/// @brief Modify an existing item in a CSV list.
/// @param sList The CSV list to modify.
/// @param sListItem The item to insert at nIndex.
/// @param nIndex The index of the item to modify (0-based).
/// @param bAddUnique If TRUE, will only modify the item to the list if it is not
///     already there.
/// @returns A modified copy of sList with item at nIndex modified.
/// @note If nIndex is out of bounds for sList, no values will be modified.
/// @warning If bAddUnique is TRUE and a non-unique value is set, the value with a lower
///     list index will be kept and values with higher list indices removed.
string SetListItem(string sList, string sListItem, int nIndex = -1, int bAddUnique = FALSE);

/// @brief Return the item at an index in a CSV list.
/// @param sList The CSV list to get the item from.
/// @param nIndex The index of the item to get (0-based).
string GetListItem(string sList, int nIndex = 0);

/// @brief Return the index of a value in a CSV list.
/// @param sList The CSV list to search.
/// @param sListItem The value to search for.
/// @param nNth The nth repetition of sListItem.
/// @returns -1 if the item was not found in the list.
int FindListItem(string sList, string sListItem, int nNth = 0);

/// @brief Return whether a CSV list contains a value.
/// @param sList The CSV list to search.
/// @param sListItem The value to search for.
/// @returns TRUE if the item is in the list, otherwise FALSE.
int HasListItem(string sList, string sListItem);

/// @brief Delete the item at an index in a CSV list.
/// @param sList The CSV list to delete the item from.
/// @param nIndex The index of the item to delete (0-based).
/// @returns A modified copy of sList with the item deleted.
string DeleteListItem(string sList, int nIndex = 0);

/// @brief Delete the first occurrence of an item in a CSV list.
/// @param sList The CSV list to remove the item from.
/// @param sListItem The value to remove from the list.
/// @param nNth The nth repetition of sListItem.
/// @returns A modified copy of sList with the item removed.
string RemoveListItem(string sList, string sListItem, int nNth = 0);

/// @brief Copy items from one CSV list to another.
/// @param sSource The CSV list to copy items from.
/// @param sTarget The CSV list to copy items to.
/// @param nIndex The index to begin copying from.
/// @param nRange The number of items to copy.
/// @param bAddUnique If TRUE, will only copy items to sTarget if they are not
///     already there.
/// @returns A modified copy of sTarget with the items added to the end.
string CopyListItem(string sSource, string sTarget, int nIndex, int nRange = 1, int bAddUnique = FALSE);

/// @brief Merge the contents of two CSV lists.
/// @param sList1 The first CSV list.
/// @param sList2 The second CSV list.
/// @param bAddUnique If TRUE, will only put items in the returned list if they
///     are not already there.
/// @returns A CSV list containing the items from each list.
string MergeLists(string sList1, string sList2, int bAddUnique = FALSE);

/// @brief Add an item to a CSV list saved as a local variable on an object.
/// @param oObject The object on which the local variable is saved.
/// @param sListName The varname for the local variable.
/// @param sListItem The item to add to the list.
/// @param bAddUnique If TRUE, will only add the item to the list if it is not
///     already there.
/// @returns The updated copy of the list with sListItem added.
string AddLocalListItem(object oObject, string sListName, string sListItem, int bAddUnique = FALSE);

/// @brief Delete an item in a CSV list saved as a local variable on an object.
/// @param oObject The object on which the local variable is saved.
/// @param sListName The varname for the local variable.
/// @param nIndex The index of the item to delete (0-based).
/// @returns The updated copy of the list with the item at nIndex deleted.
string DeleteLocalListItem(object oObject, string sListName, int nIndex = 0);

/// @brief Remove an item in a CSV list saved as a local variable on an object.
/// @param oObject The object on which the local variable is saved.
/// @param sListName The varname for the local variable.
/// @param sListItem The value to remove from the list.
/// @param nNth The nth repetition of sListItem.
/// @returns The updated copy of the list with the first instance of sListItem
///     removed.
string RemoveLocalListItem(object oObject, string sListName, string sListItem, int nNth = 0);

/// @brief Merge the contents of a CSV list with those of a CSV list stored as a
///     local variable on an object.
/// @param oObject The object on which the local variable is saved.
/// @param sListName The varname for the local variable.
/// @param sListToMerge The CSV list to merge into the saved list.
/// @param bAddUnique If TRUE, will only put items in the returned list if they
///     are not already there.
/// @returns The updated copy of the list with all items from sListToMerge
///     added.
string MergeLocalList(object oObject, string sListName, string sListToMerge, int bAddUnique = FALSE);

/// @brief Convert a comma-separated value list to a JSON array.
/// @param sList Source CSV list.
/// @param bNormalize TRUE to remove excess spaces and values.  See NormalizeList().
/// @returns JSON array representation of CSV list.
json ListToJson(string sList, int bNormalize = TRUE);

/// @brief Convert a JSON array to a comma-separate value list.
/// @param jList JSON array list.
/// @param bNormalize TRUE to remove excess spaces and values.  See NormalizeList().
/// @returns CSV list of JSON array values.
string JsonToList(json jList, int bNormalize = TRUE);

// -----------------------------------------------------------------------------
//                           Function Implementations
// -----------------------------------------------------------------------------

string NormalizeList(string sList, int bRemoveEmpty = TRUE)
{
    string sRegex = "(?:[\\s]*,[\\s]*)" + (bRemoveEmpty ? "+" : "");
    sList = RegExpReplace(sRegex, sList, ",");
    return TrimString(bRemoveEmpty ? RegExpReplace("^[\\s]*,|,[\\s]*$", sList, "") : sList);
}

int CountList(string sList)
{
    if (sList == "")
        return 0;

    return GetSubStringCount(sList, ",") + 1;
}

string AddListItem(string sList, string sListItem, int bAddUnique = FALSE)
{
    sList = NormalizeList(sList);
    sListItem = TrimString(sListItem);

    if (bAddUnique && HasListItem(sList, sListItem))
        return sList;

    if (sList != "")
        return sList + "," + sListItem;

    return sListItem;
}

string InsertListItem(string sList, string sListItem, int nIndex = -1, int bAddUnique = FALSE)
{
    if (nIndex == -1 || sList == "" || nIndex > CountList(sList) - 1)
        return AddListItem(sList, sListItem, bAddUnique);

    if (nIndex < 0) nIndex = 0;
    json jList = JsonArrayInsert(ListToJson(sList), JsonString(sListItem), nIndex);

    if (bAddUnique == TRUE)
        jList = JsonArrayTransform(jList, JSON_ARRAY_UNIQUE);
    
    return JsonToList(jList);
}

string SetListItem(string sList, string sListItem, int nIndex = -1, int bAddUnique = FALSE)
{
    if (nIndex < 0 || nIndex > (CountList(sList) - 1))
        return sList;

    json jList = JsonArraySet(ListToJson(sList), nIndex, JsonString(sListItem));

    if (bAddUnique == TRUE)
        jList = JsonArrayTransform(jList, JSON_ARRAY_UNIQUE);
    
    return JsonToList(jList);
}

string GetListItem(string sList, int nIndex = 0)
{
    if (nIndex < 0 || sList == "" || nIndex > (CountList(sList) - 1))
        return "";

    return JsonGetString(JsonArrayGet(ListToJson(sList), nIndex));
}

int FindListItem(string sList, string sListItem, int nNth = 0)
{
    json jIndex = JsonFind(ListToJson(sList), JsonString(TrimString(sListItem)), nNth);
    return jIndex == JSON_NULL ? -1 : JsonGetInt(jIndex);
}

int HasListItem(string sList, string sListItem)
{
    return (FindListItem(sList, sListItem) > -1);
}

string DeleteListItem(string sList, int nIndex = 0)
{
    if (nIndex < 0 || sList == "" || nIndex > (CountList(sList) - 1))
        return sList;

    return JsonToList(JsonArrayDel(ListToJson(sList), nIndex));
}

string RemoveListItem(string sList, string sListItem, int nNth = 0)
{
    return DeleteListItem(sList, FindListItem(sList, sListItem, nNth));
}

string CopyListItem(string sSource, string sTarget, int nIndex, int nRange = 1, int bAddUnique = FALSE)
{
    int i, nCount = CountList(sSource);

    if (nIndex < 0 || nIndex >= nCount || !nCount)
        return sSource;

    nRange = clamp(nRange, 1, nCount - nIndex);

    for (i = 0; i < nRange; i++)
        sTarget = AddListItem(sTarget, GetListItem(sSource, nIndex + i), bAddUnique);

    return sTarget;
}

string MergeLists(string sList1, string sList2, int bAddUnique = FALSE)
{
    if (sList1 != "" && sList2 == "")
        return sList1;
    else if (sList1 == "" && sList2 != "")
        return sList2;
    else if (sList1 == "" && sList2 == "")
        return "";

    string sList = sList1 + "," + sList2;

    if (bAddUnique)
        sList = JsonToList(JsonArrayTransform(ListToJson(sList), JSON_ARRAY_UNIQUE));

    return bAddUnique ? sList : NormalizeList(sList);
}

string AddLocalListItem(object oObject, string sListName, string sListItem, int bAddUnique = FALSE)
{
    string sList = GetLocalString(oObject, sListName);
    sList = AddListItem(sList, sListItem, bAddUnique);
    SetLocalString(oObject, sListName, sList);
    return sList;
}

string DeleteLocalListItem(object oObject, string sListName, int nIndex = 0)
{
    string sList = GetLocalString(oObject, sListName);
    sList = DeleteListItem(sList, nIndex);
    SetLocalString(oObject, sListName, sList);
    return sList;
}

string RemoveLocalListItem(object oObject, string sListName, string sListItem, int nNth = 0)
{
    string sList = GetLocalString(oObject, sListName);
    sList = RemoveListItem(sList, sListItem, nNth);
    SetLocalString(oObject, sListName, sList);
    return sList;
}

string MergeLocalList(object oObject, string sListName, string sListToMerge, int bAddUnique = FALSE)
{
    string sList = GetLocalString(oObject, sListName);
    sList = MergeLists(sList, sListToMerge, bAddUnique);
    SetLocalString(oObject, sListName, sList);
    return sList;
}

json ListToJson(string sList, int bNormalize = TRUE)
{
    if (sList == "")
        return JSON_ARRAY;

    if (bNormalize)
        sList = NormalizeList(sList);
    
    sList = RegExpReplace("\"", sList, "\\\"");
    return JsonParse("[\"" + RegExpReplace(",", sList, "\",\"") + "\"]");
}

string JsonToList(json jList, int bNormalize = TRUE)
{
    if (JsonGetType(jList) != JSON_TYPE_ARRAY)
        return "";

    string sList;
    int n; for (n; n < JsonGetLength(jList); n++)
        sList += (sList == "" ? "" : ",") + JsonGetString(JsonArrayGet(jList, n));

    return bNormalize ? NormalizeList(sList) : sList;
}
