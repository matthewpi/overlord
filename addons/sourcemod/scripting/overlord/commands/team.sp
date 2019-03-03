/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Command_Team_T (sm_team_t)
 * Swaps a client to the terrorist team.
 */
public Action Command_Team_T(const int client, const int args) {
    return TeamCommand(client, args, "sm_team_t", CS_TEAM_T, "Terrorist");
}

/**
 * Command_Team_CT (sm_team_ct)
 * Swaps a client to the counter terrorist team.
 */
public Action Command_Team_CT(const int client, const int args) {
    return TeamCommand(client, args, "sm_team_ct", CS_TEAM_CT, "Counter Terrorist");
}

/**
 * Command_Team_Spec (sm_team_spec)
 * Swaps a client to the spectator team.
 */
public Action Command_Team_Spec(const int client, const int args) {
    return TeamCommand(client, args, "sm_team_spec", CS_TEAM_SPECTATOR, "Spectator");
}

/**
 * TeamCommand
 * Handles all of the Command_Team_* commands.
 */
static Action TeamCommand(const int client, const int args, const char[] command, const int commandTeam, const char[] commandTeamName) {
    // Check if the client is invalid.
    if(!IsClientValid(client)) {
        // Send a message to the client.
        ReplyToCommand(client, "%s You must be a client to execute this command.", CONSOLE_PREFIX);
        return Plugin_Handled;
    }

    // Check if the client did not pass an argument.
    if(args != 1 && args != 2) {
        // Send a message to the client.
        ReplyToCommand(client, "%s \x07Usage: \x01%s <#userid;target> [round end]", PREFIX, command);
        // Log the command execution.
        LogCommand(client, -1, command, "");
        return Plugin_Handled;
    }

    // Get the first command argument.
    char potentialTarget[64];
    GetCmdArg(1, potentialTarget, sizeof(potentialTarget));

    // Define variables to store target information.
    char targetName[MAX_TARGET_LENGTH];
    int targets[MAXPLAYERS];
    bool tnIsMl;

    // Process the target string.
    int targetCount = ProcessTargetString(potentialTarget, client, targets, MAXPLAYERS, COMMAND_FILTER_CONNECTED, targetName, sizeof(targetName), tnIsMl);

    // Check if no clients were found.
    if(targetCount < 1) {
        // Send a message to the client.
        ReplyToTargetError(client, targetCount);
        // Log the command execution.
        LogCommand(client, -1, command, "");
        return Plugin_Handled;
    }

    if(targetCount > 2) {
        // Get and format the translation.
        char buffer[512];
        GetTranslation(buffer, sizeof(buffer), "%T", "Too many clients were matched", client);

        // Send a message to the client.
        ReplyToCommand(client, buffer);

        // Log the command execution.
        LogCommand(client, -1, command, "");
        return Plugin_Handled;
    }

    // Get the target's id.
    int target = targets[0];

    // Check if the target is already on the selected team.
    if(GetClientTeam(target) != commandTeam) {
        if(args == 2) {
            // Get the second command argument.
            char canSwap[512];
            GetCmdArg(2, canSwap, sizeof(canSwap));

            // Define a swap variable.
            bool swapOnRoundEnd = false;

            // Check if the second command argument equals "true"
            if(StrEqual(canSwap, "true", false)) {
                swapOnRoundEnd = true;
            }

            // Check if we should swap on round end.
            if(swapOnRoundEnd) {
                // Update the swap on round end array.
                g_iSwapOnRoundEnd[target] = commandTeam;

                // Get and format the translation.
                char buffer[512];
                GetTranslationNP(buffer, sizeof(buffer), "%T", "sm_team Round End", client, targetName, commandTeamName);

                // Show the activity to the players.
                LogActivity(client, buffer);
                //LogActivity(client, "\x10%s\x01 will be swapped to the \x07%s\x01 team on round end.", targetName, commandTeamName);
            // Else, make sure the client is not changing teams at round end.
            } else {
                // Update the swap on round end array.
                g_iSwapOnRoundEnd[target] = -1;

                // Get and format the translation.
                char buffer[512];
                GetTranslationNP(buffer, sizeof(buffer), "%T", "sm_team NOT Round End", client, targetName);

                // Show the activity to the players.
                LogActivity(client, buffer);
                //LogActivity(client, "\x10%s\x01 will \x02NOT\x01 be swapped on round end.", targetName);
            }
        } else {
            // Swap the target's team.
            ChangeClientTeam(target, commandTeam);

            // Get and format the translation.
            char buffer[512];
            GetTranslationNP(buffer, sizeof(buffer), "%T", "sm_team Swapped", client, targetName, commandTeamName);

            // Show the activity to the players.
            LogActivity(client, buffer);
            //LogActivity(client, "\x01Swapped \x10%s\x01 to the \x07%s\x01 team.", targetName, commandTeamName);
        }
    } else {
        // Get and format the translation.
        char buffer[512];
        GetTranslation(buffer, sizeof(buffer), "%T", "sm_team Already", client, targetName, commandTeamName);

        // Send a message to the client.
        ReplyToCommand(client, buffer);
        //ReplyToCommand(client, "%s \x10%s \x01is already on the \x07%s\x01 team", PREFIX, targetName, commandTeamName);
    }

    // Log the command execution.
    LogCommand(client, target, command, "(Target: '%s')", targetName);

    return Plugin_Handled;
}
