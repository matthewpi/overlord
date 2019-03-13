#if defined _overlord_included
    #endinput
#endif
#define _overlord_included

public SharedPlugin __pl_overlord = {
    name = "Overlord",
    file = "overlord.smx",
    #if defined REQUIRE_PLUGIN
    required = 1,
    #else
    required = 0,
    #endif
};

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
