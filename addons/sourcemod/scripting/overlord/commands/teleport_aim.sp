/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Command_TeleportAim (sm_tpaim)
 * Teleport a client to where you are looking.
 */
public Action Command_TeleportAim(const int client, const int args) {
    // Variable to hold the command name.
    char command[64] = "sm_tpaim";

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
    int target = FindTarget(client, potentialTarget);
    if(target == -1) {
        // Log the command execution.
        LogCommand(client, -1, command, "(Targetting error)");
        return Plugin_Handled;
    }

    // Get client's eye position.
    float origins[3];
    GetClientEyePosition(client, origins);

    // Get client's eye angles.
    float angles[3];
    GetClientEyeAngles(client, angles);

    // Get the client's eye position that we can actually teleport a player to.
    TR_TraceRayFilter(origins, angles, MASK_ALL, RayType_Infinite, TraceEntityFilter_NoPlayers);

    // Check if the eye position is a valid location.
    if(TR_DidHit()) {
        // Get the Trace Ray position.
        float position[3];
        TR_GetEndPosition(position);

        // Teleport the target to the position.
        TeleportClientToPosition(target, position);
    }

    // Get the target's name.
    char targetName[128];
    GetClientName(target, targetName, sizeof(targetName));

    // Get and format the translation.
    char buffer[512];
    GetTranslationNP(buffer, sizeof(buffer), "%T", "sm_tpaim Player", client, targetName);

    // Show the activity to the players.
    LogActivity(client, buffer);

    return Plugin_Handled;
}
