/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Command_VIP (sm_vip)
 * Prints a list of all online VIPs.
 */
public Action Command_VIP(const int client, const int args) {
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

        // Print the vip information to the client's chat.
        ReplyToCommand(client, " \x02%N\x01 \x0F%s\x01", i, steamId);
        matched++;
    }

    // Print a message if no vips were listed.
    if(matched == 0) {
        ReplyToCommand(client, "%s There are currently no \x10VIPs\x01 online.", PREFIX);
    }

    return Plugin_Handled;
}
