/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Command_Respawn (sm_respawn)
 * Respawns a dead client.
 */
public Action Command_Respawn(const int client, const int args) {
    // Variable to hold the command name.
    char command[64] = "sm_respawn";

    // Check if the client is invalid.
    if(!IsClientValid(client)) {
        // Send a message to the client.
        ReplyToCommand(client, "%s You must be a client to execute this command.", CONSOLE_PREFIX);
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
    if(targetCount <= 0) {
        // Send a message to the client.
        ReplyToTargetError(client, targetCount);

        // Log the command execution.
        LogCommand(client, -1, command, "");
        return Plugin_Handled;
    }

    // Loop through all targets.
    int respawned = 0;
    for(int i = 0; i < targetCount; i++) {
        int target = targets[i];
        // Check if the target is invalid.
        if(!IsClientValid(target)) {
            continue;
        }

        // Check if the target is on spectator.
        if(GetClientTeam(target) == CS_TEAM_SPECTATOR) {
            if(targetCount == 1) {
                ReplyToCommand(client, "%s \x10%N\x01 is a \x07Spectator\x01 and cannot be respawned.", PREFIX, target);
            }
            continue;
        }

        // Check if the target is alive.
        if(IsPlayerAlive(target)) {
            if(targetCount == 1) {
                ReplyToCommand(client, "%s \x10%N\x01 is already alive.", PREFIX, target);
            }
            continue;
        }

        // Respawn the target.
        CS_RespawnPlayer(target);
        respawned++;
    }

    if(respawned > 1) {
        // Show the activity to the players.
        ShowActivity2(client, ACTION_PREFIX, " Respawned \x10%i\x01 players.");

        // Log the command execution.
        LogCommand(client, -1, command, "(Respawned: %i)", respawned);
    } else if(respawned == 1) {
        // Show the activity to the players.
        ShowActivity2(client, ACTION_PREFIX, " Respawned \x10%N\x01.", targets[0]);

        // Log the command execution.
        LogCommand(client, targets[0], command, "");
    }

    return Plugin_Handled;
}
