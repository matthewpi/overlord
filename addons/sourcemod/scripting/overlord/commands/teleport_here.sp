/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Command_TeleportHere (sm_tphere)
 * Teleport a client to the command sender.
 */
public Action Command_TeleportHere(const int client, const int args) {
    // Variable to hold the command name.
    char command[64] = "sm_tphere";

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

    // Loop through all targets.
    int teleported = 0;
    for (int i = 0; i < targetCount; i++) {
        int target = targets[i];

        // Check if the target is invalid.
        if (!IsClientValid(target)) {
            continue;
        }

        // Check if the target is dead.
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

        // Teleport the target to the client.
        TeleportClientToTarget(target, client);

        // Call the "g_hOnPlayerTeleport" forward.
        Call_StartForward(g_hOnPlayerTeleport);
        Call_PushCell(target);
        Call_PushCell(client);
        Call_Finish();

        teleported++;
    }

    // Get and format the translation.
    char buffer[512];
    GetTranslationNP(buffer, sizeof(buffer), "%T", "sm_tphere Player", client, targetName);

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
