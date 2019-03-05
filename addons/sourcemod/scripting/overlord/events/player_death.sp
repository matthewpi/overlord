/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Event_PlayerDeath (player_death)
 * This event is called whenever a player dies.
 */
public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
    int client = GetClientOfUserId(event.GetInt("userid"));

    // Check if the client is invalid.
    if(!IsClientValid(client)) {
        return Plugin_Continue;
    }

    // Check if the player is dead.
    if(!IsPlayerAlive(client)) {
        return Plugin_Continue;
    }

    // Get the client's position.
    float position[3];
    GetClientAbsOrigin(client, position);

    // Update the "g_fDeathPosition" array with the client's death position.
    g_fDeathPosition[client] = position;

    return Plugin_Continue;
}
