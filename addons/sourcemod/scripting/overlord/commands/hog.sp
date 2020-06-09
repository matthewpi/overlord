/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Command_Hog (sm_hog)
 * Slays a client and strikes lightning on them.
 */
public Action Command_Hog(const int client, const int args) {
    // Variable to hold the command name.
    char command[64] = "sm_hog";

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

    // Loop through all targets
    int target = 0;
    int hogCount = 0;
    for (int i = 0; i < targetCount; i++) {
        // Update the target int so we can target the target properly.
        target = targets[i];

        // Check if the target is dead.
        if (!IsPlayerAlive(target)) {
            continue;
        }

        // Get the target's position.
        float position[3];
        GetClientAbsOrigin(target, position);

        // Get a random position?
        float startPosition[3];
        startPosition[0] = position[0] + GetRandomInt(-500, 500);
        startPosition[1] = position[1] + GetRandomInt(-500, 500);
        startPosition[2] = position[2] + 826;

        int color[4];
        float direction[3];

        // Spawn the lightning beam.
        TE_SetupBeamPoints(startPosition, position, g_iLightningSprite, 0, 0, 0, 0.2, 20.0, 10.0, 0, 1.0, color, 3);
        TE_SendToAll();

        // Spawn the sparks.
        TE_SetupSparks(position, direction, 5000, 1000);
        TE_SendToAll();

        // Spawn the energy splash.
        TE_SetupEnergySplash(position, direction, false);
        TE_SendToAll();

        // Spawn the smoke.
        TE_SetupSmoke(position, g_iSmokeSprite, 5.0, 10);
        TE_SendToAll();

        // Emit the sound.
        EmitAmbientSound(OVERLORD_SND_HOG, startPosition, client);

        // Disarm the target.
        DisarmClient(target);

        // Kill the target.
        ForcePlayerSuicide(target);

        // Call the "g_hOnPlayerHog" forward.
        Call_StartForward(g_hOnPlayerHog);
        Call_PushCell(client);
        Call_Finish();

        hogCount++;
    }

    // Get and format the translation.
    char buffer[512];
    GetTranslationNP(buffer, sizeof(buffer), "%T", "sm_hog Hogged", client, targetName);

    // Show the activity to the players.
    LogActivity(client, buffer);

    // Check if only one player was hogged.
    if (hogCount == 1) {
        // Log the command execution.
        LogCommand(client, targets[0], command, "(Target: '%s')", targetName);
    } else {
        // Log the command execution.
        LogCommand(client, -1, command, "(Hogged %i players)", hogCount);
    }

    return Plugin_Handled;
}
