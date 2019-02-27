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
        // Get the admin object from the admins array.
        Admin admin = g_hAdmins[i];
        if(admin == null) {
            continue;
        }

        // Check if the admin has no group.
        if(admin.GetGroup() == 0) {
            continue;
        }

        // Get the admin's group.
        Group group = g_hGroups[admin.GetGroup()];
        if(group == null) {
            continue;
        }

        // Check if the group isn't VIP.
        if(group.GetImmunity() != 0) {
            continue;
        }

        // Get the vip's steamid.
        char steamId[64];
        admin.GetSteamID(steamId, sizeof(steamId));

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
