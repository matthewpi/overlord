/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

#include <cstrike>
#include <geoip>
#include <overlord>
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
#define PREFIX         "\x01[\x06Overlord\x01]"
#define ACTION_PREFIX  "\x01[\x06Overlord\x01]\x08 "
#define CONSOLE_PREFIX "[Overlord]"

// Actions
#define OVERLORD_ACTION_NONE    -1
#define OVERLORD_ACTION_ADMIN_NAME 1
#define OVERLORD_ACTION_GROUP_NAME 2
#define OVERLORD_ACTION_GROUP_TAG  3

// Limits
#define GROUP_MAX 32
// END Definitions

// Project Models
#include "overlord/models/admin.sp"
#include "overlord/models/group.sp"
#include "overlord/models/player.sp"
// END Project Models

// Project Files
#include "overlord/globals.sp"
#include "overlord/admin.sp"
#include "overlord/assets.sp"
#include "overlord/chat.sp"
#include "overlord/natives.sp"
#include "overlord/sourcemod.sp"
#include "overlord/utils.sp"

// Backend
#include "overlord/backend/queries.sp"
#include "overlord/backend/admin.sp"
#include "overlord/backend/group.sp"
#include "overlord/backend/server.sp"
#include "overlord/backend/backend.sp"

// Commands
#include "overlord/commands/admins.sp"
#include "overlord/commands/disconnected.sp"
#include "overlord/commands/follow.sp"
#include "overlord/commands/groups.sp"
#include "overlord/commands/heal.sp"
#include "overlord/commands/health.sp"
#include "overlord/commands/hide.sp"
#include "overlord/commands/hog.sp"
#include "overlord/commands/overlord.sp"
#include "overlord/commands/respawn.sp"
#include "overlord/commands/respawn_aim.sp"
#include "overlord/commands/respawn_here.sp"
#include "overlord/commands/team.sp"
#include "overlord/commands/teleport.sp"
#include "overlord/commands/teleport_aim.sp"
#include "overlord/commands/teleport_here.sp"
#include "overlord/commands/vips.sp"

// Events
#include "overlord/events/map_change.sp"
#include "overlord/events/player_chat.sp"
#include "overlord/events/player_death.sp"
#include "overlord/events/player_spawn.sp"
#include "overlord/events/round_end.sp"

// Menus
#include "overlord/menus/disconnected.sp"
#include "overlord/menus/overlord.sp"
#include "overlord/menus/admin/main.sp"
#include "overlord/menus/admin/info.sp"
#include "overlord/menus/admin/new.sp"
#include "overlord/menus/group/main.sp"
#include "overlord/menus/group/info.sp"
// END Project Files

// Plugin Information
public Plugin myinfo = {
    name = "[Overlord] Core",
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
    // Load translations.
    LoadTranslations("common.phrases");
    LoadTranslations("overlord.phrases");
    LoadTranslations("overlord.chat.phrases");

    // ConVars
    g_cvDatabase    = CreateConVar("sm_overlord_database", "overlord", "Sets what database the plugin should use.");
    g_cvMessageJoin = CreateConVar("sm_overlord_message_join", "1", "Should we print a join message?", _, true, 0.0, true, 1.0);
    g_cvMessageQuit = CreateConVar("sm_overlord_message_quit", "1", "Should we print a quit message?", _, true, 0.0, true, 1.0);
    g_cvCollisions  = CreateConVar("sm_overlord_collisions", "0", "Should collisions be enabled?", _, true, 0.0, true, 1.0);
    g_cvCrashfix    = CreateConVar("sm_overlord_crashfix", "1", "Should we enable the experimental crash fix?", _, true, 0.0, true, 1.0);
    g_cvArmorT      = CreateConVar("sm_overlord_armor_t", "2", "Should we give Ts armor when they spawn?", _, true, 0.0, true, 2.0);
    g_cvArmorCT     = CreateConVar("sm_overlord_armor_ct", "2", "Should we give CTs armor when they spawn?", _, true, 0.0, true, 2.0);
    // END ConVars

    // Generate and load our plugin convar config.
    AutoExecConfig(true, "overlord");

    // Get the "m_CollisionGroup" offset.
    g_iCollisionGroup = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
    if (g_iCollisionGroup == -1) {
        LogMessage("%s Failed to get offset for CBaseEntity::m_CollisionGroup, cannot disable collisions.", CONSOLE_PREFIX);
    }

    // Commands
    // overlord/commands/admins.sp
    RegConsoleCmd("sm_admins", Command_Admins, "sm_admins - Prints a list of admins.");
    // overlord/commands/disconnected.sp
    RegAdminCmd("sm_disconnected", Command_Disconnected, ADMFLAG_KICK, "sm_disconnected - Opens a menu with a list of recently disconnected players.");
    // overlord/commands/follow.sp
    RegAdminCmd("sm_follow", Command_Follow, ADMFLAG_SLAY, "sm_follow <#userid;target> - Follows a player while in spectate.");
    // overlord/commands/groups.sp
    RegConsoleCmd("sm_groups", Command_Groups, "sm_groups - Prints a list of groups.");
    // overlord/commands/heal.sp
    RegAdminCmd("sm_heal", Command_Heal, ADMFLAG_SLAY, "sm_heal <#userid;target> - Heals a player.");
    // overlord/commands/health.sp
    RegAdminCmd("sm_health", Command_Health, ADMFLAG_SLAY, "sm_health <#userid;target> <health> - Sets the specified target's health.");
    // overlord/commands/hide.sp
    RegAdminCmd("sm_hide", Command_Hide, ADMFLAG_KICK, "sm_hide - Toggles an admin's hidden state.");
    // overlord/commands/hog.sp
    RegAdminCmd("sm_hog", Command_Hog, ADMFLAG_BAN, "sm_hog <#userid;target> - Slays a client and strikes lightning on them.");
    // overlord/commands/overlord.sp
    RegAdminCmd("sm_overlord", Command_Overlord, ADMFLAG_ROOT, "sm_overlord - Opens a menu to manage the overlord plugin.");
    // overlord/commands/respawn.sp
    RegAdminCmd("sm_respawn", Command_Respawn, ADMFLAG_SLAY, "sm_respawn <#userid;target> - Respawns a dead player.");
    // overlord/commands/respawn_aim.sp
    RegAdminCmd("respawn_aim", Command_RespawnAim, ADMFLAG_SLAY, "sm_respawn_aim <#userid;target> - Respawns a client to where you are looking.");
    // overlord/commands/respawn_here.sp
    RegAdminCmd("respawn_here", Command_RespawnHere, ADMFLAG_SLAY, "sm_respawn_here <#userid;target> - Respawns a client to your position.");
    // overlord/commands/team.sp
    RegAdminCmd("sm_team_t", Command_Team_T, ADMFLAG_SLAY, "sm_team_t <#userid;target> [round end] - Swap a client to the terrorist team.");
    RegAdminCmd("sm_team_ct", Command_Team_CT, ADMFLAG_SLAY, "sm_team_ct <#userid;target> [round end] - Swap a client to the counter-terrorist team.");
    RegAdminCmd("sm_team_spec", Command_Team_Spec, ADMFLAG_SLAY, "sm_team_spec <#userid;target> [round end] - Swap a client to the spectator team.");
    // overlord/commands/teleport.sp
    RegAdminCmd("sm_tp", Command_Teleport, ADMFLAG_BAN, "sm_tp <#userid;target> - Teleport to a client.");
    // overlord/commands/teleport_aim.sp
    RegAdminCmd("sm_tpaim", Command_TeleportAim, ADMFLAG_BAN, "sm_tpaim <#userid;target> - Teleport a client to where you are looking.");
    // overlord/commands/teleport_here.sp
    RegAdminCmd("sm_tphere", Command_TeleportHere, ADMFLAG_BAN, "sm_tphere <#userid;target> - Teleport a client to yourself.");
    // overlord/commands/vips.sp
    RegConsoleCmd("sm_vips", Command_VIPs, "sm_vips - Prints a list of vips.");
    // END Commands

    // Events
    if (g_cvCrashfix.BoolValue) {
        // overlord/events/map_change.sp
        AddCommandListener(Event_MapChange, "map");
        AddCommandListener(Event_MapChange, "changelevel");
    }
    // overlord/events/player_death.sp
    if (!HookEventEx("player_death", Event_PlayerDeath)) {
        SetFailState("%s Failed to hook \"player_death\" event, disabling plugin..", CONSOLE_PREFIX);
        return;
    }
    // overlord/events/player_spawn.sp
    if (!HookEventEx("player_spawn", Event_PlayerSpawn)) {
        SetFailState("%s Failed to hook \"player_spawn\" event, disabling plugin..", CONSOLE_PREFIX);
        return;
    }
    // overlord/events/round_end.sp
    if (!HookEventEx("round_end", Event_RoundEnd)) {
        SetFailState("%s Failed to hook \"round_end\" event, disabling plugin..", CONSOLE_PREFIX);
        return;
    }
    // END Events

    // Forwards
    g_hOnAdminJoin = CreateGlobalForward("Overlord_OnAdminJoin", ET_Event, Param_Cell);
    g_hOnAdminQuit = CreateGlobalForward("Overlord_OnAdminQuit", ET_Event, Param_Cell);
    g_hOnAdminAdded = CreateGlobalForward("Overlord_OnAdminAdded", ET_Event, Param_Cell);
    g_hOnAdminRemoved = CreateGlobalForward("Overlord_OnAdminRemoved", ET_Event, Param_Cell);
    g_hOnAdminFollow = CreateGlobalForward("Overlord_OnAdminFollow", ET_Event, Param_Cell, Param_Cell);
    g_hOnAdminVisible = CreateGlobalForward("Overlord_OnAdminVisible", ET_Event, Param_Cell);
    g_hOnAdminHide = CreateGlobalForward("Overlord_OnAdminHide", ET_Event, Param_Cell);
    g_hOnPlayerHeal = CreateGlobalForward("Overlord_OnPlayerHeal", ET_Event, Param_Cell);
    g_hOnPlayerHealth = CreateGlobalForward("Overlord_OnPlayerHealth", ET_Event, Param_Cell);
    g_hOnPlayerHog = CreateGlobalForward("Overlord_OnPlayerHog", ET_Event, Param_Cell);
    g_hOnPlayerRespawn = CreateGlobalForward("Overlord_OnPlayerRespawn", ET_Event, Param_Cell);
    g_hOnPlayerTeam = CreateGlobalForward("Overlord_OnPlayerTeam", ET_Event, Param_Cell, Param_Cell);
    g_hOnPlayerTeleport = CreateGlobalForward("Overlord_OnPlayerTeleport", ET_Event, Param_Cell, Param_Cell);
    g_hOnPlayerTeleportPos = CreateGlobalForward("Overlord_OnPlayerTeleportPos", ET_Event, Param_Cell, Param_Array);
    // END Forwards

    // Other
    g_alDisconnected = CreateArray();
    // overlord/sourcemod.sp
    HookUserMessage(GetUserMessageId("TextMsg"), Sourcemod_TextMessage, true);
    // overlord/chat.sp
    Chat_Register();
    // overlord/admin.sp
    Admin_TagTimer();
    // END Other
}

/**
 * OnConfigsExecuted
 * Connects to the database using the configured convar.
 */
public void OnConfigsExecuted() {
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
}

/**
 * OnMapStart
 * Adds files that need to be downloaded; precaches materials, sprites, and sounds.
 */
public void OnMapStart() {
    AddAssetsToDownloadTable();
    PrecacheAssets();
}

/**
 * OnClientPutInServer
 * Registers SDK Hooks, sets default array values.
 */
public void OnClientPutInServer(int client) {
    // Set default array values.
    g_iSwapOnRoundEnd[client] = -1;
    g_iFollowing[client] = -1;
    g_iOverlordMenu[client] = -1;
    g_iOverlordAction[client] = OVERLORD_ACTION_NONE;

    for (int i = 0; i < 3; i++) {
        g_fDeathPosition[client][i] = 0.0;
    }
}

/**
 * OnClientAuthorized
 * Prints a connect chat message, loads client's admin data.
 */
public void OnClientAuthorized(int client, const char[] auth) {
    g_hAdmins[client] = null;

    // Ignore bot users.
    if (StrEqual(auth, "BOT", true)) {
        return;
    }

    // Check if the join message is enabled.
    if (g_cvMessageJoin.BoolValue) {
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

    if (g_hAdmins[client] != null) {
        LogMessage("%s %N is an admin. :)", CONSOLE_PREFIX, client);

        // Call the "g_hOnAdminJoin" forward.
        Call_StartForward(g_hOnAdminJoin);
        Call_PushCell(client);
        Call_Finish();
    }
}

/**
 * OnClientDisconnect
 * Prints a disconnect chat message.
 */
public void OnClientDisconnect(int client) {
    // Set default array values.
    g_iSwapOnRoundEnd[client] = -1;
    g_iFollowing[client] = -1;
    g_iOverlordMenu[client] = -1;
    g_iOverlordAction[client] = -1;

    for (int i = 0; i < 3; i++) {
        g_fDeathPosition[client][i] = 0.0;
    }

    // Get the client's steam id.
    char auth[64];
    GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth));

    // Ignore bot users.
    if (StrEqual(auth, "BOT", true)) {
        return;
    }

    // Check if the quit message is enabled.
    if (g_cvMessageQuit.BoolValue) {
        // Print the disconnect message to everyone.
        PrintToChatAll("%s \x05%N \x01has disconnected. (\x10%s\x01)", PREFIX, client, auth);

        // Print the disconnect message to the server.
        LogMessage("%s %N has disconnected. (%s)", CONSOLE_PREFIX, client, auth);
    }

    char buffer[64];
    for (int i = 0; i < g_alDisconnected.Length-1; i++) {
        Player player = g_alDisconnected.Get(i);
        if (player == null) {
            continue;
        }

        player.GetSteamID(buffer, sizeof(buffer));

        if (StrEqual(buffer, auth, true)) {
            g_alDisconnected.Erase(i);
            break;
        }
    }

    Player player = new Player();
    player.SetSteamID(auth);

    char name[128];
    GetClientName(client, name, sizeof(name));
    player.SetName(name);

    char ipAddress[32];
    GetClientIP(client, ipAddress, sizeof(ipAddress));
    player.SetIpAddress(ipAddress);

    g_alDisconnected.Push(player);

    // Check if user is an admin.
    if (g_hAdmins[client] == null) {
        return;
    }

    // Call the "g_hOnAdminQuit" forward.
    Call_StartForward(g_hOnAdminQuit);
    Call_PushCell(client);
    Call_Finish();

    // Save the admin's information.
    Backend_UpdateAdmin(client);

    // Unallocate memory for user admin storage.
    delete g_hAdmins[client];
}

/**
 * OnGameFrame
 * ?
 */
public void OnGameFrame() {
    Chat_ProcessQueue();
}
