/// ----------------------------------------------------------------------------
/// @file   util_t_csvlists.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Functions for unit-testing comma-separated value (CSV) lists.
/// @details
///
/// This testing script uses variable naming conventions as outlined in
///     util_i_unittest.  In addition, the following terms are used:
///
///     Abnormal List - a comma-delimited list containing excess spaces,
///         empty items, leading commas, trailing commas and/or any/all
///         combinations of these characteristics.
///     Extended List - a comma-delimited list containing excess empty
///         items.  This list can include leading and trailing commas,
///         or simply an entire string of nothing but commas, but should
///         not have excess spaces around the commas or any items.  This
///         type of list can be created with NormalizeList(sList, FALSE).
///     Normal List - a comma-delimited list containing only valid items,
///         without empty items, leading commas or trailing commas.  This
///         type of list can be created with NormalizeList(sList, TRUE).
///         A single-item list without commas and an empty list are considered
///         Normal Lists, but will be tested separately in this suite.
/// ----------------------------------------------------------------------------

#include "util_i_csvlists"
#include "util_i_unittest"

// An abnormal list.
string sInputAbnormal = ",   ,one  ,two,,item four,,,,,seven,   ,,, ,,         ,";
int    nCountAbnormal = 18;

// A normalized list without empty elements.
string sInputNormal = "one,two,item four,seven";
int    nCountNormal = 4;

// A normalized list with empty elements.
string sInputExtended = ",,one,two,,item four,,,,,seven,,,,,,,";
int    nCountExtended = 18;

// A list with only one element.
string sInputSingle = "single item";
int    nCountSingle = 1;

// An empty list.
string sInputEmpty = "";
int    nCountEmpty = 0;

// @TESTSUITE[CSV Lists]
// @TESTGROUP[CSV Lists]

// NormalizeList()
// (1) Test list normalization with `bRemoveEmpty` = FALSE.  This should remove all excess
//      spaces both before and after all commas, but leave spaces within item phrases.
//      Trailing commas will remain as no commas are removed.
// (2) Test list normalization with `bRemoveEmpty` = TRUE.  This should remove all empty
//      items, resulting in a list with no spaces either before or after any comma, and
//      no leading or trailing commas.
// (3) Test list normalization with a single-entry list.  There should be no change to the
//      input list.
// (4) Test list normalization with an empty list.  There should be no change to the input
//      list.

// @TEST[NormalizeList()]
int test_csvlists_NormalizeList()
{
    int    t1, t2, t3, t4, tGroup;
    int    b1, b2, b3, b4;
    string r1, r2, r3, r4;

    tGroup       = Timer();
    /* (1) */ t1 = Timer(); r1 = NormalizeList(sInputAbnormal);       t1 = Timer(t1);
    /* (2) */ t2 = Timer(); r2 = NormalizeList(sInputAbnormal, TRUE); t2 = Timer(t2);
    /* (3) */ t3 = Timer(); r3 = NormalizeList(sInputSingle, TRUE);   t3 = Timer(t3);
    /* (4) */ t4 = Timer(); r4 = NormalizeList(sInputEmpty, TRUE);    t4 = Timer(t4);
    tGroup       = Timer(tGroup);

    int bGroup = (b1 = r1 == sInputExtended) &
                 (b2 = r2 == sInputNormal)   &
                 (b3 = r3 == sInputSingle)   &
                 (b4 = r4 == sInputEmpty);

    if (!AssertGroup("NormalizeList()", bGroup))
    {
        if (!Assert("Keep Empty Values in List", b1))
            DescribeTestParameters(sInputAbnormal, sInputExtended, r1);
        DescribeTestTime(t1);

        if (!Assert("Remove Empty Values from List", b2))
            DescribeTestParameters(sInputAbnormal, sInputNormal, r2);
        DescribeTestTime(t2);

        if (!Assert("Single Item List", b3))
            DescribeTestParameters(sInputSingle, sInputSingle, r3);
        DescribeTestTime(t3);

        if (!Assert("Empty List", b4))
            DescribeTestParameters(sInputEmpty, sInputEmpty, r4);
        DescribeTestTime(t4);
    } DescribeGroupTime(tGroup); Outdent();

    return bGroup;
}

// CountList()
// (1) Test list count for a normalized list with empty elements.
// (2) Test list count for a non-normalized list with empty elements.
// (3) Test list count for a normalized list without empty elements.
// (4) Test list count for a single item list.
// (5) Test list count for an empty list.

// @TEST[CountList()]
int test_csvlists_CountList()
{
    int t1, t2, t3, t4, t5, tGroup;
    int b1, b2, b3, b4, b5;
    int r1, r2, r3, r4, r5;

    tGroup       = Timer();
    /* (1) */ t1 = Timer(); r1 = CountList(sInputExtended); t1 = Timer(t1);
    /* (2) */ t2 = Timer(); r2 = CountList(sInputAbnormal); t2 = Timer(t2);
    /* (3) */ t3 = Timer(); r3 = CountList(sInputNormal);   t3 = Timer(t3);
    /* (4) */ t4 = Timer(); r4 = CountList(sInputSingle);   t4 = Timer(t4);
    /* (5) */ t5 = Timer(); r5 = CountList(sInputEmpty);    t5 = Timer(t5);
    tGroup       = Timer(tGroup);

    int bGroup = (b1 = r1 == nCountExtended) &
                 (b2 = r2 == nCountAbnormal) &
                 (b3 = r3 == nCountNormal)   &
                 (b4 = r4 == nCountSingle)   &
                 (b5 = r5 == nCountEmpty);

    if (!AssertGroup("CountList()", bGroup))
    {
        if (!Assert("Normal List with Empty Items", b1))
            DescribeTestParameters(sInputExtended, _i(nCountExtended), _i(r1));
        DescribeTestTime(t1);

        if (!Assert("Abnormal List", b2))
            DescribeTestParameters(sInputAbnormal, _i(nCountAbnormal), _i(r2));
        DescribeTestTime(t2);

        if (!Assert("Normal List without Empty Items", b3))
            DescribeTestParameters(sInputNormal, _i(nCountNormal), _i(r3));
        DescribeTestTime(t3);

        if (!Assert("Single Item List", b4))
            DescribeTestParameters(sInputSingle, _i(nCountSingle), _i(r4));
        DescribeTestTime(t4);

        if (!Assert("Empty List", b5))
            DescribeTestParameters(sInputEmpty, _i(nCountEmpty), _i(r5));
        DescribeTestTime(t5);
    } DescribeGroupTime(tGroup); Outdent();

    return bGroup;
}

// AddListItem()
// (1) Add unique item to abnormal list.
// (2) Add unique item to extended list.
// (3) Add unique item to normal list.
// (4) Add duplicate item to extended list, allowing duplicates.
// (5) Add duplicate item to extended list, not allowing duplicates.
// (6) Add duplicate item to normal list, allowing duplicates.
// (7) Add duplicate item to normal list, not allowing duplicates.

// @TEST[AddListItem()]
int test_csvlists_AddListItem()
{
    int    t1, t2, t3, t4, t5, t6, t7, tGroup;
    int    b1, b2, b3, b4, b5, b6, b7;
    string r1, r2, r3, r4, r5, r6, r7;
    string e1, e2, e3, e4, e5, e6, e7;

    string sItemUnique = "nine";
    string sItemDuplicate = "two";

    e1 = sInputAbnormal + "," + sItemUnique;
    e2 = sInputExtended + "," + sItemUnique;
    e3 = sInputNormal   + "," + sItemUnique;
    e4 = sInputExtended + "," + sItemDuplicate;
    e5 = sInputExtended;
    e6 = sInputNormal   + "," + sItemDuplicate;
    e7 = sInputNormal;

    tGroup       = Timer();
    /* (1) */ t1 = Timer(); r1 = AddListItem(sInputAbnormal, sItemUnique);          t1 = Timer(t1);
    /* (2) */ t2 = Timer(); r2 = AddListItem(sInputExtended, sItemUnique);          t2 = Timer(t2);
    /* (3) */ t3 = Timer(); r3 = AddListItem(sInputNormal,   sItemUnique);          t3 = Timer(t3);
    /* (4) */ t4 = Timer(); r4 = AddListItem(sInputExtended, sItemDuplicate);       t4 = Timer(t4);
    /* (5) */ t5 = Timer(); r5 = AddListItem(sInputExtended, sItemDuplicate, TRUE); t5 = Timer(t5);
    /* (6) */ t6 = Timer(); r6 = AddListItem(sInputNormal,   sItemDuplicate);       t6 = Timer(t6);
    /* (7) */ t7 = Timer(); r7 = AddListItem(sInputNormal,   sItemDuplicate, TRUE); t7 = Timer(t7);
    tGroup       = Timer(tGroup);

    int bGroup = (b1 = r1 == e1) &
                 (b2 = r2 == e2) &
                 (b3 = r3 == e3) &
                 (b4 = r4 == e4) &
                 (b5 = r5 == e5) &
                 (b6 = r6 == e6) &
                 (b7 = r7 == e7);

    if (!AssertGroup("AddListItem()", bGroup))
    {
        if (!Assert("Abnormal List + Unique", b1))
            DescribeTestParameters(sInputAbnormal + " :: " + sItemUnique, e1, r1);
        DescribeTestTime(t1);

        if (!Assert("Extended List + Unique", b2))
            DescribeTestParameters(sInputExtended + " :: " + sItemUnique, e2, r2);
        DescribeTestTime(t2);

        if (!Assert("Normal List + Unique", b3))
            DescribeTestParameters(sInputNormal + " :: " + sItemUnique, e3, r3);
        DescribeTestTime(t3);

        if (!Assert("Extended List + Dupe (Allowed)", b4))
            DescribeTestParameters(sInputExtended + " :: " + sItemDuplicate, e4, r4);
        DescribeTestTime(t4);

        if (!Assert("Extended List + Dupe (Not Allowed)", b5))
            DescribeTestParameters(sInputExtended + " :: " + sItemDuplicate, e5, r5);
        DescribeTestTime(t5);

        if (!Assert("Normal List + Dupe (Allowed)", b6))
            DescribeTestParameters(sInputNormal + " :: " + sItemDuplicate, e6, r6);
        DescribeTestTime(t6);

        if (!Assert("Normal List + Dupe (Not Allowed)", b7))
            DescribeTestParameters(sInputNormal + " :: " + sItemDuplicate, e7, r7);
        DescribeTestTime(t7);
    } DescribeGroupTime(tGroup); Outdent();

    return bGroup;
}

// InsertListItem()
// (1) Insert unique item to abnormal list @ nIndex.
// (2) Insert unique item to extended list @ nIndex.
// (3) Insert unique item to normal list @ nIndex.
// (4) Insert duplicate item to extended list, allowing duplicates,  @ nIndex.
// (5) Insert duplicate item to extended list, not allowing duplicates,  @ nIndex.
// (6) Insert duplicate item to normal list, allowing duplicates,  @ nIndex.
// (7) Insert duplicate item to normal list, not allowing duplicates,  @ nIndex.
// (8) Insert any item outside the list's range.

// @TEST[InsertListItem()]
int test_csvlists_InsertListItem()
{
    string sInputAbnormal = ", ,,one,two ,  item three,   ,dupe, ";
    string sInputExtended = ",,,one,two,item three,,dupe,";
    string sInputNormal = "one,two,item_three,dupe";

    int    t1, t2, t3, t4, t5, t6, t7, t8, tGroup;
    int    b1, b2, b3, b4, b5, b6, b7, b8;
    string r1, r2, r3, r4, r5, r6, r7, r8;
    string e1, e2, e3, e4, e5, e6, e7, e8;

    string sItemUnique = "unique";
    string sItemDuplicate = "dupe";
    int    nIndex = 1;
    int    nBadIndex = 100;

    e1 = ",unique, ,,one,two ,  item three,   ,dupe, ";
    e2 = ",unique,,,one,two,item three,,dupe,";
    e3 = "one,unique,two,item_three,dupe";
    e4 = ",dupe,,,one,two,item three,,dupe,";
    e5 = ",dupe,one,two,item three";
    e6 = "one,dupe,two,item_three,dupe";
    e7 = "one,dupe,two,item_three";
    e8 = "one,two,item_three,dupe";

    tGroup       = Timer();
    /* (1) */ t1 = Timer(); r1 = InsertListItem(sInputAbnormal, sItemUnique,    nIndex);       t1 = Timer(t1);
    /* (2) */ t2 = Timer(); r2 = InsertListItem(sInputExtended, sItemUnique,    nIndex);       t2 = Timer(t2);
    /* (3) */ t3 = Timer(); r3 = InsertListItem(sInputNormal,   sItemUnique,    nIndex);       t3 = Timer(t3);
    /* (4) */ t4 = Timer(); r4 = InsertListItem(sInputExtended, sItemDuplicate, nIndex);       t4 = Timer(t4);
    /* (5) */ t5 = Timer(); r5 = InsertListItem(sInputExtended, sItemDuplicate, nIndex, TRUE); t5 = Timer(t5);
    /* (6) */ t6 = Timer(); r6 = InsertListItem(sInputNormal,   sItemDuplicate, nIndex);       t6 = Timer(t6);
    /* (7) */ t7 = Timer(); r7 = InsertListItem(sInputNormal,   sItemDuplicate, nIndex, TRUE); t7 = Timer(t7);
    /* (8) */ t8 = Timer(); r8 = InsertListItem(sInputNormal,   sItemUnique,    nBadIndex);    t8 = Timer(t8);
    tGroup       = Timer(tGroup);

    int bGroup = (b1 = r1 == e1) &
                 (b2 = r2 == e2) &
                 (b3 = r3 == e3) &
                 (b4 = r4 == e4) &
                 (b5 = r5 == e5) &
                 (b6 = r6 == e6) &
                 (b7 = r7 == e7) &
                 (b8 = r8 == e8);

    if (!AssertGroup("InsertListItem()", bGroup))
    {
        if (!Assert("Abnormal List + Unique", b1))
            DescribeTestParameters(sInputAbnormal + " :: " + sItemUnique + " :: " + _i(nIndex), e1, r1);
        DescribeTestTime(t1);

        if (!Assert("Extended List + Unique", b2))
            DescribeTestParameters(sInputExtended + " :: " + sItemUnique + " :: " + _i(nIndex), e2, r2);
        DescribeTestTime(t2);

        if (!Assert("Normal List + Unique", b3))
            DescribeTestParameters(sInputNormal + " :: " + sItemUnique + " :: " + _i(nIndex), e3, r3);
        DescribeTestTime(t3);

        if (!Assert("Extended List + Dupe (Allowed)", b4))
            DescribeTestParameters(sInputExtended + " :: " + sItemDuplicate + " :: " + _i(nIndex), e4, r4);
        DescribeTestTime(t4);

        if (!Assert("Extended List + Dupe (Not Allowed)", b5))
            DescribeTestParameters(sInputExtended + " :: " + sItemDuplicate + " :: " + _i(nIndex), e5, r5);
        DescribeTestTime(t5);

        if (!Assert("Normal List + Dupe (Allowed)", b6))
            DescribeTestParameters(sInputNormal + " :: " + sItemDuplicate + " :: " + _i(nIndex), e6, r6);
        DescribeTestTime(t6);

        if (!Assert("Normal List + Dupe (Not Allowed)", b7))
            DescribeTestParameters(sInputNormal + " :: " + sItemDuplicate + " :: " + _i(nIndex), e7, r7);
        DescribeTestTime(t7);

        if (!Assert("Insert Outside List Range", b8))
            DescribeTestParameters(sInputNormal + " :: " + sItemUnique + " :: " + _i(nBadIndex), e8, r8);
        DescribeTestTime(t8);
    } DescribeGroupTime(tGroup); Outdent();

    return bGroup;
}

// SetListItem()
// (1) Set unique item to abnormal list @ nIndex.
// (2) Set unique item to extended list @ nIndex.
// (3) Set unique item to normal list @ nIndex.
// (4) Set duplicate item to extended list, allowing duplicates,  @ nIndex.
// (5) Set duplicate item to extended list, not allowing duplicates,  @ nIndex.
// (6) Set duplicate item to normal list, allowing duplicates,  @ nIndex.
// (7) Set duplicate item to normal list, not allowing duplicates,  @ nIndex.
// (8) Set any item outside the list's range

// @TEST[SetListItem()]
int test_csvlists_SetListItem()
{
    string sInputAbnormal = ", ,,one,two ,  item three,   ,dupe, ";
    string sInputExtended = ",,,one,two,item three,,dupe,";
    string sInputNormal = "one,two,item_three,dupe";

    int    t1, t2, t3, t4, t5, t6, t7, t8, tGroup;
    int    b1, b2, b3, b4, b5, b6, b7, b8;
    string r1, r2, r3, r4, r5, r6, r7, r8;
    string e1, e2, e3, e4, e5, e6, e7, e8;

    string sItemUnique = "unique";
    string sItemDuplicate = "dupe";
    int    nIndex = 1;
    int    nBadIndex = 100;

    e1 = ",unique,,one,two ,  item three,   ,dupe, ";
    e2 = ",unique,,one,two,item three,,dupe,";
    e3 = "one,unique,item_three,dupe";
    e4 = ",dupe,,one,two,item three,,dupe,";
    e5 = ",dupe,one,two,item three";
    e6 = "one,dupe,item_three,dupe";
    e7 = "one,dupe,item_three";
    e8 = "one,two,item_three,dupe";

    tGroup       = Timer();
    /* (1) */ t1 = Timer(); r1 = SetListItem(sInputAbnormal, sItemUnique,    nIndex);       t1 = Timer(t1);
    /* (2) */ t2 = Timer(); r2 = SetListItem(sInputExtended, sItemUnique,    nIndex);       t2 = Timer(t2);
    /* (3) */ t3 = Timer(); r3 = SetListItem(sInputNormal,   sItemUnique,    nIndex);       t3 = Timer(t3);
    /* (4) */ t4 = Timer(); r4 = SetListItem(sInputExtended, sItemDuplicate, nIndex);       t4 = Timer(t4);
    /* (5) */ t5 = Timer(); r5 = SetListItem(sInputExtended, sItemDuplicate, nIndex, TRUE); t5 = Timer(t5);
    /* (6) */ t6 = Timer(); r6 = SetListItem(sInputNormal,   sItemDuplicate, nIndex);       t6 = Timer(t6);
    /* (7) */ t7 = Timer(); r7 = SetListItem(sInputNormal,   sItemDuplicate, nIndex, TRUE); t7 = Timer(t7);
    /* (8) */ t8 = Timer(); r8 = SetListItem(sInputNormal,   sItemUnique,    nBadIndex);    t8 = Timer(t8);
    tGroup       = Timer(tGroup);

    int bGroup = (b1 = r1 == e1) &
                 (b2 = r2 == e2) &
                 (b3 = r3 == e3) &
                 (b4 = r4 == e4) &
                 (b5 = r5 == e5) &
                 (b6 = r6 == e6) &
                 (b7 = r7 == e7) &
                 (b8 = r8 == e8);

    if (!AssertGroup("SetListItem()", bGroup))
    {
        if (!Assert("Abnormal List + Unique", b1))
            DescribeTestParameters(sInputAbnormal + " :: " + sItemUnique + " :: " + _i(nIndex), e1, r1);
        DescribeTestTime(t1);

        if (!Assert("Extended List + Unique", b2))
            DescribeTestParameters(sInputExtended + " :: " + sItemUnique + " :: " + _i(nIndex), e2, r2);
        DescribeTestTime(t2);

        if (!Assert("Normal List + Unique", b3))
            DescribeTestParameters(sInputNormal + " :: " + sItemUnique + " :: " + _i(nIndex), e3, r3);
        DescribeTestTime(t3);

        if (!Assert("Extended List + Dupe (Allowed)", b4))
            DescribeTestParameters(sInputExtended + " :: " + sItemDuplicate + " :: " + _i(nIndex), e4, r4);
        DescribeTestTime(t4);

        if (!Assert("Extended List + Dupe (Not Allowed)", b5))
            DescribeTestParameters(sInputExtended + " :: " + sItemDuplicate + " :: " + _i(nIndex), e5, r5);
        DescribeTestTime(t5);

        if (!Assert("Normal List + Dupe (Allowed)", b6))
            DescribeTestParameters(sInputNormal + " :: " + sItemDuplicate + " :: " + _i(nIndex), e6, r6);
        DescribeTestTime(t6);

        if (!Assert("Normal List + Dupe (Not Allowed)", b7))
            DescribeTestParameters(sInputNormal + " :: " + sItemDuplicate + " :: " + _i(nIndex), e7, r7);
        DescribeTestTime(t7);

        if (!Assert("Insert Outside List Range", b8))
            DescribeTestParameters(sInputNormal + " :: " + sItemUnique + " :: " + _i(nBadIndex), e8, r8);
        DescribeTestTime(t8);
    } DescribeGroupTime(tGroup); Outdent();

    return bGroup;
}

// GetListItem()
// (1) Get Item from Abnormal List.
// (2) Get Item from Extended List.
// (3) Get Item from Normal List.
// (4) Get Item from outside list's range.
// (5) Get Item from single-item list.

// @TEST[GetListItem()]
int test_csvlists_GetListItem()
{
    int    t1, t2, t3, t4, t5, tGroup;
    int    b1, b2, b3, b4, b5;
    string r1, r2, r3, r4, r5;
    string e1, e2, e3, e4, e5;

    int    nIndex = 2;
    int    nBadIndex = 100;

    e1 = "one";
    e2 = "one";
    e3 = "item four";
    e4 = "";
    e5 = "single item";

    tGroup       = Timer();
    /* (1) */ t1 = Timer(); r1 = GetListItem(sInputAbnormal, nIndex);     t1 = Timer(t1);
    /* (2) */ t2 = Timer(); r2 = GetListItem(sInputExtended, nIndex);     t2 = Timer(t2);
    /* (3) */ t3 = Timer(); r3 = GetListItem(sInputNormal,   nIndex);     t3 = Timer(t3);
    /* (4) */ t4 = Timer(); r4 = GetListItem(sInputNormal,   nBadIndex);  t4 = Timer(t4);
    /* (5) */ t5 = Timer(); r5 = GetListItem(sInputSingle,   0);          t5 = Timer(t5);
    tGroup       = Timer(tGroup);

    int bGroup = (b1 = r1 == e1) &
                 (b2 = r2 == e2) &
                 (b3 = r3 == e3) &
                 (b4 = r4 == e4) &
                 (b5 = r5 == e5);

    if (!AssertGroup("GetListItem()", bGroup))
    {
        if (!Assert("Abnormal List", b1))
            DescribeTestParameters(sInputAbnormal + " :: " + _i(nIndex), e1, r1);
        DescribeTestTime(t1);

        if (!Assert("Extended List", b2))
            DescribeTestParameters(sInputExtended + " :: " + _i(nIndex), e2, r2);
        DescribeTestTime(t2);

        if (!Assert("Normal List", b3))
            DescribeTestParameters(sInputNormal + " :: " + _i(nIndex), e3, r3);
        DescribeTestTime(t3);

        if (!Assert("Outside List Range", b4))
            DescribeTestParameters(sInputNormal + " :: " + _i(nBadIndex), e4, r4);
        DescribeTestTime(t4);

        if (!Assert("Single Item List", b5))
            DescribeTestParameters(sInputSingle + " :: " + _i(0), e5, r5);
        DescribeTestTime(t5);
    } DescribeGroupTime(tGroup); Outdent();

    return bGroup;
}

// FindListItem()
// (1) Find Item in Abnormal List.
// (2) Find Item in Extended List.
// (3) Find Item in Normal List.
// (4) Find Item in outside list's range.
// (5) Find item in single-item list.

// @TEST[FindListItem()]
int test_csvlists_FindListItem()
{
    int t1, t2, t3, t4, t5, tGroup;
    int b1, b2, b3, b4, b5;
    int r1, r2, r3, r4, r5;
    int e1, e2, e3, e4, e5;

    string sFind = "one";
    string sFindSingle = "single item";

    e1 = -1;
    e2 = 2;
    e3 = 0;
    e4 = -1;
    e5 = 0;

    tGroup       = Timer();
    /* (1) */ t1 = Timer(); r1 = FindListItem(sInputAbnormal, sFind);       t1 = Timer(t1);
    /* (2) */ t2 = Timer(); r2 = FindListItem(sInputExtended, sFind);       t2 = Timer(t2);
    /* (3) */ t3 = Timer(); r3 = FindListItem(sInputNormal,   sFind);       t3 = Timer(t3);
    /* (4) */ t4 = Timer(); r4 = FindListItem(sInputNormal,   sFindSingle); t4 = Timer(t4);
    /* (5) */ t5 = Timer(); r5 = FindListItem(sInputSingle,   sFindSingle); t5 = Timer(t5);
    tGroup       = Timer(tGroup);

    int bGroup = (b1 = r1 == e1) &
                 (b2 = r2 == e2) &
                 (b3 = r3 == e3) &
                 (b4 = r4 == e4) &
                 (b5 = r5 == e5);

    if (!AssertGroup("FindListItem() [Infers HasListItem()]", bGroup))
    {
        if (!Assert("Abnormal List", b1))
            DescribeTestParameters(sInputAbnormal + " :: " + sFind, _i(e1), _i(r1));
        DescribeTestTime(t1);

        if (!Assert("Extended List", b2))
            DescribeTestParameters(sInputExtended + " :: " + sFind, _i(e2), _i(r2));
        DescribeTestTime(t2);

        if (!Assert("Normal List", b3))
            DescribeTestParameters(sInputNormal + " :: " + sFind, _i(e3), _i(r3));
        DescribeTestTime(t3);

        if (!Assert("Outside List Range", b4))
            DescribeTestParameters(sInputNormal + " :: " + sFindSingle, _i(e4), _i(r4));
        DescribeTestTime(t4);

        if (!Assert("Single Item List", b5))
            DescribeTestParameters(sInputSingle + " :: " + sFindSingle, _i(e5), _i(r5));
        DescribeTestTime(t5);
    } DescribeGroupTime(tGroup); Outdent();

    return bGroup;
}


void main()
{
    DescribeTestSuite("Running Unit Test Suite for CSV Lists (util_i_csvlists.nss)");

    test_csvlists_NormalizeList();
    test_csvlists_CountList();
    test_csvlists_AddListItem();
    test_csvlists_InsertListItem();
    test_csvlists_SetListItem();
    test_csvlists_GetListItem();
    test_csvlists_FindListItem();

}