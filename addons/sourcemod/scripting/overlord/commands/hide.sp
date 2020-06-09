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
    if (!IsClientValid(client)) {
        ReplyToCommand(client, "%s You must be a player to execute this command.", CONSOLE_PREFIX);
        return Plugin_Handled;
    }

    // Get the client's admin.
    Admin admin = g_hAdmins[client];
    if (admin == null) {
        return Plugin_Handled;
    }

    // Update the admin's hidden state.
    admin.SetHidden(!admin.IsHidden());

    // Get the client's name.
    char clientName[128];
    GetClientName(client, clientName, sizeof(clientName));

    // Get and format the translation.
    char buffer[512];
    if (!admin.IsHidden()) {
        GetTranslation(buffer, sizeof(buffer), "%T", "sm_hide Visible", client, clientName);
    } else {
        GetTranslation(buffer, sizeof(buffer), "%T", "sm_hide Hidden", client, clientName);
    }

    // Send a message to the client.
    ReplyToCommand(client, buffer);

    // Log the command execution.
    LogCommand(client, -1, command, "");

    // Check if the admin is visible.
    if (!admin.IsHidden()) {
        // Call the "g_hOnAdminVisible" forward.
        Call_StartForward(g_hOnAdminVisible);
    } else {
        // Call the "g_hOnAdminHide" forward.
        Call_StartForward(g_hOnAdminHide);
    }

    // Add the client as a parameter.
    Call_PushCell(client);

    // Finish the forward call.
    Call_Finish();

    return Plugin_Handled;
}
