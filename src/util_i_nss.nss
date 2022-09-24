/// ----------------------------------------------------------------------------
/// @file   util_i_nss.nss
/// @author Daz <daztek@gmail.com>
/// @brief  Functions to assemble scripts for use with `ExecuteScriptChunk()`.
/// @note   Borrowed from https://github.com/Daztek/EventSystem
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Return a `void main()` block.
/// @param sContents The contents of the block.
string NssVoidMain(string sContents);

/// @brief Return an `int StartingConditional()` block.
/// @param sContents The contents of the block.
string NssStartingConditional(string sContents);

/// @brief Return an include directive.
/// @param sIncludeFile The file to include.
string NssInclude(string sIncludeFile);

/// @brief Return an if statement with a comparison.
/// @param sLeft The left side of the comparison. If sComparison or sRight are
///     blank, will be evalated as a boolean expression.
/// @param sComparison The comparison operator.
/// @param sRight The right side of the comparison.
string NssIf(string sLeft, string sComparison = "", string sRight = "");

/// @brief Return an else statement.
string NssElse();

/// @brief Return an else-if statement with a comparison.
/// @param sLeft The left side of the comparison. If sComparison or sRight are
///     blank, will be evalated as a boolean expression.
/// @param sComparison The comparison operator.
/// @param sRight The right side of the comparison.
string NssElseIf(string sLeft, string sComparison = "", string sRight = "");

/// @brief Create a while statement with a comparison.
/// @param sLeft The left side of the comparison. If sComparison or sRight are
///     blank, will be evalated as a boolean expression.
/// @param sComparison The comparison operator.
/// @param sRight The right side of the comparison.
string NssWhile(string sLeft, string sComparison = "", string sRight = "");

/// @brief Return a script block bounded by curly brackets.
/// @param sContents The contents of the block.
string NssBrackets(string sContents);

/// @brief Return a string wrapped in double quotes.
/// @param sString The string to wrap.
string NssQuote(string sString);

/// @brief Return a switch statement.
/// @param sVariable The variable to evaluate in the switch statement.
/// @param sCases A series of case statements the switch should dispatch to.
/// @see NssCase().
string NssSwitch(string sVariable, string sCases);

/// @brief Return a case statement.
/// @param nCase The value matching the switch statement.
/// @param sContents The contents of the case block.
/// @param bBreak If TRUE, will add a break statement after sContents.
string NssCase(int nCase, string sContents, int bBreak = TRUE);

/// @brief Return an object variable declaration and/or assignment.
/// @param sVarName The name for the variable.
/// @param sValue The value to assign to the variable. If blank, no value will
///     be assigned.
/// @param bIncludeType If TRUE, the variable will be declared as well.
string NssObject(string sVarName, string sValue = "", int bIncludeType = TRUE);

/// @brief Return a string variable declaration and/or assignment.
/// @param sVarName The name for the variable.
/// @param sValue The value to assign to the variable. If blank, no value will
///     be assigned.
/// @param bIncludeType If TRUE, the variable will be declared as well.
string NssString(string sVarName, string sValue = "", int bIncludeType = TRUE);

/// @brief Return an int variable declaration and/or assignment.
/// @param sVarName The name for the variable.
/// @param sValue The value to assign to the variable. If blank, no value will
///     be assigned.
/// @param bIncludeType If TRUE, the variable will be declared as well.
string NssInt(string sVarName, string sValue = "", int bIncludeType = TRUE);

/// @brief Return a float variable declaration and/or assignment.
/// @param sVarName The name for the variable.
/// @param sValue The value to assign to the variable. If blank, no value will
///     be assigned.
/// @param bIncludeType If TRUE, the variable will be declared as well.
string NssFloat(string sVarName, string sValue = "", int bIncludeType = TRUE);

/// @brief Return a vector variable declaration and/or assignment.
/// @param sVarName The name for the variable.
/// @param sValue The value to assign to the variable. If blank, no value will
///     be assigned.
/// @param bIncludeType If TRUE, the variable will be declared as well.
string NssVector(string sVarName, string sValue = "", int bIncludeType = TRUE);

/// @brief Return a location variable declaration and/or assignment.
/// @param sVarName The name for the variable.
/// @param sValue The value to assign to the variable. If blank, no value will
///     be assigned.
/// @param bIncludeType If TRUE, the variable will be declared as well.
string NssLocation(string sVarName, string sValue = "", int bIncludeType = TRUE);

/// @brief Return a call, prototype, or definition of a function.
/// @param sFunction The name of the function.
/// @param sArguments The list of arguments for the function.
/// @param bAddSemicolon If TRUE, a semicolon will be assed to the end of the
///     statement.
string NssFunction(string sFunction, string sArguments = "", int bAddSemicolon = TRUE);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

string NssVoidMain(string sContents)
{
    return "void main() { " + sContents + " }";
}

string NssStartingConditional(string sContents)
{
    return "int StartingConditional() { return " + sContents + " }";
}

string NssInclude(string sIncludeFile)
{
    return sIncludeFile == "" ? sIncludeFile : "#" + "include \"" + sIncludeFile + "\" ";
}

string NssCompare(string sLeft, string sComparison, string sRight)
{
    return (sComparison == "" || sRight == "") ? sLeft : sLeft + " " + sComparison + " " + sRight;
}

string NssIf(string sLeft, string sComparison = "", string sRight = "")
{
    return "if (" + NssCompare(sLeft, sComparison, sRight) + ") ";
}

string NssElse()
{
    return "else ";
}

string NssElseIf(string sLeft, string sComparison = "", string sRight = "")
{
    return "else if (" + NssCompare(sLeft, sComparison, sRight) + ") ";
}

string NssWhile(string sLeft, string sComparison = "", string sRight = "")
{
    return "while (" + NssCompare(sLeft, sComparison, sRight) + ") ";
}

string NssBrackets(string sContents)
{
    return "{ " + sContents + " } ";
}

string NssQuote(string sString)
{
    return "\"" + sString + "\"";
}

string NssSwitch(string sVariable, string sCases)
{
    return "switch (" + sVariable + ") { " + sCases + " }";
}

string NssCase(int nCase, string sContents, int bBreak = TRUE)
{
    return "case " + IntToString(nCase) + ": { " + sContents + (bBreak ? " break;" : "") + " } ";
}

string NssSemicolon(string sString)
{
    return (GetStringRight(sString, 1) == ";" || GetStringRight(sString, 2) == "; ") ? sString + " " : sString + "; ";
}

string NssVariable(string sType, string sVarName, string sValue)
{
    return sType + " " + sVarName + (sValue == "" ? "; " : " = " + NssSemicolon(sValue));
}

string NssObject(string sVarName, string sValue = "", int bIncludeType = TRUE)
{
    return NssVariable(bIncludeType ? "object" : "", sVarName, sValue);
}

string NssString(string sVarName, string sValue = "", int bIncludeType = TRUE)
{
    return NssVariable(bIncludeType ? "string" : "", sVarName, sValue);
}

string NssInt(string sVarName, string sValue = "", int bIncludeType = TRUE)
{
    return NssVariable(bIncludeType ? "int" : "", sVarName, sValue);
}

string NssFloat(string sVarName, string sValue = "", int bIncludeType = TRUE)
{
    return NssVariable(bIncludeType ? "float" : "", sVarName, sValue);
}

string NssVector(string sVarName, string sValue = "", int bIncludeType = TRUE)
{
    return NssVariable(bIncludeType ? "vector" : "", sVarName, sValue);
}

string NssLocation(string sVarName, string sValue = "", int bIncludeType = TRUE)
{
    return NssVariable(bIncludeType ? "location" : "", sVarName, sValue);
}

string NssFunction(string sFunction, string sArguments = "", int bAddSemicolon = TRUE)
{
    return sFunction + "(" + sArguments + (bAddSemicolon ? ");" : ")") + " ";
}
