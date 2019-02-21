/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

#include <cstrike>
#include <geoip>
#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

// Definitions
#define OVERLORD_AUTHOR "Matthew \"MP\" Penner"
#define OVERLORD_VERSION "0.0.1-BETA"

#define PREFIX "[\x06Overlord\x01]"
#define CONSOLE_PREFIX "[Overlord]"

#define GROUP_MAX 16
// END Definitions

// Project Models
#include "overlord/models/admin.sp"
#include "overlord/models/group.sp"
// END Project Models

// Globals
// sm_overlord_database - "Sets what database the plugin should use." (Default: "overlord")
ConVar g_cvDatabase;
// sm_overlord_message_join - "" (Default: "1")
ConVar g_cvMessageJoin;
// sm_overlord_message_quit - "" (Default: "1")
ConVar g_cvMessageQuit;
// ip
ConVar g_cvServerIp;
// hostport
ConVar g_cvServerPort;
// hostname
ConVar g_cvServerHostname;
// rcon_password
ConVar g_cvServerRconPassword;

// g_iServerId .
int g_iServerId = 1;

// g_hGroups stores an array of loaded Groups.
Group g_hGroups[GROUP_MAX];

// g_hAdmins stores an array of loaded Admins.
Admin g_hAdmins[MAXPLAYERS + 1];
// END Globals

// Project Files
#include "overlord/admin.sp"
#include "overlord/backend.sp"
#include "overlord/commands.sp"
#include "overlord/utils.sp"
// END Project Files

// Plugin Information
public Plugin myinfo = {
    name = "[Krygon] Overlord",
    author = OVERLORD_AUTHOR,
    description = "Admin, Group, and Punishment System",
    version = OVERLORD_VERSION,
    url = "https://matthewp.io"
};
// END Plugin Information

/**
 * OnPluginStart
 * Initiates plugin, registers convars, registers commands, connects to database.
 */
public void OnPluginStart() {
    LoadTranslations("common.phrases");
    LoadTranslations("overlord.phrases");

    g_cvDatabase = CreateConVar("sm_overlord_database", "overlord", "Sets what database the plugin should use.");
    g_cvMessageJoin = CreateConVar("sm_overlord_message_join", "1", "", _, true, 0.0, true, 1.0);
    g_cvMessageQuit = CreateConVar("sm_overlord_message_quit", "1", "", _, true, 0.0, true, 1.0);
    g_cvServerIp = FindConVar("ip");
    g_cvServerPort = FindConVar("hostport");
    g_cvServerHostname = FindConVar("hostname");
    g_cvServerRconPassword = FindConVar("rcon_password");

    AutoExecConfig(true, "overlord");

    char databaseName[64];
    g_cvDatabase.GetString(databaseName, sizeof(databaseName));
    Database.Connect(Backend_Connnection, databaseName);

    RegConsoleCmd("sm_admins", Command_Admins, "Prints a list of admins.");
    RegConsoleCmd("sm_vip", Command_VIP, "Prints a list of vips.");
    RegConsoleCmd("sm_groups", Command_Groups, "Prints a list of groups.");
    RegAdminCmd("sm_hide", Command_Hide, ADMFLAG_GENERIC, "Toggles an admin's hidden state.");
}

/**
 * OnClientAuthorized
 * Prints a connect chat message, loads client's admin data.
 */
public void OnClientAuthorized(int client, const char[] auth) {
    // Ignore bot users.
    if(StrEqual(auth, "BOT", true)) {
        return;
    }

    char ipAddress[16];
    GetClientIP(client, ipAddress, sizeof(ipAddress));
    char country[45];
    GeoipCountry(ipAddress, country, sizeof(country));

    // Check if the join message is enabled.
    if(g_cvMessageJoin.BoolValue) {
        // Print the connect message to everyone.
        PrintToChatAll("%s \x05%N \x01has connected from \x07%s\x01. (\x10%s\x01)", PREFIX, client, country, auth);
        // Print the connect message to the server.
        LogMessage("%s %N has connected from %s. (%s)", CONSOLE_PREFIX, client, country, auth);
    }

    // Attempt to load user's admin information.
    Backend_GetAdmin(client, auth);
}

/**
 * OnClientDisconnect
 * Prints a disconnect chat message.
 */
public void OnClientDisconnect(int client) {
    // Get the client's steam id.
    char auth[64];
    GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth));

    // Ignore bot users.
    if(StrEqual(auth, "BOT", true)) {
        return;
    }

    // Check if the quit message is enabled.
    if(g_cvMessageQuit.BoolValue) {
        // Print the disconnect message to everyone.
        PrintToChatAll("%s \x05%N \x01has disconnected. (\x10%s\x01)", PREFIX, client, auth);
        // Print the disconnect message to the server.
        LogMessage("%s %N has disconnected. (%s)", CONSOLE_PREFIX, client, auth);
    }

    // Check if user is an admin.
    if(g_hAdmins[client] == null) {
        return;
    }

    // Check if the admin has a valid group and if they are a vip.
    if(g_hAdmins[client].GetGroup() == 0 || g_hGroups[g_hAdmins[client].GetGroup()].GetImmunity() == 0) {
        return;
    }

    // Save the admin's information.
    Backend_UpdateAdmin(client);

    // Unallocate memory for user admin storage.
    delete g_hAdmins[client];
}
