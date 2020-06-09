/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Command_RespawnAim (sm_respawn_aim)
 * Respawns a client to where you are looking.
 */
public Action Command_RespawnAim(const int client, const int args) {
    // Variable to hold the command name.
    char command[64] = "sm_respawn_aim";

    // Check if the client is invalid.
    if (!IsClientValid(client)) {
        // Send a message to the client.
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
    int targetCount = ProcessTargetString(potentialTarget, client, targets, MAXPLAYERS, COMMAND_FILTER_DEAD, targetName, sizeof(targetName), tnIsMl);

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
    int respawned = 0;
    for (int i = 0; i < targetCount; i++) {
        int target = targets[i];
        // Check if the target is invalid.
        if (!IsClientValid(target)) {
            continue;
        }

        // Check if the target is on spectator.
        if (GetClientTeam(target) == CS_TEAM_SPECTATOR) {
            if (targetCount == 1) {
                ReplyToCommand(client, "%s \x10%N\x01 is a \x07Spectator\x01 and cannot be respawned.", PREFIX, target);
            }
            continue;
        }

        // Check if the target is alive.
        if (IsPlayerAlive(target)) {
            if (targetCount == 1) {
                // Get and format the translation.
                char buffer[512];
                GetTranslation(buffer, sizeof(buffer), "%T", "Is already alive", client, targetName);

                // Send a message to the client.
                ReplyToCommand(client, buffer);
            }
            continue;
        }

        // Respawn the target.
        CS_RespawnPlayer(target);

        // Teleport the target to the position.
        TeleportClientToPosition(target, position);

        // Call the "g_hOnPlayerRespawn" forward.
        Call_StartForward(g_hOnPlayerRespawn);
        Call_PushCell(client);
        Call_Finish();

        respawned++;
    }

    // Get and format the translation.
    char buffer[512];
    GetTranslationNP(buffer, sizeof(buffer), "%T", "sm_respawn Player", client, targetName);

    // Show the activity to the players.
    LogActivity(client, buffer);

    if (respawned > 1) {
        // Log the command execution.
        LogCommand(client, -1, command, "(Respawned %i players)", respawned);
    } else if (respawned == 1) {
        // Log the command execution.
        LogCommand(client, targets[0], command, "(Target: '%s')", targetName);
    }

    return Plugin_Handled;
}
