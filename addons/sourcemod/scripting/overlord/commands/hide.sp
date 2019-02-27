/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Command_Hide (sm_hide)
 * Admin command that allows them to toggle their hidden status.
 */
public Action Command_Hide(const int client, const int args) {
    // Variable to hold the command name.
    char command[64] = "sm_hide";

    // Check if the client is invalid.
    if(!IsClientValid(client)) {
        ReplyToCommand(client, "%s You must be a client to execute this command.", CONSOLE_PREFIX);
        return Plugin_Handled;
    }

    // Check if the client isn't an admin
    if(GetUserAdmin(client) == INVALID_ADMIN_ID) {
        ReplyToCommand(client, "%s No permission.", PREFIX);
        return Plugin_Handled;
    }

    // Get the client's admin.
    Admin admin = g_hAdmins[client];
    if(admin == null) {
        return Plugin_Handled;
    }

    // Update the admin's hidden state.
    admin.SetHidden(!admin.IsHidden());

    // Notify the admin.
    ReplyToCommand(client, "%s \x10%N\x01 is now %s\x01 to all players.", PREFIX, client, admin.IsHidden() ? "\x04Hidden" : "\x07Visible");

    // Log the command execution.
    LogCommand(client, -1, command, "");

    return Plugin_Handled;
}
