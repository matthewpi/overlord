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
	char potentialTarget[64];
	GetCmdArg(1, potentialTarget, sizeof(potentialTarget));

	// Define variables to store target information.
	char targetName[MAX_TARGET_LENGTH];
	int targets[MAXPLAYERS];
	bool tnIsMl;

	// Process the target string.
	int targetCount = ProcessTargetString(potentialTarget, client, targets, MAXPLAYERS, COMMAND_FILTER_CONNECTED, targetName, sizeof(targetName), tnIsMl);

	// Check if no clients were found.
	if(targetCount < 1) {
		// Send a message to the client.
		ReplyToTargetError(client, targetCount);
		// Log the command execution.
		LogCommand(client, -1, command, "");
		return Plugin_Handled;
	}

	// Loop through all targets.
	for(int target = 1; target < sizeof(targets); target++) {
		// Check if the target isn't valid, is alive, or is on the spectator team.
		if(!IsClientValid(target) || IsPlayerAlive(target) || GetClientTeam(target) == CS_TEAM_SPECTATOR) {
			continue;
		}

		// Respawn the target.
		CS_RespawnPlayer(target);
	}

	// Log the command execution.
	LogCommand(client, -1, command, "");

	return Plugin_Handled;
}
