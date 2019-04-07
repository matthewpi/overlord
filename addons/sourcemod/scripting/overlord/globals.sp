/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/* -------------------------------- */
/*              ConVars             */
/* -------------------------------- */
// sm_overlord_database - "Sets what database the plugin should use." (Default: "overlord")
ConVar g_cvDatabase;

// sm_overlord_message_join - "Should we print a join message?" (Default: "1")
ConVar g_cvMessageJoin;

// sm_overlord_message_quit - "Should we print a quit message?" (Default: "1")
ConVar g_cvMessageQuit;

// sm_overlord_collisions - "Should collisions be enabled?" (Default: "0")
ConVar g_cvCollisions;

// sm_overlord_crashfix - "Should we enable the experimental crash fix?" (Default: "1")
ConVar g_cvCrashfix;

// sm_overlord_armor_t - "Should we give Ts armor when they spawn?" (Default: "1")
ConVar g_cvArmorT;

// sm_overlord_armor_ct - "Should we give CTs armor when they spawn?" (Default: "1")
ConVar g_cvArmorCT;

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
/* -------------------------------- */



/* -------------------------------- */
/*              Backend             */
/* -------------------------------- */
// g_dbOverlord stores the active database connection.
Database g_dbOverlord;

// g_hGroups stores an array of loaded Groups.
Group g_hGroups[GROUP_MAX];

// g_hAdmins stores an array of loaded Admins.
Admin g_hAdmins[MAXPLAYERS + 1];

// g_iServerId stores the server's database id.
int g_iServerId = 0;
/* -------------------------------- */



/* -------------------------------- */
/*             Forwards             */
/* -------------------------------- */
// g_hOnAdminJoin
Handle g_hOnAdminJoin;

// g_hOnAdminQuit
Handle g_hOnAdminQuit;

// g_hOnAdminAdded
Handle g_hOnAdminAdded;

// g_hOnAdminRemoved
Handle g_hOnAdminRemoved;

// g_hOnAdminFollow
Handle g_hOnAdminFollow;

// g_hOnAdminHide
Handle g_hOnAdminVisible;

// g_hOnAdminHide
Handle g_hOnAdminHide;

// g_hOnPlayerHeal
Handle g_hOnPlayerHeal;

// g_hOnPlayerHealth
Handle g_hOnPlayerHealth;

// g_hOnPlayerHog
Handle g_hOnPlayerHog;

// g_hOnPlayerRespawn
Handle g_hOnPlayerRespawn;

// g_hOnPlayerTeam
Handle g_hOnPlayerTeam;

// g_hOnPlayerTeleport
Handle g_hOnPlayerTeleport;

// g_hOnPlayerTeleportPos
Handle g_hOnPlayerTeleportPos;
/* -------------------------------- */



/* -------------------------------- */
/*              Timers              */
/* -------------------------------- */
// g_hAdminTagTimer stores the handle for the active admin tag timer.
Handle g_hAdminTagTimer = INVALID_HANDLE;
/* -------------------------------- */



/* -------------------------------- */
/*              Assets              */
/* -------------------------------- */
// g_iLightningSprite
int g_iLightningSprite;

// g_iSmokeSprite
int g_iSmokeSprite;
/* -------------------------------- */



/* -------------------------------- */
/*              Other               */
/* -------------------------------- */
// g_alDisconnected stores a list of recently disconnected clients.
ArrayList g_alDisconnected;

// g_iSwapOnRoundEnd stores an array of client to swap to another team.
int g_iSwapOnRoundEnd[MAXPLAYERS + 1];

// g_fDeathPosition stores a list of client death positions.
float g_fDeathPosition[MAXPLAYERS + 1][3];

// g_iFollowing
int g_iFollowing[MAXPLAYERS + 1];

// g_iOverlordMenu
int g_iOverlordMenu[MAXPLAYERS + 1];

// g_iOverlordAction
int g_iOverlordAction[MAXPLAYERS + 1];

// g_iCollisionGroup
int g_iCollisionGroup = -1;
/* -------------------------------- */
