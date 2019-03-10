/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Command_Heal (sm_heal)
 * Heals the specified target.
 */
public Action Command_Heal(const int client, const int args) {
    char command[64] = "sm_heal";

    // Check if the client is invalid.
    if(!IsClientValid(client)) {
        // Send a message to the client.
        ReplyToCommand(client, "%s You must be a player to execute this command.", CONSOLE_PREFIX);
        return Plugin_Handled;
    }

    // Check if the client did not pass an argument.
    if(args != 1 && args != 2) {
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

    // Get the target's name.
    char targetName[128];
    GetClientName(target, targetName, sizeof(targetName));

    // Check if the target is not alive.
    if(!IsPlayerAlive(target)) {
        // Get and format the translation.
        char buffer[512];
        GetTranslation(buffer, sizeof(buffer), "%T", "Is not alive", client, targetName);

        // Send a message to the client.
        ReplyToCommand(client, buffer);

        // Log the command execution.
        LogCommand(client, target, command, "(Target is not alive)");
        return Plugin_Handled;
    }

    // Get and format the translation.
    char buffer[512];
    GetTranslationNP(buffer, sizeof(buffer), "%T", "sm_heal Healed", client, targetName);

    // Show the activity to the players.
    LogActivity(client, buffer);

    // Update the target's health.
    int health = 100;
    SetEntityHealth(target, health);

    // Log the command execution.
    LogCommand(client, target, command, "(Target: '%s', Health: %i)", targetName, health);

    return Plugin_Handled;
}
