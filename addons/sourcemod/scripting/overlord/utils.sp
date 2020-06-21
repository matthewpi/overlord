/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

static char _colorNames[][] = {
    "{NORMAL}", "{DARK_RED}", "{PINK}", "{LIME_GREEN}", "{GREEN}",
    "{LIGHT_GREEN}", "{RED}", "{GRAY}", "{YELLOW}", "{ORANGE}",
    "{LIGHT_BLUE}", "{DARK_BLUE}", "{PURPLE}", "{LIGHT_RED}"
};
static char _colorCodes[][] = {
    "\x01",     "\x02",       "\x03",   "\x04",    "\x05",
    "\x06",          "\x07",  "\x08",   "\x09",     "\x10",
    "\x0B",         "\x0C",        "\x0E",     "\x0F"
};

/**
 * IsClientValid
 * Returns true if the client is valid. (in game, connected, isn't fake)
 */
bool IsClientValid(const int client, bool fake = false) {
    if (client <= 0 || client > MaxClients || !IsClientConnected(client) || !IsClientInGame(client)) {
        return false;
    }

    if (!fake && IsFakeClient(client)) {
        return false;
    }

    return true;
}

/**
 * LogCommand
 * Logs a command execution.
 */
public void LogCommand(const int client, const int target, const char[] command, const char[] extra, any...) {
    // Check if there were extra parameters passed to the function.
    if (strlen(extra) > 0) {
        // Format the extra parameters.
        char buffer[512];
        VFormat(buffer, sizeof(buffer), extra, 5);

        // Log the command execution.
        LogAction(client, target, "%s '%N' executed command '%s' %s", CONSOLE_PREFIX, client, command, buffer);
    } else {
        // Log the command execution.
        LogAction(client, target, "%s '%N' executed command '%s'", CONSOLE_PREFIX, client, command);
    }
}

/**
 * LogActivity
 * Logs an activity to all players on the server.
 */
public void LogActivity(const int client, const char[] message, any...) {
    char formattedMessage[512];
    VFormat(formattedMessage, sizeof(formattedMessage), message, 3);
    ShowActivity2(client, ACTION_PREFIX, formattedMessage);
}

/**
 * Colorize
 * Colorizes a message.
 */
public void Colorize(char[] buffer, const int maxlen) {
    // Loop through the _colorNames array.
    for (int i = 0; i < sizeof(_colorNames); i++) {
        // Replace all color codes in the message.
        ReplaceString(buffer, maxlen, _colorNames[i], _colorCodes[i]);
    }
}

/**
 * GetTranslation
 * Gets and formats a translation message and adds the plugin prefix.
 */
public void GetTranslation(char[] buffer, const int maxlen, const char[] msg, any...) {
    // Get and format the translation portion of the message.
    char message[512];
    VFormat(message, sizeof(message), msg, 4);

    // Add colours to the translation.
    Colorize(message, sizeof(message));

    // Add the prefix to the translation.
    Format(message, sizeof(message), "%s %s", PREFIX, message);

    // Copy the formatted translation to the buffer.
    strcopy(buffer, maxlen, message);
}

/**
 * GetTranslationNP
 * Gets and formats a translation message and doesn't add the plugin prefix.
 */
public void GetTranslationNP(char[] buffer, const int maxlen, const char[] msg, any...) {
    // Get and format the translation portion of the message.
    char message[512];
    VFormat(message, sizeof(message), msg, 4);

    // Add colours to the translation.
    Colorize(message, sizeof(message));

    // Copy the formatted translation to the buffer.
    strcopy(buffer, maxlen, message);
}

/**
 * GetClientTeamName
 * Gets the string format of a client's team.
 */
public void GetClientTeamName(const int team, char[] buffer, const int maxlen) {
    switch (team) {
        case CS_TEAM_T:
            strcopy(buffer, maxlen, "T");
        case CS_TEAM_CT:
            strcopy(buffer, maxlen, "CT");
        case CS_TEAM_SPECTATOR:
            strcopy(buffer, maxlen, "Spec");
    }
}

/**
 * PrintToAdmins
 * Prints a message to admins that match the function arguments.
 */
void PrintToAdmins(const char[] message, const AdminFlag flag = Admin_Chat, const int team = -1, const bool dead = false) {
    for (int client = 1; client <= MaxClients; client++) {
        // Check if the client is invalid.
        if (!IsClientValid(client)) {
            continue;
        }

        // Get the client's admin id.
        AdminId adminId = GetUserAdmin(client);

        // Check if the client is not an admin.
        if (adminId == INVALID_ADMIN_ID) {
            continue;
        }

        // Check if the client does not have the admin flag.
        if (!adminId.HasFlag(flag)) {
            continue;
        }

        // Check if the function arguments set a team.
        if (team != -1) {
            // Check if the client's team is same as the argument.
            if (GetClientTeam(client) == team) {
                continue;
            }
        }

        // Check if the message is ignoring dead players.
        if (dead) {
            // Check if the admin is dead.
            if (!IsPlayerAlive(client)) {
                continue;
            }
        }

        // Send the message to the admin.
        PrintToChat(client, "%s %s", PREFIX, message);
    }
}

/**
 * TeleportClientToTarget
 * Teleports a client to a target.
 */
public void TeleportClientToTarget(const int client, const int target) {
    // Get the target's origin.
    float origin[3];
    GetClientAbsOrigin(target, origin);

    // Teleport the client.
    TeleportEntity(client, origin, NULL_VECTOR, NULL_VECTOR);
}

/**
 * TeleportClientToTarget
 * Teleports a client to a target.
 */
public void TeleportClientToPosition(const int client, const float position[3]) {
    // Teleport the client.
    TeleportEntity(client, position, NULL_VECTOR, NULL_VECTOR);
}

/**
 * DisarmClient
 * Removes a player's weapons.
 */
void DisarmClient(const int client, bool knife = false) {
    for (int i = 0; i < 5; i++) {
        if (i == CS_SLOT_KNIFE && !knife) {
            continue;
        }

        int weapon = GetPlayerWeaponSlot(client, i);

        while (weapon > 0) {
            RemovePlayerItem(client, weapon);
            AcceptEntityInput(weapon, "Kill");

            weapon = GetPlayerWeaponSlot(client, i);
        }
    }
}

public bool TraceEntityFilter_NoPlayers(const int entity, const int contentsMask) {
    return (entity <= 0 || entity > MaxClients);
}
