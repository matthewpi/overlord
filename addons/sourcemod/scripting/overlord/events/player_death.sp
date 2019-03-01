/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Event_PlayerDeath (player_death)
 * ?
 */
public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
    int client = GetClientOfUserId(event.GetInt("userid"));
    if(!IsClientConnected(client) || !IsClientInGame(client)) {
        return Plugin_Continue;
    }

    float position[3];
    GetClientAbsOrigin(client, position);

    if(!IsPlayerAlive(client)) {
        return Plugin_Continue;
    }

    g_alDeathPosition.SetArray(client, position);

    return Plugin_Continue;
}
