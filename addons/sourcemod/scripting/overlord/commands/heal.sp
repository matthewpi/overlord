/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Command_Heal (sm_heal)
 * Heals the specified target.
 */
public Action Command_Heal(const int client, const int args) {
    char command[64] = "sm_heal";

    // Check if the client is invalid.
    if(!IsClientValid(client)) {
        // Send a message to the client.
        ReplyToCommand(client, "%s You must be a player to execute this command.", CONSOLE_PREFIX);
        return Plugin_Handled;
    }

    // Check if the client did not pass an argument.
    if(args != 1) {
        // Send a message to the client.
        ReplyToCommand(client, "%s \x07Usage: \x01%s <#userid;target>", PREFIX, command);

        // Log the command execution.
        LogCommand(client, -1, command, "");
        return Plugin_Handled;
    }

    // Get the first command argument.
    char potentialTarget[512];
    GetCmdArg(1, potentialTarget, sizeof(potentialTarget));

    // Define variables to store target information.
    char targetName[MAX_TARGET_LENGTH];
    int targets[MAXPLAYERS];
    bool tnIsMl;

    // Process the target string.
    int targetCount = ProcessTargetString(potentialTarget, client, targets, MAXPLAYERS, COMMAND_FILTER_ALIVE, targetName, sizeof(targetName), tnIsMl);

    // Check if no clients were found.
    if(targetCount <= COMMAND_TARGET_NONE) {
        // Send a message to the client.
        ReplyToTargetError(client, targetCount);

        // Log the command execution.
        LogCommand(client, -1, command, "");
        return Plugin_Handled;
    }

    // Loop through all targets.
    int healed = 0;
    for(int i = 0; i < targetCount; i++) {
        int target = targets[i];
        // Check if the target is invalid.
        if(!IsClientValid(target)) {
            continue;
        }

        // Check if the target is alive.
        if(!IsPlayerAlive(target)) {
            if(targetCount == 1) {
                // Get and format the translation.
                char buffer[512];
                GetTranslation(buffer, sizeof(buffer), "%T", "Is not alive", client, targetName);

                // Send a message to the client.
                ReplyToCommand(client, buffer);

                // Log the command execution.
                LogCommand(client, targets[0], command, "(Target is not alive)");
            }
            continue;
        }

        // Call the "g_hOnPlayerHeal" forward.
        Call_StartForward(g_hOnPlayerHeal);
        Call_PushCell(client);
        Call_Finish();

        // Update the target's health.
        int health = 100;
        SetEntityHealth(target, health);

        healed++;
    }

    // Get and format the translation.
    char buffer[512];
    GetTranslationNP(buffer, sizeof(buffer), "%T", "sm_heal Player", client, targetName);

    // Show the activity to the players.
    LogActivity(client, buffer);

    if(healed > 1) {
        // Log the command execution.
        LogCommand(client, -1, command, "(Healed %i players)", healed);
    } else if(healed == 1) {
        // Log the command execution.
        LogCommand(client, targets[0], command, "(Target: '%s')", targetName);
    }

    return Plugin_Handled;
}
