/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Command_VIPs (sm_vips)
 * Prints a list of all online VIPs.
 */
public Action Command_VIPs(const int client, const int args) {
    // Check if the client is invalid.
    if(!IsClientValid(client)) {
        ReplyToCommand(client, "%s You must be a client to execute this command.", CONSOLE_PREFIX);
        return Plugin_Handled;
    }

    // Loop through all admins.
    int matched = 0;
    for(int i = 1; i < sizeof(g_hAdmins); i++) {
        // Check if the client is a VIP.
        if(!Overlord_IsVIP(i)) {
            continue;
        }

        // Get the client's steamid.
        char steamId[64];
        GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId));

        // Get the admin's name.
        char clientName[128];
        GetClientName(i, clientName, sizeof(clientName));

        // Get and format the translation.
        char buffer[512];
        GetTranslationNP(buffer, sizeof(buffer), "%T", "sm_vips VIP", client, clientName, steamId);

        // Print the vip information to the client's chat.
        ReplyToCommand(client, buffer, i, steamId);
        //ReplyToCommand(client, " \x02%N\x01 \x0F%s\x01", i, steamId);
        matched++;
    }

    // Print a message if no vips were listed.
    if(matched == 0) {
        // Get and format the translation.
        char buffer[512];
        GetTranslation(buffer, sizeof(buffer), "%T", "sm_vips None", client);

        // Send a message to the client.
        ReplyToCommand(client, buffer);
    }

    return Plugin_Handled;
}
