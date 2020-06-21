/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Command_RespawnHere (sm_respawn_here)
 * Respawns a client to your position.
 */
public Action Command_RespawnHere(const int client, const int args) {
    // Variable to hold the command name.
    char command[64] = "sm_respawn_here";

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
                // ReplyToCommand(client, "%s \x10%N\x01 is a \x07Spectator\x01 and cannot be respawned.", PREFIX, target);

                // Get and format the translation.
                char buffer[512];
                GetTranslation(buffer, sizeof(buffer), "%T", "sm_respawn Spectator", client, targetName);

                // Send a message to the client.
                ReplyToCommand(client, buffer);
            }

            continue;
        }

        // Check if the target is alive.
        if (IsPlayerAlive(target)) {
            if (targetCount == 1) {
                // Get and format the translation.
                char buffer[512];
                GetTranslation(buffer, sizeof(buffer), "%T", "Is still alive", client, targetName);

                // Send a message to the client.
                ReplyToCommand(client, buffer);
            }

            continue;
        }

        // Respawn the target.
        CS_RespawnPlayer(target);

        // Teleport the target to the client.
        TeleportClientToTarget(target, client);

        // Call the "g_hOnPlayerRespawn" forward.
        Call_StartForward(g_hOnPlayerRespawn);
        Call_PushCell(target);
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
