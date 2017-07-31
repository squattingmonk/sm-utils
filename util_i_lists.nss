/*
Filename:        util_i_lists.nss
System:          Foundation Utilities (include script)
Author:          Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
Date Created:    Dec. 15, 2008
Summary:
Foundation Utilities include script. This file holds list utility functions
commonly used throughout Foundation and its associated systems.

Revision Info should only be included for post-release revisions.
-----------------
Revision Date:
Revision Author:
Revision Summary:

*/

// 1.69 string manipulation functions
#include "x3_inc_string"

// -----------------------------------------------------------------------------
//                                 Constants
// -----------------------------------------------------------------------------

// Prefixes used to keep list variables from colliding with other locals.
const string LIST_REF_FLOAT      = "FL:";
const string LIST_REF_INT        = "IL:";
const string LIST_REF_LOCATION   = "LL:";
const string LIST_REF_OBJECT     = "OL:";
const string LIST_REF_STRING     = "SL:";

const string LIST_COUNT_FLOAT    = "FC:";
const string LIST_COUNT_INT      = "IC:";
const string LIST_COUNT_LOCATION = "LC:";
const string LIST_COUNT_OBJECT   = "OC:";
const string LIST_COUNT_STRING   = "SC:";

// Acceptable values for nListType in ExplodeList() and CompressList() in
// core_i_utility.
const int LIST_TYPE_FLOAT    = 0;
const int LIST_TYPE_INT      = 1;
const int LIST_TYPE_STRING   = 2;

// Used to replace commas in strings being added to a compressed list.
const string COMMA = "#COMMA#";


//------------------------------------------------------------------------------
//                             Function Prototypes
//------------------------------------------------------------------------------

// ----- String Utilities ------------------------------------------------------

// ---< GetSubStringCount >---
// ---< util_i_lists >---
// Returns the number of occurrences of sSubString within sString.
int GetSubStringCount(string sString, string sSubString);

// ---< ProtectCommas >---
// ---< util_i_lists >---
// Replaces all commas in sString with a control character if bProtect is TRUE.
// Replaces the control characters with commas if bProtect is FALSE. Use this
// when adding or retrieving strings that may have commas from CSV lists.
string ProtectCommas(string sString, int bProtect = TRUE);

// ---< TrimString >---
// ---< util_i_lists >---
// Trims all leading and trailing whitspace from sString.
string TrimString(string sString);


// ----- CSV Lists -------------------------------------------------------------

// ---< ExplodeList >---
// ---< util_i_lists >---
// Takes a comma-separated string list and creates an exploded list of nListType
// with the given name on oTarget.
// Parameters:
// - oTarget: the object on which to create the list
// - sList: the CSV list to explode
// - sListName: the name of the list to create or add to
// - bAddUnique: only add items to the list if they are not already there?
// - nListType: the type of list to create
//   Possible values:
//   - LIST_TYPE_STRING (default)
//   - LIST_TYPE_FLOAT
//   - LIST_TYPE_INT
void ExplodeList(object oTarget, string sList, string sListName = "", int bAddUnique = FALSE, int nListType = LIST_TYPE_STRING);

// ---< CompressList >---
// ---< util_i_lists >---
// Creates a comma-separated string list from the local variable list of
// nListType with the given name on oTarget.
// Parameters:
// - oTarget: the object on which to find the list to compress
// - sListName: the name of the list to compress
// - bAddUnique: only add items to the list if they are not already there?
// - nListType: the type of list to compress
//   Possible values:
//   - LIST_TYPE_STRING (default)
//   - LIST_TYPE_FLOAT
//   - LIST_TYPE_INT
string CompressList(object oTarget, string sListName, int bAddUnique = FALSE, int nListType = LIST_TYPE_STRING);

// ---< CountList >---
// ---< util_i_lists >---
// Returns the number of items in the CSV list sList.
int CountList(string sList);

// ---< GetListItem >---
// ---< util_i_lists >---
// Returns the nNth item in the CSV list sList.
string GetListItem(string sList, int nNth = 0);

// ---< FindListItem >---
// ---< util_i_lists >---
// Returns the item number of sListItem in the CSV list sList. Returns -1 if
// sListItem is not in the list.
int FindListItem(string sList, string sListItem);

// ---< HasListItem >---
// ---< util_i_lists >---
// Returns whether sListItem is in the CSV list sList.
int HasListItem(string sList, string sListItem);

// ---< DeleteListItem >---
// ---< util_i_lists >---
// Returns the CSV list sList with the nNth item removed.
string DeleteListItem(string sList, int nNth = 0);

// ---< RemoveListItem >---
// ---< util_i_lists >---
// Returns the CSV list sList with the first occurrence of sListItem removed.
string RemoveListItem(string sList, string sListItem);

// ---< AddListItem >---
// ---< util_i_lists >---
// Returns the CSV list sList with sListItem added. If bAddUnique is TRUE, will
// only add items to the list if they are not already there.
string AddListItem(string sList, string sListItem, int bAddUnique = FALSE);

// ---< MergeLists >---
// ---< util_i_lists >---
// Returns the CSV list sList1 with every item in sList2 added. If bAddUnique is
// TRUE, will only add items to the list if they are not already there.
string MergeLists(string sList1, string sList2, int bAddUnique = FALSE);


// ----- Local Variable Lists --------------------------------------------------

// ---< AddListFloat >---
// ---< util_i_lists >---
// Adds fValue to a float list on oTarget given the list name sListName. If
// bAddUnique is TRUE, this only adds to the list if it is not already there.
// Returns whether the addition was successful.
int AddListFloat(object oTarget, float fValue, string sListName = "", int bAddUnique = FALSE);

// ---< AddListInt >---
// ---< util_i_lists >---
// Adds nValue to an int list on oTarget given the list name sListName. If
// bAddUnique is TRUE, this only adds to the list if it is not already there.
// Returns whether the addition was successful.
int AddListInt(object oTarget, int nValue, string sListName = "", int bAddUnique = FALSE);

// ---< AddListLocation >---
// ---< util_i_lists >---
// Adds lValue to a location list on oTarget given the list name sListName. If
// bAddUnique is TRUE, this only adds to the list if it is not already there.
// Returns whether the addition was successful.
int AddListLocation(object oTarget, location lValue, string sListName = "", int bAddUnique = FALSE);

// ---< AddListObject >---
// ---< util_i_lists >---
// Adds oValue to a object list on oTarget given the list name sListName. If
// bAddUnique is TRUE, this only adds to the list if it is not already there.
// Returns whether the addition was successful.
int AddListObject(object oTarget, object oValue, string sListName = "", int bAddUnique = FALSE);

// ---< AddListString >---
// ---< util_i_lists >---
// Adds sValue to a string list on oTarget given the list name sListName. If
// bAddUnique is TRUE, this only adds to the list if it is not already there.
// Returns whether the addition was successful.
int AddListString(object oTarget, string sValue, string sListName = "", int bAddUnique = FALSE);

// ---< SetListFloat >---
// ---< util_i_lists >---
// Sets item nIndex in the float list of sListName on oTarget to fValue. If the
// index is at the end of the list, it will be added. If it exceeds the length
// of the list, nothing is added.
void SetListFloat(object oTarget, int nIndex, float fValue, string sListName = "");

// ---< SetListInt >---
// ---< util_i_lists >---
// Sets item nIndex in the int list of sListName on oTarget to nValue. If the
// index is at the end of the list, it will be added. If it exceeds the length
// of the list, nothing is added.
void SetListInt(object oTarget, int nIndex, int nValue, string sListName = "");

// ---< SetListLocation >---
// ---< util_i_lists >---
// Sets item nIndex in the location list of sListName on oTarget to lValue. If
// the index is at the end of the list, it will be added. If it exceeds the
// length of the list, nothing is added.
void SetListLocation(object oTarget, int nIndex, location lValue, string sListName = "");

// ---< SetListObject >---
// ---< util_i_lists >---
// Sets item nIndex in the object list of sListName on oTarget to oValue. If the
// index is at the end of the list, it will be added. If it exceeds the length
// of the list, nothing is added.
void SetListObject(object oTarget, int nIndex, object oValue, string sListName = "");

// ---< SetListString >---
// ---< util_i_lists >---
// Sets item nIndex in the string list of sListName on oTarget to sValue. If the
// index is at the end of the list, it will be added. If it exceeds the length
// of the list, nothing is added.
void SetListString(object oTarget, int nIndex, string sValue, string sListName = "");

// ---< GetListFloat >---
// ---< util_i_lists >---
// Returns the float at nIndex in oTarget's float list sListName. If no float is
// found at that index, 0.0 is returned.
float GetListFloat(object oTarget, int nIndex = 0, string sListName = "");

// ---< GetListInt >---
// ---< util_i_lists >---
// Returns the int at nIndex in oTarget's int list sListName. If no int is found
// at that index, 0 is returned.
int GetListInt(object oTarget, int nIndex = 0, string sListName = "");

// ---< GetListLocation >---
// ---< util_i_lists >---
// Returns the location at nIndex in oTarget's location list sListName. If no
// location is found at that index, an invalid location is returned.
location GetListLocation(object oTarget, int nIndex = 0, string sListName = "");

// ---< GetListObject >---
// ---< util_i_lists >---
// Returns the object at nIndex in oTarget's object list sListName. If no object
// is found at that index, OBJECT_INVALID is returned.
object GetListObject(object oTarget, int nIndex = 0, string sListName = "");

// ---< GetListString >---
// ---< util_i_lists >---
// Returns the string at nIndex in oTarget's string list sListName. If no string
// is found at that index, "" is returned.
string GetListString(object oTarget, int nIndex = 0, string sListName = "");

// ---< DeleteListFloat >---
// ---< util_i_lists >---
// Removes the float at nIndex on oTarget's float list sListName and returns the
// number of items remaining in the list. If bMaintainOrder is TRUE, this will
// shift up all entries after nIndex in the list. If FALSE, it will replace the
// removed item with the last entry in the list. If the order of items in the
// list doesn't matter, this will save a lot of cycles.
int DeleteListFloat(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE);

// ---< DeleteListInt >---
// ---< util_i_lists >---
// Removes the int at nIndex on oTarget's int list sListName and returns the
// number of items remaining in the list. If bMaintainOrder is TRUE, this will
// shift up all entries after nIndex in the list. If FALSE, it will replace the
// removed item with the last entry in the list. If the order of items in the
// list doesn't matter, this will save a lot of cycles.
int DeleteListInt(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE);

// ---< DeleteListLocation >---
// Removes the location at nIndex on oTarget's location list sListName and
// returns the number of items remaining in the list. If bMaintainOrder is TRUE,
// this will shift up all entries after nIndex in the list. If FALSE, it will
// replace the removed item with the last entry in the list. If the order of
// items in the list doesn't matter, this will save a lot of cycles.
int DeleteListLocation(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE);

// ---< DeleteListObject >---
// ---< util_i_lists >---
// Removes the object at nIndex on oTarget's object list sListName and returns
// the number of items remaining in the list. If bMaintainOrder is TRUE, this
// will shift up all entries after nIndex in the list. If FALSE, it will replace
// the removed item with the last entry in the list. If the order of items in
// the list doesn't matter, this will save a lot of cycles.
int DeleteListObject(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE);

// ---< DeleteListString >---
// ---< util_i_lists >---
// Removes the string at nIndex on oTarget's string list sListName and returns
// the number of items remaining in the list. If bMaintainOrder is TRUE, this
// will shift up all entries after nIndex in the list. If FALSE, it will replace
// the removed item with the last entry in the list. If the order of items in
// the list doesn't matter, this will save a lot of cycles.
int DeleteListString(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE);

// ---< RemoveListFloat >---
// ---< util_i_lists >---
// Removes a float of fValue from the float list sListName on oTarget and
// returns the number of items remaining in the list. If this float was added
// more than once, only the first reference is removed. If bMaintainOrder is
// TRUE, this will his shift up all entries after nIndex in the list. If FALSE,
// it will replace the removed item with the last entry in the list. If the
// order of items in the list doesn't matter, this will save a lot of cycles.
int RemoveListFloat(object oTarget, float fValue, string sListName = "", int bMaintainOrder = FALSE);

// ---< RemoveListInt >---
// ---< util_i_lists >---
// Removes an int of nValue from the float list sListName on oTarget and returns
// the number of items remaining in the list. If this float was added more than
// once, only the first reference is removed. If bMaintainOrder is TRUE, this
// will his shift up all entries after nIndex in the list. If FALSE, it will
// replace the removed item with the last entry in the list. If the order of
// items in the list doesn't matter, this will save a lot of cycles.
int RemoveListInt(object oTarget, int nValue, string sListName = "", int bMaintainOrder = FALSE);

// ---< RemoveListLocation >---
// ---< util_i_lists >---
// Removes a location of lValue from the location list sListName on oTarget and
// returns the number of items remaining in the list. If this float was added
// more than once, only the first reference is removed. If bMaintainOrder is
// TRUE, this will his shift up all entries after nIndex in the list. If FALSE,
// it will replace the removed item with the last entry in the list. If the
// order of items in the list doesn't matter, this will save a lot of cycles.
int RemoveListLocation(object oTarget, location lValue, string sListName = "", int bMaintainOrder = FALSE);

// ---< RemoveListObject >---
// ---< util_i_lists >---
// Removes an object of oValue from the object list sListName on oTarget and
// returns the number of items remaining in the list. If this float was added
// more than once, only the first reference is removed. If bMaintainOrder is
// TRUE, this will his shift up all entries after nIndex in the list. If FALSE,
// it will replace the removed item with the last entry in the list. If the
// order of items in the list doesn't matter, this will save a lot of cycles.
int RemoveListObject(object oTarget, object oValue, string sListName = "", int bMaintainOrder = FALSE);

// ---< RemoveListString >---
// ---< util_i_lists >---
// Removes a string of sValue from the object list sListName on oTarget and
// returns the number of items remaining in the list. If this float was added
// more than once, only the first reference is removed. If bMaintainOrder is
// TRUE, this will his shift up all entries after nIndex in the list. If FALSE,
// it will replace the removed item with the last entry in the list. If the
// order of items in the list doesn't matter, this will save a lot of cycles.
int RemoveListString(object oTarget, string sValue, string sListName = "", int bMaintainOrder = FALSE);

// ---< FindListFloat >---
// ---< util_i_lists >---
// Returns the index of the first reference of the float fValue in the float
// list sListName on oTarget. If it is not in the list, returns -1.
int FindListFloat(object oTarget, float fValue, string sListName = "");

// ---< FindListInt >---
// ---< util_i_lists >---
// Returns the index of the first reference of the int nValue in the int list
// sListName on oTarget. If it is not in the list, returns -1.
int FindListInt(object oTarget, int nValue, string sListName = "");

// ---< FindListLocation >---
// ---< util_i_lists >---
// Returns the index of the first reference of the location lValue in the
// location list sListName on oTarget. If it is not in the list, returns -1.
int FindListLocation(object oTarget, location lValue, string sListName = "");

// ---< FindListObject >---
// ---< util_i_lists >---
// Returns the index of the first reference of the obejct oValue in the object
// list sListName on oTarget. If it is not in the list, returns -1.
int FindListObject(object oTarget, object oValue, string sListName = "");

// ---< FindListString >---
// ---< util_i_lists >---
// Returns the index of the first reference of the string sValue in the string
// list sListName on oTarget. If it is not in the list, returns -1.
int FindListString(object oTarget, string sValue, string sListName = "");

// ---< HasListFloat >---
// ---< util_i_lists >---
// Returns whether oTarget has a float with the value fValue in its float list
// sListName.
int HasListFloat(object oTarget, float fValue, string sListName = "");

// ---< HasListInt >---
// ---< util_i_lists >---
// Returns whether oTarget has an int with the value nValue in its int list
// sListName.
int HasListInt(object oTarget, int nValue, string sListName = "");

// ---< HasListLocation >---
// ---< util_i_lists >---
// Returns whether oTarget has a location with the value lValue in its locaiton
// list sListName.
int HasListLocation(object oTarget, location lValue, string sListName = "");

// ---< HasListObject >---
// ---< util_i_lists >---
// Returns whether oTarget has an object with the value oValue in its object
// list sListName.
int HasListObject(object oTarget, object oValue, string sListName = "");

// ---< HasListString >---
// ---< util_i_lists >---
// Returns whether oTarget has a string with the value sValue in its string list
// sListName.
int HasListString(object oTarget, string sValue, string sListName = "");

// ---< DeleteFloatList >---
// ---< util_i_lists >---
// Deletes the float list sListName from oTarget.
void DeleteFloatList(object oTarget, string sListName = "");

// ---< DeleteIntList >---
// ---< util_i_lists >---
// Deletes the int list sListName from oTarget.
void DeleteIntList(object oTarget, string sListName = "");

// ---< DeleteLocationList >---
// ---< util_i_lists >---
// Deletes the location list sListName from oTarget.
void DeleteLocationList(object oTarget, string sListName = "");

// ---< DeleteObjectList >---
// ---< util_i_lists >---
// Deletes the object list sListName from oTarget.
void DeleteObjectList(object oTarget, string sListName = "");

// ---< DeleteStringList >---
// ---< util_i_lists >---
// Deletes the string list sListName from oTarget.
void DeleteStringList(object oTarget, string sListName = "");

// ---< DeclareFloatList >---
// ---< util_i_lists >---
// Creates a float list of sListName on oTarget with nCount null items. If
// oTarget already had a list with this name, that list is deleted before the
// new one is created.
void DeclareFloatList(object oTarget, int nCount, string sListName = "");

// ---< DeclareIntList >---
// ---< util_i_lists >---
// Creates an int list of sListName on oTarget with nCount null items. If
// oTarget already had a list with this name, that list is deleted before the
// new one is created.
void DeclareIntList(object oTarget, int nCount, string sListName = "");

// ---< DeclareLocationList >---
// ---< util_i_lists >---
// Creates a location list of sListName on oTarget with nCount null items. If
// oTarget already had a list with this name, that list is deleted before the
// new one is created.
void DeclareLocationList(object oTarget, int nCount, string sListName = "");

// ---< DeclareObjectList >---
// ---< util_i_lists >---
// Creates an object list of sListName on oTarget with nCount null items. If
// oTarget already had a list with this name, that list is deleted before the
// new one is created.
void DeclareObjectList(object oTarget, int nCount, string sListName = "");

// ---< DeclareStringList >---
// ---< util_i_lists >---
// Creates a string list of sListName on oTarget with nCount null items. If
// oTarget already had a list with this name, that list is deleted before the
// new one is created.
void DeclareStringList(object oTarget, int nCount, string sListName = "");

// ---< CopyFloatList >---
// ---< util_i_lists >---
// Copies the float list sSourceName from oSource to oTarget, renamed sTargetName.
void CopyFloatList(object oSource, object oTarget, string sSourceName, string sTargetName);

// ---< CopyIntList >---
// ---< util_i_lists >---
// Copies the int list sSourceName from oSource to oTarget, renamed sTargetName.
void CopyIntList(object oSource, object oTarget, string sSourceName, string sTargetName);

// ---< CopyLocationList >---
// ---< util_i_lists >---
// Copies the location list sSourceName from oSource to oTarget, renamed sTargetName.
void CopyLocationList(object oSource, object oTarget, string sSourceName, string sTargetName);

// ---< CopyObjectList >---
// ---< util_i_lists >---
// Copies the object list sSourceName from oSource to oTarget, renamed sTargetName.
void CopyObjectList(object oSource, object oTarget, string sSourceName, string sTargetName);

// ---< CopyStringList >---
// ---< util_i_lists >---
// Copies the string list sSourceName from oSource to oTarget, renamed sTargetName.
void CopyStringList(object oSource, object oTarget, string sSourceName, string sTargetName);

// ---< CountFloatList >---
// ---< util_i_lists >---
// Returns the number of items in oTarget's float list sListName.
int CountFloatList(object oTarget, string sListName = "");

// ---< CountIntList >---
// ---< util_i_lists >---
// Returns the number of items in oTarget's int list sListName.
int CountIntList(object oTarget, string sListName = "");

// ---< CountLocationList >---
// ---< util_i_lists >---
// Returns the number of items in oTarget's location list sListName.
int CountLocationList(object oTarget, string sListName = "");

// ---< CountObjectList >---
// ---< util_i_lists >---
// Returns the number of items in oTarget's object list sListName.
int CountObjectList(object oTarget, string sListName = "");

// ---< CountStringList >---
// ---< util_i_lists >---
// Returns the number of items in oTarget's string list sListName.
int CountStringList(object oTarget, string sListName = "");


//------------------------------------------------------------------------------
//                          Function Implementations
//------------------------------------------------------------------------------

// ----- String Utilities ------------------------------------------------------

int GetSubStringCount(string sString, string sSubString)
{
    // Sanity Check
    if (sSubString == "") return 0;

    int nLength = GetStringLength(sSubString);
    int nCount, nPos = FindSubString(sString, sSubString);

    while (nPos != -1)
    {
        nCount++;
        nPos = FindSubString(sString, sSubString, nPos + nLength);
    }

    return nCount;
}

string ProtectCommas(string sString, int bProtect = TRUE)
{
    if (bProtect) return StringReplace(sString, ",", COMMA);
    else          return StringReplace(sString, COMMA, ",");
}

string TrimString(string sString)
{
    while (GetStringLeft(sString, 1) == " ")
        sString = GetStringRight(sString, GetStringLength(sString) - 1);

    while (GetStringRight(sString, 1) == " ")
        sString = GetStringLeft(sString, GetStringLength(sString) - 1);

    return sString;
}


// ----- CSV Lists -------------------------------------------------------------

void ExplodeList(object oTarget, string sList, string sListName = "", int bAddUnique = FALSE, int nListType = LIST_TYPE_STRING)
{
    int    offset, len = GetStringLength(sList);
    string item, text  = sList;

    // This loop parses the list "a, b,c,d, e,f" and processes each item.
    while (text != "")
    {
        // Remove white space from the front of text
        // Remember, we're in a loop here so we may have just gone from:
        // "a, b" to " b" after "a," is stripped away. Since we want to
        // process "b" not " b" we strip away all spaces and extra commas.
        while (FindSubString(text, " ") == 0 || FindSubString(text, ",") == 0 )
            text = GetStringRight(text, --len);

        // Now find where the first item ends -- look for a comma.
        offset = FindSubString(text, ",");

        // If we found a comma there's more than one item; peel it off and
        // truncate the left side of list, removing the item and its comma.
        if (offset != -1)
        {
            item  = GetStringLeft(text, offset);
            len   -= offset+1;
            text  = GetStringRight(text, len);
        }
        // Otherwise the offset is -1, we didn't find a comma - there is only one item left.
        else
        {
            item = text;
            text = "";
        }

        // Add the item to the list.
        switch (nListType)
        {
            case LIST_TYPE_STRING: AddListString(oTarget,               item,  sListName, bAddUnique); break;
            case LIST_TYPE_INT:    AddListFloat (oTarget, StringToFloat(item), sListName, bAddUnique); break;
            case LIST_TYPE_FLOAT:  AddListInt   (oTarget, StringToInt  (item), sListName, bAddUnique); break;
        }
    }
}

string CompressList(object oTarget, string sListName = "", int bAddUnique = FALSE, int nListType = LIST_TYPE_STRING)
{
    int nCount;

    // Count the items in the list
    switch (nListType)
    {
        case LIST_TYPE_STRING: nCount = CountStringList(oTarget, sListName); break;
        case LIST_TYPE_FLOAT:  nCount = CountFloatList (oTarget, sListName); break;
        case LIST_TYPE_INT:    nCount = CountIntList   (oTarget, sListName); break;
    }

    if (!nCount)
        return "";

    // Now add the items to the compressed list
    int i;
    string sList, sListItem;
    for (i = 0; i < nCount; i++)
    {
        switch (nListType)
        {
            case LIST_TYPE_STRING: sListItem =               GetListString(oTarget, i, sListName);  break;
            case LIST_TYPE_FLOAT:  sListItem = FloatToString(GetListFloat (oTarget, i, sListName)); break;
            case LIST_TYPE_INT:    sListItem = IntToString  (GetListInt   (oTarget, i, sListName)); break;
        }

        sList = AddListItem(sList, sListItem, bAddUnique);
    }

    return sList;
}

int CountList(string sList)
{
    if (sList == "")
        return 0;

    return GetSubStringCount(sList, ",") + 1;
}

string AddListItem(string sList, string sListItem, int bAddUnique = FALSE)
{
    if (bAddUnique && HasListItem(sList, sListItem))
        return sList;

    if (sList != "")
        return sList + ", " + sListItem;

    return sListItem;
}

string GetListItem(string sList, int nNth = 0)
{
    // Sanity check.
    if (sList == "" || nNth < 0) return "";

    // Loop through the elements until we find the one we want.
    int nCount, nLeft, nRight = FindSubString(sList, ",");
    while (nRight != -1 && nCount < nNth)
    {
        nCount++;
        nLeft = nRight + 1;
        nRight = FindSubString(sList, ",", nLeft);
    }

    // If there were not enough elements, return a null string.
    if (nCount < nNth) return "";

    // Get the element
    if (nRight >= 0)
        sList = GetStringLeft(sList, nRight);
    sList = GetStringRight(sList, GetStringLength(sList) - nLeft);
    return TrimString(sList);
}

int FindListItem(string sList, string sListItem)
{
    // Sanity check.
    if (sList == "" || sListItem == "") return -1;

    // Is the item even in the list?
    int nOffset = FindSubString(sList, sListItem);
    if (nOffset == -1) return -1;

    // Quickest way to find it: count the commas that occur before the item.
    int i = GetSubStringCount(GetStringLeft(sList, nOffset), ",");

    // Make sure it's not a partial match.
    if (GetListItem(sList, i) == sListItem)
        return i;

    // Okay, so let's slim down the list and re-execute.
    string sParsed = StringParse(sList, GetListItem(sList, ++i));
    return FindListItem(StringRemoveParsed(sList, sParsed), sListItem);
}

int HasListItem(string sList, string sListItem)
{
    return (FindListItem(sList, sListItem) > -1);
}

string DeleteListItem(string sList, int nNth = 0)
{
    // Sanity check.
    if (sList == "" || nNth < 0) return "";

    // Are there enough items in the list?
    int nItems = CountList(sList);
    if (nNth > nItems) return "";

    // Count the commas until they equal the item number.
    int i;
    string sListItem, sNewList;
    for (i = 0; i < nItems; i++)
    {
        // Look for the item and remove it from the list
        sListItem = StringParse(sList, ", ");
        sList     = StringRemoveParsed(sList, sListItem, ", ");

        if (i != nNth - 1)
            sNewList = (sNewList == "" ? sListItem : sNewList + ", " + sListItem);
    }

    return sNewList;
}

string RemoveListItem(string sList, string sListItem)
{
    return DeleteListItem(sList, FindListItem(sList, sListItem));
}

string MergeLists(string sList1, string sList2, int bAddUnique = FALSE)
{
    int i, nCount = CountList(sList2);
    for (i = 0; i < nCount; i++)
        sList1 = AddListItem(sList1, GetListItem(sList2, i), bAddUnique);

    return sList1;
}


// ----- Local Variable Lists --------------------------------------------------

// List tables look like: <type>:<varname>[<index>] where type is:
// FL: Float List,    FC: Float Count
// IL: Int List,      IC: Int Count
// LL: Location List, LC: Location Count
// OL: Object List,   OC: Object Count
// SL: String List,   SC: String Count

int AddListFloat(object oTarget, float fValue, string sListName = "", int bAddUnique = FALSE)
{
    int nCount = CountFloatList(oTarget, sListName);

    // If we're adding unique we should check to see if this entry already exists
    if (bAddUnique)
    {
        int i;
        for (i = nCount-1; i >= 0; i--)
        {
            if (GetLocalFloat(oTarget, LIST_REF_FLOAT + sListName + IntToString(i)) == fValue)
                return FALSE;
        }
    }

    SetLocalFloat(oTarget, LIST_REF_FLOAT   + sListName + IntToString(nCount), fValue);
    SetLocalInt  (oTarget, LIST_COUNT_FLOAT + sListName, nCount + 1);
    return TRUE;
}

int AddListInt(object oTarget, int nValue, string sListName = "", int bAddUnique = FALSE)
{
    int nCount = CountIntList(oTarget, sListName);

    // If we're adding unique we should check to see if this entry already exists
    if (bAddUnique)
    {
        int i;
        for (i = nCount-1; i >= 0; i--)
        {
            if (GetLocalInt(oTarget, LIST_REF_INT + sListName + IntToString(i)) == nValue)
                return FALSE;
        }
    }

    SetLocalInt(oTarget, LIST_REF_INT   + sListName + IntToString(nCount), nValue);
    SetLocalInt(oTarget, LIST_COUNT_INT + sListName, nCount+1);
    return TRUE;
}

int AddListLocation(object oTarget, location lValue, string sListName = "", int bAddUnique = FALSE)
{
    int nCount = CountLocationList(oTarget, sListName);

    // If we're adding unique we should check to see if this entry already exists
    if (bAddUnique)
    {
        int i;
        for (i = nCount-1; i >= 0; i--)
        {
            if (GetLocalLocation(oTarget, LIST_REF_INT + sListName + IntToString(i)) == lValue)
                return FALSE;
        }
    }

    SetLocalLocation(oTarget, LIST_REF_LOCATION   + sListName + IntToString(nCount), lValue);
    SetLocalInt     (oTarget, LIST_COUNT_LOCATION + sListName, nCount+1);
    return TRUE;
}

int AddListObject(object oTarget, object oObject, string sListName = "", int bAddUnique = FALSE)
{
    int nCount = CountObjectList(oTarget, sListName);

    // If we're adding unique we should check to see if this entry already exists
    if (bAddUnique)
    {
        int i;
        for (i = nCount-1; i >= 0; i--)
        {
            if (GetLocalObject(oTarget, LIST_REF_OBJECT + sListName + IntToString(i)) == oObject)
                return FALSE;
        }
    }

    SetLocalObject(oTarget, LIST_REF_OBJECT   + sListName + IntToString(nCount), oObject);
    SetLocalInt   (oTarget, LIST_COUNT_OBJECT + sListName, nCount + 1);
    return TRUE;
}

int AddListString(object oTarget, string sString, string sListName = "", int bAddUnique = FALSE)
{
    int nCount = CountStringList(oTarget, sListName);

    // If we're adding unique we should check to see if this entry already exists
    if (bAddUnique)
    {
        int i;
        for (i = nCount-1; i >= 0; i--)
        {
            if (GetLocalString(oTarget, LIST_REF_STRING + sListName + IntToString(i)) == sString)
                return FALSE;
        }
    }

    SetLocalString(oTarget, LIST_REF_STRING   + sListName + IntToString(nCount), sString);
    SetLocalInt   (oTarget, LIST_COUNT_STRING + sListName, nCount + 1);
    return TRUE;
}

float GetListFloat(object oTarget, int nIndex = 0, string sListName = "")
{
    int nCount = CountFloatList(oTarget, sListName);
    if (nIndex >= nCount) return 0.0;
    return GetLocalFloat(oTarget, LIST_REF_FLOAT+sListName+IntToString(nIndex));
}

int GetListInt(object oTarget, int nIndex = 0, string sListName = "")
{
    int nCount = CountIntList(oTarget, sListName);
    if (nIndex >= nCount) return 0;
    return GetLocalInt(oTarget, LIST_REF_INT+sListName+IntToString(nIndex));
}

location GetListLocation(object oTarget, int nIndex = 0, string sListName = "")
{
    int nCount = CountLocationList(oTarget, sListName);
    if (nIndex >= nCount) return Location(OBJECT_INVALID, Vector(), 0.0);
    return GetLocalLocation(oTarget, LIST_REF_LOCATION+sListName+IntToString(nIndex));
}

object GetListObject(object oTarget, int nIndex = 0, string sListName = "")
{
    int nCount = CountObjectList(oTarget, sListName);
    if (nIndex >= nCount) return OBJECT_INVALID;
    return GetLocalObject(oTarget, LIST_REF_OBJECT+sListName+IntToString(nIndex));
}

string GetListString(object oTarget, int nIndex = 0, string sListName = "")
{
    int nCount = CountStringList(oTarget, sListName);
    if (nIndex >= nCount) return "";
    return GetLocalString(oTarget, LIST_REF_STRING+sListName+IntToString(nIndex));
}

int DeleteListFloat(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE)
{
    int nCount = CountFloatList(oTarget, sListName);

    // Sanity check
    if (nCount == 0 || nIndex >= nCount || nIndex < 0) return nCount;

    float fRef;
    if (bMaintainOrder)
    {
        // Shift all entries up
        for (nIndex; nIndex < nCount; nIndex++)
        {
            fRef = GetLocalFloat(oTarget, LIST_REF_FLOAT + sListName + IntToString(nIndex+1));
                   SetLocalFloat(oTarget, LIST_REF_FLOAT + sListName + IntToString(nIndex), fRef);
        }
    }
    else
    {
        // Replace this item with the last one in the list
        fRef = GetLocalFloat(oTarget, LIST_REF_FLOAT + sListName + IntToString(nCount - 1));
               SetLocalFloat(oTarget, LIST_REF_FLOAT + sListName + IntToString(nIndex), fRef);
    }

    // Delete the last item in the list and set the new count
    DeleteLocalFloat(oTarget, LIST_REF_FLOAT   + sListName + IntToString(--nCount));
    SetLocalInt     (oTarget, LIST_COUNT_FLOAT + sListName, nCount);

    return nCount;
}

int DeleteListInt(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE)
{
    int nCount = CountIntList(oTarget, sListName);

    // Sanity check
    if (nCount == 0 || nIndex >= nCount || nIndex < 0) return nCount;

    int nRef;
    if (bMaintainOrder)
    {
        // Shift all entries up
        for (nIndex; nIndex < nCount; nIndex++)
        {
            nRef = GetLocalInt(oTarget, LIST_REF_INT + sListName + IntToString(nIndex+1));
                   SetLocalInt(oTarget, LIST_REF_INT + sListName + IntToString(nIndex), nRef);
        }
    }
    else
    {
        // Replace this item with the last one in the list
        nRef = GetLocalInt(oTarget, LIST_REF_INT + sListName + IntToString(nCount - 1));
               SetLocalInt(oTarget, LIST_REF_INT + sListName + IntToString(nIndex), nRef);
    }

    // Delete the last item in the list and set the new count
    DeleteLocalInt(oTarget, LIST_REF_INT   + sListName + IntToString(--nCount));
    SetLocalInt   (oTarget, LIST_COUNT_INT + sListName, nCount);

    return nCount;
}

int DeleteListLocation(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE)
{
    int nCount = CountLocationList(oTarget, sListName);

    // Sanity check
    if (nCount == 0 || nIndex >= nCount || nIndex < 0) return nCount;

    location lRef;
    if (bMaintainOrder)
    {
        // Shift all entries up
        for (nIndex; nIndex < nCount; nIndex++)
        {
            lRef = GetLocalLocation(oTarget, LIST_REF_LOCATION + sListName + IntToString(nIndex+1));
                   SetLocalLocation(oTarget, LIST_REF_LOCATION + sListName + IntToString(nIndex), lRef);
        }
    }
    else
    {
        // Replace this item with the last one in the list
        lRef = GetLocalLocation(oTarget, LIST_REF_LOCATION + sListName + IntToString(nCount - 1));
               SetLocalLocation(oTarget, LIST_REF_LOCATION + sListName + IntToString(nIndex), lRef);
    }

    // Delete the last item in the list and set the new count
    DeleteLocalLocation(oTarget, LIST_REF_LOCATION   + sListName + IntToString(--nCount));
    SetLocalInt        (oTarget, LIST_COUNT_LOCATION + sListName, nCount);

    return nCount;
}

int DeleteListObject(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE)
{
    int nCount = CountObjectList(oTarget, sListName);

    // Sanity check
    if (nCount == 0 || nIndex >= nCount || nIndex < 0) return nCount;

    object oRef;
    if (bMaintainOrder)
    {
        // Shift all entries up
        for (nIndex; nIndex < nCount; nIndex++)
        {
            oRef = GetLocalObject(oTarget, LIST_REF_OBJECT + sListName + IntToString(nIndex+1));
                   SetLocalObject(oTarget, LIST_REF_OBJECT + sListName + IntToString(nIndex), oRef);
        }
    }
    else
    {
        // Replace this item with the last one in the list
        oRef = GetLocalObject(oTarget, LIST_REF_OBJECT + sListName + IntToString(nCount - 1));
               SetLocalObject(oTarget, LIST_REF_OBJECT + sListName + IntToString(nIndex), oRef);
    }

    // Delete the last item in the list and set the new count
    DeleteLocalObject(oTarget, LIST_REF_OBJECT   + sListName + IntToString(--nCount));
    SetLocalInt      (oTarget, LIST_COUNT_OBJECT + sListName, nCount);

    return nCount;
}

int DeleteListString(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE)
{
    int nCount = CountStringList(oTarget, sListName);

    // Sanity check
    if (nCount == 0 || nIndex >= nCount || nIndex < 0) return nCount;

    string sRef;
    if (bMaintainOrder)
    {
        // Shift all entries up
        for (nIndex; nIndex < nCount; nIndex++)
        {
            sRef = GetLocalString(oTarget, LIST_REF_STRING + sListName + IntToString(nIndex+1));
                   SetLocalString(oTarget, LIST_REF_STRING + sListName + IntToString(nIndex), sRef);
        }
    }
    else
    {
        // Replace this item with the last one in the list
        sRef = GetLocalString(oTarget, LIST_REF_STRING + sListName + IntToString(nCount - 1));
               SetLocalString(oTarget, LIST_REF_STRING + sListName + IntToString(nIndex), sRef);
    }

    // Delete the last item in the list and set the new count
    DeleteLocalString(oTarget, LIST_REF_STRING   + sListName + IntToString(--nCount));
    SetLocalInt      (oTarget, LIST_COUNT_STRING + sListName, nCount);

    return nCount;
}

int RemoveListFloat(object oTarget, float fValue, string sListName = "", int bMaintainOrder = FALSE)
{
    int nIndex = FindListFloat(oTarget, fValue, sListName);
    return DeleteListFloat(oTarget, nIndex, sListName, bMaintainOrder);
}

int RemoveListInt(object oTarget, int nValue, string sListName = "", int bMaintainOrder = FALSE)
{
    int nIndex = FindListInt(oTarget, nValue, sListName);
    return DeleteListInt(oTarget, nIndex, sListName, bMaintainOrder);
}

int RemoveListLocation(object oTarget, location lValue, string sListName = "", int bMaintainOrder = FALSE)
{
    int nIndex = FindListLocation(oTarget, lValue, sListName);
    return DeleteListLocation(oTarget, nIndex, sListName, bMaintainOrder);
}

int RemoveListObject(object oTarget, object oValue, string sListName = "", int bMaintainOrder = FALSE)
{
    int nIndex = FindListObject(oTarget, oValue, sListName);
    return DeleteListObject(oTarget, nIndex, sListName, bMaintainOrder);
}

int RemoveListString(object oTarget, string sValue, string sListName = "", int bMaintainOrder = FALSE)
{
    int nIndex = FindListString(oTarget, sValue, sListName);
    return DeleteListString(oTarget, nIndex, sListName, bMaintainOrder);
}

int FindListFloat(object oTarget, float fValue, string sListName = "")
{
    int i, nCount = CountFloatList(oTarget, sListName);

    for (i = 0; i < nCount; i++)
        if (GetLocalFloat(oTarget, LIST_REF_FLOAT + sListName + IntToString(i)) == fValue)
            return i;

    return -1;
}

int FindListInt(object oTarget, int nValue, string sListName = "")
{
    int i, nCount = CountIntList(oTarget, sListName);

    for (i = 0; i < nCount; i++)
        if (GetLocalInt(oTarget, LIST_REF_INT + sListName + IntToString(i)) == nValue)
            return i;

    return -1;
}

int FindListLocation(object oTarget, location lValue, string sListName = "")
{
    int i, nCount = CountLocationList(oTarget, sListName);

    for (i = 0; i < nCount; i++)
        if (GetLocalLocation(oTarget, LIST_REF_LOCATION + sListName + IntToString(i)) == lValue)
            return i;

    return -1;
}

int FindListObject(object oTarget, object oValue, string sListName = "")
{
    int i, nCount = CountObjectList(oTarget, sListName);

    for (i = 0; i < nCount; i++)
        if (GetLocalObject(oTarget, LIST_REF_OBJECT + sListName + IntToString(i)) == oValue)
            return i;

    return -1;
}

int FindListString(object oTarget, string sValue, string sListName = "")
{
    int i, nCount = CountStringList(oTarget, sListName);

    for (i = 0; i < nCount; i++)
        if (GetLocalString(oTarget, LIST_REF_STRING + sListName + IntToString(i)) == sValue)
            return i;

    return -1;
}

int HasListFloat(object oTarget, float fValue, string sListName = "")
{
    if (FindListFloat(oTarget, fValue, sListName) != -1) return TRUE;
    else                                                 return FALSE;
}

int HasListInt(object oTarget, int nValue, string sListName = "")
{
    if (FindListInt(oTarget, nValue, sListName) != -1) return TRUE;
    else                                               return FALSE;
}

int HasListLocation(object oTarget, location lValue, string sListName = "")
{
    if (FindListLocation(oTarget, lValue, sListName) != -1) return TRUE;
    else                                                    return FALSE;
}

int HasListObject(object oTarget, object oValue, string sListName = "")
{
    if (FindListObject(oTarget, oValue, sListName) != -1) return TRUE;
    else                                                  return FALSE;
}

int HasListString(object oTarget, string sValue, string sListName = "")
{
    if (FindListString(oTarget, sValue, sListName) != -1) return TRUE;
    else                                                  return FALSE;
}

void SetListFloat(object oTarget, int nIndex, float fValue, string sListName = "")
{
    int nCount = CountFloatList(oTarget, sListName);

    if (nIndex > nCount) return;

    if (nIndex == nCount)
        AddListFloat(oTarget, fValue, sListName);
    else
        SetLocalFloat(oTarget, LIST_REF_FLOAT + sListName + IntToString(nIndex), fValue);
}

void SetListInt(object oTarget, int nIndex, int nValue, string sListName = "")
{
    int nCount = CountIntList(oTarget, sListName);

    if (nIndex > nCount) return;

    if (nIndex == nCount)
        AddListInt(oTarget, nValue, sListName);
    else
        SetLocalInt(oTarget, LIST_REF_INT + sListName + IntToString(nIndex), nValue);
}

void SetListLocation(object oTarget, int nIndex, location lValue, string sListName = "")
{
    int nCount = CountLocationList(oTarget, sListName);

    if (nIndex > nCount) return;

    if (nIndex == nCount)
        AddListLocation(oTarget, lValue, sListName);
    else
        SetLocalLocation(oTarget, LIST_REF_LOCATION + sListName + IntToString(nIndex), lValue);
}

void SetListObject(object oTarget, int nIndex, object oValue, string sListName = "")
{
    int nCount = CountObjectList(oTarget, sListName);

    if (nIndex > nCount) return;

    if (nIndex == nCount)
        AddListObject(oTarget, oValue, sListName);
    else
        SetLocalObject(oTarget, LIST_REF_OBJECT + sListName + IntToString(nIndex), oValue);
}

void SetListString(object oTarget, int nIndex, string sValue, string sListName = "")
{
    int nCount = CountStringList(oTarget, sListName);

    if (nIndex > nCount) return;

    if (nIndex == nCount)
        AddListString(oTarget, sValue, sListName);
    else
        SetLocalString(oTarget, LIST_REF_STRING + sListName + IntToString(nIndex), sValue);
}

void DeleteFloatList(object oTarget, string sListName = "")
{
    int i, nCount = CountFloatList(oTarget, sListName);
    for (i = 0; i < nCount; i++)
        DeleteLocalFloat(oTarget, LIST_REF_FLOAT+sListName+IntToString(i));

    DeleteLocalInt(oTarget, LIST_COUNT_FLOAT+sListName);
}

void DeleteIntList(object oTarget, string sListName = "")
{
    int i, nCount = CountIntList(oTarget, sListName);
    for (i = 0; i < nCount; i++)
        DeleteLocalInt(oTarget, LIST_REF_INT+sListName+IntToString(i));

    DeleteLocalInt(oTarget, LIST_COUNT_INT+sListName);
}

void DeleteLocationList(object oTarget, string sListName = "")
{
    int i, nCount = CountLocationList(oTarget, sListName);
    for (i = 0; i < nCount; i++)
        DeleteLocalLocation(oTarget, LIST_REF_LOCATION+sListName+IntToString(i));

    DeleteLocalInt(oTarget, LIST_COUNT_LOCATION+sListName);
}

void DeleteObjectList(object oTarget, string sListName = "")
{
    int i, nCount = CountObjectList(oTarget, sListName);
    for (i = 0; i < nCount; i++)
        DeleteLocalObject(oTarget, LIST_REF_OBJECT+sListName+IntToString(i));

    DeleteLocalInt(oTarget, LIST_COUNT_STRING+sListName);
}

void DeleteStringList(object oTarget, string sListName = "")
{
    int i, nCount = CountStringList(oTarget, sListName);
    for (i = 0; i < nCount; i++)
        DeleteLocalString(oTarget, LIST_REF_STRING+sListName+IntToString(i));

    DeleteLocalInt(oTarget, LIST_COUNT_STRING+sListName);
}

void DeclareFloatList(object oTarget, int nCount, string sListName = "")
{
    DeleteFloatList(oTarget, sListName);
    SetLocalInt(oTarget, LIST_COUNT_FLOAT + sListName, nCount);
}

void DeclareIntList(object oTarget, int nCount, string sListName = "")
{
    DeleteIntList(oTarget, sListName);
    SetLocalInt(oTarget, LIST_COUNT_INT + sListName, nCount);
}

void DeclareLocationList(object oTarget, int nCount, string sListName = "")
{
    DeleteLocationList(oTarget, sListName);
    SetLocalInt(oTarget, LIST_COUNT_LOCATION + sListName, nCount);
}

void DeclareObjectList(object oTarget, int nCount, string sListName = "")
{
    DeleteObjectList(oTarget, sListName);
    SetLocalInt(oTarget, LIST_COUNT_OBJECT + sListName, nCount);
}

void DeclareStringList(object oTarget, int nCount, string sListName = "")
{
    DeleteStringList(oTarget, sListName);
    SetLocalInt(oTarget, LIST_COUNT_STRING + sListName, nCount);
}

// WARNING!! Extremely long list management can cause TMI; this list code
// is expensive. It is NOT recommended that you create long lists.
void CopyFloatList(object oSource, object oTarget, string sSourceName, string sTargetName)
{
    string sSourceItem, sTargetItem;
    int    nCount = CountFloatList(oSource, sSourceName);

    DeclareFloatList(oTarget, nCount, sTargetName);

    for (nCount--; nCount >= 0; nCount--)
    {
        sSourceItem = LIST_REF_FLOAT+sSourceName+IntToString(nCount);
        sTargetItem = LIST_REF_FLOAT+sTargetName+IntToString(nCount);
        SetLocalFloat(oTarget, sTargetItem, GetLocalFloat(oSource, sSourceItem));
    }
}

void CopyIntList(object oSource, object oTarget, string sSourceName, string sTargetName)
{
    string sSourceItem, sTargetItem;
    int    nCount = CountIntList(oSource, sSourceName);

    DeclareIntList(oTarget, nCount, sTargetName);

    for (nCount--; nCount >= 0; nCount--)
    {
        sSourceItem = LIST_REF_INT+sSourceName+IntToString(nCount);
        sTargetItem = LIST_REF_INT+sTargetName+IntToString(nCount);
        SetLocalInt(oTarget, sTargetItem, GetLocalInt(oSource, sSourceItem));
    }
}

void CopyLocationList(object oSource, object oTarget, string sSourceName, string sTargetName)
{
    string sSourceItem, sTargetItem;
    int    nCount = CountLocationList(oSource, sSourceName);

    DeclareLocationList(oTarget, nCount, sTargetName);

    for (nCount--; nCount >= 0; nCount--)
    {
        sSourceItem = LIST_REF_LOCATION+sSourceName+IntToString(nCount);
        sTargetItem = LIST_REF_LOCATION+sTargetName+IntToString(nCount);
        SetLocalLocation(oTarget, sTargetItem, GetLocalLocation(oSource, sSourceItem));
    }
}

void CopyObjectList(object oSource, object oTarget, string sSourceName, string sTargetName)
{
    string sSourceItem, sTargetItem;
    int    nCount = CountObjectList(oSource, sSourceName);

    DeclareObjectList(oTarget, nCount, sTargetName);

    for (nCount--; nCount >= 0; nCount--)
    {
        sSourceItem = LIST_REF_OBJECT+sSourceName+IntToString(nCount);
        sTargetItem = LIST_REF_OBJECT+sTargetName+IntToString(nCount);
        SetLocalObject(oTarget, sTargetItem, GetLocalObject(oSource, sSourceItem));
    }
}

void CopyStringList(object oSource, object oTarget, string sSourceName, string sTargetName)
{
    string sSourceItem, sTargetItem;
    int    nCount = CountStringList(oSource, sSourceName);

    DeclareStringList(oTarget, nCount, sTargetName);

    for (nCount--; nCount >= 0; nCount--)
    {
        sSourceItem = LIST_REF_STRING+sSourceName+IntToString(nCount);
        sTargetItem = LIST_REF_STRING+sTargetName+IntToString(nCount);
        SetLocalString(oTarget, sTargetItem, GetLocalString(oSource, sSourceItem));
    }
}

int CountFloatList(object oTarget, string sListName = "")
{
    return GetLocalInt(oTarget, LIST_COUNT_FLOAT+sListName);
}

int CountIntList(object oTarget, string sListName = "")
{
    return GetLocalInt(oTarget, LIST_COUNT_INT+sListName);
}

int CountLocationList(object oTarget, string sListName = "")
{
    return GetLocalInt(oTarget, LIST_COUNT_LOCATION+sListName);
}

int CountObjectList(object oTarget, string sListName = "")
{
    return GetLocalInt(oTarget, LIST_COUNT_OBJECT+sListName);
}

int CountStringList(object oTarget, string sListName = "")
{
    return GetLocalInt(oTarget, LIST_COUNT_STRING+sListName);
}
