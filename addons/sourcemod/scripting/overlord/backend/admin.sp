/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Backend_ReloadAdmins
 * Reloads all admins from the database.
 */
public void Backend_ReloadAdmins() {
    // Check if the g_dbOverlord handle is invalid.
    if(g_dbOverlord == INVALID_HANDLE) {
        LogError("%s Failed to run Backend_ReloadAdmins() due to an invalid database handle.", CONSOLE_PREFIX);
        return;
    }

    // Loop through all online clients.
    for(int client = 1; client <= MaxClients; client++) {
        // Check if the client is invalid.
        if(!IsClientValid(client)) {
            continue;
        }

        OnClientPutInServer(client);

        // Get the client's steam id.
        char steamId[64];
        GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId));

        // Load the client's admin.
        Backend_GetAdmin(client, steamId);
    }
}

/**
 * Backend_GetAdmin
 * Loads a user's admin information.
 */
public void Backend_GetAdmin(int client, const char[] steamId) {
    // Check if the g_dbOverlord handle is invalid.
    if(g_dbOverlord == INVALID_HANDLE) {
        LogError("%s Failed to run Backend_GetAdmin(int, char[]) due to an invalid database handle.", CONSOLE_PREFIX);
        return;
    }

    // Create and format the query.
    char query[1024];
    Format(query, sizeof(query), GET_ADMIN, g_iServerId, steamId);

    // Execute the query.
    g_dbOverlord.Query(Callback_GetAdmin, query, client);
}

/**
 * Callback_GetAdmin
 * Backend callback for Backend_GetAdmin(int, char[])
 */
static void Callback_GetAdmin(Database database, DBResultSet results, const char[] error, int client) {
    // Handle query error.
    if(results == null) {
        LogError("%s Query failure. %s >> %s", CONSOLE_PREFIX, "Callback_GetAdmin", (strlen(error) > 0 ? error : "Unknown."));
        return;
    }

    // Ignore empty result set.
    if(results.RowCount == 0) {
        return;
    }

    // Get table column indexes.
    int idIndex;
    int nameIndex;
    int steamIdIndex;
    int hiddenIndex;
    int activeIndex;
    int createdAtIndex;
    int groupIdIndex;
    int serverGroupIdIndex;
    if(!results.FieldNameToNum("id", idIndex)) { LogError("%s Failed to locate \"id\" field in table \"overlord_admins\".", CONSOLE_PREFIX); return; }
    if(!results.FieldNameToNum("name", nameIndex)) { LogError("%s Failed to locate \"name\" field in table \"overlord_admins\".", CONSOLE_PREFIX); return; }
    if(!results.FieldNameToNum("steamId", steamIdIndex)) { LogError("%s Failed to locate \"steamId\" field in table \"overlord_admins\".", CONSOLE_PREFIX); return; }
    if(!results.FieldNameToNum("hidden", hiddenIndex)) { LogError("%s Failed to locate \"hidden\" field in table \"overlord_admins\".", CONSOLE_PREFIX); return; }
    if(!results.FieldNameToNum("active", activeIndex)) { LogError("%s Failed to locate \"active\" field in table \"overlord_admins\".", CONSOLE_PREFIX); return; }
    if(!results.FieldNameToNum("createdAt", createdAtIndex)) { LogError("%s Failed to locate \"createdAt\" field in table \"overlord_admins\".", CONSOLE_PREFIX); return; }
    if(!results.FieldNameToNum("groupId", groupIdIndex)) { LogError("%s Failed to locate \"groupId\" field in table \"overlord_admins\".", CONSOLE_PREFIX); return; }
    if(!results.FieldNameToNum("serverGroupId", serverGroupIdIndex)) { LogError("%s Failed to locate \"serverGroupId\" field in table \"overlord_admins\".", CONSOLE_PREFIX); return; }
    // END Get table column indexes.

    // Loop through query results.
    while(results.FetchRow()) {
        // Check if admin is deactivated.
        if(results.FetchInt(activeIndex) == 0) {
            LogMessage("%s Found admin for '%N', but it is deactivated.", CONSOLE_PREFIX, client);
            continue;
        }

        // Pull row information.
        int id = results.FetchInt(idIndex);
        char name[32];
        char steamId[64];
        bool hidden = false;
        if(results.FetchInt(hiddenIndex) == 1) {
            hidden = true;
        }
        int createdAt = results.FetchInt(createdAtIndex);
        int group = 0;

        results.FetchString(nameIndex, name, sizeof(name));
        results.FetchString(steamIdIndex, steamId, sizeof(steamId));

        if(results.IsFieldNull(serverGroupIdIndex)) {
            if(results.IsFieldNull(groupIdIndex)) {
                // Log that we found an admin, but no group is set.
                LogMessage("%s Found admin for '%N' but group is null. (Steam ID: %s)", CONSOLE_PREFIX, client, steamId);
                LogMessage("%s %i", CONSOLE_PREFIX, results.FetchInt(serverGroupIdIndex));
                continue;
            }
            group = results.FetchInt(groupIdIndex);
        } else {
            group = results.FetchInt(serverGroupIdIndex);
        }
        // END Pull row information.

        // Log that we found an admin.
        LogMessage("%s Found admin for '%N' (Steam ID: %s)", CONSOLE_PREFIX, client, steamId);

        // Create admin object and set properties.
        Admin admin = new Admin();
        admin.SetID(id);
        admin.SetName(name);
        admin.SetSteamID(steamId);
        admin.SetGroup(group);
        admin.SetHidden(hidden);
        admin.SetCreatedAt(createdAt);

        // Create admin
        AdminId adminId = GetUserAdmin(client);
        if(adminId == INVALID_ADMIN_ID) {
            adminId = CreateAdmin(name);
            SetUserAdmin(client, adminId, true);
        }
        // END Create admin

        // Add admin group if one isn't already present.
        if(adminId.GroupCount == 0) {
            Group userGroup = g_hGroups[group];
            if(userGroup == null) {
                continue;
            }

            char groupName[32];
            userGroup.GetName(groupName, sizeof(groupName));

            GroupId groupId = FindAdmGroup(groupName);
            if(groupId == INVALID_GROUP_ID) {
                LogError("%s Failed to locate existing admin group.", CONSOLE_PREFIX);
                continue;
            }

            if(!adminId.InheritGroup(groupId)) {
                LogError("%s Failed to inherit admin group.", CONSOLE_PREFIX);
                continue;
            }
        }
        // END Add admin group if one isn't already present.

        // Add admin to the admins array.
        g_hAdmins[client] = admin;
    }
}

/**
 * Backend_UpdateAdmin
 * Updates a user's admin information.
 */
public void Backend_UpdateAdmin(int client) {
    // Check if the g_dbOverlord handle is invalid.
    if(g_dbOverlord == INVALID_HANDLE) {
        LogError("%s Failed to run Backend_UpdateAdmin(int) due to an invalid database handle.", CONSOLE_PREFIX);
        return;
    }

    // Get client's admin.
    Admin admin = g_hAdmins[client];
    if(admin == null) {
        return;
    }

    // Get the admin's steam id.
    char steamId[64];
    admin.GetSteamID(steamId, sizeof(steamId));

    // Create and format the query.
    char query[512];
    Format(query, sizeof(query), UPDATE_ADMIN, admin.IsHidden() ? 1 : 0, steamId);

    // Execute the query.
    g_dbOverlord.Query(Callback_UpdateAdmin, query, client);
}

/**
 * Callback_UpdateAdmin
 * Backend callback for Backend_UpdateAdmin(int)
 */
static void Callback_UpdateAdmin(Database database, DBResultSet results, const char[] error, int client) {
    // Handle query error.
    if(results == null) {
        LogError("%s Query failure. %s >> %s", CONSOLE_PREFIX, "Callback_UpdateAdmin", (strlen(error) > 0 ? error : "Unknown."));
        return;
    }

    // Log that we saved the admin's information.
    LogMessage("%s Saved admin information for %i.", CONSOLE_PREFIX, client);
}
