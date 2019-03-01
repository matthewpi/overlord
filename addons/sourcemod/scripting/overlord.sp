/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

#include <cstrike>
#include <geoip>
#include <overlord>
#include <regex>
#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

// Definitions
// Overlord
#define OVERLORD_AUTHOR  "Matthew \"MP\" Penner"
#define OVERLORD_VERSION "0.0.1-BETA"
#define OVERLORD_RELEASE "https://api.github.com/repos/matthewpi/overlord/releases/latest"

// Prefixes
#define PREFIX         "[\x06Overlord\x01]"
#define ACTION_PREFIX  "[\x06Overlord\x01] "
#define CONSOLE_PREFIX "[Overlord]"

// Limits
#define GROUP_MAX 16

// Models
#define MODEL_LIGHTNING    "sprites/steam1.vmt"
#define MODEL_LIGHTNING_DL "materials/overlord/laserbeam.vmt"

#define MODEL_SMOKE    "sprites/steam1.vmt"
#define MODEL_SMOKE_DL "materials/sprites/steam1.vmt"

// Sounds
#define SOUND_HOG "*overlord/hog.mp3"
#define SOUND_HOG_DL "sound/overlord/hog.mp3"
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
// sv_deadtalk
ConVar g_cvDeadTalk;
// ip
ConVar g_cvServerIp;
// hostport
ConVar g_cvServerPort;
// hostname
ConVar g_cvServerHostname;
// rcon_password
ConVar g_cvServerRconPassword;

char g_cServerMap[128];

// g_dbOverlord Stores the active database connection.
Database g_dbOverlord;

// g_hAdminTagTimer stores the handle for the active admin tag timer.
Handle g_hAdminTagTimer;

// g_iLightningSprite
int g_iLightningSprite;

// g_iSmokeSprite
int g_iSmokeSprite;

// g_iServerId stores the server's database id.
int g_iServerId = 0;

// g_hGroups stores an array of loaded Groups.
Group g_hGroups[GROUP_MAX];

// g_hAdmins stores an array of loaded Admins.
Admin g_hAdmins[MAXPLAYERS + 1];

// g_iSwapOnRoundEnd stores an array of client to swap to another team.
int g_iSwapOnRoundEnd[MAXPLAYERS + 1];

// g_alDeathPosition stores a list of client death positions.
ArrayList g_alDeathPosition;

// g_bStealthed stores an array of clients and a boolean value representing if they are stealthed or not.
bool g_bStealthed[MAXPLAYERS + 1];

// g_bStealthDisconnect stores an array of clients and a boolean value representing if they are "disconnected" or not.
bool g_bStealthDisconnect[MAXPLAYERS + 1];

// g_iStealthPlayerManager
int g_iStealthPlayerManager;

// g_iFollowing
int g_iFollowing[MAXPLAYERS + 1];
// END Globals

// Project Files
#include "overlord/admin.sp"
#include "overlord/natives.sp"
#include "overlord/sourcemod.sp"
#include "overlord/stealth.sp"
#include "overlord/utils.sp"

// Backend
#include "overlord/backend/queries.sp"
#include "overlord/backend/admin.sp"
#include "overlord/backend/group.sp"
#include "overlord/backend/server.sp"
#include "overlord/backend/backend.sp"

// Commands
#include "overlord/commands/admins.sp"
#include "overlord/commands/follow.sp"
#include "overlord/commands/groups.sp"
#include "overlord/commands/heal.sp"
#include "overlord/commands/hide.sp"
#include "overlord/commands/hog.sp"
#include "overlord/commands/respawn.sp"
#include "overlord/commands/status.sp"
#include "overlord/commands/team.sp"
#include "overlord/commands/teleport.sp"
#include "overlord/commands/vip.sp"

// Events
#include "overlord/events/player_chat.sp"
#include "overlord/events/player_death.sp"
#include "overlord/events/player_spawn.sp"
#include "overlord/events/player_team.sp"
#include "overlord/events/round_end.sp"
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
    // Load translations
    LoadTranslations("common.phrases");
    LoadTranslations("overlord.phrases");

    // Create custom convars for the plugin.
    g_cvDatabase = CreateConVar("sm_overlord_database", "overlord", "Sets what database the plugin should use.");
    g_cvMessageJoin = CreateConVar("sm_overlord_message_join", "1", "", _, true, 0.0, true, 1.0);
    g_cvMessageQuit = CreateConVar("sm_overlord_message_quit", "1", "", _, true, 0.0, true, 1.0);

    // Generate and load our plugin convar config.
    AutoExecConfig(true, "overlord");

    // Find server convars
    g_cvDeadTalk = FindConVar("sv_deadtalk");
    g_cvServerIp = FindConVar("ip");
    g_cvServerPort = FindConVar("hostport");
    g_cvServerHostname = FindConVar("hostname");
    g_cvServerRconPassword = FindConVar("rcon_password");

    // Get the database name from the g_cvDatabase convar.
    char databaseName[64];
    g_cvDatabase.GetString(databaseName, sizeof(databaseName));

    // Attempt connection to the database.
    Database.Connect(Backend_Connnection, databaseName);

    // Commands
    // overlord/commands/admins.sp
    RegConsoleCmd("sm_admins", Command_Admins, "Prints a list of admins.");
    // overlord/commands/follow.sp
    RegAdminCmd("sm_follow", Command_Follow, ADMFLAG_SLAY, "Follows a player while in spectate.");
    // overlord/commands/groups.sp
    RegConsoleCmd("sm_groups", Command_Groups, "Prints a list of groups.");
    // overlord/commands/heal.sp
    RegAdminCmd("sm_heal", Command_Heal, ADMFLAG_SLAY, "Heals a player.");
    // overlord/commands/hide.sp
    RegAdminCmd("sm_hide", Command_Hide, ADMFLAG_KICK, "Toggles an admin's hidden state.");
    // overlord/commands/hog.sp
    RegAdminCmd("sm_hog", Command_Hog, ADMFLAG_BAN, "Slays a client and strikes lightning on them.");
    // overlord/commands/respawn.sp
    RegAdminCmd("sm_respawn", Command_Respawn, ADMFLAG_SLAY, "Respawns a dead player.");
    // overlord/commands/status.sp
    AddCommandListener(Command_Status, "status");
    // overlord/commands/team.sp
    RegAdminCmd("sm_team_t", Command_Team_T, ADMFLAG_SLAY, "Swap a client to the terrorist team.");
    RegAdminCmd("sm_team_ct", Command_Team_CT, ADMFLAG_SLAY, "Swap a client to the counter-terrorist team.");
    RegAdminCmd("sm_team_spec", Command_Team_Spec, ADMFLAG_SLAY, "Swap a client to the spectator team.");
    // overlord/commands/teleport.sp
    RegAdminCmd("sm_tp", Command_Teleport, ADMFLAG_BAN, "Teleport to a client.");
    // overlord/commands/vip.sp
    RegConsoleCmd("sm_vip", Command_VIP, "Prints a list of vips.");
    // END Commands

    // Events
    // overlord/events/player_death.sp
    if(!HookEventEx("player_death", Event_PlayerDeath)) {
        SetFailState("%s Failed to hook \"player_death\" event, disabling plugin..", CONSOLE_PREFIX);
        return;
    }
    // overlord/events/player_spawn.sp
    if(!HookEventEx("player_spawn", Event_PlayerSpawn)) {
        SetFailState("%s Failed to hook \"player_spawn\" event, disabling plugin..", CONSOLE_PREFIX);
        return;
    }
    // overlord/events/player_team.sp
    if(!HookEventEx("player_team", Event_PlayerTeamPre, EventHookMode_Pre)) {
        SetFailState("%s Failed to hook \"player_team\" event, disabling plugin..", CONSOLE_PREFIX);
        return;
    }
    // overlord/events/round_end.sp
    if(!HookEventEx("round_end", Event_RoundEnd)) {
        SetFailState("%s Failed to hook \"round_end\" event, disabling plugin..", CONSOLE_PREFIX);
        return;
    }
    // END Events

    // overlord/sourcemod.sp
    HookUserMessage(GetUserMessageId("TextMsg"), Sourcemod_TextMessage, true);
}

/**
 * OnMapStart
 * Adds files that need to be downloaded; precaches materials, sprites, and sounds.
 */
public void OnMapStart() {
    // Cache the current map name.
    GetCurrentMap(g_cServerMap, sizeof(g_cServerMap));

    // File Downloads
    AddFileToDownloadsTable(SOUND_HOG_DL);
    AddFileToDownloadsTable(MODEL_LIGHTNING_DL);
    AddFileToDownloadsTable(MODEL_SMOKE_DL);

    // Sounds
    PrecacheSound(SOUND_HOG, true);

    // Models
    g_iLightningSprite = PrecacheModel(MODEL_LIGHTNING);
    g_iSmokeSprite = PrecacheModel(MODEL_SMOKE);

    // Update the "g_iStealthPlayerManager".
    g_iStealthPlayerManager = GetPlayerResourceEntity();

    // Hook "Stealth_PlayerManagerThinkPost",
    SDKHook(g_iStealthPlayerManager, SDKHook_ThinkPost, Stealth_PlayerManagerThinkPost);
}

/**
 * OnClientPutInServer
 * Registers SDK Hooks, sets default array values.
 */
public void OnClientPutInServer(int client) {
    // overlord/stealth.sp
    SDKHook(client, SDKHook_SetTransmit, Stealth_SetTransmit);

    // Set default array values.
    g_iSwapOnRoundEnd[client] = -1;
    g_bStealthed[client] = false;
    g_bStealthDisconnect[client] = false;
    g_iFollowing[client] = -1;
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

    // Check if the join message is enabled.
    if(g_cvMessageJoin.BoolValue) {
        // Get the client's ip address.
        char ipAddress[16];
        GetClientIP(client, ipAddress, sizeof(ipAddress));

        // Get the client's country using their ip.
        char country[45];
        GeoipCountry(ipAddress, country, sizeof(country));

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
    // Set default array values.
    g_iSwapOnRoundEnd[client] = -1;
    g_bStealthed[client] = false;
    g_bStealthDisconnect[client] = false;

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

/**
 * OnEntityCreated
 * ?
 */
public void OnEntityCreated(int entity, const char[] classname) {
    // Check if the classname does not contain "player_manager"
    if(StrContains(classname, "player_manager", false) == -1) {
        return;
    }

    // Update the "g_iStealthPlayerManager".
    g_iStealthPlayerManager = entity;

    // Hook "Stealth_PlayerManagerThinkPost",
    SDKHook(g_iStealthPlayerManager, SDKHook_ThinkPost, Stealth_PlayerManagerThinkPost);
}
