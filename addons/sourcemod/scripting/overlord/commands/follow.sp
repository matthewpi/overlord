/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Command_Follow (sm_follow)
 * Prints a list of all online VIPs.
 */
public Action Command_Follow(const int client, const int args) {
    // Variable to hold the command name.
    char command[64] = "sm_follow";

    // Check if the client is invalid.
    if(!IsClientValid(client)) {
        ReplyToCommand(client, "%s You must be a client to execute this command.", CONSOLE_PREFIX);
        return Plugin_Handled;
    }

    if(args == 0 && g_iFollowing[client] != -1) {
        // Send a message to the client.
        ReplyToCommand(client, "%s No longer following \x10%N", PREFIX, g_iFollowing[client]);

        // Log the command execution.
        LogCommand(client, -1, command, "");

        // Unset who the client was following.
        g_iFollowing[client] = -1;
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
        // Send a message to the client.
        ReplyToCommand(client, "%s \x07Too many clients were matched.", PREFIX);
        // Log the command execution.
        LogCommand(client, -1, command, "");
        return Plugin_Handled;
    }

    // Get the target's id.
    int target = targets[0];

    // Update the "g_iFollowing" array.
    g_iFollowing[client] = target;

    // Set who the client is spectating.
    FakeClientCommand(client, "spec_player \"%N\"", g_iFollowing[client]);

    return Plugin_Handled;
}
