#if defined _overlord_included
    #endinput
#endif
#define _overlord_included

public SharedPlugin __pl_overlord = {
    name = "overlord",
    file = "overlord.smx",
    #if defined REQUIRE_PLUGIN
    required = 1,
    #else
    required = 0,
    #endif
};

/*methodmap Admin {
    public native int GetID();
    public native void SetID(const int id);
    public native void GetName(char[] buffer, const int maxlen);
    public native void SetName(const char[] name);
    public native void GetSteamID(char[] buffer, const int maxlen);
    public native void SetSteamID(const char[] steamId);
    public native int GetGroupID();
    public native void SetGroupID(const int group);
    public native int GetServerGroupID();
    public native void SetServerGroupID(const int serverGroupId);
    public native int GetGroup();
    public native bool IsHidden();
    public native void SetHidden(bool hidden);
    public native int GetCreatedAt();
    public native void SetCreatedAt(const int createdAt);
}*/

/**
 * Overlord_IsAdmin
 *
 * Check if a client is an admin.
 *
 * @param Client index.
 * @return True if the client is an admin, false otherwise.
 */
native bool Overlord_IsAdmin(const int client);

/**
 * Overlord_GetAdminName
 *
 * Get an admin's name.
 *
 * @param Client index.
 * @param Buffer to store admin's name.
 * @param Buffer max length.
 * @return True if buffer was updated, false otherwise.
 */
native bool Overlord_GetAdminName(const int client, char[] buffer, const int maxlen);

/**
 * Overlord_GetAdminGroupName
 *
 * Get an admin's group name.
 *
 * @param Client index.
 * @param Buffer to store the group name.
 * @param Buffer max length.
 * @return True if buffer was updated, false otherwise.
 */
native bool Overlord_GetAdminGroupName(const int client, char[] buffer, const int maxlen);

/**
 * Overlord_IsAdminHidden
 *
 * Check if an admin is hidden.
 *
 * @param Client index.
 * @return True if a client is hidden, false otherwise.
 */
native bool Overlord_IsAdminHidden(const int client);

/**
 * Overlord_IsVIP
 *
 * Check if a client is a vip.
 *
 * @param Client index.
 * @return True if the client is a vip, false otherwise.
 */
native bool Overlord_IsVIP(const int client);
