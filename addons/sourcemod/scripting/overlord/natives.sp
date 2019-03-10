/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * AskPluginLoad2
 * Registers overlord as a plugin library and registers our natives.
 */
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
    RegPluginLibrary("overlord");
    CreateNative("Overlord_IsAdmin", Native_IsAdmin);
    CreateNative("Overlord_IsAdminHidden", Native_IsAdminHidden);
    CreateNative("Overlord_IsVIP", Native_IsVIP);
    return APLRes_Success;
}

/**
 * Overlord_IsAdmin
 *
 * Check if a client is an admin.
 *
 * @param Client index.
 * @return True if the client is an admin, false otherwise.
 */
public int Native_IsAdmin(Handle plugin, int params) {
    int client = GetNativeCell(1);
    return g_hAdmins[client] != null;
}

/**
 * Overlord_IsAdminHidden
 *
 * Check if an admin is hidden.
 *
 * @param Client index.
 * @return True if a client is hidden, false otherwise.
 */
public int Native_IsAdminHidden(Handle plugin, int params) {
    int client = GetNativeCell(1);

    Admin admin = g_hAdmins[client];
    if(admin == null) {
        return false;
    }

    return admin.IsHidden();
}

/**
 * Overlord_IsVIP
 *
 * Check if a client is a vip.
 *
 * @param Client index.
 * @return True if the client is a vip, false otherwise.
 */
public int Native_IsVIP(Handle plugin, int params) {
    int client = GetNativeCell(1);

    Admin admin = g_hAdmins[client];
    if(admin == null) {
        return false;
    }

    Group group = g_hGroups[admin.GetGroup()];
    if(group == null) {
        return false;
    }

    char groupName[64];
    group.GetName(groupName, sizeof(groupName));

    return StrEqual("VIP", groupName, true);
}
