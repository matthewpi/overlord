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
        LogCommand(client, -1, command, "(Targetting error)");
        return Plugin_Handled;
    }

    if(targetCount > 2) {
        // Send a message to the client.
        ReplyToCommand(client, "%s \x07Too many clients were found.", PREFIX);

        // Log the command execution.
        LogCommand(client, -1, command, "(Too many clients found)");
        return Plugin_Handled;
    }

    // Get the target's id.
    int target = targets[0];

    // Check if the target is not alive.
    if(!IsPlayerAlive(target)) {
        // Send a message to the client.
        ReplyToCommand(client, "%s \x10%N\x01 is not alive.", PREFIX, target);

        // Log the command execution.
        LogCommand(client, target, command, "(Target is not alive)");
        return Plugin_Handled;
    }

    // Update the target's health.
    SetEntityHealth(target, 100);

    // Show the activity to the players.
    ShowActivity2(client, ACTION_PREFIX, " Healed \x10%N\x01.", target);

    // Log the command execution.
    LogCommand(client, target, command, "(Healed target)");

    return Plugin_Handled;
}
