/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

 /**
  * GetPlayerCount
  * ?
  */
stock int GetPlayerCount() {
    int players = 0;
    for(int client = 1; client <= MaxClients; client++) {
        if(g_bStealthed[client]) {
            continue;
        }

        players++;
    }

    return players;
}

/**
 * GetBotCount
 * ?
 */
stock int GetBotCount() {
    int bots = 0;
    for(int client = 1; client <= MaxClients; client++) {
        if(!IsFakeClient(client)) {
            continue;
        }

        bots++;
    }

    return bots;
}

/**
 * GetStealthCount
 * ?
 */
public int GetStealthCount() {
    int stealthed = 0;
    for(int client = 1; client <= MaxClients; client++) {
        if(!g_bStealthed[client]) {
            continue;
        }

        stealthed++;
    }

    return stealthed;
}
