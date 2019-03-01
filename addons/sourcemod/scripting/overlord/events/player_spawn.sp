/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Event_PlayerSpawn (player_spawn)
 * ?
 */
public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
    int client = GetClientOfUserId(event.GetInt("userid"));
    if(!IsClientConnected(client) || !IsClientInGame(client)) {
        return Plugin_Continue;
    }

    // Check if the admin is following someone.
    if(g_iFollowing[client] == -1) {
        return Plugin_Continue;
    }

    // Set who the client is spectating.
    FakeClientCommand(client, "spec_player \"%N\"", g_iFollowing[client]);

    return Plugin_Continue;
}
