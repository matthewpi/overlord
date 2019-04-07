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

    // Attempt to get and target a player using the first command argument.
    int target = FindTarget(client, potentialTarget, false, false);
    if(target == -1) {
        // Log the command execution.
        LogCommand(client, -1, command, "(Targetting error)");
        return Plugin_Handled;
    }

    // Get the target's name.
    char targetName[128];
    GetClientName(target, targetName, sizeof(targetName));

    if(!IsPlayerAlive(target)) {
        // Get and format the translation.
        char buffer[512];
        GetTranslation(buffer, sizeof(buffer), "%T", "Is not alive", client, targetName);

        // Send a message to the client.
        ReplyToCommand(client, buffer);
        return Plugin_Handled;
    }

    // Teleport the client to the target.
    TeleportClientToTarget(client, target);

    // Call the "g_hOnPlayerTeleport" forward.
    Call_StartForward(g_hOnPlayerTeleport);
    Call_PushCell(client);
    Call_PushCell(target);
    Call_Finish();

    // Get and format the translation.
    char buffer[512];
    GetTranslationNP(buffer, sizeof(buffer), "%T", "sm_tp Player", client, targetName);

    // Show the activity to the players.
    LogActivity(client, buffer);

    return Plugin_Handled;
}
