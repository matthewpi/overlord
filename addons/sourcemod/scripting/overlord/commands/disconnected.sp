/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Command_Disconnected (sm_disconnected)
 * Opens a menu with a list of recently disconnected players.
 */
public Action Command_Disconnected(const int client, const int args) {
    // Check if the client is invalid.
    if (!IsClientValid(client)) {
        ReplyToCommand(client, "%s You must be a player to execute this command.", CONSOLE_PREFIX);
        return Plugin_Handled;
    }

    // Check if no players have recently disconnected.
    if (g_alDisconnected.Length < 1) {
        ReplyToCommand(client, "%s There have been no recently disconnected players.", PREFIX);
        return Plugin_Handled;
    }

    ReplyToCommand(client, "%s Showing the last \x10%i\x01 disconnected players.", PREFIX, g_alDisconnected.Length);
    Disconnected_Menu(client);
    return Plugin_Handled;
}
