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
    CreateNative("Overlord_IsVIP", Native_IsVIP);
    CreateNative("Overlord_IsStealthed", Native_IsStealthed);
    CreateNative("Overlord_CanStealth", Native_CanStealth);
    return APLRes_Success;
}

/**
 * Native_IsAdmin
 * Returns true if a client is an admin, otherwise false.
 */
public int Native_IsAdmin(Handle plugin, int params) {
    int client = GetNativeCell(1);
    return g_hAdmins[client] != null;
}

/**
 * Native_IsVIP
 * Returns true if a client is a vip, otherwise false.
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

/**
 * Native_IsStealthed
 * Returns true if a client is stealthed, otherwise false.
 */
public int Native_IsStealthed(Handle plugin, int params) {
    int client = GetNativeCell(1);
    return g_bStealthed[client];
}

/**
 * Native_CanStealth
 * Returns true if a client can stealth, otherwise false.
 */
public int Native_CanStealth(Handle plugin, int params) {
    int client = GetNativeCell(1);
    return g_bStealthed[client];
}
