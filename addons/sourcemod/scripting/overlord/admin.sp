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

        // Reload all admins.
        Backend_ReloadAdmins();
    }
}

/**
 * Admin_RefreshId
 * Reloads an admin's groups and privileges.
 */
public void Admin_RefreshId(const int client) {
    Admin admin = g_hAdmins[client];
    if(admin == null) {
        return;
    }

    // Get the admin's name.
    char name[32];
    admin.GetName(name, sizeof(name));

    // Create admin
    AdminId adminId = GetUserAdmin(client);
    if(adminId != INVALID_ADMIN_ID) {
        RemoveAdmin(adminId);
    }

    adminId = CreateAdmin(name);
    SetUserAdmin(client, adminId, true);
    // END Create admin

    // Add admin group
    Group userGroup = g_hGroups[admin.GetGroup()];
    if(userGroup == null) {
        return;
    }

    char groupName[32];
    userGroup.GetName(groupName, sizeof(groupName));

    GroupId groupId = FindAdmGroup(groupName);
    if(groupId == INVALID_GROUP_ID) {
        LogError("%s Failed to locate existing admin group.", CONSOLE_PREFIX);
        return;
    }

    if(!adminId.InheritGroup(groupId)) {
        LogError("%s Failed to inherit admin group.", CONSOLE_PREFIX);
        return;
    }
    // END Add admin group
}

/**
 * Admin_SetTag
 * Sets a client's clan tag to the one specified in their group.
 */
public void Admin_SetTag(const int client) {
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
    if(g_hAdminTagTimer != INVALID_HANDLE) {
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
