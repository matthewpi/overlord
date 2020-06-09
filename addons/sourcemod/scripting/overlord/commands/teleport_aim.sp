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
    if (!IsClientValid(client)) {
        ReplyToCommand(client, "%s You must be a player to execute this command.", CONSOLE_PREFIX);
        return Plugin_Handled;
    }

    // Check if the client did not pass an argument.
    if (args != 1) {
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
    if (targetCount <= COMMAND_TARGET_NONE) {
        // Send a message to the client.
        ReplyToTargetError(client, targetCount);

        // Log the command execution.
        LogCommand(client, -1, command, "");
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
    if (!TR_DidHit()) {
        // Log the command execution.
        LogCommand(client, -1, command, "(TraceRay did not hit)", targetName);
        return Plugin_Handled;
    }

    // Get the Trace Ray position.
    float position[3];
    TR_GetEndPosition(position);

    // Loop through all targets.
    int teleported = 0;
    for (int i = 0; i < targetCount; i++) {
        int target = targets[i];
        // Check if the target is invalid.
        if (!IsClientValid(target)) {
            continue;
        }

        // Check if the target is alive.
        if (!IsPlayerAlive(target)) {
            if (targetCount == 1) {
                // Get and format the translation.
                char buffer[512];
                GetTranslation(buffer, sizeof(buffer), "%T", "Is not alive", client, targetName);

                // Send a message to the client.
                ReplyToCommand(client, buffer);
            }

            continue;
        }

        // Teleport the target to the position.
        TeleportClientToPosition(target, position);

        // Call the "g_hOnPlayerTeleportPos" forward.
        Call_StartForward(g_hOnPlayerTeleportPos);
        Call_PushCell(client);
        Call_PushArray(position, sizeof(position));
        Call_Finish();

        teleported++;
    }

    // Get and format the translation.
    char buffer[512];
    GetTranslationNP(buffer, sizeof(buffer), "%T", "sm_tpaim Player", client, targetName);

    // Show the activity to the players.
    LogActivity(client, buffer);

    if (teleported > 1) {
        // Log the command execution.
        LogCommand(client, -1, command, "(Teleported %i players)", teleported);
    } else if (teleported == 1) {
        // Log the command execution.
        LogCommand(client, targets[0], command, "(Target: '%s')", targetName);
    }

    return Plugin_Handled;
}
