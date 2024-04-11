/// ----------------------------------------------------------------------------
/// @file   util_i_unittest.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Functions for managing unit test reporting.
/// ----------------------------------------------------------------------------
/// @details
///
/// Variable Conventions:
///
/// Tests can be written in just about any format, however since tests tend to be
///     repetitive, having a variable and formatting convention can make building
///     multiple tests quick and easy.  Following are variable naming conventions
///     and an example that showcases how to use them.
///
///     Variable Naming:
///         ix - Function Input Variables
///         ex - Expected Function Result Variables
///         rx - Actual Function Result Variables
///         bx - Boolean Test Result Variables
///         tx - Timer Variables
///
///     Convenience Functions:
///         _i : IntToString
///         _f : FloatToString; Rounds to significant digits
///         _b : Returns `True` or `False` (literals)
///
///         _q  : Returns string wrapped in single quotes
///         _qq : Returns string wrapped in double quotes
///         _p  : Returns string wrapped in parenthesis
///
///     Timers:
///         To start a timer:
///             t1 = Timer();   : Sets timer variable `t1` to GetMicrosecondCounter()
///
///         To end a timer and save the results:
///             t1 = Timer(t1); : Sets timer variable `t1` to GetMicrosecondCounter() - t1
/// 
/// The following example shows how to create a grouped assertion and display
///     only relevant results, assuming only assertion failures are of
///     interest.  If you always want to see expanded results regardless of test
///     outcome, set UNITTEST_ALWAYS_EXPAND to TRUE in `util_c_unittest`.
///
/// For example purposes only, this unit test sample code will run a unittest
///     against the following function, which will return:
///         -1, if n <= 0
///         20 * n, if 0 < n <= 3
///         100, if n > 3
///
/// ```nwscript
/// int unittest_demo_ConvertValue(int n)
/// {
///     return n <= 0 ? -1 : n > 3 ? 100 : 20 * n;
/// }
/// ```
///
/// The following unit test will run against the function above for three test cases:
///     - Out of bounds (low) -> n <= 0;
///     - In bounds -> 0 < n <= 3;
///     - Out of bounds (high) -> n > 3;
///
/// ```nwscript
/// int unittest_ConvertValue()
/// {
///     int i1, i2, i3;
///     int e1, e2, e3;
///     int r1, r2, r3;
///     int b1, b2, b3, b;
///     int t1, t2, t3, t;
/// 
///     // Setup the input values
///     i1 = -10;
///     i2 = 2;
///     i3 = 12;
/// 
///     // Setup the expected return values 
///     e1 = -1;
///     e2 = 40;
///     e3 = 100;
/// 
///     // Run the unit tests with timers
///     t = Timer();
///     t1 = Timer(); r1 = unittest_demo_ConvertValue(i1); t1 = Timer(t1);
///     t2 = Timer(); r2 = unittest_demo_ConvertValue(i2); t2 = Timer(t2);
///     t3 = Timer(); r3 = unittest_demo_ConvertValue(i3); t3 = Timer(t3);
///     t = Timer(t);
/// 
///     // Populate the results
///     b = (b1 = r1 == e1) &
///         (b2 = r2 == e2) &
///         (b3 = r3 == e3);
/// 
///     // Display the result
///     if (!AssertGroup("ConvertValue()", b))
///     {
///         if (!Assert("Out of bounds (low)", b1))
///             DescribeTestParameters(_i(i1), _i(e1), _i(r1));
///         DescribeTestTime(t1);
/// 
///         if (!Assert("In bounds", b2))
///             DescribeTestParameters(_i(i2), _i(e2), _i(r2));
///         DescribeTestTime(t2);
/// 
///         if (!Assert("Out of bounds (high)", b3))
///             DescribeTestParameters(_i(i3), _i(e3), _i(r3));
///         DescribeTestTime(t3);
///     } DescribeGroupTime(t); Outdent();
/// }
/// Note:  Use of ResetIndent() or another indentation function, such as
/// Outdent(), may be required if moving to another group assertion.

#include "util_c_unittest"
#include "util_i_strings"

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

/// @brief Establishes or calculates a timer or elapsed value.
/// @param t Previous timer value derived from this function.
/// @note Calling this function without parameter `t` specified will
///     return a starting value in microseconds.  When the code in
///     question has been run, call this function again and pass
///     the previously returned value as parameter `t` to calculate
///     the total elapsed time for between calls to this function.
int Timer(int t = 0);

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

/// @brief Display function timer result.
/// @param nTime Function timer result, in microseconds.
/// @note This function is intended to use output from GetMicrosecondCounter().
void DescribeTestTime(int nTime);

/// @brief Display function timer result.
/// @param nTime Function timer result, in microseconds.
/// @note This function is intended to use output from GetMicrosecondCounter().
void DescribeGroupTime(int nTime);

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

string _i(int n)     { return IntToString(n); }
string _f(float f)   { return FormatFloat(f, "%!f"); }
string _b(int b)     { return b ? "True" : "False"; }

string _q(string s)  { return "'" + s + "'"; }
string _qq(string s) { return "\"" + s + "\""; }
string _p(string s)  { return "(" + s + ")"; }

int Timer(int t = 0)
{
    return GetMicrosecondCounter() - t;
}

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
    Indent(TRUE);
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
    Indent();
    if (sInput != "")
    {
        json jInput = JsonParse(sInput);
        if (jInput != JSON_NULL && JsonGetLength(jInput) > 0)
        {
            if (JsonGetType(jInput) == JSON_TYPE_ARRAY)
            {
                string s = "WITH atoms AS (SELECT atom FROM json_each(@json)) " +
                           "SELECT group_concat(atom, ' | ') FROM atoms;";
                sqlquery q = SqlPrepareQueryObject(GetModule(), s);
                SqlBindJson(q, "@json", jInput);
                sInput = SqlStep(q) ? SqlGetString(q, 0) : sInput;
            }
            else if (JsonGetType(jInput) == JSON_TYPE_OBJECT)
            {
                string s = "WITH kvps AS (SELECT key, value FROM json_each(@json)) " +
                           "SELECT group_concat(key || ' = ' || (IFNULL(value, '\"\"\"\"')), ' | ') FROM kvps;";
                sqlquery q = SqlPrepareQueryObject(GetModule(), s);
                SqlBindJson(q, "@json", jInput);
                sInput = SqlStep(q) ? SqlGetString(q, 0) : sInput;
            }

            sInput = RegExpReplace("(?:^|\\| )(.*?)(?= =)", sInput, HexToColor(COLOR_BLUE_STEEL) + "$&</c>");
            sInput = RegExpReplace("\\||=", sInput, HexToColor(COLOR_WHITE) + "$&</c>");
        }

        sInput = _GetIndent() + HexColorString("Input: ", UNITTEST_PARAMETER_COLOR) +
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
    Outdent();
}

void DescribeTestTime(int nTime)
{
    if (nTime <= 0)
        return;

    Indent();
    string sTimer = _f(nTime / 1000000.0);
    string sTime = _GetIndent() + HexColorString("Test Time: ", UNITTEST_PARAMETER_COLOR) +
        HexColorString(sTimer + "s", UNITTEST_PARAMETER_INPUT);
    Outdent();

    HandleUnitTestOutput(sTime);
}

void DescribeGroupTime(int nTime)
{
    if (nTime <= 0)
        return;

    string sTimer = _f(nTime / 1000000.0);
    string sTime = _GetIndent() + HexColorString("Group Time: ", UNITTEST_PARAMETER_COLOR) +
        HexColorString(sTimer + "s", UNITTEST_PARAMETER_INPUT);

    HandleUnitTestOutput(sTime);
}

int Assert(string sTest, int bAssertion)
{
    sTest = HexColorString("Test ", UNITTEST_TITLE_COLOR) +
        HexColorString(sTest, UNITTEST_NAME_COLOR);

    HandleUnitTestOutput(_GetIndent() + sTest + TEST_DELIMITER + (bAssertion ? TEST_PASS : TEST_FAIL));

    if (!bAssertion)
        HandleUnitTestFailure(sTest);

    return UNITTEST_ALWAYS_EXPAND ? FALSE : bAssertion;
}

int AssertGroup(string sGroup, int bAssertion)
{
    sGroup = HexColorString("Test Group ", UNITTEST_TITLE_COLOR) +
        HexColorString(sGroup, UNITTEST_NAME_COLOR);

    HandleUnitTestOutput(_GetIndent() + sGroup + TEST_DELIMITER + (bAssertion ? TEST_PASS : TEST_FAIL));
    Indent();

    if (!bAssertion)
        HandleUnitTestFailure(sGroup);

    return UNITTEST_ALWAYS_EXPAND ? FALSE : bAssertion;
}
