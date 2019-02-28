/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * OnRebuildAdminCache
 * Reloads overlord groups and users.
 */
public void OnRebuildAdminCache(AdminCachePart part) {
    // Check if we are reloading groups.
    if(part == AdminCache_Groups) {
        // Log that we are reloading admin groups.
        LogMessage("%s Reloading admin groups.", CONSOLE_PREFIX);

        // Reload the admin groups.
        Backend_LoadGroups();
    // Check if we are reloading admins.
    } else if(part == AdminCache_Admins) {
        // Log that we are reloading admins.
        LogMessage("%s Reloading admins.", CONSOLE_PREFIX);

        // Loop through all online clients.
        for(int i = 1; i <= MaxClients; i++) {
            // Check if the client is invalid.
            if(!IsClientValid(i)) {
                continue;
            }

            // Get the client's steam id.
            char steamId[64];
            GetClientAuthId(i, AuthId_Steam2, steamId, sizeof(steamId));

            // Load the client's admin profile from the database.
            // TODO: Use a transaction per 5-10 Backend_GetAdmin queries.
            Backend_GetAdmin(i, steamId);
        }
    }
}

/**
 * Admin_SetTag
 * Sets a client's clan tag to the one specified in their group.
 */
public void Admin_SetTag(int client) {
    // Check if the client is invalid.
    if(!IsClientValid(client)) {
        return;
    }

    // Check if the user is a loaded admin.
    Admin admin = g_hAdmins[client];
    if(admin == null) {
        return;
    }

    // Check if the user is hidden.
    if(admin.IsHidden()) {
        return;
    }

    // Get the user's group.
    Group group = g_hGroups[admin.GetGroup()];
    if(group == null) {
        return;
    }

    // Get the user's group tag.
    char groupTag[16];
    group.GetTag(groupTag, sizeof(groupTag));

    // Set the client's clan tag.
    CS_SetClientClanTag(client, groupTag);
}

/**
 * Admin_TagTimer
 * Creates a timer that sets all the admin's clan tags.
 */
public void Admin_TagTimer() {
    // Check if the timer already exists.
    if(g_hAdminTagTimer != null) {
        return;
    }

    // Create tag timer. (set all admin's clan tag)
    g_hAdminTagTimer = CreateTimer(3.0, Timer_TagAll, _, TIMER_REPEAT);
}

/**
 * Timer_TagAll
 * Sets all player's clantag to the one specified in their group.
 */
static Action Timer_TagAll(Handle timer) {
    // Loop through all online clients.
    for(int client = 1; client <= MaxClients; client++) {
        // Check if the client is invalid.
        if(!IsClientValid(client)) {
            continue;
        }

        // Attempt to set the client's tag.
        Admin_SetTag(client);
    }
}
