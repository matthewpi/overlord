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
        ReplyToCommand(client, "%s You must be a player to execute this command.", CONSOLE_PREFIX);
        return Plugin_Handled;
    }

    if(args == 0 && g_iFollowing[client] != -1) {
        // Get the client's target's name.
        char targetName[128];
        GetClientName(g_iFollowing[client], targetName, sizeof(targetName));

        // Get and format the translation.
        char buffer[512];
        GetTranslation(buffer, sizeof(buffer), "%T", "sm_follow Stopped", client, targetName);

        // Send a message to the client.
        ReplyToCommand(client, buffer);

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

    if(GetClientTeam(client) != CS_TEAM_SPECTATOR) {
        // Get and format the translation.
        char buffer[512];
        GetTranslation(buffer, sizeof(buffer), "%T", "sm_follow Spectator", client);

        // Send a message to the client.
        ReplyToCommand(client, buffer);

        // Log the command execution.
        LogCommand(client, -1, command, "");

        return Plugin_Handled;
    }

    // Get the first command argument.
    char potentialTarget[512];
    GetCmdArg(1, potentialTarget, sizeof(potentialTarget));

    // Attempt to get and target a player using the first command argument.
    int target = FindTarget(client, potentialTarget);
    if(target == -1) {
        // Log the command execution.
        LogCommand(client, -1, command, "(Targetting error)");
        return Plugin_Handled;
    }

    // Get the target's name.
    char targetName[128];
    GetClientName(target, targetName, sizeof(targetName));

    // Update the "g_iFollowing" array.
    g_iFollowing[client] = target;

    // Set who the client is spectating.
    FakeClientCommand(client, "spec_player \"%N\"", target);

    // Get and format the translation.
    char buffer[512];
    GetTranslation(buffer, sizeof(buffer), "%T", "sm_follow Following", client, targetName);

    // Send a message to the client.
    ReplyToCommand(client, buffer);

    // Log the command execution.
    LogCommand(client, target, command, "(Target: '%s')", targetName);

    // Call the "g_hOnAdminFollow" forward.
    Call_StartForward(g_hOnAdminFollow);
    Call_PushCell(client);
    Call_PushCell(target);
    Call_Finish();

    return Plugin_Handled;
}
