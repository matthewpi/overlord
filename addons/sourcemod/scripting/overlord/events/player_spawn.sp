/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Event_PlayerSpawn (player_spawn)
 * This event is called whenever a player is spawned.
 */
public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
    int client = GetClientOfUserId(event.GetInt("userid"));

    // Check is the client is invalid.
    if(!IsClientValid(client)) {
        return Plugin_Continue;
    }

    // Loop through all of the admin's following entires.
    for(int i = 1; i < sizeof(g_iFollowing); i++) {
        // Check if the follow entry does not equal the spawned client.
        if(g_iFollowing[i] != client) {
            continue;
        }

        // Check if the admin is invalid.
        if(!IsClientValid(i)) {
            continue;
        }

        // Set who the admin is spectating.
        FakeClientCommand(i, "spec_player \"%N\"", g_iFollowing[i]);
    }

    return Plugin_Continue;
}
