/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Command_Overlord (sm_overlord)
 * Opens a menu to manage the overlord plugin.
 */
public Action Command_Overlord(const int client, const int args) {
    // Check if the client is invalid.
    if(!IsClientValid(client)) {
        ReplyToCommand(client, "%s You must be a player to execute this command.", CONSOLE_PREFIX);
        return Plugin_Handled;
    }

    ReplyToCommand(client, "%s \x10Overlord v%s\x01 by \x07%s\x01.", PREFIX, OVERLORD_VERSION, OVERLORD_AUTHOR);
    Overlord_Menu(client);
    return Plugin_Handled;
}
