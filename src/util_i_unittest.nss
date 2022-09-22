/// ----------------------------------------------------------------------------
/// @file   util_i_unittest.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Functions for managing unit test reporting
/// ----------------------------------------------------------------------------
/// @details
///
/// The following example shows how to create a grouped assertion and display
///     only relevant results, assuming only assertion failures are of
//      interest.
    /*
    string sVarName = "TEST";

    // Conduct the unit testing and store the results
    int a, b, c;

    a = 751;
    SetLocaInt(GetModule(), "TEST", a);
    b = GetLocalInt(GetModule(), "TEST");
    DeleteLocalInt(GetModule(), "TEST");
    c = GetLocalInt(GetModule(), "TEST");

    // Conduct the assertions to display the results
    // Using a group assertion will provide for collapsed results to
    //  prevent spamming the chat window. The AssertGroup() function
    //  returns the result of the assertion, so it can be used to
    //  allow/prevent the display of expanded results. If display
    //  of the individual assertions is desired, remove the not (!) or
    //  use DescribeGroupTest() to add a title without an assertion result.
    if (!AssertGroup("[Set|Get|Delete]PlayerInt", a == b && c == 0))
    {
        // If the Group Assertion fails, the individual assertions that
        //  make up the group assertion can be displayed. Like AssertGroup(),
        //  Assert() returns the result of the assertion, so it can be used
        //  to prevent displaying passing results when only failing results
        //  are of interest
        if (!Assert("SetPlayerInt", a == b))
            AssertParameters(IntToString(a), IntToString(a), IntToString(b));

        if (!Assert("GetPlayerInt", a == b))
            AssertParameters(IntToString(a), IntToString(a), IntToString(b));

        if (!Assert("DeletePlayerInt", c == 0))
            AssertParameters(IntToString(a), IntToString(0), IntToString(c));
    } ResetIndent();
    */
    // Note:  Use of ResetIndent() or another indentation function, such as
    //  Outdent() may be required if moving to another group assertion.


#include "util_c_unittest"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

string TEST_INDENT = "TEST_INDENT";

string TEST_PASS      = HexColorString("PASS", COLOR_GREEN_LIGHT);
string TEST_FAIL      = HexColorString("FAIL", COLOR_RED_LIGHT);
string TEST_DELIMITER = HexColorString(" | ", COLOR_WHITE);

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Reset the indentation level used in displaying test results.
/// @returns The indenation string used to pad test result output.
string ResetIndent();

/// @brief Indent test results display by one indentation level.
/// @param bReset If TRUE, will reset the indentation level to 0 before
///     adding an indentation level.
/// @returns The indenation string used to pad test result output.
string Indent(int bReset = FALSE);

/// @brief Outdent test results display by one indentation level.
/// @returns The indenation string used to pad test result output.
string Outdent();

/// @brief Provide a test suite description.
/// @param sDescription The description to display.
/// @note Test suite description will always display at indentation level
///     0 and will reset the indentation level for the subsequest assertions.
void DescribeTestSuite(string sDescription);

/// @brief Provide a test group description.
/// @param sDescription The description to display.
/// @note Test groups are used to minimize unit test output if all tests
///     within a group pass. This function only provides a header for the
///     test group. To provide a test group description combined with
///     test group ouput, use AssertGroup().
void DescribeTestGroup(string sDescription);

/// @brief Display the parameter used in a test.
/// @param sInput The input data.
/// @param sExpected The expected test result.
/// @param sReceived The actual test result.
/// @note Each paramater is optional. If any parameter is an empty string,
///     that parameter will not be output.
void DescribeTestParameters(string sInput = "", string sExpected = "", string sReceived = "");

/// @brief Display the results of a unit test.
/// @param sTest The name of the unit test.
/// @param bAssertion The results of the unit test.
/// @returns The results of the unit test.
int Assert(string sTest, int bAssertion);

/// @brief Display the results of a group test.
/// @param sTest The name of the group test.
/// @param bAssertion The results of the group test.
/// @returns The results of the group test.
int AssertGroup(string sGroup, int bAssertion);

// -----------------------------------------------------------------------------
//                        Private Function Implementations
// -----------------------------------------------------------------------------

string _GetIndent(int bReset = FALSE)
{
    if (bReset)
        ResetIndent();

    string sIndent;
    int nIndent = GetLocalInt(GetModule(), TEST_INDENT);
    if (nIndent == 0)
        return "";

    while (nIndent-- > 0)
        sIndent += "  ";

    return sIndent;
}

// -----------------------------------------------------------------------------
//                        Public Function Implementations
// -----------------------------------------------------------------------------

string ResetIndent()
{
    DeleteLocalInt(GetModule(), TEST_INDENT);
    return _GetIndent();
}

string Indent(int bReset = FALSE)
{
    if (bReset)
        ResetIndent();

    int nIndent = GetLocalInt(GetModule(), TEST_INDENT);
    SetLocalInt(GetModule(), TEST_INDENT, ++nIndent);

    return _GetIndent();
}

string Outdent()
{
    int nIndent = GetLocalInt(GetModule(), TEST_INDENT);
    SetLocalInt(GetModule(), TEST_INDENT, max(0, --nIndent));

    return _GetIndent();
}

void DescribeTestSuite(string sDescription)
{
    sDescription = HexColorString("Test Suite ", UNITTEST_TITLE_COLOR) +
        HexColorString(sDescription, UNITTEST_NAME_COLOR);

    ResetIndent();
    HandleUnitTestOutput(sDescription);
}

void DescribeTestGroup(string sDescription)
{
    sDescription = HexColorString("Test Group ", UNITTEST_TITLE_COLOR) +
        HexColorString(sDescription, UNITTEST_NAME_COLOR);

    HandleUnitTestOutput(_GetIndent() + sDescription);
    Indent();
}

void DescribeTestParameters(string sInput, string sExpected, string sReceived)
{
    if (sInput != "")
    {
        sInput = _GetIndent() + HexColorString("     Input: ", UNITTEST_PARAMETER_COLOR) +
            HexColorString(sInput, UNITTEST_PARAMETER_INPUT);

        HandleUnitTestOutput(sInput);
    }

    if (sExpected != "")
    {
        sExpected = _GetIndent() + HexColorString("Expected: ", UNITTEST_PARAMETER_COLOR) +
            HexColorString(sExpected, UNITTEST_PARAMETER_INPUT);

        HandleUnitTestOutput(sExpected);
    }

    if (sReceived != "")
    {
        sReceived = _GetIndent() + HexColorString("Received: ", UNITTEST_PARAMETER_COLOR) +
            HexColorString(sReceived, UNITTEST_PARAMETER_RECEIVED);

        HandleUnitTestOutput(sReceived);
    }
}

int Assert(string sTest, int bAssertion)
{
    sTest = HexColorString("Test ", UNITTEST_TITLE_COLOR) +
        HexColorString(sTest, UNITTEST_NAME_COLOR);

    HandleUnitTestOutput(_GetIndent() + sTest + TEST_DELIMITER + (bAssertion ? TEST_PASS : TEST_FAIL));

    if (!bAssertion)
        HandleUnitTestFailure(sTest);

    return bAssertion;
}

int AssertGroup(string sGroup, int bAssertion)
{
    sGroup = HexColorString("Test Group ", UNITTEST_TITLE_COLOR) +
        HexColorString(sGroup, UNITTEST_NAME_COLOR);

    HandleUnitTestOutput(_GetIndent() + sGroup + TEST_DELIMITER + (bAssertion ? TEST_PASS : TEST_FAIL));
    Indent();

    if (!bAssertion)
        HandleUnitTestFailure(sGroup);

    return bAssertion;
}
