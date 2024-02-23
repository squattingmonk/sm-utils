/// ----------------------------------------------------------------------------
/// @file   util_c_unittest.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Configuration file for util_i_unittest.nss.
/// ----------------------------------------------------------------------------

#include "util_i_debug"

// -----------------------------------------------------------------------------
//                        Unit Test Configuration Settings
// -----------------------------------------------------------------------------

// Set this value to the color the test title text will be colored to. The value
//  can be a value from util_c_color or any other hex value representing a
//  color.
// Example Output:  Test My Variable Test
//                  ^^^^ This portion of the text will be affected
const int UNITTEST_TITLE_COLOR = COLOR_CYAN;

// Set this value to the color the test name text will be colored to. The value
//  can be a value from util_c_color or any other hex value representing a
//  color.
// Example Output:  Test My Variable Test | PASS
//                       ^^^^^^^^^^^^^^^^ This portion of the text will be affected
const int UNITTEST_NAME_COLOR = COLOR_ORANGE_LIGHT;

// Set this value to the color the test parameter text will be colored to. The
//  value can be a value from util_c_color or any other hex value representing a
//  color.
// Example Output:    Input: my_input
//                 Expected: my_assertion
//                 Received: my_output
//                 ^^^^^^^^^ This portion of the text will be affected
const int UNITTEST_PARAMETER_COLOR = COLOR_WHITE;

// Set this value to the color the test parameter text will be colored to. The
//  value can be a value from util_c_color or any other hex value representing a
//  color.
// Example Output:    Input: my_input
//                 Expected: my_assertion
//                           ^^^^^^^^^^^^ This portion of the text will be affected
const int UNITTEST_PARAMETER_INPUT = COLOR_GREEN_SEA;

// Set this value to the color the test parameter text will be colored to. The
//  value can be a value from util_c_color or any other hex value representing a
//  color.
// Example Output: Received: my_output
//                           ^^^^^^^^^ This portion of the text will be affected
const int UNITTEST_PARAMETER_RECEIVED = COLOR_PINK;

// Set this value to the name of the script or event to run in case of a unit
//  test failure.
const string UNITTEST_FAILURE_SCRIPT = "";

// This value determines whether test results are expanded.  Set to TRUE to force
//  all test results to show expanded data.  Set to FALSE to show expanded data
//  only on test failures.
const int UNITTEST_ALWAYS_EXPAND = FALSE;

// -----------------------------------------------------------------------------
//                        Helper Constants and Functions
// -----------------------------------------------------------------------------
// If you need custom constants, functions, or #includes, you may add them here.
// Since this file is included by util_i_unittest.nss, you do not need to
// #include it to use its constants.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                           Unit Test Output Handler
// -----------------------------------------------------------------------------
// You may alter the contents of this function, but do not alter its signature.
// -----------------------------------------------------------------------------

/// @brief Custom handler to handle reporting unit test results.
/// @param sOutput The formatted and colored output results of a unit test.
void HandleUnitTestOutput(string sOutput)
{
    // This handler can be used to report the unit test output using any module
    //  debugging or other reporting system.
    /*
        SendMessageToPC(GetFirstPC(), sOutput);
    */

    Notice(sOutput);
}

// -----------------------------------------------------------------------------
//                      Unit Test Failure Reporting Handler
// -----------------------------------------------------------------------------
// You may alter the contents of this function, but do not alter its signature.
// -----------------------------------------------------------------------------

/// @brief Custom handler to report unit testing failures.
/// @param sOutput The formatted and colored output results of a unit test.
void HandleUnitTestFailure(string sOutput)
{
    // This handler can be used to report unit test failures to module systems
    //  or take specific action based on a failure. This function will
    //  generally not be used in a test environment, but may be useful for
    //  reporting failures in a production environment if unit tests are run
    //  during module startup.

    if (UNITTEST_FAILURE_SCRIPT != "")
        ExecuteScript(UNITTEST_FAILURE_SCRIPT, GetModule());
}
