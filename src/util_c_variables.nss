/// ----------------------------------------------------------------------------
/// @file   util_c_variables.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Configuration file for util_i_variables.nss.
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                                Configuration
// -----------------------------------------------------------------------------

// This volatile table will be created on the GetModule() object the first time
// a module variable is set.
const string VARIABLE_TABLE_MODULE      = "module_variables";

// This persitent table will be created on the PC object the first time a player
// variable is set.  This table will be stored in the player's .bic file.
const string VARIABLE_TABLE_PC          = "player_variables";

// A persistent table will be created in a campaign database with the following
// name.  The table name will be VARIABLE_TABLE_MODULE above.
const string VARIABLE_CAMPAIGN_DATABASE = "module_variables";

// -----------------------------------------------------------------------------
//                             Variable Tag Constructor
// -----------------------------------------------------------------------------
// This function is not called by the variable handling system, but is presented
//  here for users to modify to their desire to allow consistent creation
//  of variable tags based on specified criteria.  The function signature may
//  be modified to the user's desired and additional constructors created as
//  required to suit the module's needs.
// -----------------------------------------------------------------------------

string ConstructPlayerTag(object oPlayer, string sPrefix = "")
{
    return sPrefix + (sPrefix == "" ? "" : ":") + GetObjectUUID(oPlayer);
}
