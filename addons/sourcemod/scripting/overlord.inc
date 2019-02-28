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
 * Returns true if a client is an admin, otherwise false.
 */
native bool Overlord_IsAdmin(const int client);

/**
 * Overlord_IsVIP
 * Returns true if a client is a vip, otherwise false.
 */
native bool Overlord_IsVIP(const int client);

/**
 * Overlord_IsStealthed
 * Returns true if a client is stealthed, otherwise false.
 */
native bool Overlord_IsStealthed(const int client);

/**
 * Overlord_CanStealth
 * Returns true if a client can stealth, otherwise false.
 */
native bool Overlord_CanStealth(const int client);
