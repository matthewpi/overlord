/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Command_Health (sm_health)
 * Sets the specified target's health.
 */
public Action Command_Health(const int client, const int args) {
    char command[64] = "sm_health";

    // Check if the client is invalid.
    if(!IsClientValid(client)) {
        // Send a message to the client.
        ReplyToCommand(client, "%s You must be a player to execute this command.", CONSOLE_PREFIX);
        return Plugin_Handled;
    }

    // Check if the client did not pass an argument.
    if(args != 2) {
        // Send a message to the client.
        ReplyToCommand(client, "%s \x07Usage: \x01%s <#userid;target> <health>", PREFIX, command);

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

    // Get the second command argument.
    char healthValue[512];
    GetCmdArg(2, healthValue, sizeof(healthValue));

    // Convert the second command argument to an integer.
    int health = StringToInt(healthValue);

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

        // Call the "g_hOnPlayerHealth" forward.
        Call_StartForward(g_hOnPlayerHealth);
        Call_PushCell(client);
        Call_Finish();

        // Update the target's health.
        SetEntityHealth(target, health);

        healed++;
    }

    // Get and format the translation.
    char buffer[512];
    GetTranslationNP(buffer, sizeof(buffer), "%T", "sm_health Player", client, targetName, health);

    // Show the activity to the players.
    LogActivity(client, buffer);

    if(healed > 1) {
        // Log the command execution.
        LogCommand(client, -1, command, "(Set health of %i players to %i)", healed, health);
    } else if(healed == 1) {
        // Log the command execution.
        LogCommand(client, targets[0], command, "(Target: '%s', Health: %i)", targetName, health);
    }

    return Plugin_Handled;
}
