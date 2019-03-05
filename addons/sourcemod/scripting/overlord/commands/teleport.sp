/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Command_Teleport (sm_tp)
 * Teleport to a client.
 */
public Action Command_Teleport(const int client, const int args) {
    // Variable to hold the command name.
    char command[64] = "sm_tp";

    // Check if the client is invalid.
    if(!IsClientValid(client)) {
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
    int targetCount = ProcessTargetString(potentialTarget, client, targets, MAXPLAYERS, COMMAND_FILTER_CONNECTED, targetName, sizeof(targetName), tnIsMl);

    // Check if no clients were found.
    if(targetCount <= COMMAND_TARGET_NONE) {
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

    // Get the first target.
    int target = targets[0];

    // Teleport the client to the target.
    TeleportClientToTarget(client, target);

    // Get and format the translation.
    char buffer[512];
    GetTranslationNP(buffer, sizeof(buffer), "%T", "sm_tp Player", client, targetName);

    // Show the activity to the players.
    LogActivity(client, buffer);

    return Plugin_Handled;
}
