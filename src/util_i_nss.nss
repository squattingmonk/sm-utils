// -----------------------------------------------------------------------------
//    File: util_i_nss.nss
//  System: Utilities (include script)
//     URL: https://github.com/squattingmonk/nwn-core-framework
// Authors: Daz <daztek@gmail.com>
// -----------------------------------------------------------------------------
// This file holds helper functions for assembling scripts to execute with
// `ExecuteScriptChunk()`.
// -----------------------------------------------------------------------------
// Acknowledgement: these scripts have been borrowed from Daz's EventSystem. See
// https://github.com/Daztek/EventSystem
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// Wraps sContents into a `void main()` block.
string NssVoidMain(string sContents);

// Wraps sContents into an `int StartingConditional()` block.
string NssStartingConditional(string sContents);

// Create an include directive for sIncludeFile.
string NssInclude(string sIncludeFile);

// Create an if statement comparing sLeft to sRight using the comparison
// operator sComparison.
string NssIf(string sLeft, string sComparison = "", string sRight = "");

// Create an else-if statement comparing sLeft to sRight using the comparison
// operator sComparison.
string NssElseIf(string sLeft, string sComparison = "", string sRight = "");

// Create a while statement comparing sLeft to sRight using the comparison
// operator sComparison.
string NssWhile(string sLeft, string sComparison = "", string sRight = "");

// Wraps sContents with curly brackets.
string NssBrackets(string sContents);

// Wraps a string with double quotes.
string NssQuote(string sString);

// Return a switch statement evaluating sVariable and dispatching to the case
// statements in sCases.
string NssSwitch(string sVariable, string sCases);

// Return a case statement matching nCase containing sContents. If bBreak is
// TRUE, a break statement will be added after the case statement.
string NssCase(int nCase, string sContents, int bBreak = TRUE);

// Returns an object variable declaration and/or assignment. The variable will
// have the varname sVarName and the value sValue. If sValue is blank, no value
// will be assigned to the variable. If bIncludeType is TRUE, the variable will
// be declared as well.
string NssObject(string sVarName, string sValue = "", int bIncludeType = TRUE);

// Returns a string variable declaration and/or assignment. The variable will
// have the varname sVarName and the value sValue. If sValue is blank, no value
// will be assigned to the variable. If bIncludeType is TRUE, the variable will
// be declared as well.
string NssString(string sVarName, string sValue = "", int bIncludeType = TRUE);

// Returns an int variable declaration and/or assignment. The variable will have
// the varname sVarName and the value sValue. If sValue is blank, no value will
// be assigned to the variable. If bIncludeType is TRUE, the variable will be
// declared as well.
string NssInt(string sVarName, string sValue = "", int bIncludeType = TRUE);

// Returns a float variable declaration and/or assignment. The variable will
// have the varname sVarName and the value sValue. If sValue is blank, no value
// will be assigned to the variable. If bIncludeType is TRUE, the variable will
// be declared as well.
string NssFloat(string sVarName, string sValue = "", int bIncludeType = TRUE);

// Returns a vector variable declaration and/or assignment. The variable will
// have the varname sVarName and the value sValue. If sValue is blank, no value
// will be assigned to the variable. If bIncludeType is TRUE, the variable will
// be declared as well.
string NssVector(string sVarName, string sValue = "", int bIncludeType = TRUE);

// Returns a location variable declaration and/or assignment. The variable will
// have the varname sVarName and the value sValue. If sValue is blank, no value
// will be assigned to the variable. If bIncludeType is TRUE, the variable will
// be declared as well.
string NssLocation(string sVarName, string sValue = "", int bIncludeType = TRUE);

// Return a call, prototype, or definition of a function named sFunction and
// having the arguments sArguments. If bAddSemicolon is TRUE, a semicolon will
// be added to the end of the statement.
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
